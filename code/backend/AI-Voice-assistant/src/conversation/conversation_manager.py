from dataclasses import dataclass
from typing import List, Dict, Optional
import time

@dataclass
class Message:
    role: str  # 'user' or 'assistant'
    content: str
    timestamp: float
    context: Optional[Dict] = None

class ConversationManager:
    def __init__(self, max_history: int = 10):
        self.history: List[Message] = []
        self.max_history = max_history
        self.context = {}
        
    def add_message(self, role: str, content: str, context: Optional[Dict] = None):
        message = Message(
            role=role,
            content=content,
            timestamp=time.time(),
            context=context
        )
        self.history.append(message)
        
        # Trim history if it exceeds max_history
        if len(self.history) > self.max_history:
            self.history = self.history[-self.max_history:]
            
    def get_context_window(self, window_size: int = 5) -> str:
        """Get recent conversation context"""
        recent_messages = self.history[-window_size:]
        context_str = ""
        
        for msg in recent_messages:
            context_str += f"{msg.role.title()}: {msg.content}\n"
            
        return context_str.strip()
    
    def update_context(self, key: str, value: any):
        """Update conversation context"""
        self.context[key] = value
        
    def get_context(self, key: str) -> Optional[any]:
        """Get specific context value"""
        return self.context.get(key)
    
    def clear_context(self):
        """Clear conversation context"""
        self.context = {}
        
    def clear_history(self):
        """Clear conversation history"""
        self.history = []
