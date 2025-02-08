from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import datetime

# Scopes define what permissions the app will request
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

# Authenticate and get credentials
flow = InstalledAppFlow.from_client_secrets_file(
    'Credentials.json', SCOPES)
creds = flow.run_local_server(port=0)  # Opens a browser for user login

# Build the Calendar service
service = build('calendar', 'v3', credentials=creds)

# Get events from yesterday to next week
now = datetime.datetime.utcnow().isoformat() + 'Z'
events_result = service.events().list(
    calendarId='primary', timeMin=now,
    maxResults=10, singleEvents=True,
    orderBy='startTime').execute()
events = events_result.get('items', [])

# Print events
for event in events:
    start = event['start'].get('dateTime', event['start'].get('date'))
    print(f"{start} - {event['summary']}")
