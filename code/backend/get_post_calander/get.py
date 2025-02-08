from __future__ import print_function
import datetime
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/calendar']

def main():
    creds = None
    # Check if token.json exists for saved user credentials
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no valid credentials, prompt the user to log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    service = build('calendar', 'v3', credentials=creds)

    # Missing events to add
    missing_events = [
        {
            "summary": "MAERSK_T123 - Logistics Delay",
            "location": "Port of Jeddah",
            "description": "Container shipment delayed due to port congestion. Impact: Samsung_Factory_A, Regional_Distribution_Center",
            "start": {
                "dateTime": "2025-02-08T10:00:00",
                "timeZone": "Asia/Riyadh",
            },
            "end": {
                "dateTime": "2025-02-08T14:00:00",
                "timeZone": "Asia/Riyadh",
            }
        },
        {
            "summary": "DHL_TR789 - Logistics Delay",
            "location": "Dammam Highway Checkpoint",
            "description": "Truck delivery delayed due to road maintenance. Impact: LG_Assembly_Line, Gulf_Distribution_Hub",
            "start": {
                "dateTime": "2025-02-08T15:00:00",
                "timeZone": "Asia/Riyadh",
            },
            "end": {
                "dateTime": "2025-02-08T17:00:00",
                "timeZone": "Asia/Riyadh",
            }
        }
    ]

    # Insert each event into the Google Calendar
    for event in missing_events:
        event_result = service.events().insert(calendarId='primary', body=event).execute()
        print(f"Event created: {event_result.get('htmlLink')}")

if __name__ == '__main__':
    main()
