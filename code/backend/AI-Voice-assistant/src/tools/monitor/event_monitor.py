import datetime
from typing import ClassVar, Dict, Any
from pydantic import Field
from ..base_tool import BaseTool

class EventMonitor(BaseTool):
    """
    Monitors events and detects problems in real-time
    """
    action: str = Field(description="Action to perform: check_status, analyze_impact, propose_solution")
    event_id: str = Field(default=None, description="ID of the event to monitor")

    # Fix: Add ClassVar annotation for the synthetic data
    SYNTHETIC_EVENTS: ClassVar[Dict[str, Any]] = {
        "TRUCK123": {
            "type": "logistics",
            "status": "delayed",
            "delay_hours": 3,
            "location": "checkpoint B",
            "impact": ["Factory_X_Production", "Customer_Delivery_A"],
        },
        "PROD456": {
            "type": "production",
            "status": "at_risk",
            "issue": "material_shortage",
            "location": "Factory_X",
            "impact": ["Customer_Delivery_B", "Inventory_Level_C"],
        }
    }

    def check_status(self):
        """Check current status of operations"""
        if self.event_id in self.SYNTHETIC_EVENTS:
            event = self.SYNTHETIC_EVENTS[self.event_id]
            return {
                "status": event["status"],
                "details": f"{event['type'].title()} event {self.event_id} is {event['status']} at {event['location']}"
            }
        return {"status": "normal", "details": "No issues detected"}

    def analyze_impact(self):
        """Analyze the impact of a delay or issue"""
        if self.event_id in self.SYNTHETIC_EVENTS:
            event = self.SYNTHETIC_EVENTS[self.event_id]
            impact_analysis = f"Impact Analysis for {self.event_id}:\n"
            impact_analysis += f"- Primary Issue: {event['status']} at {event['location']}\n"
            impact_analysis += "- Affected Operations:\n"
            for impact in event['impact']:
                impact_analysis += f"  * {impact}\n"
            return impact_analysis
        return "No impact detected"

    def propose_solution(self):
        """Propose corrective actions"""
        if self.event_id in self.SYNTHETIC_EVENTS:
            event = self.SYNTHETIC_EVENTS[self.event_id]
            if event['type'] == 'logistics':
                return {
                    "proposed_actions": [
                        f"Reschedule production at {event['impact'][0]} with 3-hour delay",
                        f"Update delivery time for {event['impact'][1]}",
                        "Notify affected teams"
                    ],
                    "requires_approval": True
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
        for event_id, event in self.SYNTHETIC_EVENTS.items():
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
