# Real-Time Supply Chain Monitoring and Adaptation System

## Overview
An intelligent supply chain management solution that provides real-time monitoring and adaptive response to logistics challenges. The system uses AI agents to detect, analyze, and respond to supply chain disruptions while continuously learning from historical data.

## Key Features
- Real-time monitoring and problem detection
- AI-powered adaptive response system
- Voice Interaction Capabilities:
  - Speech-to-text for voice commands
  - Text-to-speech for agent responses
  - Natural voice conversations with AI agent
- Predictive analytics for future disruptions
- Sales prediction capabilities
- Human-in-the-loop confirmation system
- Automated calendar management and stakeholder notification

## Technology Stack
- **Frontend**: Flutter/Dart (Web Application)
- **Backend**: 
  - Python (AI Agents)
  - FastAPI & Flask (API Services)
  - Dart
- **Database**: Firebase
- **Authentication**: Firebase Auth
- **Calendar Integration**: Google Calendar API
- **AI & Voice**: 
  - Deepgram (Speech-to-Text)
  - Google Text-to-Speech
  - Gemini & Groq AI
  - Tavily Search API
- **Other Tools**: 
  - Colorama (Agent Console Interface)
  - IoT Integration (Simulated)

## System Components
1. **Main AI Agent**: Real-time monitoring and response system
2. **Predictive AI**: Historical analysis and future disruption prediction
3. **Sales Prediction AI**: Product sales forecasting
4. **Web Interface**: Flutter-based dashboard and control panel

## Important Notes
⚠️ **Rate Limit Warning**: The AI agent system may have computational limitations and API rate limits. While it works well for common tasks (calendar management, email notifications, etc.), complex real-time processing might be throttled based on computational resources.

## Project Structure
```
├── frontend/                 # Flutter web application
│   ├── lib/                 
│   │   ├── screens/         # UI screens
│   │   ├── widgets/         # Reusable components
│   │   ├── services/        # API services
│   │   └── models/          # Data models
├── backend/
│   ├── ai_agents/          # AI agent implementations
│   │   ├── main_agent/     # Real-time monitoring agent
│   │   ├── predictive/     # Predictive analysis agent
│   │   └── sales/          # Sales prediction agent
│   ├── api/                # FastAPI and Flask services
│   └── utils/              # Utility functions
└── docs/                   # Documentation
```

## Getting Started
### Prerequisites
1. Firebase account and configuration
2. Google Calendar API access
3. Python 3.8+
4. Flutter SDK

### Google Calendar Integration
The system uses a dedicated Google Calendar account for managing logistics schedules. Contact the system administrator for access credentials. **Never share these credentials publicly.**

> ⚠️ **Security Note**: Calendar credentials should be stored in environment variables or secure configuration files, not in the code.

## Architecture
For detailed technical architecture, please see [ARCHITECTURE.md](./docs/ARCHITECTURE.md)
