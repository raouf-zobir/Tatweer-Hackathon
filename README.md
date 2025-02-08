# Real-Time Supply Chain Monitoring and Adaptation System

## Overview
An intelligent supply chain management solution powered by LLaMA-70B that provides real-time monitoring and adaptive response to logistics challenges. The system actively monitors, detects, analyzes, and autonomously responds to supply chain disruptions while continuously learning from historical data.

![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot_33.png)
## Key Features

### Intelligent AI Agent System
- Real-time monitoring and problem detection across multiple facilities
- Autonomous analysis of logistics delays and production issues
- Proactive issue identification and impact assessment
- Smart scheduling and calendar management
- Automated stakeholder notification system
- Human-in-the-loop confirmation for critical decisions
- ## Example Operation
```
Operational Update and Issue Management Example:

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
![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot_35.png)



![Screenshot 1]((https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot%202025-02-08%20225520.png))


![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot%202025-02-08%20225431.png)

![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot%202025-02-08%20225520.png)

### Real-Time Monitoring Capabilities
- Multi-facility monitoring (Ports, Factories, Distribution Centers)
- Real-time tracking of:
  - Logistics operations
  - Production schedules
  - Delivery timelines
  - Quality control checks
- Immediate detection of delays and disruptions
- Advanced Delay Detection System:
  - Real-time GPS position tracking
  - Route analysis using OpenRouteService API
  - ETA calculations and updates
  - Automated mismatch detection between planned and actual schedules
  - Real-time delay notifications

### Adaptive Response System
- Autonomous problem analysis and solution generation
- Calendar-aware schedule optimization
- Automated email notifications to stakeholders
- Impact assessment across the supply chain
- Coordinated response planning
- 
![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot_36.png)



![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/Screenshot_37.png)

### Travel ETA Detection
- Planned and current ETAs.
- Planned arrival time.
- Time spent traveling.
- Delay analysis (planned and real-time).

## Technology Stack
- **AI Core**: LLaMA-70B for intelligent decision-making
- **Backend**: 
  - Python (AI Agents)
  - FastAPI & Flask (API Services)
- **Frontend**: Flutter/Dart Web Application
- **Database**: Firebase
- **Integration**: 
  - Google Calendar API
  - Email Service
  - IoT Data Simulation

## System Components


### Delay Detector
The system uses OpenRouteService API to:
- Calculate real-time ETAs based on current vehicle positions
- Compare actual progress against planned schedules
- Detect two types of delays:
  - **Planned Delay**: Deviation from original schedule
  - **Real-Time Delay**: Updated ETA based on current position
- Automatically trigger AI agent responses when delays are detected


# Predictive Logistics AI

This repository contains a project designed to predict key outcomes in transportation and logistics using machine learning. The model leverages features such as weather conditions, traffic levels, vehicle specifications, and driver experience to predict events like delivery delays, accidents, damaged goods, and vehicle breakdowns.

## Dataset Description

### Input Features:
1. **Weather Condition**: Weather during transit (e.g., sunny, rainy, foggy, snowy).
2. **Distance (km)**: Distance of the delivery route.
3. **Traffic Level**: Traffic conditions on the route (e.g., low, medium, high).
4. **Vehicle Type**: Type of vehicle used for the delivery (e.g., truck, van, car).
5. **Driver Experience (years)**: Years of driving experience of the driver.
6. **Goods Type**: Category of goods being transported (e.g., fragile, perishable).
7. **Loading Weight (kg)**: Weight of the goods in kilograms.
8. **Year of Vehicle**: Manufacturing year of the vehicle.

### Predicted Outcomes:
1. **Delivery Delay**: Whether the delivery is delayed.
2. **Accident Occurred**: Whether an accident occurred during the delivery.
3. **Damaged Product**: Whether the goods were damaged in transit.
4. **Breakdown Occurred**: Whether the vehicle broke down during the trip.

## Features of the Repository
- **Exploratory Data Analysis (EDA)**: Scripts to explore and visualize the dataset.
- **Predictive Models**: Machine learning models for classification and regression tasks.
- **Evaluation Metrics**: Metrics to assess the performance of the models (e.g., accuracy, precision, recall, RMSE).
- **Documentation**: Detailed notes on how to preprocess the data, train models, and interpret predictions.

![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/image2.png)


## How to Run

### Prerequisites

- Python 3.9+

- Google API credentials (for Calendar, Contacts, and Gmail access)

- Tavily API key (for web search)

- Groq API key (for Llama3)

- Google Gemini API key (for using the Gemini model)

- Deepgram API key (for voice processing)

- Necessary Python libraries (listed in `requirements.txt`)

### Setup

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



![Screenshot 1](https://github.com/raouf-zobir/Tatweer-Hackathon/blob/master/hackathon_explain.png)

