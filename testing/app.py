import requests
import json

# URL of your Flask server
url = "http://localhost:5000/forecast"

# Data to send (dates and temperatures)
# data = {
#     "dates": ["01.01.2024", "02.01.2024", "03.01.2024"],
#     "temperatures": [20, 12, 15]
# }

data = {
    "dates": ["01.01.2024"],
    "temperatures": [20]
}

# Send a POST request
response = requests.post(url, json=data)

# Print the response
if response.status_code == 200:
    print("Forecast Results:")
    print(json.dumps(response.json(), indent=4))
else:
    print(f"Error {response.status_code}: {response.text}")
