from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import pickle
import os

# -------------------------------
# Load the pre-trained Prophet model
# -------------------------------
MODEL_FILENAME = 'C:\\Users\\Raouf\\Documents\GitHub\\Tatweer_Hackathon\\code\\backend\\Ai-Demand-prediction\\prophet_model_log.pkl'

# Check if the model file exists
if not os.path.exists(MODEL_FILENAME):
    raise FileNotFoundError(f"Model file '{MODEL_FILENAME}' not found. Please ensure it exists at the specified path.")

# Load the model
try:
    with open(MODEL_FILENAME, 'rb') as f:
        model = pickle.load(f)
except Exception as e:
    raise RuntimeError(f"Error loading model: {str(e)}")

# -------------------------------
# Create the Flask app
# -------------------------------
app = Flask(__name__)

@app.route('/', methods=['GET'])
def home():
    """
    Root endpoint for the API.
    """
    return "Welcome to the Prophet Forecast API! Use the `/forecast` endpoint to make predictions.", 200

@app.route('/forecast', methods=['POST'])
def forecast():
    """
    Forecast endpoint. Expects a JSON payload with two lists:
    {
        "dates": ["01.01.2024", "02.01.2024", ...],
        "temperatures": [10, 12, ...]
    }
    The lists must be of the same length.
    """
    # Parse the JSON payload
    data = request.get_json()
    if not data:
        return jsonify({"error": "No input data provided. Please provide 'dates' and 'temperatures' in JSON format."}), 400

    dates = data.get("dates")
    temperatures = data.get("temperatures")
    if not dates or not temperatures:
        return jsonify({"error": "Both 'dates' and 'temperatures' must be provided."}), 400

    if len(dates) != len(temperatures):
        return jsonify({"error": "Length of 'dates' and 'temperatures' must match."}), 400

    # Validate and prepare input data
    try:
        df_input = pd.DataFrame({
            "ds": [pd.to_datetime(d, format='%d.%m.%Y') for d in dates],
            "temperature": temperatures
        })
    except Exception as e:
        return jsonify({"error": f"Date conversion error: {str(e)}"}), 400

    # Make predictions using the model
    try:
        forecast_df = model.predict(df_input)
        # Inverse the log1p transformation using np.expm1 to get back to the original scale
        forecast_df['yhat_original'] = np.expm1(forecast_df['yhat'])
        forecast_df['yhat_lower_original'] = np.expm1(forecast_df['yhat_lower'])
        forecast_df['yhat_upper_original'] = np.expm1(forecast_df['yhat_upper'])
    except Exception as e:
        return jsonify({"error": f"Forecast error: {str(e)}"}), 500

    # Build the results list
    results = []
    for _, row in forecast_df.iterrows():
        results.append({
            "date": row['ds'].strftime('%d.%m.%Y'),
            "forecast": row['yhat_original'],
            "forecast_lower": row['yhat_lower_original'],
            "forecast_upper": row['yhat_upper_original']
        })

    return jsonify(results)

# -------------------------------
# Run the Flask app
# -------------------------------
if __name__ == '__main__':
    # Disable the reloader if you're running in an interactive environment.
    app.run(host='127.0.0.1', port=5000, debug=True, use_reloader=False)
