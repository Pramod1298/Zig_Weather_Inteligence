import os
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import lightgbm as lgb
import pickle

# Load dataset
def load_and_preprocess_data(csv_path="ml/historical_weather.csv"):
    if not os.path.exists(csv_path):
        # Generate synthetic fallback data if pipeline hasn't been run
        print(f"Data file {csv_path} not found. Generating synthetic weather dataset for development...")
        generate_synthetic_data(csv_path)
        
    df = pd.read_csv(csv_path)
    
    # Feature engineering: target is predicting rain next hour (rain_1h > 0)
    # Target label: 1 if rain in next hour, 0 otherwise
    df['target'] = (df['rain_1h'].shift(-1) > 0.1).astype(int)
    
    # Drop the last row as it won't have a target
    df = df.dropna()
    df = df.iloc[:-1]
    
    # Select features
    feature_cols = ['temp', 'feels_like', 'pressure', 'humidity', 'dew_point', 'clouds', 'wind_speed']
    X = df[feature_cols]
    y = df['target']
    
    return X, y, feature_cols

def generate_synthetic_data(csv_path):
    """Generates synthetic dataset for development / testing without live keys"""
    np.random.seed(42)
    n_samples = 1000
    
    temps = np.random.normal(15, 8, n_samples)
    humidities = np.random.uniform(30, 95, n_samples)
    pressures = np.random.normal(1013, 10, n_samples)
    clouds = np.random.uniform(0, 100, n_samples)
    wind_speeds = np.random.uniform(0, 15, n_samples)
    
    # Correlation logic for rain
    rain_val = []
    for t, h, p, c in zip(temps, humidities, pressures, clouds):
        prob = (h / 100.0) * 0.5 + (c / 100.0) * 0.4 + ((1013 - p) / 30.0) * 0.1
        if prob > 0.6 and np.random.rand() > 0.3:
            rain_val.append(np.random.exponential(2.0))
        else:
            rain_val.append(0.0)
            
    df = pd.DataFrame({
        'dt': range(n_samples),
        'temp': temps,
        'feels_like': temps + np.random.normal(0, 2, n_samples),
        'pressure': pressures,
        'humidity': humidities,
        'dew_point': temps - ((100 - humidities)/5),
        'clouds': clouds,
        'wind_speed': wind_speeds,
        'wind_deg': np.random.uniform(0, 360, n_samples),
        'weather_id': [800 if r == 0 else 500 for r in rain_val],
        'weather_main': ['Clear' if r == 0 else 'Rain' for r in rain_val],
        'weather_desc': ['clear sky' if r == 0 else 'light rain' for r in rain_val],
        'rain_1h': rain_val,
        'snow_1h': [0.0] * n_samples
    })
    
    os.makedirs(os.path.dirname(csv_path), exist_ok=True)
    df.to_csv(csv_path, index=False)
    print(f"Generated {n_samples} synthetic rows at {csv_path}")

def train_model():
    X, y, feature_cols = load_and_preprocess_data()
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Scaling
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Save scaler for prediction inference
    os.makedirs("ml/models", exist_ok=True)
    with open("ml/models/scaler.pkl", "wb") as f:
        pickle.dump(scaler, f)
        
    # LightGBM Dataset
    train_data = lgb.Dataset(X_train_scaled, label=y_train)
    test_data = lgb.Dataset(X_test_scaled, label=y_test, reference=train_data)
    
    params = {
        'objective': 'binary',
        'metric': 'binary_logloss',
        'boosting_type': 'gbdt',
        'learning_rate': 0.05,
        'num_leaves': 15,
        'verbose': -1
    }
    
    print("Training LightGBM weather prediction model...")
    model = lgb.train(
        params,
        train_data,
        num_boost_round=100,
        valid_sets=[test_data]
    )
    
    # Save standard model
    model.save_model("ml/models/weather_model.txt")
    print("Model saved to ml/models/weather_model.txt")
    
    # Save features list
    with open("ml/models/features.txt", "w") as f:
        f.write("\n".join(feature_cols))

if __name__ == "__main__":
    train_model()
