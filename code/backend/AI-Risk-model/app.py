import sys
import os

# Add the virtual environment's site-packages to the Python path
venv_path = os.path.join(os.path.dirname(__file__), 'venv', 'Lib', 'site-packages')
sys.path.append(venv_path)

import requests
import json

# URL of your FastAPI server
url = "http://127.0.0.1:8000/predict/"

# Sample data to send
data = {
    "Weather_Condition": "Rainy",
    "Distance_km": 15.0,
    "Traffic_Level": "High",
    "Vehicle_Type": "Large Truck",
    "Driver_Experience_years": 5,
    "Goods_Type": "Perishable",
    "Loading_Weight_kg": 2000,
    "Year_of_Vehicle": 2015
}

# Send a POST request
response = requests.post(url, json=data)

# Print the response
if response.status_code == 200:
    print("Prediction Result:")
    print(json.dumps(response.json(), indent=4))
else:
    print(f"Error {response.status_code}: {response.text}")
