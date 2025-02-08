from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
import pickle
from prophet import Prophet

# -------------------------------
# Load the pre-trained Prophet model
# -------------------------------
MODEL_FILENAME = 'prophet_model_log.pkl'
with open(MODEL_FILENAME, 'rb') as f:
    model = pickle.load(f)

# -------------------------------
# Create the Flask app
# -------------------------------
app = Flask(__name__)

@app.route('/forecast', methods=['POST'])
def forecast():
    """
    Expects a JSON payload with two lists:
    {
        "dates": ["01.01.2024", "02.01.2024", ...],
        "temperatures": [10, 12, ...]
    }
    The lists must be of the same length.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "No input data provided"}), 400

    dates = data.get("dates")
    temperatures = data.get("temperatures")
    if not dates or not temperatures:
        return jsonify({"error": "Both 'dates' and 'temperatures' must be provided"}), 400

    if len(dates) != len(temperatures):
        return jsonify({"error": "Length of 'dates' and 'temperatures' must match"}), 400

    try:
        # Convert dates from dd.mm.yyyy to datetime and create DataFrame
        df_input = pd.DataFrame({
            "ds": [pd.to_datetime(d, format='%d.%m.%Y') for d in dates],
            "temperature": temperatures
        })
    except Exception as e:
        return jsonify({"error": f"Date conversion error: {str(e)}"}), 400

    try:
        # Predict using the loaded Prophet model
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
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)
