from typing import Dict, List, ClassVar

class ContactsDatabase:
    """Manages organization contacts and department mappings"""
    
    DEPARTMENT_CONTACTS: ClassVar[Dict[str, List[Dict[str, str]]]] = {
        "Factory_X_Production": [
            {
                "name": "Bob Smith",
                "role": "Production Manager",
                "email": "benmatiziad5@gmail.com",
                "priority": "high"
            },
            {
                "name": "Alice Chen",
                "role": "Line Supervisor",
                "email": "bz.benmati@mynit-edu.net",
                "priority": "medium"
            }
        ],
        "Quality_Control": [
            {
                "name": "David Johnson",
                "role": "QC Manager",
                "email": "aotdevimpact@gmail.com",
                "priority": "high"
            }
        ],
        "Logistics": [
            {
                "name": "Sarah Williams",
                "role": "Logistics Coordinator",
                "email": "hanini.firebase@gmail.com",
                "priority": "high"
            }
        ],
        "Procurement": [
            {
                "name": "Mike Davis",
                "role": "Procurement Manager",
                "email": "benmatiziad5@gmail.com",
                "priority": "high"
            }
        ],
        "Customer_Delivery": [
            {
                "name": "Emma Rodriguez",
                "role": "Delivery Manager",
                "email": "bz.benmati@mynit-edu.net",
                "priority": "high"
            }
        ],
        "Inventory_Management": [
            {
                "name": "Tom Wilson",
                "role": "Inventory Manager",
                "email": "aotdevimpact@gmail.com",
                "priority": "high"
            }
        ]
    }

    @classmethod
    def get_department_contacts(cls, department: str) -> List[Dict[str, str]]:
        """Get all contacts for a specific department"""
        return cls.DEPARTMENT_CONTACTS.get(department, [])

    @classmethod
    def get_high_priority_contacts(cls, department: str) -> List[Dict[str, str]]:
        """Get high priority contacts for a department"""
        return [
            contact for contact in cls.get_department_contacts(department)
            if contact["priority"] == "high"
        ]

    @classmethod
    def get_all_affected_contacts(cls, departments: List[str]) -> List[Dict[str, str]]:
        """Get all contacts for multiple departments without duplicates"""
        seen_emails = set()
        contacts = []
        for dept in departments:
            for contact in cls.get_department_contacts(dept):
                if contact["email"] not in seen_emails:
                    contacts.append(contact)
                    seen_emails.add(contact["email"])
        return contacts
