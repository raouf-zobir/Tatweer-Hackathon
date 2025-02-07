import os, re
import json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from pydantic import Field
from ..base_tool import BaseTool
from src.utils import SCOPES

class FetchContactTool(BaseTool):
    """
    A tool for fetching contact information from Google Contacts
    """
    contact_name: str = Field(description='Name (first or last) of the contact to search for')

    def get_credentials(self):
        """
        Get and refresh Google Contacts API credentials
        """
        creds = None
        if os.path.exists('token.json'):
            creds = Credentials.from_authorized_user_file('token.json', SCOPES)
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    'credentials.json', SCOPES)
                creds = flow.run_local_server(port=0)
            with open('token.json', 'w') as token:
                token.write(creds.to_json())
        return creds

    def fetch_contact(self):
        """
        Fetches contact information from Google Contacts
        """
        try:
            creds = self.get_credentials()
            service = build('people', 'v1', credentials=creds)

            # Search for the contact with broader criteria
            results = service.people().searchContacts(
                query=self.contact_name,
                readMask='names,phoneNumbers,emailAddresses,organizations'
            ).execute()

            connections = results.get('results', [])
            matching_contacts = []

            for connection in connections:
                contact = connection['person']
                names = contact.get('names', [])
                organizations = contact.get('organizations', [])

                # Check both name and organization
                team_match = any(
                    org.get('name', '').lower() == self.contact_name.lower() or
                    org.get('department', '').lower() == self.contact_name.lower()
                    for org in organizations
                )

                if team_match or (names and self.contact_name.lower() in 
                    names[0].get('displayName', '').lower()):
                    full_name = names[0].get('displayName', 'N/A') if names else 'N/A'
                    phone_numbers = [phone.get('value', 'N/A') 
                                   for phone in contact.get('phoneNumbers', [])]
                    emails = [email.get('value', 'N/A') 
                            for email in contact.get('emailAddresses', [])]

                    matching_contacts.append({
                        'name': full_name,
                        'phone_numbers': phone_numbers,
                        'emails': emails
                    })

            # Return JSON-formatted string instead of raw string representation
            return json.dumps(matching_contacts) if matching_contacts else \
                   json.dumps({"error": f"No contacts found for team/organization: {self.contact_name}"})

        except HttpError as error:
            return json.dumps({"error": f"An error occurred: {error}"})

    def run(self):
        return self.fetch_contact()
