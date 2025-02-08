from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncio
from src.agents.agent import Agent
from src.tools.calendar.calendar_tool import CalendarTool
from src.tools.contacts import AddContactTool, FetchContactTool
from src.tools.emails.emailing_tool import EmailingTool
from src.tools.search import SearchWebTool
from src.prompts.prompts import assistant_prompt
from dotenv import load_dotenv
from src.tools.monitor.event_monitor import EventMonitor

load_dotenv()

app = FastAPI()

model = "groq/llama3-70b-8192"
tools_list = [
    CalendarTool,
    EventMonitor,
    AddContactTool,
    FetchContactTool,
    EmailingTool,
    SearchWebTool,
]

agent = Agent("Assistant Agent", model, tools_list, system_prompt=assistant_prompt)

class CommandRequest(BaseModel):
    command: str

@app.post("/process_command/")
async def process_command(request: CommandRequest):
    try:
        response = await handle_command(agent, request.command)
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

async def handle_command(agent, command):
    """Handle a single command with retries"""
    max_retries = 3
    retry_delay = 20  # seconds
    
    for attempt in range(max_retries):
        try:
            response = agent.invoke(command)
            if response and response != "None":
                return response
            if attempt < max_retries - 1:
                await asyncio.sleep(retry_delay)
            else:
                return "I'm having trouble processing that request. Please try again later."
        except Exception as e:
            if attempt < max_retries - 1:
                await asyncio.sleep(retry_delay)
            else:
                return "I encountered an error. Please try again later."
