import os
from dotenv import load_dotenv

load_dotenv()

class CalendarConfig:
    GOOGLE_CALENDAR_EMAIL = os.getenv('GOOGLE_CALENDAR_EMAIL')
    CREDENTIALS_FILE = os.getenv('GOOGLE_CALENDAR_CREDENTIALS_FILE')
    
    @staticmethod
    def validate_config():
        if not all([CalendarConfig.GOOGLE_CALENDAR_EMAIL, 
                   CalendarConfig.CREDENTIALS_FILE]):
            raise ValueError("Missing required Google Calendar configuration")
