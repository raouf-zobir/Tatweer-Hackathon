import os
import datetime
from typing import ClassVar, Dict, Any, Optional
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from pydantic import Field
from ..base_tool import BaseTool
from src.utils import SCOPES

class CalendarTool(BaseTool):
    """A tool for managing Google Calendar events"""
    action: str = Field(description='Action to perform: create, view, edit, or delete')
    event_name: Optional[str] = Field(default=None, description='Name of the event')
    event_datetime: Optional[str] = Field(default=None, description='Date and time of the event')
    event_description: Optional[str] = Field(default="", description='Optional description of the event')
    event_id: Optional[str] = Field(default=None, description='Event ID for editing or deleting')
    delay_hours: Optional[int] = Field(default=None, description='Number of hours to delay the event')
    event_data: Optional[Dict[str, Any]] = Field(default=None, description="Data for new event")

    # Store monitored events mapping
    _monitored_events: Dict[str, Dict[str, Any]] = {}

    def __init__(self, **data):
        super().__init__(**data)
        self._ensure_monitored_events()

    def _ensure_monitored_events(self):
        """Ensure monitored events are initialized"""
        if not self._monitored_events:
            # Initialize with base schedule
            base_date = datetime.datetime.now().replace(hour=8, minute=0, second=0, microsecond=0)
            self._monitored_events.update({
                "MAERSK_T123": {
                    "summary": "MAERSK_T123 - Logistics Operation",
                    "location": "Port of Jeddah",
                    "start_time": base_date + datetime.timedelta(days=1),
                    "duration": 4,
                    "type": "logistics"
                },
                "DHL_TR789": {
                    "summary": "DHL_TR789 - Transport Operation",
                    "location": "Dammam Highway Checkpoint",
                    "start_time": base_date + datetime.timedelta(days=1, hours=4),
                    "duration": 2,
                    "type": "logistics"
                }
            })

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
        """Populates the calendar with synthetic data from EventMonitor"""
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            # Get events from EventMonitor instead
            event_monitor = EventMonitor(action="check_all")
            all_events = event_monitor.SYNTHETIC_EVENTS
            
            today = datetime.datetime.now().date()
            events_created = []
            
            # Create events for next 7 days
            for day in range(7):
                current_date = today + datetime.timedelta(days=day)
                
                for event_id, event_data in all_events.items():
                    event_datetime = datetime.datetime.combine(
                        current_date,
                        datetime.datetime.strptime("09:00", "%H:%M").time()
                    )
                    
                    event = {
                        'summary': f"{event_data['type'].title()}: {event_data['details']}",
                        'location': event_data['location'],
                        'description': f"Event ID: {event_id}\nStatus: {event_data['status']}\nImpact: {', '.join(event_data['impact'])}",
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

            return f"Successfully created {len(events_created)} events"

        except HttpError as error:
            return f"An error occurred: {error}"

    def edit(self):
        """Edit an event in the calendar"""
        try:
            if not self.event_id:
                return {"error": "No event ID provided"}

            # Check if this is a monitored event
            if self.event_id in self._monitored_events:
                event = self._monitored_events[self.event_id]
                
                if self.delay_hours:
                    # Update the event timing
                    event['start_time'] += datetime.timedelta(hours=self.delay_hours)
                    
                    # Create or update in Google Calendar
                    creds = self.get_credentials()
                    service = build("calendar", "v3", credentials=creds)
                    
                    calendar_event = {
                        'summary': event['summary'],
                        'location': event['location'],
                        'description': f"Monitored Event ID: {self.event_id}",
                        'start': {
                            'dateTime': event['start_time'].isoformat(),
                            'timeZone': 'UTC',
                        },
                        'end': {
                            'dateTime': (event['start_time'] + datetime.timedelta(hours=event['duration'])).isoformat(),
                            'timeZone': 'UTC',
                        },
                    }
                    
                    # Check if event exists in Google Calendar
                    try:
                        existing_event = service.events().get(
                            calendarId='primary', 
                            eventId=self.event_id
                        ).execute()
                        # Update existing event
                        updated_event = service.events().update(
                            calendarId='primary',
                            eventId=self.event_id,
                            body=calendar_event
                        ).execute()
                    except HttpError:
                        # Create new event
                        created_event = service.events().insert(
                            calendarId='primary',
                            body=calendar_event
                        ).execute()
                    
                    return {
                        "status": "updated",
                        "event_id": self.event_id,
                        "new_time": event['start_time'].isoformat()
                    }

            return {"error": f"Event {self.event_id} not found"}

        except Exception as e:
            return {"error": f"Failed to edit event: {str(e)}"}

    def run(self):
        """Execute the calendar tool action"""
        if self.action == "edit":
            return self.edit()
        elif self.action == "view":
            return self.view_calendar()
        elif self.action == "create":
            return self.create_event()
        elif self.action == "delete":
            return self.delete_event()
        elif self.action == "initialize":
            return self.initialize_synthetic_calendar()
        return {"error": "Invalid action specified"}