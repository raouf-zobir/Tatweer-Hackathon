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
    allow_origins=["*"],  # In production, replace with specific origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Get the current directory
current_dir = os.path.dirname(os.path.abspath(__file__))

# Load encoder, scaler, and model
encoder = joblib.load(os.path.join(current_dir, "encoder.pkl"))
scaler = joblib.load(os.path.join(current_dir, "scaler.pkl"))
model = xgb.Booster()
model.load_model(os.path.join(current_dir, "xgb_Delivery Delay.h5"))

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
        X_numerical = scaler.transinform(input_data[["Distance (km)", "Driver Experience (years)", "Loading Weight (kg)", "Year of Vehicle"]])
        X = np.hstack((X_categorical, X_numerical))

        # Make predictions
        dmatrix = xgb.DMatrix(X)
        prediction = model.predict(dmatrix)
        result = {"Delivery_Delay": int(prediction[0] > 0.5)}

        return result

    except Exception as e:
        return {"error": str(e)}

@app.post("/predict_commands/")
async def predict_commands(data: dict):
    try:
        # Example response - replace with actual ML model prediction
        # This is a placeholder that returns a random number between 10 and 100
        import random
        predicted_commands = random.randint(10, 100)
        return {"predicted_commands": predicted_commands}
    except Exception as e:
        return {"error": str(e)}

# Run the FastAPI app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
