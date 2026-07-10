import os
import time
import requests
import pandas as pd
from dotenv import load_dotenv

# Load environmental variables from .env in the parent directory
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../.env'))

API_KEY = os.getenv("OPENWEATHER_API_KEY")
BASE_URL = "http://api.openweathermap.org/data/2.5/onecall/timemachine"

def fetch_historical_day(lat, lon, dt):
    """
    Fetches hourly historical weather data for a specific timestamp (dt is Unix time)
    """
    params = {
        'lat': lat,
        'lon': lon,
        'dt': dt,
        'appid': API_KEY,
        'units': 'metric'
    }
    
    try:
        response = requests.get(BASE_URL, params=params)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error fetching data for timestamp {dt}: HTTP {response.status_code}")
            return None
    except Exception as e:
        print(f"Connection error: {e}")
        return None

def parse_day_data(day_json):
    """Parses raw JSON from historical query into a list of dictionaries (hourly data)"""
    if not day_json or 'hourly' not in day_json:
        if 'data' in day_json:
            return day_json['data']
        return []
    
    hourly_records = []
    for hour in day_json.get('hourly', []):
        record = {
            'dt': hour.get('dt'),
            'temp': hour.get('temp'),
            'feels_like': hour.get('feels_like'),
            'pressure': hour.get('pressure'),
            'humidity': hour.get('humidity'),
            'dew_point': hour.get('dew_point'),
            'clouds': hour.get('clouds'),
            'wind_speed': hour.get('wind_speed'),
            'wind_deg': hour.get('wind_deg'),
            'weather_id': hour.get('weather', [{}])[0].get('id'),
            'weather_main': hour.get('weather', [{}])[0].get('main'),
            'weather_desc': hour.get('weather', [{}])[0].get('description'),
        }
        
        # Optional fields
        if 'rain' in hour:
            record['rain_1h'] = hour['rain'].get('1h', 0.0)
        else:
            record['rain_1h'] = 0.0
            
        if 'snow' in hour:
            record['snow_1h'] = hour['snow'].get('1h', 0.0)
        else:
            record['snow_1h'] = 0.0
            
        hourly_records.append(record)
        
    return hourly_records

def collect_historical_dataset(lat, lon, days_back=30, output_file="ml/historical_weather.csv"):
    """Collects historical data from past days and saves to CSV"""
    if not API_KEY:
        print("Error: OPENWEATHER_API_KEY is not defined in environment or .env file.")
        return
    
    print(f"Starting historical data pipeline for coords: {lat}, {lon}")
    all_records = []
    
    current_time = int(time.time())
    seconds_in_day = 86400
    
    for i in range(1, days_back + 1):
        target_dt = current_time - (i * seconds_in_day)
        print(f"Fetching data for {days_back - i + 1} days ago (timestamp: {target_dt})...")
        
        day_data = fetch_historical_day(lat, lon, target_dt)
        if day_data:
            hourly = parse_day_data(day_data)
            all_records.extend(hourly)
            print(f"  Collected {len(hourly)} hourly records.")
        
        # Rate limit safety
        time.sleep(1.0)
        
    if all_records:
        df = pd.DataFrame(all_records)
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        df.to_csv(output_file, index=False)
        print(f"Successfully saved {len(df)} records to {output_file}")
    else:
        print("No historical records collected.")

if __name__ == "__main__":
    # Default coordinates: Seattle (47.6062, -122.3321)
    collect_historical_dataset(47.6062, -122.3321, days_back=14)
