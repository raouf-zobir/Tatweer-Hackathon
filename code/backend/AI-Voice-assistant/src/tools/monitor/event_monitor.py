import datetime
import sys
import os
import json
from typing import ClassVar, Dict, Any
from pydantic import Field
from ..base_tool import BaseTool
from .. import CalendarTool  # Import from tools package

class EventMonitor(BaseTool):
    """
    Monitors events and detects problems in real-time
    """
    action: str = Field(description="Action to perform: check_status, analyze_impact, propose_solution")
    event_id: str = Field(default=None, description="ID of the event to monitor")
    
    EVENTS_JSON_PATH: ClassVar[str] = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), 
        '../../../../DelayDetector/delay_events.json'
    )

    def get_current_events(self) -> Dict[str, Any]:
        """Fetch current events from JSON file"""
        try:
            if os.path.exists(self.EVENTS_JSON_PATH):
                with open(self.EVENTS_JSON_PATH, 'r') as f:
                    return json.load(f)
        except Exception as e:
            print(f"Error reading events: {e}")
        return {}

    def check_status(self):
        """Check current status of operations"""
        events = self.get_current_events()
        if self.event_id in events:
            event = events[self.event_id]
            return {
                "status": event["status"],
                "details": f"{event['type'].title()} event {self.event_id} is {event['status']} at {event['location']}"
            }
        return {"status": "normal", "details": "No issues detected"}

    def analyze_impact(self):
        """Analyze the impact of a delay or issue"""
        events = self.get_current_events()
        if self.event_id in events:
            event = events[self.event_id]
            impact_analysis = f"Impact Analysis for {self.event_id}:\n"
            impact_analysis += f"- Primary Issue: {event['status']} at {event['location']}\n"
            impact_analysis += "- Affected Operations:\n"
            for impact in event['impact']:
                impact_analysis += f"  * {impact}\n"
            return impact_analysis
        return "No impact detected"

    def propose_solution(self):
        """Propose corrective actions"""
        events = self.get_current_events()
        if self.event_id in events:
            event = events[self.event_id]
            
            # Create calendar tool instance for status check
            calendar_tool = CalendarTool(action="view")
            calendar_status = calendar_tool.run()
            
            # Find actual event ID if it exists
            actual_event_id = None
            if isinstance(calendar_status, str):
                for line in calendar_status.split('\n'):
                    if self.event_id in line:
                        # Extract ID from line
                        event_id_part = line.split('(ID: ')[-1].strip(')')
                        if event_id_part:
                            actual_event_id = event_id_part
                            break

            if event['type'] == 'logistics':
                return {
                    "proposed_actions": [
                        f"Reschedule production at {event['impact'][0]} with 3-hour delay",
                        f"Update delivery time for {event['impact'][1]}",
                        "Notify affected teams"
                    ],
                    "requires_approval": True,
                    "calendar_event_id": actual_event_id or self.event_id
                }
            elif event['type'] == 'production':
                return {
                    "proposed_actions": [
                        "Check alternative material sources",
                        f"Adjust inventory allocation for {event['impact'][1]}",
                        "Alert procurement team"
                    ],
                    "requires_approval": True
                }
        return {"proposed_actions": [], "requires_approval": False}

    def check_all_operations(self):
        """Check all operations for any issues"""
        issues = []
        events = self.get_current_events()
        for event_id, event in events.items():
            if event['status'] in ['delayed', 'at_risk']:
                issues.append({
                    'id': event_id,
                    'status': event['status'],
                    'type': event['type'],
                    'details': f"{event['type'].title()} issue at {event['location']}"
                })
        return issues

    def run(self):
        if self.action == "check_all":
            return self.check_all_operations()
        if self.action == "check_status":
            return self.check_status()
        elif self.action == "analyze_impact":
            return self.analyze_impact()
        elif self.action == "propose_solution":
            return self.propose_solution()
        return "Invalid action specified"
