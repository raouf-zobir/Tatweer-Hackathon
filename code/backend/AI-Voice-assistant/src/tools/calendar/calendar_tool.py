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

    def edit_event(self, event_id, delay_hours):
        """Edit a single event with validation"""
        try:
            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)
            
            # Get the existing event
            event = service.events().get(calendarId='primary', eventId=event_id).execute()
            
            # Calculate new times
            start_time = datetime.datetime.fromisoformat(event['start']['dateTime'].replace('Z', ''))
            new_start = start_time + datetime.timedelta(hours=delay_hours)
            new_end = new_start + (
                datetime.datetime.fromisoformat(event['end']['dateTime'].replace('Z', '')) - 
                start_time
            )
            
            # Update event times
            event['start']['dateTime'] = new_start.isoformat()
            event['end']['dateTime'] = new_end.isoformat()
            
            # Update event
            updated_event = service.events().update(
                calendarId='primary',
                eventId=event_id,
                body=event
            ).execute()
            
            return {
                "event_id": event_id,
                "status": "updated",
                "new_start": updated_event['start']['dateTime']
            }
            
        except Exception as e:
            return {"error": f"Failed to edit event {event_id}: {str(e)}"}

    def batch_edit(self, edits):
        """Handle multiple calendar edits in a single operation"""
        try:
            results = []
            for edit in edits:
                event_id = edit.get('event_id')
                delay_hours = edit.get('delay_hours')
                
                if event_id and delay_hours is not None:
                    result = self.edit_event(event_id, delay_hours)
                    results.append(result)
            
            return {
                "status": "success",
                "updated": len(results),
                "results": results
            }
            
        except Exception as e:
            return {"error": f"Batch edit failed: {str(e)}"}

    def edit(self):
        """Edit an event in the calendar"""
        try:
            if not self.event_id:
                return {"error": "No event ID provided"}

            creds = self.get_credentials()
            service = build("calendar", "v3", credentials=creds)

            # First try to find the event by its ID
            try:
                event = service.events().get(calendarId='primary', eventId=self.event_id).execute()
            except HttpError:
                # If not found, search for events with matching summary
                events_result = service.events().list(
                    calendarId='primary',
                    q=self.event_id,  # Search by event ID in summary/description
                    singleEvents=True,
                    orderBy='startTime'
                ).execute()
                events = events_result.get('items', [])
                
                if not events:
                    # If no events found, create a new one
                    base_date = datetime.datetime.now().replace(hour=8, minute=0, second=0, microsecond=0)
                    event = {
                        'summary': f"{self.event_id}",
                        'start': {
                            'dateTime': base_date.isoformat(),
                            'timeZone': 'UTC',
                        },
                        'end': {
                            'dateTime': (base_date + datetime.timedelta(hours=1)).isoformat(),
                            'timeZone': 'UTC',
                        },
                    }
                else:
                    event = events[0]  # Use the first matching event

            # Apply the delay
            if self.delay_hours:
                start_time = datetime.datetime.fromisoformat(event['start']['dateTime'].replace('Z', ''))
                new_start = start_time + datetime.timedelta(hours=self.delay_hours)
                
                # Update event times
                event['start']['dateTime'] = new_start.isoformat()
                event['end']['dateTime'] = (new_start + datetime.timedelta(hours=1)).isoformat()
                
                # Update or create event
                try:
                    updated_event = service.events().update(
                        calendarId='primary',
                        eventId=event['id'],
                        body=event
                    ).execute()
                except HttpError:
                    updated_event = service.events().insert(
                        calendarId='primary',
                        body=event
                    ).execute()

                return {
                    "status": "updated",
                    "event_id": updated_event['id'],
                    "summary": updated_event['summary'],
                    "new_time": updated_event['start']['dateTime']
                }

            return {"error": "No changes specified"}

        except Exception as e:
            return {"error": f"Failed to edit event: {str(e)}"}

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