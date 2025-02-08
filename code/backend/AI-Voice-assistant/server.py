from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import asyncio
from main import agent, startup_sequence, handle_command
import json

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    
    try:
        # Send initial startup response
        startup_response = await startup_sequence(agent)
        await websocket.send_text(json.dumps({
            "type": "startup",
            "message": startup_response
        }))
        
        # Handle ongoing conversation
        while True:
            data = await websocket.receive_json()
            message_type = data.get("type", "message")
            content = data.get("content", "")
            
            if message_type == "message":
                # Regular message handling
                response = await handle_command(agent, content)
                await websocket.send_text(json.dumps({
                    "type": "response",
                    "message": response
                }))
                
            elif message_type == "change_confirmation":
                # Handle change confirmation responses
                changes = data.get("changes", [])
                issues = data.get("issues", [])
                user_response = data.get("user_response", "")
                
                if "approve" in user_response.lower():
                    result = await apply_approved_changes(changes, "")
                elif "modify" in user_response.lower():
                    result = await handle_modification_request(agent, user_response, changes, issues)
                else:
                    result = {
                        "type": "change_cancelled",
                        "message": "Changes cancelled. Let me know if you'd like to explore other options."
                    }
                
                await websocket.send_text(json.dumps(result))
            
    except Exception as e:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": str(e)
        }))

@app.get("/")
async def root():
    return {"message": "AI Assistant API is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
