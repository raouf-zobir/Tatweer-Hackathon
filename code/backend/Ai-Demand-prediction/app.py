import requests
import json

# URL of your Flask server
url = "http://localhost:5000/predict_demand"

# Data to send (date and temperature)
data = {
    "date": "01.01.2024",
    "temperature": 20
}

# Send a POST request
response = requests.post(url, json=data)

# Print the response
if response.status_code == 200:
    print("Prediction Result:")
    print(json.dumps(response.json(), indent=4))
else:
    print(f"Error {response.status_code}: {response.text}")
