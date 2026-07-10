import os
import sys
import json
import pickle
import numpy as np
import lightgbm as lgb

def predict(input_data):
    """
    Inputs: dict containing current weather parameters:
    {
        'temp': float,
        'feels_like': float,
        'pressure': float,
        'humidity': float,
        'dew_point': float,
        'clouds': float,
        'wind_speed': float
    }
    Outputs: JSON with prediction probability
    """
    model_path = "ml/models/weather_model.txt"
    scaler_path = "ml/models/scaler.pkl"
    
    if not os.path.exists(model_path) or not os.path.exists(scaler_path):
        # Fallback heuristic if ML pipeline isn't fully trained/ready
        h = input_data.get('humidity', 50.0) / 100.0
        c = input_data.get('clouds', 50.0) / 100.0
        fallback_prob = (h * 0.6 + c * 0.4) * 100.0
        return {
            'status': 'fallback',
            'rain_probability': round(fallback_prob, 2),
            'prediction_engine': 'heuristic_fallback'
        }
        
    try:
        # Load assets
        model = lgb.Booster(model_file=model_path)
        with open(scaler_path, 'rb') as f:
            scaler = pickle.load(f)
            
        features = [
            input_data.get('temp', 15.0),
            input_data.get('feels_like', 15.0),
            input_data.get('pressure', 1013.0),
            input_data.get('humidity', 60.0),
            input_data.get('dew_point', 10.0),
            input_data.get('clouds', 40.0),
            input_data.get('wind_speed', 3.0)
        ]
        
        # Scale and predict
        features_arr = np.array([features])
        scaled_features = scaler.transform(features_arr)
        
        pred_prob = model.predict(scaled_features)[0]
        
        return {
            'status': 'success',
            'rain_probability': round(float(pred_prob) * 100.0, 2),
            'prediction_engine': 'LightGBM'
        }
    except Exception as e:
        return {
            'status': 'error',
            'error_message': str(e),
            'rain_probability': 0.0
        }

if __name__ == "__main__":
    # Expects single CLI argument containing JSON weather data
    if len(sys.argv) < 2:
        print(json.dumps({'status': 'error', 'error_message': 'No input JSON provided'}))
        sys.exit(1)
        
    try:
        input_json = json.loads(sys.argv[1])
        result = predict(input_json)
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({'status': 'error', 'error_message': f'Invalid arguments/input: {str(e)}'}))
