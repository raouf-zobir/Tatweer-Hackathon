import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from pydantic import Field
from ..base_tool import BaseTool
from src.tools.contacts import FetchContactTool

class EmailingTool(BaseTool):
    """
    A tool for sending emails using Gmail
    """
    action: str = Field(description="Action to perform (send)")
    recipient: str = Field(description="Email recipient address")
    recipient_name: str = Field(description="Name of the recipient")
    subject: str = Field(description="Email subject line")
    body: str = Field(description="Email body content")

    def fetch_recipient_email(self):
        """
        Fetches the email address of the recipient using FetchContactTool
        """
        try:
            fetch_contact_tool = FetchContactTool(contact_name=self.recipient_name)
            result = fetch_contact_tool.run()
            contact_info = eval(result)
            email = contact_info[0].get('emails', [None])[0]
            if not email:
                raise ValueError(f"No email found for contact: {self.recipient_name}")
            return email
        except Exception as e:
            raise ValueError(f"Failed to fetch email for {self.recipient_name}: {e}")

    def send_email_with_gmail(self, recipient_email):
        """
        Sends an email using Gmail SMTP
        """
        try:
            sender_email = os.getenv("GMAIL_MAIL")
            app_password = os.getenv("GMAIL_APP_PASSWORD")

            msg = MIMEMultipart()
            msg['From'] = sender_email
            msg['To'] = recipient_email
            msg['Subject'] = self.subject
            msg.attach(MIMEText(self.body, 'plain'))

            server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
            server.login(sender_email, app_password)
            text = msg.as_string()
            server.sendmail(sender_email, recipient_email, text)
            server.quit()
            return "Email sent successfully."
        except Exception as e:
            return f"Email was not sent successfully, error: {e}"

    def send(self):
        """Send an email (simulated for now)"""
        if not all([self.recipient, self.subject, self.body]):
            return {"error": "Missing required email fields"}
            
        # Simulate email sending
        print(f"\nSending email to: {self.recipient}")
        print(f"Subject: {self.subject}")
        return {"status": "sent", "to": self.recipient}

    def run(self):
        if self.action == "send":
            return self.send()
        return {"error": "Invalid action specified"}
