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

async def handle_command(agent, command):
    """Handle a single command with retries"""
    max_retries = 3
    retry_delay = 20  # seconds
    
    for attempt in range(max_retries):
        try:
            response = agent.invoke(command)
            if response and response != "None":
                return response
            if attempt < max_retries - 1:
                print(f"\nRetrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                return "I'm having trouble processing that request. Please try again later."
        except Exception as e:
            print(f"\nError (attempt {attempt + 1}/{max_retries}): {str(e)}")
            if attempt < max_retries - 1:
                print(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
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
        
        print("\n=== ACTION REQUIRED ===")
        print("Please review the above summary and choose:")
        print("1. 'approve' - Apply all changes as described")
        print("2. 'modify' - Adjust specific changes")
        print("3. 'explain' - Get more details about specific changes")
        print("4. 'cancel' - Cancel all changes")
        
        while True:
            user_input = input("\nYour decision: ").strip().lower()
            
            if any(word in user_input for word in ['yes', 'approve', 'accept', 'proceed', 'do this']):
                return await apply_approved_changes(changes, summary)
            
            elif any(word in user_input for word in ['no', 'cancel', 'reject', 'stop']):
                return "Changes cancelled. Let me know if you'd like to explore other options."
            
            elif any(word in user_input for word in ['modify', 'change', 'adjust', 'different']):
                return await handle_modification_request(agent, user_input, changes, issues)
            
            elif 'explain' in user_input:
                print("\nWhat specific aspect would you like me to explain?")
                aspect = input("Your question: ")
                response = await agent.invoke(f"Explain this aspect of the changes: {aspect}")
                print(f"\nAssistant: {response}")
                print("\nWould you like to proceed with the changes?")
            
            else:
                print("\nI didn't understand. Please use 'approve', 'modify', 'explain', or 'cancel'.")
    except Exception as e:
        return f"Error during confirmation: {str(e)}"

async def apply_approved_changes(changes, summary):
    """Apply approved changes with comprehensive updates"""
    try:
        print("\nApplying changes...")
        
        # Group all related changes
        all_updates = []
        notifications = []
        
        for change in changes:
            # Update calendar
            result = await direct_tool_call(CalendarTool, **change)
            if result:
                all_updates.append(result)
            
            # Handle cascading updates
            if change.get('event_id'):
                impact = await direct_tool_call(EventMonitor, 
                                              action="analyze_impact",
                                              event_id=change['event_id'])
                if impact:
                    # Extract affected events and create updates
                    affected = [line.strip()[2:] for line in impact.split('\n') if '*' in line]
                    for affected_event in affected:
                        update = {
                            'action': 'edit',
                            'event_id': affected_event,
                            'delay_hours': change.get('delay_hours', 0)
                        }
                        result = await direct_tool_call(CalendarTool, **update)
                        if result:
                            all_updates.append(result)

        # Send comprehensive notification
        notification = {
            'action': 'send',
            'recipient': 'operations_team@company.com',
            'subject': 'Schedule Updates - Multiple Changes',
            'body': summary
        }
        await direct_tool_call(EmailingTool, **notification)
        
        return f"Successfully applied {len(all_updates)} schedule updates. All affected teams have been notified."
        
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
    print("\nAssistant: Initializing system and checking for operational issues...")
    
    try:
        # Check calendar directly - no initialization
        print("\nChecking calendar...")
        calendar_status = await direct_tool_call(CalendarTool, action="view")
        print("\nCurrent Schedule:")
        print(calendar_status)

        # Check for issues directly
        print("\nChecking for operational issues...")
        issues = await direct_tool_call(EventMonitor, action="check_all")
        
        if issues and len(issues) > 0:
            all_changes = []
            print("\nFound operational issues:")
            
            for issue in issues:
                print(f"\n- {issue['type'].title()} issue: {issue['details']}")
                
                # Get impact analysis
                impact = await direct_tool_call(EventMonitor, 
                                              action="analyze_impact",
                                              event_id=issue['id'])
                print(impact)
                
                # Get solutions
                solutions = await direct_tool_call(EventMonitor,
                                                 action="propose_solution",
                                                 event_id=issue['id'])
                
                if isinstance(solutions, dict) and 'proposed_actions' in solutions:
                    changes = []
                    print("\nProposed actions:")
                    for action in solutions['proposed_actions']:
                        print(f"  - {action}")
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
                result = await handle_change_confirmation(agent, all_changes, issues)
                print(f"\n{result}")
        else:
            print("\nNo operational issues detected.")

    except Exception as e:
        print(Fore.RED + f"\nError during startup: {str(e)}")
        print("Continuing with basic operation mode...")
    
    print("\nAssistant: I'm ready to help you manage operations. What would you like to do?")

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
    asyncio.run(text_conversation_loop())
    asyncio.run(text_conversation_loop())