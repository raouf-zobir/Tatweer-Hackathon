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
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
from fastapi.middleware.cors import CORSMiddleware

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

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

class CommandRequest(BaseModel):
    command: str

class CommandResponse(BaseModel):
    response: str

class StartupMessageResponse(BaseModel):
    message: str

class UserDecisionRequest(BaseModel):
    decision: str

@app.post("/handle_command", response_model=CommandResponse)
async def handle_command_endpoint(request: CommandRequest):
    raise HTTPException(status_code=500, detail="Error processing command")

@app.get("/startup_message", response_model=StartupMessageResponse)
async def get_startup_message():
    message = await startup_sequence(agent)
    return StartupMessageResponse(message=message)

@app.post("/user_decision", response_model=CommandResponse)
async def handle_user_decision(request: UserDecisionRequest):
    decision = request.decision.lower()
    if any(word in decision for word in ['yes', 'approve', 'accept', 'proceed', 'do this']):
        response = await apply_approved_changes(changes, summary)
    elif any(word in decision for word in ['no', 'cancel', 'reject', 'stop']):
        response = "Changes cancelled. Let me know if you'd like to explore other options."
    elif any(word in decision for word in ['modify', 'change', 'adjust', 'different']):
        response = await handle_modification_request(agent, decision, changes, issues)
    elif 'explain' in decision:
        response = agent.invoke(f"Explain this aspect of the changes: {decision}")
    else:
        response = "I didn't understand. Please use 'approve', 'modify', 'explain', or 'cancel'."
    return CommandResponse(response=response)

@app.on_event("startup")
async def startup_event():
    await startup_sequence(agent)

async def handle_command(agent, command):
    """Handle a single command with retries and exponential backoff"""
    max_retries = 5
    base_delay = 10  # seconds
    
    for attempt in range(max_retries):
        try:
            response = agent.invoke(command)
            if response and response != "None":
                return response
            if attempt < max_retries - 1:
                delay = base_delay * (2 ** attempt)  # Exponential backoff
                print(f"\nRetrying in {delay} seconds...")
                await asyncio.sleep(delay)
            else:
                return "I'm having trouble processing that request. Please try again later."
        except Exception as e:
            print(f"\nError (attempt {attempt + 1}/{max_retries}): {str(e)}")
            if attempt < max_retries - 1:
                delay = base_delay * (2 ** attempt)  # Exponential backoff
                print(f"Retrying in {delay} seconds...")
                await asyncio.sleep(delay)
            else:
                return "I encountered an error. Please try again later."

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
    """Handle change proposals with natural language interaction"""
    try:
        # Get current calendar status
        calendar_status = await direct_tool_call(CalendarTool, action="view")
        
        # Generate comprehensive summary
        summary = await generate_comprehensive_summary(calendar_status, issues, changes)
        print(summary)
        
        # Simulate user input for testing purposes
        user_input = "approve"  # Replace this with actual user input from the frontend
        
        if any(word in user_input for word in ['yes', 'approve', 'accept', 'proceed', 'do this']):
            return await apply_approved_changes(changes, summary)
        
        elif any(word in user_input for word in ['no', 'cancel', 'reject', 'stop']):
            return "Changes cancelled. Let me know if you'd like to explore other options."
        
        elif any(word in user_input for word in ['modify', 'change', 'adjust', 'different']):
            return await handle_modification_request(agent, user_input, changes, issues)
        
        elif 'explain' in user_input:
            print("\nWhat specific aspect would you like me to explain?")
            aspect = "impact"  # Replace this with actual user input from the frontend
            response = agent.invoke(f"Explain this aspect of the changes: {aspect}")
            print(f"\nAssistant: {response}")
            print("\nWould you like to proceed with the changes?")
        
        else:
            print("\nI didn't understand. Please use 'approve', 'modify', 'explain', or 'cancel'.")
    except Exception as e:
        return f"Error during confirmation: {str(e)}"

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
    """Apply approved changes with comprehensive updates"""
    try:
        print("\nApplying changes...")
        
        all_updates = []
        affected_teams = set()
        
        # Collect affected teams and their impacts
        team_impacts = {}
        for change in changes:
            if change.get('event_id'):
                impact = await direct_tool_call(EventMonitor, 
                                              action="analyze_impact",
                                              event_id=change['event_id'])
                if impact:
                    for line in impact.split('\n'):
                        if '*' in line:
                            team = line.strip()[2:].split()[0]
                            affected_teams.add(team)
                            team_impacts[team] = impact
        
        # Process calendar updates
        for change in changes:
            result = await direct_tool_call(CalendarTool, **change)
            if result:
                all_updates.append(result)
        
        # Prepare and confirm notifications
        print("\nPreparing notifications for affected teams...")
        notifications = []
        
        for team in affected_teams:
            contacts = await get_team_contacts(team)
            if contacts:
                for contact in contacts:
                    if 'emails' in contact and contact['emails']:
                        for email in contact['emails']:
                            if email and email != 'N/A':
                                # Generate personalized content
                                email_content = await generate_personalized_email(
                                    contact.get('name', 'Team Member'),
                                    team,
                                    "Team Member",  # You could add role detection here
                                    changes,
                                    team_impacts.get(team, "")
                                )
                                
                                notifications.append({
                                    'recipient_name': contact.get('name', 'Team Member'),
                                    'recipient': email,
                                    'team': team,
                                    'content': email_content
                                })
        
        # Show preview and confirm
        if notifications:
            editing = True
            while editing:
                print("\nEmail Preview (first notification):")
                print("-" * 50)
                print(notifications[0]['content'])
                print("-" * 50)
                
                print("\nWould you like to:")
                print("1. Edit the email")
                print("2. Send as is")
                print("3. Cancel sending")
                
                choice = input("\nYour choice (1-3): ").strip()
                
                if choice == '1':
                    edited_notification = await edit_email_content(notifications[0])
                    if edited_notification:
                        # Apply the edited template to all notifications
                        template = edited_notification['content']
                        for notif in notifications:
                            notif['content'] = template.replace(
                                notifications[0]['recipient_name'], notif['recipient_name']
                            ).replace(
                                notifications[0]['team'], notif['team']
                            )
                        continue
                    else:
                        return "Notification sending cancelled. Calendar updates still applied."
                elif choice == '2':
                    editing = False
                elif choice == '3':
                    return "Notification sending cancelled. Calendar updates still applied."
            
            # Send confirmed notifications
            notifications_sent = 0
            for notif in notifications:
                notification = {
                    'action': 'send',
                    'recipient_name': notif['recipient_name'],
                    'recipient': notif['recipient'],
                    'subject': f'Important Schedule Update - {notif["team"]}',
                    'body': notif['content']
                }
                await direct_tool_call(EmailingTool, **notification)
                notifications_sent += 1
            
            return f"Successfully applied {len(all_updates)} schedule updates. Sent {notifications_sent} personalized notifications."
        
        return f"Successfully applied {len(all_updates)} schedule updates. No notifications needed."
        
    except Exception as e:
        return f"Error applying changes: {str(e)}"

