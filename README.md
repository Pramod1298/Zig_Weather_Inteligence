#  Weather Intelligence Engine

> High-performance weather data CLI and analytics engine built in **Zig 0.13**, with a Python ML pipeline for predictive intelligence.

[![Zig](https://img.shields.io/badge/Zig-0.13.0-f7a41d?logo=zig&logoColor=white)](https://ziglang.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-Stable%20CLI-brightgreen)]()

---

## Overview

**Weather Intelligence Engine (WIE)** is a CLI tool that fetches real-time weather data from [OpenWeatherMap](https://openweathermap.org/api), analyzes it with heuristic algorithms, and provides intelligent decision support — all from the terminal in under 500ms.

Built to be genuinely useful for:
- 🧗 **Rock climbers** — go/no-go decisions based on wind, humidity, rain probability
- 🎲 **Prediction market traders** — confidence scoring for weather-event bets on [Kalshi](https://kalshi.com)
- 🌦️ **Anyone who wants** fast, intelligent, no-BS weather from the command line

---

## Features

| Feature | Status |
|---|---|
| Real-time weather fetch (OpenWeatherMap) | ✅ Complete |
| JSON & formatted CLI output | ✅ Complete |
| Weather analytics (dew point, heat index, storm risk) | ✅ Complete |
| Rock climbing score | ✅ Complete |
| Kalshi betting confidence score | ✅ Complete |
| Performance optimization (curl fallback, sub-second) | ✅ Complete |
| Python ML pipeline (LightGBM / LSTM scaffolding) | ✅ Complete |
| **Next.js Web Dashboard** | ✅ **Live & Working** |
| Train ML model on real historical data | 📋 Next |
| Kalshi API integration | 📋 Planned |
| TUI companion terminal interface | 📋 Stretch |

---

## Quick Start

### Prerequisites

- [Zig 0.13.0](https://ziglang.org/download/) (stable — do **not** use nightly)
- [OpenWeatherMap API key](https://openweathermap.org/appid) (free tier works)
- (Optional) Python 3.10+ for ML pipeline

### Install & Build

```bash
git clone <repo-url>
cd Zig_Weather_Inteligence

# Create your environment file
echo "OPENWEATHER_API_KEY=your_key_here" > .env

# Build
zig build

# Run
./zig-out/bin/weather-intel "Seattle"
```

### Or run directly

```bash
zig build run -- --city "Seattle"
zig build run -- --city "New York" --analytics
zig build run -- --city "London" --json
```

### Run the Web Dashboard

```bash
cd ../weather-dashboard
npm install
npm run dev
# Open http://localhost:3000
```

The dashboard automatically calls the Zig CLI binary and the Python ML pipeline via the Next.js API route. *Check `docs/screenshots/dashboard.png` for a preview of the live interface.*

---

## Usage

```
Weather Intelligence Engine - High-Performance Weather CLI

Usage: weather-intel [options] [city]

Options:
  -c, --city <city>         City name (e.g., "Seattle")
  -a, --analytics           Show detailed weather analysis
  -j, --json                Output raw JSON from API
  -v, --verbose             Verbose output (shows HTTP steps)
  -h, --help                Show this help

Examples:
  weather-intel "Seattle"
  weather-intel --city "New York" --analytics
  weather-intel --json --city "London"
  weather-intel -c "Tokyo" -a -v
```

### Example Output

```
┌─────────────────────────────────────────────┐
│           🌤️  CURRENT WEATHER              │
├─────────────────────────────────────────────┤
│ 🌡️  Temperature:    34.2°C /   93.6°F   │
│ 🌡️  Feels Like:    38.5°C /  101.3°F   │
│ 💧  Humidity:        49%              │
│ 📊  Pressure:      1013 hPa          │
│ 💨  Wind:           7.6 m/s           │
│ ☁️  Conditions:  overcast clouds     │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│           📊 WEATHER ANALYSIS              │
├─────────────────────────────────────────────┤
│ ☔ Rain Prob:      19.2%                  │
│ 📊 Confidence:    70.0%                  │
│ ⛈️  Storm Risk:  LOW                     │
│ 🌡️  Heat Index:    38.5°C              │
│ 🧗 ✅  Climbing:      96.7/100          │
│ 🎲 🔴  Bet Conf:     60.0%              │
└─────────────────────────────────────────────┘
```

---

## Project Architecture

```
Zig_Weather_Inteligence/
├── build.zig              # Zig build system config
├── build.zig.zon          # Package manifest (no external deps)
├── .env                   # API keys (gitignored)
│
├── src/
│   ├── main.zig           # CLI entrypoint, arg parsing, orchestration
│   ├── config.zig         # API key loading (.env + env vars)
│   ├── http_client.zig    # HTTP fetch (curl fallback for stability)
│   ├── parser.zig         # JSON → WeatherData struct mapping
│   ├── analytics.zig      # Heuristic analysis algorithms
│   └── utils.zig          # Shared helpers
│
└── ml/                    # Python ML Pipeline (Maya's domain)
    ├── requirements.txt   # Python ML dependencies
    ├── data_pipeline.py   # Historical data collection
    ├── train.py           # LightGBM training with synthetic fallback
    ├── predict.py         # JSON-based inference engine
    └── models/            # Trained models (generated)
```

### Data Flow

```
CLI Args → config.zig (load API key)
         → http_client.zig (fetch JSON via curl)
         → parser.zig (WeatherData struct)
         → analytics.zig (analysis + scores)
         → main.zig (formatted output)
```

---

## Analytics Algorithms

### Dew Point
Uses the Magnus formula approximation:
```
γ(T, RH) = ln(RH/100) + (17.62 × T) / (243.12 + T)
Td = 243.12 × γ / (17.62 - γ)
```

### Rain Probability
Heuristic model using humidity, pressure, and cloud cover:
```
P(rain) = f(humidity, pressure, cloud_cover)
```
- Humidity > 60% → increasing probability
- Pressure < 1013 hPa → increasing probability  
- Higher cloud cover → increasing probability

### Rock Climbing Score (0–100)
Penalty-based scoring:
- Rain probability > 20% → heavy penalty
- Wind > 10 m/s → moderate penalty
- Temp < 5°C or > 32°C → light penalty
- Returns 0-100 score with emoji indicator

### Betting Confidence (0–100)
Cross-references rain probability with dew point and pressure trends:
- Rain probability in 30-70% range → higher confidence
- Dew point within 3°C of temp → strong pattern
- Pressure dropping → likely storm

### Storm Risk
Four-level classification based on pressure and wind speed:
- **LOW**: pressure > 1008 hPa, wind < 10 m/s
- **MODERATE**: pressure < 1008 hPa or wind > 10 m/s
- **HIGH**: pressure < 1000 hPa and wind > 15 m/s
- **EXTREME**: pressure < 990 hPa and wind > 20 m/s

---

## ML Pipeline (Ready)

The Python ML layer runs separately from the Zig core and is designed for easy integration.

**Stack:**
- `LightGBM` — gradient boosting, fast training, C-compatible export
- `pandas` / `numpy` — data processing
- `scikit-learn` — preprocessing (StandardScaler)
- Historical data from OpenWeatherMap Timemachine API

**Usage (once trained):**
```bash
cd ml
python3 data_pipeline.py           # Collect historical data
python3 train.py                   # Train the model
python3 predict.py '{"temp":25,"humidity":70,...}'  # Test prediction
```

**Integration (planned):**
```bash
weather-intel --city "Seattle" --ml  # Uses ML prediction
```

---

## Configuration

### `.env` file (preferred)
```env
OPENWEATHER_API_KEY=your_key_here
```

### Environment variable (fallback)
```bash
export OPENWEATHER_API_KEY=your_key_here
```

The config loader checks `.env` first, then falls back to the shell environment.

---

## Build Commands

```bash
zig build                                    # Compile the project
zig build run                                # Build + run
zig build run -- --city "Denver" --analytics # Run with args
zig build test                               # Run unit tests
zig build docs                               # Generate HTML docs → zig-out/docs/html/
zig build -Doptimize=ReleaseFast             # Optimized release build
```

---

## Development Roadmap

| Phase | Description | Owner | Status |
|---|---|---|---|
| **1** | HTTP client + raw JSON output | Jonathon | ✅ Done |
| **2** | JSON parsing + formatted display | Jonathon | ✅ Done |
| **3** | Analytics engine (dew point, storm risk, scoring) | Jonathon + Maya | ✅ Done |
| **4** | Performance optimization (curl fallback, sub-second) | Jonathon | ✅ Done |
| **5** | Python ML pipeline scaffolding | **Maya** | ✅ Done |
| **6** | Next.js Web Dashboard + ML toggle | Jonathon + Maya | ✅ **Live** |
| **7** | Train ML on real historical data | Maya | 📋 Next |
| **8** | Kalshi API integration | Jonathon + Maya | 📋 Planned |
| **9** | TUI companion + notifications | Jonathon + Maya | 📋 Stretch |

---

## Key Zig Concepts Used

| Concept | Where | Why |
|---|---|---|
| `GeneralPurposeAllocator` | `main.zig` | Safe heap allocator with leak detection |
| `var` vs `const` | `main.zig` | Zig's const-correctness for deinit() methods |
| `defer` | Throughout | Guaranteed cleanup on error paths |
| `std.json.parseFromSlice` | `parser.zig` | Built-in JSON parsing with `ArrayList.items` |
| `.items[0]` vs `[0]` | `parser.zig` | ArrayList indexing in Zig's JSON API |
| `{d:6.1}` format | `main.zig` | Zig format specifiers (no 'f' suffix) |
| `curl` fallback | `http_client.zig` | Reliable HTTP fetching when stdlib panics |

---

## Debugging & Memory Leak Detection

The project uses `GeneralPurposeAllocator` which automatically detects memory leaks:

```bash
# Build with leak detection enabled (default in debug mode)
zig build

# Run and check for leaks
./zig-out/bin/weather-intel "Austin"

# Should show NO "error(gpa): memory address leaked" messages
```

---

## Known Issues

| Issue | Status | Workaround |
|---|---|---|
| Native Zig HTTP client panics | ⚠️ Known | Using `curl` fallback |
| Python ML not yet integrated | ⏳ Planned | Will add `--ml` flag |

---

## Contributing

Contributions welcome! Open issues or submit PRs.

**Team:**
- **Jonathon** — Zig Core Engine, Architecture, Build System
- **Maya (AI Assistant)** — ML Pipeline, Documentation, Python Integration  
- **DeepSeek V4** — Systems Debugging, Zig Expertise, Architecture Guidance

---

## License

MIT — do whatever you want with it.

---

*Built with Zig 0.13 + Python · Powered by OpenWeatherMap*