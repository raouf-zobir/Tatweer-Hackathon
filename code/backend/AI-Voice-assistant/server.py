from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import asyncio
from main import agent, startup_sequence, handle_command
from src.conversation.conversation_manager import ConversationManager
import json
from typing import Dict

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store active conversations
active_conversations: Dict[str, ConversationManager] = {}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    
    # Create new conversation manager for this session
    conversation = ConversationManager()
    session_id = str(id(websocket))
    active_conversations[session_id] = conversation
    
    try:
        # Send initial startup response
        startup_response = await startup_sequence(agent)
        conversation.add_message('assistant', startup_response)
        
        await websocket.send_text(json.dumps({
            "type": "startup",
            "message": startup_response
        }))
        
        # Handle ongoing conversation
        while True:
            data = await websocket.receive_json()
            message_type = data.get("type", "message")
            content = data.get("content", "")
            
            # Add user message to history
            conversation.add_message('user', content)
            
            if message_type == "message":
                # Include conversation history in command context
                context_window = conversation.get_context_window()
                response = await handle_command(
                    agent, 
                    content,
                    conversation_context=context_window,
                    conversation_manager=conversation
                )
                
                # Add assistant response to history
                conversation.add_message('assistant', response)
                
                await websocket.send_text(json.dumps({
                    "type": "response",
                    "message": response
                }))
                
            elif message_type == "change_confirmation":
                changes = data.get("changes", [])
                issues = data.get("issues", [])
                user_response = data.get("user_response", "")
                
                # Update context with current changes
                conversation.update_context('current_changes', changes)
                conversation.update_context('current_issues', issues)
                
                if "approve" in user_response.lower():
                    result = await apply_approved_changes(changes, "", conversation)
                elif "modify" in user_response.lower():
                    result = await handle_modification_request(
                        agent, 
                        user_response, 
                        changes, 
                        issues,
                        conversation
                    )
                else:
                    result = {
                        "type": "change_cancelled",
                        "message": "Changes cancelled. Let me know if you'd like to explore other options."
                    }
                
                conversation.add_message('assistant', result['message'])
                await websocket.send_text(json.dumps(result))
            
    except Exception as e:
        error_msg = str(e)
        conversation.add_message('assistant', f"Error: {error_msg}")
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": error_msg
        }))
    finally:
        # Clean up conversation when connection closes
        if session_id in active_conversations:
            del active_conversations[session_id]

@app.get("/")
async def root():
    return {"message": "AI Assistant API is running"}

if __name__ == "__main__": 
    import uvicorn
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
