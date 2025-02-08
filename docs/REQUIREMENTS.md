# Project Requirements

## Backend Requirements

### Core Frameworks
- **FastAPI**: Main API framework for real-time processing
- **Flask**: Secondary API framework for additional services
- **Uvicorn**: ASGI server for FastAPI

### AI and Machine Learning
- **LangChain Components**:
  - langchain-google-genai: Google AI integration
  - langchain-groq: Groq integration
  - langchain-core: Core LangChain functionality
  - langchain-community: Community tools
  - langchain-chroma: Vector store integration
  - langchain-text-splitters: Text processing
- **litellm**: LLM interface
- **tenacity**: Retry mechanism for API calls

### Agent System
- **asyncio**: Asynchronous I/O
- **dataclasses**: Data structure tools
- **email components**: Email handling utilities
- **colorama**: Terminal coloring

### Google Calendar Integration
- **google-auth**: Google authentication
- **google-api-python-client**: Google Calendar API client

### Firebase Integration
- **firebase-admin**: Server-side Firebase integration

### Voice and AI APIs
- **Deepgram**: Speech-to-text processing
- **Google Cloud TTS**: Text-to-speech conversion
- **Gemini AI**: Advanced language processing
- **Groq**: Fast AI inference
- **Tavily**: AI-powered search capabilities

### Utilities
- **python-dotenv**: Environment variable management
- **colorama**: Terminal text coloring for logging
- **requests**: HTTP client
- **pydantic**: Data validation
- **python-jose**: JWT token handling

## Frontend Requirements

### Core
- **Flutter SDK**: ^2.12.0
- **Dart SDK**: ^2.12.0

### Firebase
- **firebase_core**: Firebase initialization
- **firebase_auth**: Authentication
- **cloud_firestore**: Database operations

### State Management
- **provider**: Application state management

### UI Components
- **flutter_charts**: Data visualization
- **google_fonts**: Custom typography

### API Integration
- **http**: HTTP client
- **googleapis**: Google API integration
- **googleapis_auth**: Google authentication

### Utilities
- **intl**: Internationalization
- **shared_preferences**: Local storage

## Development Setup

### Backend Setup
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Unix
.\venv\Scripts\activate   # Windows

# Install requirements
pip install -r requirements.txt
```

### Frontend Setup
```bash
# Install Flutter dependencies
flutter pub get

# Run the application
flutter run -d chrome
```

### API Credentials Required
```env
GOOGLE_API_KEY=************
DEEPGRAM_API_KEY=************
TAVILY_API_KEY=************
GEMINI_API_KEY=************
GROQ_API_KEY=************
```

> ⚠️ **Security Note**: Never commit API keys to version control. Use environment variables or secure secret management.

## Important Notes
- Python version >= 3.8 required
- Flutter version >= 2.12.0 required
- Google Calendar API credentials required
- Firebase project configuration required

## Development Notes
- The system uses LangChain for AI agent implementation
- Vector store implementation uses Chroma
- Retry mechanisms implemented for API stability
- Asynchronous operations for improved performance