async def handle_modification_request(agent, user_input, changes, issues):
    """Handle requests to modify the proposed changes"""
    try:
        response = await agent.invoke(
            f"User wants to modify changes: '{user_input}'. Current changes: {changes}. "
            "Analyze request and suggest modifications."
        )
        print(f"\nAssistant: {response}")
        
        # Get new proposal based on user's request
        return await handle_change_confirmation(agent, changes, issues)
        
    except Exception as e:
        return f"Error handling modification: {str(e)}"

async def startup_sequence(agent):
    """Initial startup sequence to check for problems and show solutions"""
    message = "\nAssistant: Initializing system and checking for operational issues...\n"
    
    try:
        # Check calendar directly - no initialization
        message += "\nChecking calendar...\n"
        calendar_status = await direct_tool_call(CalendarTool, action="view")
        message += "\nCurrent Schedule:\n" + calendar_status

        # Check for issues directly
        message += "\nChecking for operational issues...\n"
        issues = await direct_tool_call(EventMonitor, action="check_all")
        
        if issues and len(issues) > 0:
            all_changes = []
            message += "\nFound operational issues:\n"
            
            for issue in issues:
                message += f"\n- {issue['type'].title()} issue: {issue['details']}\n"
                
                # Get impact analysis
                impact = await direct_tool_call(EventMonitor, action="analyze_impact", event_id=issue['id'])
                message += impact
                
                # Get solutions
                solutions = await direct_tool_call(EventMonitor, action="propose_solution", event_id=issue['id'])
                
                if isinstance(solutions, dict) and 'proposed_actions' in solutions:
                    changes = []
                    message += "\nProposed actions:\n"
                    for action in solutions['proposed_actions']:
                        message += f"  - {action}\n"
                        # Convert action to calendar change
                        if "Reschedule" in action:
                            event_id = issue['id']
                            delay_hours = 3  # From the action
                            changes.append({
                                'action': 'edit',
                                'event_id': event_id,
                                'delay_hours': delay_hours
                            })
                    all_changes.extend(changes)
                
                time.sleep(1)
            
            if all_changes:
                summary = await generate_comprehensive_summary(calendar_status, issues, all_changes)
                message += f"\n{summary}"
        else:
            message += "\nNo operational issues detected.\n"

    except Exception as e:
        message += Fore.RED + f"\nError during startup: {str(e)}\n"
        message += "Continuing with basic operation mode...\n"
    
    message += "\nAssistant: I'm ready to help you manage operations. What would you like to do?\n"
    return message

async def text_conversation_loop():
    print("\nAssistant: Hello! I'm your operations assistant. Type 'quit' to exit.")
    
    # Run the startup sequence
    await startup_sequence(agent)
    
    while True:
        user_input = input("\nYou: ").strip()
        
        if user_input.lower() == 'quit':
            print("Assistant: Goodbye!")
            break
            
        if user_input:
            response = await handle_command(agent, user_input)
            print(f"\nAssistant: {response}")
    # Run the text-based conversation loop

if __name__ == "__main__":
    # Run the text-based conversation loop
    uvicorn.run(app, host="0.0.0.0", port=8000)