# Real-Time Supply Chain Monitoring and Adaptation System

## Overview
This project combines real-time supply chain monitoring and travel ETA (Estimated Time of Arrival) delay detection. It leverages intelligent AI-driven decision-making and real-time tracking to ensure smooth operations across logistics, production, and travel management.

### Key Features

#### Intelligent Supply Chain Monitoring
- Real-time monitoring and problem detection across multiple facilities.
- Autonomous analysis of logistics delays and production issues.
- Proactive issue identification and impact assessment.
- Smart scheduling and calendar management.
- Automated stakeholder notification system.
- Human-in-the-loop confirmation for critical decisions.

#### Real-Time Travel ETA and Delay Detection
- Calculate planned and real-time ETAs between locations.
- Detect delays compared to the planned schedule.
- Output detailed travel progress, including time spent and deviation analysis.

#### Adaptive Response System
- Autonomous problem analysis and solution generation.
- Calendar-aware schedule optimization.
- Automated email notifications to stakeholders.
- Impact assessment across the supply chain.
- Coordinated response planning.

## Example Operations

### Supply Chain Monitoring
```
1. Real-time Schedule Monitoring:
   - Quality Control Checks
   - Production Line Operations
   - Delivery Schedules
   - Container Shipments

2. Issue Detection & Analysis:
   - Port of Jeddah: Logistics Delay
   - Dammam Highway: Checkpoint Delay
   - Gigafactory ME: Production Delay
   - Food Processing: At-risk Operations

3. Autonomous Response:
   - Schedule Adjustments
   - Production Timeline Updates
   - Stakeholder Notifications
   - Resource Reallocation
```

### Travel ETA Detection
- Planned and current ETAs.
- Planned arrival time.
- Time spent traveling.
- Delay analysis (planned and real-time).

## Technology Stack
- **AI Core**: LLaMA-70B for intelligent decision-making.
- **Backend**:
  - Python (AI Agents).
  - FastAPI & Flask (API Services).
- **Frontend**: Flutter/Dart Web Application.
- **Database**: Firebase.
- **Integration**:
  - Routing API (e.g., OpenRouteService).
  - Google Calendar API.
  - Email Service.
  - IoT Data Simulation.

## Requirements
- Python 3.9+.
- Google API credentials (for Calendar, Contacts, and Gmail access).
- Tavily API key (for web search).
- Groq API key (for Llama3).
- Google Gemini API key (for using the Gemini model).
- Deepgram API key (for voice processing).
- Routing service API key (e.g., OpenRouteService).
- Necessary Python libraries (listed in `requirements.txt`).

## Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/AI-Voice-assistant.git
   cd AI-Voice-assistant
   ```

2. **Create and activate a virtual environment:**
   ```sh
   python -m venv venv
   source venv/bin/activate # On Windows use `venv\Scripts\activate`
   ```

3. **Install the required packages:**
   ```sh
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   Create a `.env` file in the root directory of the project and add your API keys:
   ```env
   GOOGLE_API_KEY=your_google_api_key
   DEEPGRAM_API_KEY=your_deepgram_api_key
   TAVILY_API_KEY=your_tavily_api_key
   GEMINI_API_KEY=your_gemini_api_key
   GROQ_API_KEY=your_groq_api_key
   ROUTING_API_KEY=your_routing_service_api_key
   ```

5. **Configure Google API credentials:**
   Follow Google's documentation to set up credentials for Calendar, Contacts, and Gmail APIs. Save the credentials file in a secure location and update the path in the configuration file.

6. **Update the code for travel management:**
   Replace placeholders with your routing service API key and coordinates for departure, current, and destination locations.

## Running the Application

1. **Start the AI agent server:**
   ```sh
   python server.py
   ```

2. **Run the travel ETA script:**
   ```sh
   python travel_eta.py
   ```

The system will:
- Monitor the supply chain in real-time.
- Detect and analyze disruptions.
- Propose solutions for issues.
- Send notifications to relevant stakeholders.
- Update schedules as needed.

You can monitor activities through:
- The Flutter web dashboard.
- Email notifications.
- Calendar updates.
- System logs.

## Usage Examples

- "Schedule a meeting with John for tomorrow at 2 PM."
- "Add a new contact: Jane Doe, phone number 555-1234."
- "What's Mary's email address?"
- "Send an email to Bob with the subject 'Project Update'."
- "Search the web for recent news about artificial intelligence."
- "Calculate ETA for the delivery from location A to location B."

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any changes.

## Contact
If you have any questions or suggestions, feel free to contact me at `aotdevimpact@gmail.com`.
