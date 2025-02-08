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
        # Logistics Delays
        "MAERSK_T123": {
            "type": "logistics",
            "status": "delayed",
            "delay_hours": 4,
            "location": "Port of Jeddah",
            "impact": ["Samsung_Factory_A", "Regional_Distribution_Center"],
            "details": "Container shipment delayed due to port congestion"
        },
        "DHL_TR789": {
            "type": "logistics",
            "status": "delayed",
            "delay_hours": 2,
            "location": "Dammam Highway Checkpoint",
            "impact": ["LG_Assembly_Line", "Gulf_Distribution_Hub"],
            "details": "Truck delivery delayed due to road maintenance"
        },

        # Manufacturing Equipment Issues
        "SIEMENS_M456": {
            "type": "equipment_failure",
            "status": "breakdown",
            "delay_hours": 6,
            "location": "SABIC Petrochem Plant",
            "impact": ["Chemical_Processing_A", "Packaging_Line_B", "Customer_Delivery_X"],
            "details": "Critical pump failure in processing unit",
            "repair_estimate": "6 hours"
        },
        "ABB_ROB334": {
            "type": "equipment_failure",
            "status": "maintenance",
            "delay_hours": 3,
            "location": "Toyota Assembly Riyadh",
            "impact": ["Vehicle_Assembly", "Quality_Control", "Dealer_Network"],
            "details": "Robotic arm malfunction on main assembly line",
            "repair_estimate": "3 hours"
        },

        # Raw Material Shortages
        "RM_TSMC_001": {
            "type": "material_shortage",
            "status": "critical",
            "delay_hours": 48,
            "location": "Semiconductor Facility",
            "impact": ["iPhone_Production", "Electronics_Assembly", "Apple_Distribution"],
            "details": "Silicon wafer shortage affecting chip production",
            "inventory_level": "15%"
        },
        "RM_BASF_207": {
            "type": "material_shortage",
            "status": "warning",
            "delay_hours": 24,
            "location": "Chemical Plant Yanbu",
            "impact": ["Polymer_Production", "Plastic_Molding", "Packaging_Supply"],
            "details": "Low catalyst inventory affecting polymer production",
            "inventory_level": "30%"
        },

        # Inventory Stock-outs
        "INV_UNILEVER_554": {
            "type": "stock_out",
            "status": "critical",
            "delay_hours": 12,
            "location": "Jeddah Distribution Center",
            "impact": ["Carrefour_KSA", "Panda_Retail", "LuLu_Group"],
            "details": "Personal care products stock-out affecting major retailers",
            "affected_skus": 15
        },
        "INV_PEPSI_332": {
            "type": "stock_out",
            "status": "warning",
            "delay_hours": 8,
            "location": "Riyadh Warehouse",
            "impact": ["AlOthaim_Markets", "Danube_Stores", "SPAR_KSA"],
            "details": "Beverage stock-out in central region",
            "affected_skus": 7
        },

        # Production Delays
        "PROD_TESLA_889": {
            "type": "production_delay",
            "status": "delayed",
            "delay_hours": 10,
            "location": "Gigafactory Middle East",
            "impact": ["Vehicle_Assembly", "Battery_Production", "Delivery_Centers"],
            "details": "Production line reconfiguration causing delays",
            "completion_estimate": "85%"
        },
        "PROD_NESTLE_445": {
            "type": "production_delay",
            "status": "at_risk",
            "delay_hours": 5,
            "location": "Food Processing Plant",
            "impact": ["Retail_Distribution", "Export_Division", "Cold_Storage"],
            "details": "Quality control issues in dairy production line",
            "completion_estimate": "70%"
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
