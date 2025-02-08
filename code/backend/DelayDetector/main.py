import requests
import json
import os
from datetime import datetime, timedelta

API_KEY = '5b3ce3597851110001cf6248f786fdc79a2449c1b8c4b1a8ed0369af'

# Coordinates
algiers = [3.0861, 36.7372]  # Departure
constantine = [6.6147, 36.3650]  # Real-time position
annaba = [7.7667, 36.9000]  # Destination

# OpenRouteService API URL
api_url = "https://api.openrouteservice.org/v2/directions/driving-car"

# Add this constant at the top
EVENTS_JSON_PATH = os.path.join(os.path.dirname(__file__), 'delay_events.json')

# Function to convert seconds to hours, minutes, and seconds
def format_time(seconds):
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours}h {minutes}m {secs}s"

# Function to get ETA
def get_eta(start, end):
    response = requests.post(
        api_url,
        headers={"Authorization": API_KEY, "Content-Type": "application/json"},
        json={
            "coordinates": [start, end],
            "units": "m",
            "instructions": False
        }
    )
    if response.status_code == 200:
        data = response.json()
        duration = data["routes"][0]["summary"]["duration"]  # Duration in seconds
        return duration
    else:
        print("Error:", response.status_code, response.text)
        return None

def load_existing_events():
    if os.path.exists(EVENTS_JSON_PATH):
        with open(EVENTS_JSON_PATH, 'r') as f:
            return json.load(f)
    return {}

def save_events(events):
    with open(EVENTS_JSON_PATH, 'w') as f:
        json.dump(events, f, indent=4)

# Planned departure time from Algiers
departure_time = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

# Current time
current_time = datetime.now().replace(hour=4, minute=1, second=0, microsecond=0)

# current_time = datetime.now()

# Planned ETA from Algiers to Annaba
planned_eta = get_eta(algiers, annaba)

# Current ETA from Constantine to Annaba
current_eta = get_eta(constantine, annaba)

# Detect delays
if planned_eta and current_eta:
    # Calculate the planned arrival time
    planned_arrival_time = departure_time + timedelta(seconds=planned_eta)
    
    # Calculate time spent traveling so far
    time_spent = (current_time - departure_time).total_seconds()

    # Travel time expected from Algiers to Constantine
    travel_to_constantine = planned_eta - current_eta

    # **Planned Delay**: Time deviation from the planned schedule
    planned_delay = time_spent - travel_to_constantine

    # **Real-Time Delay**: Time deviation based on current position and ETA
    real_time_delay = (time_spent + current_eta) - planned_eta

    # Output results
    print("Planned ETA:", format_time(planned_eta))
    print("Current ETA:", format_time(current_eta))
    print("Planned Arrival Time:", planned_arrival_time.strftime("%H:%M:%S"))
    print("Current Time:", current_time.strftime("%H:%M:%S"))
    print("Time Spent Traveling:", format_time(time_spent))

    # Planned delay
    if planned_delay > 0:
        print(f"Planned Delay: {format_time(planned_delay)} behind schedule.")
    else:
        print(f"On track with no planned delay.")

    # Real-time delay
    if real_time_delay > 0:
        print(f"Real-Time Delay: {format_time(real_time_delay)} behind schedule.")
    else:
        print(f"On track with no real-time delay.")
else:
    print("Failed to calculate delays.")

def get_formatted_delay_event():
    if planned_eta and current_eta:
        # Calculate delays
        planned_arrival_time = departure_time + timedelta(seconds=planned_eta)
        time_spent = (current_time - departure_time).total_seconds()
        travel_to_constantine = planned_eta - current_eta
        real_time_delay = (time_spent + current_eta) - planned_eta

        # Create unique event ID
        event_id = f"TRANSPORT_{datetime.now().strftime('%Y%m%d_%H%M')}"

        # Load existing events
        events = load_existing_events()

        # Add new event
        events[event_id] = {
            "type": "logistics",
            "status": "delayed" if real_time_delay > 0 else "on_track",
            "delay_hours": real_time_delay / 3600,
            "location": "Constantine",
            "impact": ["Annaba_Distribution", "Regional_Delivery_Network"],
            "details": f"Transport delay of {format_time(real_time_delay)} detected",
            "planned_arrival": planned_arrival_time.strftime("%H:%M:%S"),
            "current_position": "Constantine",
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }

        # Save updated events
        save_events(events)
        return events[event_id]
    return None

if __name__ == "__main__":
    delay_event = get_formatted_delay_event()
    if delay_event:
        print("New delay event detected and saved:")
        print(json.dumps(delay_event, indent=2))
    else:
        print("No delay event to report")
