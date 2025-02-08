from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np
import xgboost as xgb
import pandas as pd
import os
from fastapi.middleware.cors import CORSMiddleware

# Initialize FastAPI
app = FastAPI()

# Add CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (change for production)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Get the current directory
current_dir = os.path.dirname(os.path.abspath(__file__))

# Load encoder and scaler
encoder = joblib.load(os.path.join(current_dir, "encoder.pkl"))
scaler = joblib.load(os.path.join(current_dir, "scaler.pkl"))

# Load all models
output_labels = ["Delivery Delay", "Accident Occurred", "Damaged Product", "Breakdown Occurred"]
models = {}

for label in output_labels:
    model_path = os.path.join(current_dir, f"xgb_{label}.h5")
    model = xgb.Booster()
    model.load_model(model_path)
    models[label] = model  # Store model in dictionary

# Define request schema
class InputData(BaseModel):
    Weather_Condition: str
    Distance_km: float
    Traffic_Level: str
    Vehicle_Type: str
    Driver_Experience_years: int
    Goods_Type: str
    Loading_Weight_kg: float
    Year_of_Vehicle: int

@app.post("/predict/")
async def predict(data: InputData):
    try:
        # Convert input data into DataFrame
        input_data = pd.DataFrame([{
            "Weather Condition": data.Weather_Condition,
            "Distance (km)": data.Distance_km,
            "Traffic Level": data.Traffic_Level,
            "Vehicle Type": data.Vehicle_Type,
            "Driver Experience (years)": data.Driver_Experience_years,
            "Goods Type": data.Goods_Type,
            "Loading Weight (kg)": data.Loading_Weight_kg,
            "Year of Vehicle": data.Year_of_Vehicle
        }])

        # Encode categorical data and scale numerical data
        X_categorical = encoder.transform(input_data[["Weather Condition", "Traffic Level", "Vehicle Type", "Goods Type"]])
        X_numerical = scaler.transform(input_data[["Distance (km)", "Driver Experience (years)", "Loading Weight (kg)", "Year of Vehicle"]])
        X = np.hstack((X_categorical, X_numerical))

        # Convert to DMatrix format for XGBoost
        dmatrix = xgb.DMatrix(X)

        # Predict for all labels
        predictions = {}
        for label, model in models.items():
            pred = model.predict(dmatrix)
            predictions[label.replace(" ", "_")] = int(pred[0] > 0.5)  # Convert to 0 or 1

        return predictions

    except Exception as e:
        return {"error": str(e)}

# Run the FastAPI app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
