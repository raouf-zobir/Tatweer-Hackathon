import asyncio
from src.agents.agent import Agent
from src.tools.calendar.calendar_tool import CalendarTool
from src.tools.contacts import AddContactTool, FetchContactTool
from src.tools.emails.emailing_tool import EmailingTool
from src.tools.search import SearchWebTool
from src.prompts.prompts import assistant_prompt
from dotenv import load_dotenv
from src.tools.monitor.event_monitor import EventMonitor
import time
from colorama import Fore
import json

load_dotenv()

model = "groq/llama3-70b-8192"

tools_list = [
    CalendarTool,
    EventMonitor,
    AddContactTool,
    FetchContactTool,
    EmailingTool,
    SearchWebTool,
]

agent = Agent("Assistant Agent", model, tools_list, system_prompt=assistant_prompt)

class ResponseAccumulator:
    def __init__(self):
        self.response = ""
    
    def add(self, text):
        if text:
            self.response += f"{text}\n"
    
    def get_response(self):
        return self.response.strip()
    
    def clear(self):
        self.response = ""

async def handle_command(agent, command):
    """Handle natural language input from user"""
    max_retries = 3
    retry_delay = 20
    
    for attempt in range(max_retries):
        try:
            # Enhance command with context for better understanding
            enhanced_command = (
                f"User input: '{command}'\n"
                f"Based on this input, understand the user's intent and:\n"
                f"1. Determine if this requires any operational actions\n"
                f"2. If yes, execute appropriate tools and provide results\n"
                f"3. If no, provide a natural conversational response\n"
                f"4. Always maintain context and provide helpful information"
            )
            
            response = agent.invoke(enhanced_command)
            if response and response != "None":
                return response
            
            if attempt < max_retries - 1:
                print(f"\nRetrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                return "I need more clarity about what you'd like me to do. Could you explain further?"
                
        except Exception as e:
            print(f"\nError (attempt {attempt + 1}/{max_retries}): {str(e)}")
            if attempt < max_retries - 1:
                print(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                return "I encountered an error. Could you try expressing that differently?"

async def direct_tool_call(tool_class, **kwargs):
    """Call tools directly without going through the LLM"""
    try:
        tool = tool_class(**kwargs)
        return tool.run()
    except Exception as e:
        print(Fore.RED + f"Error calling {tool_class.__name__}: {str(e)}")
        return None

async def format_change_description(changes, issues):
    """Format changes into human-readable form with impact analysis"""
    descriptions = []
    for change in changes:
        if change['action'] == 'edit' and 'delay_hours' in change:
            # Find the related issue
            issue = next((i for i in issues if i['id'] == change['event_id']), None)
            if issue:
                desc = (
                    f"• Event '{issue['type']}' at {issue['details'].split(' at ')[1]}:\n"
                    f"  - Will be delayed by {change['delay_hours']} hours\n"
                    f"  - This affects:\n"
                )
                # Get impact analysis
                impact = await direct_tool_call(EventMonitor, 
                                              action="analyze_impact",
                                              event_id=change['event_id'])
                if impact:
                    for line in impact.split('\n'):
                        if '*' in line:  # Add affected operations
                            desc += f"    {line.strip()}\n"
                descriptions.append(desc)
    return descriptions

async def generate_comprehensive_summary(calendar_status, issues, proposed_changes):
    """Generate a detailed summary of current schedule and proposed changes"""
    summary = "\n=== CURRENT SITUATION ===\n"
    
    # Show relevant current schedule
    affected_times = set()
    for issue in issues:
        for impact in issue.get('impact', []):
            for event in calendar_status.split('\n'):
                if impact in event:
                    affected_times.add(event)
    
    if affected_times:
        summary += "\nRelevant current schedule:\n"
        for event in sorted(affected_times):
            summary += f"{event}\n"

    # Summarize issues and their impacts
    summary += "\n=== DETECTED ISSUES ===\n"
    for issue in issues:
        summary += f"\nIssue: {issue['type'].title()} at {issue['details'].split(' at ')[1]}"
        impact = await direct_tool_call(EventMonitor, action="analyze_impact", event_id=issue['id'])
        if impact:
            summary += f"\n{impact}"

    # Show proposed changes and cascading effects
    summary += "\n=== PROPOSED CHANGES ===\n"
    for change in proposed_changes:
        if change['action'] == 'edit' and 'delay_hours' in change:
            issue = next((i for i in issues if i['id'] == change['event_id']), None)
            if issue:
                summary += f"\n1. {issue['type'].title()} changes:"
                summary += f"\n   - Original schedule: Find in current schedule above"
                summary += f"\n   - New timing: Delayed by {change['delay_hours']} hours"
                summary += "\n   - Cascading effects:"
                
                # Show downstream impacts
                impact = await direct_tool_call(EventMonitor, action="analyze_impact", event_id=issue['id'])
                if impact:
                    for line in impact.split('\n'):
                        if '*' in line:
                            summary += f"\n     {line.strip()}"

    summary += "\n\n=== NOTIFICATION PLAN ===\n"
    affected_teams = set()
    for issue in issues:
        for impact in issue.get('impact', []):
            affected_teams.add(impact)
    
    summary += "\nWill notify:"
    for team in affected_teams:
        summary += f"\n- {team} team"

    return summary

async def handle_change_confirmation(agent, changes, issues):
    """Handle change proposals through websocket communication"""
    try:
        # Get current calendar status
        calendar_status = await direct_tool_call(CalendarTool, action="view")
        
        # Generate comprehensive summary
        summary = await generate_comprehensive_summary(calendar_status, issues, changes)
        
        # Return the summary as a response to be sent via websocket
        return {
            "type": "change_proposal",
            "message": summary,
            "changes": changes,
            "issues": issues
        }

    except Exception as e:
        return {
            "type": "error",
            "message": f"Error during confirmation: {str(e)}"
        }

async def get_team_contacts(team_name):
    """Fetch contacts for a specific team"""
    try:
        contacts_tool = FetchContactTool(contact_name=team_name)
        result = contacts_tool.run()
        if result:
            # Parse JSON response
            contacts_data = json.loads(result)
            if isinstance(contacts_data, list):
                return contacts_data
            elif isinstance(contacts_data, dict) and "error" in contacts_data:
                print(f"Contact fetch message: {contacts_data['error']}")
    except Exception as e:
        print(f"Error fetching contacts: {e}")
    return []

async def generate_personalized_email(recipient_name, team, role, changes, impact):
    """Generate professional, detailed email content for each recipient"""
    
    # Get the current time for the timestamp
    timestamp = time.strftime("%Y-%m-%d %H:%M")
    
    # Start with a professional greeting
    email_content = (
        f"Dear {recipient_name},\n\n"
        f"This is an urgent operational update regarding schedule changes that "
        f"affect {team} operations. Please review the following information carefully.\n\n"
    )

    # Add a clear overview section
    email_content += "SITUATION OVERVIEW:\n"
    email_content += "-----------------\n"
    if team == "Factory_X_Production":
        email_content += "Due to a logistics delay at checkpoint B, we need to implement immediate schedule adjustments.\n\n"
    elif team == "Customer_Delivery_A":
        email_content += "Due to upstream logistics delays, delivery schedules require immediate adjustment.\n\n"
    elif team == "Inventory_Level_C":
        email_content += "Due to production constraints, inventory allocation requires immediate attention.\n\n"

    # Add specific changes section
    email_content += "REQUIRED CHANGES:\n"
    email_content += "----------------\n"
    for change in changes:
        if 'delay_hours' in change:
            if team == "Factory_X_Production":
                email_content += f"• Production Schedule Adjustment:\n"
                email_content += f"  - Implementation of {change['delay_hours']}-hour schedule delay\n"
                email_content += f"  - New production start time will be adjusted accordingly\n"
            elif team == "Customer_Delivery_A":
                email_content += f"• Delivery Schedule Update:\n"
                email_content += f"  - Delivery times shifted by {change['delay_hours']} hours\n"
                email_content += f"  - Please coordinate with logistics for revised pickup times\n"

    # Add team-specific impact
    email_content += "\nIMPACT ASSESSMENT:\n"
    email_content += "----------------\n"
    if impact:
        for line in impact.split('\n'):
            if '*' in line and team in line:
                impact_details = line.strip()[2:]
                if team == "Factory_X_Production":
                    email_content += "• Production Impact:\n"
                    email_content += f"  - {impact_details}\n"
                    email_content += "  - May affect downstream operations\n"
                elif team == "Customer_Delivery_A":
                    email_content += "• Delivery Impact:\n"
                    email_content += f"  - {impact_details}\n"
                    email_content += "  - Customer communications may be required\n"

    # Add clear action items
    email_content += "\nACTION REQUIRED:\n"
    email_content += "--------------\n"
    if team == "Factory_X_Production":
        email_content += "1. Review and adjust production schedule immediately\n"
        email_content += "2. Update shift supervisors about the new timeline\n"
        email_content += "3. Ensure resource availability for adjusted schedule\n"
    elif team == "Customer_Delivery_A":
        email_content += "1. Update delivery schedule in the system\n"
        email_content += "2. Notify affected customers about delivery changes\n"
        email_content += "3. Coordinate with logistics team for new pickup times\n"
    elif team == "Inventory_Level_C":
        email_content += "1. Review current inventory levels\n"
        email_content += "2. Implement suggested allocation adjustments\n"
        email_content += "3. Update procurement team on any shortages\n"

    # Add next steps and contact information
    email_content += "\nNEXT STEPS:\n"
    email_content += "-----------\n"
    email_content += "• Please acknowledge receipt of this notification\n"
    email_content += "• Implement required changes immediately\n"
    email_content += "• Report any concerns or constraints to your supervisor\n"

    # Add footer with contact information
    email_content += "\nFor urgent matters or clarifications, please contact:\n"
    email_content += "Operations Control Center: +1-XXX-XXX-XXXX\n"
    email_content += f"Reference ID: OPS-{time.strftime('%Y%m%d')}-{team}\n\n"
    
    email_content += "Best regards,\nOperations Management Team\n"
    email_content += f"Timestamp: {timestamp}"
    
    return email_content

async def edit_email_content(email_data):
    """Allow editing of email content sections"""
    sections = {
        '1': 'Overview',
        '2': 'Required Changes',
        '3': 'Impact Assessment',
        '4': 'Action Items',
        '5': 'Next Steps',
        '6': 'Contact Information',
        '7': 'All' 
    }
    
    while True:
        print("\nCurrent Email Content:")
        print("-" * 50)
        print(email_data['content'])
        print("-" * 50)
        
        print("\nWhich section would you like to edit?")
        for key, value in sections.items():
            print(f"{key}. {value}")
        print("8. Send as is")
        print("9. Cancel")
        
        choice = input("\nYour choice (1-9): ").strip()
        
        if choice == '9':
            return None
        elif choice == '8':
            return email_data
        elif choice in sections:
            if choice == '7':
                print("\nEnter the complete new email content (press Ctrl+D or Ctrl+Z when done):")
                new_content = []
                while True:
                    try:
                        line = input()
                        new_content.append(line)
                    except EOFError:
                        break
                email_data['content'] = '\n'.join(new_content)
            else:
                print(f"\nEnter new content for {sections[choice]} section:")
                new_content = input().strip()
                
                # Update specific section in the email content
                content_parts = email_data['content'].split('\n\n')
                section_starts = {
                    '1': 'SITUATION OVERVIEW:',
                    '2': 'REQUIRED CHANGES:',
                    '3': 'IMPACT ASSESSMENT:',
                    '4': 'ACTION REQUIRED:',
                    '5': 'NEXT STEPS:',
                    '6': 'For urgent matters'
                }
                
                if choice in section_starts:
                    for i, part in enumerate(content_parts):
                        if part.startswith(section_starts[choice]):
                            next_section_idx = i + 1
                            while next_section_idx < len(content_parts):
                                if any(part.startswith(start) for start in section_starts.values()):
                                    break
                                next_section_idx += 1
                            
                            # Replace section content
                            content_parts[i] = f"{section_starts[choice]}\n{'-' * len(section_starts[choice])}\n{new_content}"
                            email_data['content'] = '\n\n'.join(content_parts)
                            break
        
        print("\nEmail updated. Review the changes?")

async def apply_approved_changes(changes, summary):
    try:
        # Deduplicate and batch calendar updates
        calendar_updates = {}  
        affected_teams = set()
        team_impacts = {}
        
        for change in changes:
            if change.get('action') == 'edit':
                event_id = change.get('event_id')
                if event_id not in calendar_updates:
                    calendar_updates[event_id] = {
                        'event_id': event_id,
                        'delay_hours': change.get('delay_hours')
                    }
                
                if event_id not in team_impacts:
                    impact = await direct_tool_call(EventMonitor, 
                                                  action="analyze_impact",
                                                  event_id=event_id)
                    if impact:
                        for line in impact.split('\n'):
                            if '*' in line:
                                team = line.strip()[2:].split()[0]
                                affected_teams.add(team)
                                team_impacts[team] = impact

        # Execute all calendar updates in one batch
        if calendar_updates:
            result = await direct_tool_call(CalendarTool, 
                                          action="batch_edit",
                                          edits=list(calendar_updates.values()))
            
            return {
                "type": "changes_applied",
                "message": f"Successfully applied {len(calendar_updates)} updates.",
                "details": result
            }

    except Exception as e:
        return {
            "type": "error",
            "message": f"Error applying changes: {str(e)}"
        }

async def handle_modification_request(agent, user_input, changes, issues):
    """Handle requests to modify the proposed changes"""
    try:
        # Parse modification intent
        if "early" in user_input.lower() or "advance" in user_input.lower():
            # Make delay hours negative for advancement
            hours = int(''.join(filter(str.isdigit, user_input))) * -1
            
            # Modify all changes at once
            modified_changes = [{
                'action': 'edit',
                'event_id': change['event_id'],
                'delay_hours': hours
            } for change in changes if change.get('action') == 'edit']
            
            # Apply changes in a single batch
            return await handle_change_confirmation(agent, modified_changes, issues)
            
        # Handle other modification types
        # ...existing code...
        
    except Exception as e:
        return f"Error handling modification: {str(e)}"

async def startup_sequence(agent):
    """Initial startup sequence to check for problems and show solutions"""
    response_accumulator = ResponseAccumulator()
    response_accumulator.add("Initializing system and checking for operational issues...")
    
    try:
        response_accumulator.add("\nChecking calendar...")
        calendar_status = await direct_tool_call(CalendarTool, action="view")
        response_accumulator.add("\nCurrent Schedule:")
        response_accumulator.add(calendar_status)

        response_accumulator.add("\nChecking for operational issues...")
        issues = await direct_tool_call(EventMonitor, action="check_all")
        
        if issues and len(issues) > 0:
            all_changes = []
            response_accumulator.add("\nFound operational issues:")
            
            for issue in issues:
                response_accumulator.add(f"\n- {issue['type'].title()} issue: {issue['details']}")
                
                impact = await direct_tool_call(EventMonitor, 
                                              action="analyze_impact",
                                              event_id=issue['id'])
                response_accumulator.add(impact)
                
                solutions = await direct_tool_call(EventMonitor,
                                                 action="propose_solution",
                                                 event_id=issue['id'])
                
                if isinstance(solutions, dict) and 'proposed_actions' in solutions:
                    changes = []
                    response_accumulator.add("\nProposed actions:")
                    for action in solutions['proposed_actions']:
                        response_accumulator.add(f"  - {action}")
                        if "Reschedule" in action:
                            changes.append({
                                'action': 'edit',
                                'event_id': issue['id'],
                                'delay_hours': 3
                            })
                    all_changes.extend(changes)
                
                time.sleep(1)
            
            if all_changes:
                result = await handle_change_confirmation(agent, all_changes, issues)
                response_accumulator.add(f"\n{result}")
        else:
            response_accumulator.add("\nNo operational issues detected.")

    except Exception as e:
        response_accumulator.add(f"\nError during startup: {str(e)}")
        response_accumulator.add("Continuing with basic operation mode...")
    
    response_accumulator.add("\nI'm ready to help you manage operations. What would you like to do?")
    return response_accumulator.get_response()

if __name__ == "__main__":
    print("This module should be imported by server.py")
