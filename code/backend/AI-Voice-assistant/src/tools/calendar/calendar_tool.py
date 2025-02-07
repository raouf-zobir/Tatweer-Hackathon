import os
import datetime
from typing import ClassVar, Dict, Any
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from pydantic import Field
from ..base_tool import BaseTool
from src.utils import SCOPES

class CalendarTool(BaseTool):
    """
    A tool for managing Google Calendar events
    """
    action: str = Field(description='Action to perform: create, view, edit, or delete')
    event_name: str = Field(description='Name of the event', default=None)
    event_datetime: str = Field(description='Date and time of the event', default=None)
    event_description: str = Field(default="", description='Optional description of the event')
    event_id: str = Field(default=None, description='Event ID for editing or deleting')
    delay_hours: int = Field(default=None, description='Number of hours to delay the event')

    # Add synthetic calendar data
    SYNTHETIC_SCHEDULE: ClassVar[Dict[str, Any]] = {
        "shipping_routes": [
            {
                "id": "SHIP001",
                "summary": "Truck Delivery: Raw Materials",
                "start_time": "09:00",
                "location": "Warehouse A",
                "description": "Daily raw materials delivery from supplier"
            },
            {
                "id": "SHIP002",
                "summary": "Container Shipment: Export Products",
                "start_time": "14:00",
                "location": "Port Terminal B",
                "description": "Weekly international shipping"
            }
        ],
        "production_schedule": [
            {
                "id": "PROD001",
                "summary": "Production Line A: Electronics Assembly",
                "start_time": "07:00",
                "location": "Factory X",
                "description": "Daily production run"
            },
            {
                "id": "PROD002",
                "summary": "Quality Control Check",
                "start_time": "16:00",
                "location": "QC Lab",
                "description": "Daily quality inspection"
            }
        ],
        "maintenance": [
            {
                "id": "MAINT001",
                "summary": "Equipment Maintenance: Line A",
                "start_time": "06:00",
                "location": "Factory X",
                "description": "Weekly preventive maintenance"
            }
        ]
    }

    def get_credentials(self):
        """
        Get and refresh Google Calendar API credentials
        """
        creds = None
        if os.path.exists("token.json"):
            creds = Credentials.from_authorized_user_file("token.json", SCOPES)
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    "credentials.json", SCOPES
                )
                creds = flow.run_local_server(port=0)
            with open("token.json", "w") as token:
                token.write(creds.to_json())
        return creds

    def create_event(self):
        """
        Creates an event on Google Calendar
        """
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            # Convert the string to a datetime object
            event_datetime = datetime.datetime.fromisoformat(self.event_datetime)

            event = {
                'summary': self.event_name,
                'description': self.event_description,
                'start': {
                    'dateTime': event_datetime.isoformat(),
                    'timeZone': 'UTC',
                },
                'end': {
                    'dateTime': (event_datetime + datetime.timedelta(hours=1)).isoformat(),
                    'timeZone': 'UTC',
                },
            }

            event = service.events().insert(calendarId='primary', body=event).execute()
            return f"Event created successfully. Event ID: {event.get('id')}"

        except HttpError as error:
            return f"An error occurred: {error}"

    def view_calendar(self):
        """
        Retrieves upcoming events from Google Calendar
        """
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            now = datetime.datetime.utcnow().isoformat() + 'Z'
            events_result = service.events().list(
                calendarId='primary', timeMin=now,
                maxResults=10, singleEvents=True,
                orderBy='startTime'
            ).execute()
            events = events_result.get('items', [])

            if not events:
                return "No upcoming events found."
                
            output = "Upcoming events:\n"
            for event in events:
                start = event['start'].get('dateTime', event['start'].get('date'))
                output += f"- {start}: {event['summary']} (ID: {event['id']})\n"
            return output

        except HttpError as error:
            return f"An error occurred: {error}"

    def edit_event(self):
        """
        Edits an existing event on Google Calendar
        """
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            # Get the existing event
            event = service.events().get(calendarId='primary', eventId=self.event_id).execute()
            
            # Handle delay if specified
            if self.delay_hours:
                start_time = datetime.datetime.fromisoformat(event['start']['dateTime'])
                new_start = start_time + datetime.timedelta(hours=self.delay_hours)
                new_end = new_start + datetime.timedelta(hours=1)
                
                event['start']['dateTime'] = new_start.isoformat()
                event['end']['dateTime'] = new_end.isoformat()
            
            # Handle other updates
            if self.event_name:
                event['summary'] = self.event_name
            if self.event_datetime:
                event_datetime = datetime.datetime.fromisoformat(self.event_datetime)
                event['start']['dateTime'] = event_datetime.isoformat()
                event['end']['dateTime'] = (event_datetime + datetime.timedelta(hours=1)).isoformat()
            if self.event_description:
                event['description'] = self.event_description

            updated_event = service.events().update(
                calendarId='primary',
                eventId=self.event_id,
                body=event
            ).execute()
            
            return f"Event updated successfully: {updated_event['summary']}"

        except HttpError as error:
            return f"An error occurred: {error}"

    def delete_event(self):
        """
        Deletes an event from Google Calendar
        """
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            service.events().delete(
                calendarId='primary',
                eventId=self.event_id
            ).execute()
            
            return f"Event deleted successfully"

        except HttpError as error:
            return f"An error occurred: {error}"

    def initialize_synthetic_calendar(self):
        """
        Populates the calendar with synthetic data for testing
        """
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            # Get today's date
            today = datetime.datetime.now().date()
            events_created = []

            # Create events for next 7 days
            for day in range(7):
                current_date = today + datetime.timedelta(days=day)
                
                # Add shipping routes
                for route in self.SYNTHETIC_SCHEDULE["shipping_routes"]:
                    if day % (2 if "Weekly" in route["description"] else 1) == 0:  # Weekly or daily
                        event_datetime = datetime.datetime.combine(
                            current_date,
                            datetime.datetime.strptime(route["start_time"], "%H:%M").time()
                        )
                        
                        event = {
                            'summary': route["summary"],
                            'location': route["location"],
                            'description': route["description"],
                            'start': {
                                'dateTime': event_datetime.isoformat(),
                                'timeZone': 'UTC',
                            },
                            'end': {
                                'dateTime': (event_datetime + datetime.timedelta(hours=2)).isoformat(),
                                'timeZone': 'UTC',
                            },
                        }
                        
                        created_event = service.events().insert(calendarId='primary', body=event).execute()
                        events_created.append(created_event['id'])

                # Add production schedule
                for prod in self.SYNTHETIC_SCHEDULE["production_schedule"]:
                    event_datetime = datetime.datetime.combine(
                        current_date,
                        datetime.datetime.strptime(prod["start_time"], "%H:%M").time()
                    )
                    
                    event = {
                        'summary': prod["summary"],
                        'location': prod["location"],
                        'description': prod["description"],
                        'start': {
                            'dateTime': event_datetime.isoformat(),
                            'timeZone': 'UTC',
                        },
                        'end': {
                            'dateTime': (event_datetime + datetime.timedelta(hours=8)).isoformat(),
                            'timeZone': 'UTC',
                        },
                    }
                    
                    created_event = service.events().insert(calendarId='primary', body=event).execute()
                    events_created.append(created_event['id'])

                # Add maintenance (weekly)
                if day % 7 == 0:
                    for maint in self.SYNTHETIC_SCHEDULE["maintenance"]:
                        event_datetime = datetime.datetime.combine(
                            current_date,
                            datetime.datetime.strptime(maint["start_time"], "%H:%M").time()
                        )
                        
                        event = {
                            'summary': maint["summary"],
                            'location': maint["location"],
                            'description': maint["description"],
                            'start': {
                                'dateTime': event_datetime.isoformat(),
                                'timeZone': 'UTC',
                            },
                            'end': {
                                'dateTime': (event_datetime + datetime.timedelta(hours=4)).isoformat(),
                                'timeZone': 'UTC',
                            },
                        }
                        
                        created_event = service.events().insert(calendarId='primary', body=event).execute()
                        events_created.append(created_event['id'])

            return f"Successfully created {len(events_created)} events"

        except HttpError as error:
            return f"An error occurred: {error}"

    def run(self):
        if self.action == "initialize":
            return self.initialize_synthetic_calendar()
        if self.action == "view":
            return self.view_calendar()
        elif self.action == "create":
            return self.create_event()
        elif self.action == "edit":
            return self.edit_event()
        elif self.action == "delete":
            return self.delete_event()
        else:
            return "Invalid action specified"