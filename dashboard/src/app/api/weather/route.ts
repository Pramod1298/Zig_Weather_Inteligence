import { NextResponse } from 'next/server';
import { exec } from 'child_process';
import { promisify } from 'util';
import path from 'path';
import fs from 'fs';
import { readFileSync } from 'fs';

const execAsync = promisify(exec);

// Load API key from .env
function getApiKey(): string {
  try {
    // Try to read from .env in Zig project directory
    const envPath = '/home/jonathon/gemini-jules/maya/Development/Zig_Weather_Inteligence/.env';
    if (fs.existsSync(envPath)) {
      const content = readFileSync(envPath, 'utf-8');
      const match = content.match(/OPENWEATHER_API_KEY\s*=\s*(.+)/);
      if (match) {
        return match[1].trim().replace(/["']/g, '');
      }
    }
  } catch (e) {
    console.error('Failed to read .env:', e);
  }
  // Fallback to environment variable
  return process.env.OPENWEATHER_API_KEY || '';
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const city = searchParams.get('city') || 'Seattle';
  const useML = searchParams.get('ml') === 'true';

  try {
    // Get API key
    const apiKey = getApiKey();
    if (!apiKey) {
      return NextResponse.json(
        { error: 'OPENWEATHER_API_KEY not configured' },
        { status: 500 }
      );
    }

    // Use the absolute path to the Zig binary
    const zigPath = path.resolve(
      process.env.HOME || '',
      'gemini-jules/maya/Development/Zig_Weather_Inteligence/zig-out/bin/weather-intel'
    );

    if (!fs.existsSync(zigPath)) {
      console.error(`Zig binary not found at: ${zigPath}`);
      return NextResponse.json(
        { error: 'Zig binary not found. Please build the Zig project first.' },
        { status: 500 }
      );
    }

    console.log(`Using Zig binary at: ${zigPath}`);

    // Call Zig CLI with --json flag, passing API key via environment
    const { stdout, stderr } = await execAsync(
      `"${zigPath}" --json --city "${city}"`,
      { 
        timeout: 15000,
        maxBuffer: 1024 * 1024 * 10,
        env: {
          ...process.env,
          OPENWEATHER_API_KEY: apiKey,
          PWD: '/home/jonathon/gemini-jules/maya/Development/Zig_Weather_Inteligence'
        }
      }
    );

    if (stderr && !stderr.includes('warning')) {
      console.error('Zig stderr:', stderr);
      return NextResponse.json({ error: stderr }, { status: 500 });
    }

    // Parse the JSON response
    let weatherData;
    try {
      weatherData = JSON.parse(stdout);
    } catch (parseError) {
      console.error('Failed to parse JSON:', stdout);
      return NextResponse.json(
        { error: 'Invalid JSON response from Zig binary' },
        { status: 500 }
      );
    }

    // Transform to match frontend expected format
    const transformedData = {
      temp: weatherData.main?.temp || weatherData.temp || 0,
      feels_like: weatherData.main?.feels_like || weatherData.feels_like || 0,
      humidity: weatherData.main?.humidity || weatherData.humidity || 0,
      pressure: weatherData.main?.pressure || weatherData.pressure || 0,
      wind_speed: weatherData.wind?.speed || weatherData.wind_speed || 0,
      cloud_cover: weatherData.clouds?.all || weatherData.cloud_cover || 0,
      condition: weatherData.weather?.[0]?.description || weatherData.condition || 'unknown',
      name: weatherData.name || city,
    };

    // If ML requested, call Python predict.py
    if (useML) {
      try {
        const mlInput = {
          temp: transformedData.temp,
          feels_like: transformedData.feels_like,
          pressure: transformedData.pressure,
          humidity: transformedData.humidity,
          dew_point: transformedData.temp - ((100 - transformedData.humidity) / 5),
          clouds: transformedData.cloud_cover,
          wind_speed: transformedData.wind_speed,
        };
        
        const mlPath = path.resolve(
          process.env.HOME || '',
          'gemini-jules/maya/Development/Zig_Weather_Inteligence/ml/predict.py'
        );

        if (fs.existsSync(mlPath)) {
          const mlResult = await execAsync(
            `python3 "${mlPath}" '${JSON.stringify(mlInput)}'`,
            { timeout: 5000 }
          );
          
          try {
            const prediction = JSON.parse(mlResult.stdout);
            transformedData.ml = {
              status: prediction.status || 'success',
              rain_probability: prediction.rain_probability || 0,
              prediction_engine: prediction.prediction_engine || 'LightGBM',
            };
          } catch (parseError) {
            console.error('Failed to parse ML output:', parseError);
          }
        } else {
          console.warn('ML script not found at:', mlPath);
        }
      } catch (mlError) {
        console.error('ML prediction failed:', mlError);
      }
    }
    
    return NextResponse.json(transformedData);
    
  } catch (error: any) {
    console.error('API Error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to fetch weather data' },
      { status: 500 }
    );
  }
}
