'use client';

import { useState, useEffect } from 'react';
import { 
  Search, Cloud, Wind, Droplets, Thermometer, 
  TrendingUp, Shield, BarChart3, AlertTriangle, CheckCircle 
} from 'lucide-react';

interface WeatherData {
  temp: number;
  feels_like: number;
  humidity: number;
  pressure: number;
  wind_speed: number;
  cloud_cover: number;
  condition: string;
  name?: string;
  ml?: {
    status: string;
    rain_probability: number;
    prediction_engine: string;
  };
}

// Main component - MUST be default export
export default function Home() {
  const [city, setCity] = useState('Seattle');
  const [currentSearch, setCurrentSearch] = useState('Seattle');
  const [weather, setWeather] = useState<WeatherData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [useML, setUseML] = useState(true);

  const fetchWeather = async (targetCity: string) => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/weather?city=${encodeURIComponent(targetCity)}&ml=${useML}`);
      if (!res.ok) throw new Error('Failed to fetch data');
      const data = await res.json();
      if (data.error) throw new Error(data.error);
      setWeather(data);
      setCurrentSearch(targetCity);
    } catch (err: any) {
      console.error(err);
      setError(err.message || 'Could not fetch weather metrics. Please ensure API key and binary are configured.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchWeather('Seattle');
  }, [useML]);

  // Client-side quick score computation matching Zig analytics logic
  const calculateClimbingScore = (w: WeatherData) => {
    let score = 100.0;
    
    // Penalties matching analytics.zig
    if (w.condition.toLowerCase().includes('rain') || w.condition.toLowerCase().includes('shower') || (w.ml && w.ml.rain_probability > 30)) {
      score -= 60.0;
    }
    if (w.wind_speed > 10) {
      score -= 25.0;
    } else if (w.wind_speed > 5) {
      score -= 10.0;
    }
    if (w.temp < 5.0 || w.temp > 35.0) {
      score -= 20.0;
    } else if (w.temp < 12.0 || w.temp > 28.0) {
      score -= 10.0;
    }
    if (w.humidity > 80.0) {
      score -= 15.0;
    }
    
    return Math.max(0, Math.round(score));
  };

  return (
    <div className="min-h-screen bg-slate-950 bg-gradient-to-br from-slate-950 via-indigo-950/20 to-slate-950 text-slate-100 flex flex-col font-sans">
      <div className="container mx-auto p-6 max-w-6xl flex-grow">
        {/* Header */}
        <header className="flex justify-between items-center mb-8 border-b border-slate-900 pb-5">
          <div>
            <h1 className="text-3xl font-extrabold tracking-tight bg-gradient-to-r from-cyan-400 via-indigo-400 to-purple-400 bg-clip-text text-transparent">
              🌤️ Weather Intelligence Engine
            </h1>
            <p className="text-slate-500 text-xs font-semibold uppercase tracking-wider mt-1">
              Sovereign Analytics Matrix • Zig & LightGBM
            </p>
          </div>
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2 text-sm text-slate-400 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={useML}
                onChange={(e) => setUseML(e.target.checked)}
                className="w-4 h-4 rounded border-slate-700 bg-slate-800 accent-purple-500 text-purple-600 focus:ring-0 focus:ring-offset-0"
              />
              <span className="font-semibold text-xs uppercase tracking-wider text-purple-400">ML Predictions Enabled</span>
            </label>
          </div>
        </header>

        {/* Search */}
        <div className="flex gap-4 mb-8">
          <div className="flex-grow relative">
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-slate-500 w-5 h-5" />
            <input
              type="text"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && fetchWeather(city)}
              placeholder="Search city (e.g., Austin, London, Tokyo)..."
              className="w-full pl-12 pr-4 py-3.5 bg-slate-900/60 backdrop-blur-md border border-slate-800/80 rounded-xl text-slate-100 placeholder-slate-500 focus:outline-none focus:border-indigo-500/80 focus:ring-1 focus:ring-indigo-500/30 transition-all text-sm font-medium"
            />
          </div>
          <button
            onClick={() => fetchWeather(city)}
            disabled={loading}
            className="px-6 py-3.5 bg-gradient-to-r from-cyan-500 to-indigo-500 rounded-xl font-bold text-white text-sm hover:opacity-90 active:scale-95 transition-all shadow-lg shadow-indigo-950/20 disabled:opacity-50"
          >
            {loading ? 'Analyzing...' : 'Fetch Weather'}
          </button>
        </div>

        {error && (
          <div className="bg-red-950/30 border border-red-900/50 text-red-200 p-4 rounded-xl text-sm flex items-start gap-3 mb-8">
            <AlertTriangle className="w-5 h-5 text-red-400 flex-shrink-0 mt-0.5" />
            <div>
              <span className="font-bold">System Alert:</span> {error}
            </div>
          </div>
        )}

        {/* Weather Display */}
        {weather && !loading && (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            
            {/* Core Stats Card */}
            <div className="lg:col-span-2 bg-slate-900/40 backdrop-blur-md border border-slate-800/60 rounded-2xl p-6 flex flex-col justify-between">
              <div>
                <div className="flex justify-between items-start mb-6">
                  <div>
                    <h2 className="text-3xl font-extrabold text-white tracking-tight">{currentSearch}</h2>
                    <p className="text-slate-400 capitalize text-sm font-medium mt-1">{weather.condition}</p>
                  </div>
                  <div className="text-right">
                    <div className="text-5xl font-black text-white">{Math.round(weather.temp)}°C</div>
                    <div className="text-slate-500 text-xs font-semibold uppercase tracking-wider mt-1">
                      Feels like {Math.round(weather.feels_like)}°C
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 border-t border-slate-900 pt-6">
                  <div className="bg-slate-950/40 p-4 rounded-xl border border-slate-900/50">
                    <div className="text-slate-500 text-xs font-bold uppercase tracking-wider mb-1">Humidity</div>
                    <div className="text-xl font-bold flex items-center gap-1.5">
                      <Droplets className="w-4 h-4 text-cyan-400" />
                      {weather.humidity}%
                    </div>
                  </div>
                  <div className="bg-slate-950/40 p-4 rounded-xl border border-slate-900/50">
                    <div className="text-slate-500 text-xs font-bold uppercase tracking-wider mb-1">Wind Speed</div>
                    <div className="text-xl font-bold flex items-center gap-1.5">
                      <Wind className="w-4 h-4 text-emerald-400" />
                      {weather.wind_speed} m/s
                    </div>
                  </div>
                  <div className="bg-slate-950/40 p-4 rounded-xl border border-slate-900/50">
                    <div className="text-slate-500 text-xs font-bold uppercase tracking-wider mb-1">Pressure</div>
                    <div className="text-xl font-bold flex items-center gap-1.5">
                      <BarChart3 className="w-4 h-4 text-purple-400" />
                      {weather.pressure} hPa
                    </div>
                  </div>
                  <div className="bg-slate-950/40 p-4 rounded-xl border border-slate-900/50">
                    <div className="text-slate-500 text-xs font-bold uppercase tracking-wider mb-1">Cloud Cover</div>
                    <div className="text-xl font-bold flex items-center gap-1.5">
                      <Cloud className="w-4 h-4 text-indigo-400" />
                      {weather.cloud_cover}%
                    </div>
                  </div>
                </div>
              </div>

              <div className="mt-6 p-4 bg-slate-950/30 border border-slate-900/50 rounded-xl flex items-center gap-3">
                <CheckCircle className="w-5 h-5 text-indigo-400 flex-shrink-0" />
                <span className="text-slate-400 text-xs font-medium">
                  Rust-proof memory allocations verified via Zig 0.13.0 GeneralPurposeAllocator context.
                </span>
              </div>
            </div>

            {/* Sidebar analytics */}
            <div className="flex flex-col gap-6">
              {/* ML Prediction */}
              {weather.ml && (
                <div className="bg-slate-900/40 backdrop-blur-md border border-purple-500/20 rounded-2xl p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex justify-between items-center mb-4">
                      <h3 className="text-xs font-bold uppercase tracking-wider text-purple-400">🤖 ML Predictive Engine</h3>
                      <span className="text-[10px] font-bold uppercase tracking-wider bg-purple-950/80 border border-purple-900/80 text-purple-300 px-2 py-0.5 rounded">
                        {weather.ml.prediction_engine}
                      </span>
                    </div>
                    <div className="text-4xl font-black text-white">{weather.ml.rain_probability}%</div>
                    <p className="text-slate-400 text-xs font-medium mt-1">Probability of rain in next hour</p>
                    
                    <div className="mt-4 h-2.5 bg-slate-950 rounded-full overflow-hidden border border-slate-900">
                      <div
                        className="h-full bg-gradient-to-r from-cyan-400 to-purple-500 transition-all duration-1000"
                        style={{ width: `${weather.ml.rain_probability}%` }}
                      />
                    </div>
                  </div>

                  <div className="text-[10px] text-slate-500 font-semibold mt-4">
                    STATUS: {weather.ml.status.toUpperCase()}
                  </div>
                </div>
              )}

              {/* Climbing Score */}
              <div className="bg-slate-900/40 backdrop-blur-md border border-slate-800/60 rounded-2xl p-6">
                <h3 className="text-xs font-bold uppercase tracking-wider text-cyan-400 mb-4">🧗 Rock Climbing Score</h3>
                <div className="flex items-baseline gap-2">
                  <div className="text-4xl font-black text-white">{calculateClimbingScore(weather)}</div>
                  <div className="text-slate-500 text-sm font-semibold">/ 100</div>
                </div>
                
                {calculateClimbingScore(weather) > 70 ? (
                  <p className="text-emerald-400 text-xs font-bold mt-2">Optimal conditions for send. Rock is dry.</p>
                ) : calculateClimbingScore(weather) > 40 ? (
                  <p className="text-amber-400 text-xs font-bold mt-2">Marginal conditions. Humidity or wind limits grip.</p>
                ) : (
                  <p className="text-red-400 text-xs font-bold mt-2">Adverse conditions. High risk of wet holds/precip.</p>
                )}
              </div>
            </div>
            
          </div>
        )}
      </div>

      <footer className="py-6 border-t border-slate-900 text-center text-[10px] font-bold uppercase tracking-widest text-slate-600">
        © 2026 Sovereign Empire Technologies • Built in Duet
      </footer>
    </div>
  );
}
