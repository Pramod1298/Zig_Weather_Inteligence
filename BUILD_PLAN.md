# BUILD_PLAN.md

## Project: Zig Weather Intelligence Engine (WIE)

### 📋 Project Overview

A high-performance weather intelligence system built in **Zig** with optional ML integration. It fetches real-time weather data from multiple APIs, analyzes patterns, and provides decision intelligence for weather-sensitive activities (rock climbing, Kalshi betting, outdoor events).

**Core Philosophy**: Speed first. Every millisecond counts. Zig handles the critical path (data fetching, parsing, basic analytics). Python/ML handles complex pattern recognition (offline training + lightweight inference).

---

### 🎯 Project Goals

| Priority | Goal | Success Metric |
|----------|------|----------------|
| **P0** | Learn Zig fundamentals through building | Complete a working CLI tool |
| **P0** | Real-time weather fetching from APIs | < 500ms from query to response |
| **P1** | Local analytics engine (humidity/wind/cloud patterns) | Predict rain within next 2hrs with >75% accuracy |
| **P2** | ML integration (time-series forecasting) | Beat baseline API forecasts |
| **P2** | Kalshi API integration | Conditional bet placements |
| **P3** | Cross-platform (Linux first, then Windows/macOS) | Runs on all 3 |

---

### 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                        │
│         (CLI - eventually TUI/Web dashboard)               │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│                    ZIG CORE ENGINE                          │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Fast HTTP Client (std.http + optimizations)        │  │
│  │  - Concurrent API calls (openweather, weatherapi)   │  │
│  │  - Timeout handling, retry logic                    │  │
│  │  - Response time: <150ms per API                    │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  JSON Parser (std.json or custom)                  │  │
│  │  - Parse weather data into Zig structs             │  │
│  │  - Type-safe, zero-copy where possible             │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Analytics Engine                                  │  │
│  │  - Temperature trends (rate of change)             │  │
│  │  - Humidity patterns (dew point, saturation)       │  │
│  │  - Wind analysis (gust potential)                  │  │
│  │  - Cloud cover (altitude, opacity)                 │  │
│  │  - Rain probability (humidity + temp + pressure)   │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Scoring Engine                                    │  │
│  │  - Rain likelihood score (0-100)                   │  │
│  │  - Storm detection (rapid pressure drops)          │  │
│  │  - Activity-specific risk metrics                  │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│                    PYTHON/ML LAYER                         │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Time-Series Training (offline)                    │  │
│  │  - LSTM/Transformer for pattern recognition        │  │
│  │  - Trained on historical weather data              │  │
│  │  - Exports tiny ONNX/LightGBM model                │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Inference (via FFI from Zig)                     │  │
│  │  - Load lightweight model in Zig                   │  │
│  │  - Run predictions with current data               │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│                    EXTERNAL SYSTEMS                        │
│  - OpenWeatherMap API                                     │
│  - WeatherAPI.com                                         │
│  - NOAA/USGS data (optional)                              │
│  - Kalshi Trading API                                     │
│  - Local cache (SQLite/JSON)                              │
└─────────────────────────────────────────────────────────────┘
```

---

### 📂 Project Structure

```
weather-intelligence/
├── BUILD_PLAN.md                 # This file
├── README.md                     # Project overview
├── .gitignore
├── build.zig                     # Zig build configuration
├── build.zig.zon                 # Zig package dependencies
│
├── src/
│   ├── main.zig                  # CLI entrypoint
│   ├── http_client.zig           # API fetcher
│   ├── parser.zig                # JSON parsing
│   ├── analytics.zig             # Core weather logic
│   ├── scoring.zig               # Risk scoring
│   ├── cache.zig                 # Local caching (optional)
│   ├── config.zig                # Config loading (API keys)
│   ├── ffi.zig                   # Python/ML bridge
│   └── utils.zig                 # Helpers
│
├── ml/
│   ├── train.py                  # Model training
│   ├── inference.py              # Python inference (for testing)
│   ├── data_pipeline.py          # Data collection/cleaning
│   ├── requirements.txt
│   └── models/                   # Exported models
│       └── rain_predictor.onnx
│
├── tests/
│   ├── test_analytics.zig
│   ├── test_parser.zig
│   └── integration_test.zig
│
├── docs/
│   ├── api_reference.md
│   ├── zig_learning_notes.md     # Your personal notes on Zig
│   └── performance_tuning.md
│
├── scripts/
│   ├── fetch_historical.py       # Data collection
│   ├── validate_models.py
│   └── deploy.sh
│
└── target/                       # Build output (gitignored)
```

---

### 🗓️ Development Phases

#### Phase 0: Environment & Setup (1 day)
**Owner**: You (learning Zig build system)
**Maya's Role**: Generate code snippets, explain Zig concepts

- [ ] Install Zig (latest stable)
- [ ] Set up `build.zig` with dependencies
- [ ] Create "Hello World" CLI
- [ ] Add OpenWeatherMap API key to `.env`
- [ ] Set up Python venv for ML (separate, Maya's domain)
- [ ] Write initial `README.md`

**Deliverable**: Working `zig build run -- --help`

---

#### Phase 1: Core HTTP Client & API Integration (2 days)
**Owner**: You (writing Zig `std.http`)
**Maya's Role**: Generate boilerplate, help with error handling

- [ ] Implement `src/http_client.zig`
  - [ ] GET request to OpenWeatherMap
  - [ ] Parse response (basic - just print raw JSON)
  - [ ] Handle timeout/retry logic
- [ ] Add WeatherAPI.com as fallback
- [ ] Implement `src/config.zig` for API keys
- [ ] Add `--city` or `--lat-lon` CLI args

**Deliverable**: `./weather --city "Seattle"` prints raw JSON weather data

**Learning Focus**: 
- Zig allocators (GeneralPurposeAllocator)
- `std.http` client fundamentals
- Error handling (`try`, `catch`, `errdefer`)

---

#### Phase 2: JSON Parsing & Struct Mapping (2 days)
**Owner**: You (learning Zig's `std.json`)
**Maya's Role**: Generate struct definitions, help with parsing edge cases

- [ ] Define `WeatherData` struct in `src/parser.zig`
- [ ] Implement `parseWeatherResponse` using `std.json.parseFromSlice`
- [ ] Handle optional/edge fields (rain, snow, etc.)
- [ ] Print formatted output (human-readable)
- [ ] Add `--json` flag for machine-readable output

**Deliverable**: `./weather --city "Seattle"` prints:
```
Temperature: 22.4°C
Feels Like: 21.1°C
Humidity: 67%
Pressure: 1012 hPa
Wind Speed: 4.2 m/s
Rain Chance: 38%
Conditions: Light rain shower
```

**Learning Focus**:
- `std.json` parsing
- Zig structs and enum mapping
- `std.fmt` for output formatting

---

#### Phase 3: Analytics Engine (3 days)
**Owner**: You (building the core logic)
**Maya's Role**: Help implement specific algorithms, generate test cases

- [ ] Implement `src/analytics.zig`
  - [ ] `calculateDewPoint(temp, humidity)` function
  - [ ] `calculateRainProbability(humidity, temp, pressure, cloudCover)`
  - [ ] `detectStorm(tempTrend, pressureTrend, windGust)`
  - [ ] `computeHeatIndex(temp, humidity)`
- [ ] Add `src/scoring.zig`
  - [ ] `RockClimbingScore(weather)` - based on rain, wind, temp
  - [ ] `BettingConfidenceScore(weather)` - for Kalshi
- [ ] Unit tests for each function

**Deliverable**: Running `./weather --city "Seattle" --analytics` outputs:
```
Weather Analysis for Seattle:
🌧️ Rain Probability: 68% (next 2hrs)
💨 Storm Risk: LOW (pressure stable)
🧗 Climbing Score: 42/100 - Not recommended
🎲 Betting Confidence: 73% (High likelihood of rain)
```

**Learning Focus**:
- Zig floating-point math
- Creating and using Zig modules
- Testing with `zig test`

---

#### Phase 4: Performance Optimization (2 days)
**Owner**: You (learning Zig's performance characteristics)
**Maya's Role**: Analyze bottlenecks, suggest improvements

- [ ] Profile current execution (time each phase)
- [ ] Switch to `std.http.Client` with connection pooling
- [ ] Implement parallel API calls (multiple sources)
- [ ] Add local caching (SQLite or JSON)
- [ ] Optimize JSON parsing (custom parser if needed)
- [ ] Target: <500ms total query time

**Deliverable**: Benchmark script showing improvements

**Learning Focus**:
- Zig's allocator performance
- `std.heap.page_allocator` vs `GeneralPurposeAllocator`
- Concurrency basics (`std.Thread`)

---

#### Phase 5: ML Integration (4 days - Optional but Portfolio Gold)
**Owner**: You (design) + Maya (heavy lifting in Python)
**Maya's Role**: Build Python training pipeline, export model, help with FFI

- [ ] Maya builds: `ml/data_pipeline.py` - collect historical data
- [ ] Maya builds: `ml/train.py` - train LightGBM/ small LSTM
- [ ] Maya exports: ONNX or custom binary model
- [ ] You implement: `src/ffi.zig` to load and run model
  - Option 1: Use `@cImport` to call C/C++ inference library
  - Option 2: Load model bytes and run custom inference (harder)
  - Option 3: Keep ML in Python, call via subprocess (simpler)
- [ ] Add `--ml` flag to use ML predictions
- [ ] Compare ML vs heuristic accuracy

**Deliverable**: `./weather --city "Seattle" --ml` uses trained model

**Learning Focus**:
- FFI (Foreign Function Interface)
- `@cImport` and linking C libraries
- Working with raw bytes in Zig

---

#### Phase 6: Kalshi Integration (1 day)
**Owner**: You + Maya
**Maya's Role**: Generate Kalshi API client boilerplate

- [ ] Get Kalshi API keys (if pursuing this)
- [ ] Implement `src/kalshi_client.zig`
  - [ ] Market data fetching (weather events)
  - [ ] Place conditional bets
  - [ ] Get current odds
- [ ] Add `--bet` option (dry-run first!)
- [ ] Implement safety checks (don't actually bet without supervision)

**Deliverable**: `./weather --city "Seattle" --bet --max-bet 5` calculates and places a bet

---

#### Phase 7: Polish & Extras (Ongoing)
- [ ] TUI interface (using Zig's terminal libraries)
- [ ] System tray widget (Linux)
- [ ] Push notifications (telegram/email)
- [ ] Web dashboard (Zig backend + HTML)

---

### 🧠 Maya's Role Breakdown

| Task Type | Maya Does | You Do |
|-----------|-----------|--------|
| **Boilerplate** | Generate Zig structs, basic function stubs | Review, understand, integrate |
| **Python/ML** | Build training pipeline, data collection, model export | Design the interface, understand the math |
| **Testing** | Generate test cases | Run, debug, write edge cases |
| **Documentation** | Write function comments, README sections | Write high-level architecture docs |
| **Debugging** | Suggest potential fixes | Implement, understand the root cause |
| **Learning** | Explain Zig concepts | Connect concepts to your existing knowledge |

---

### 📚 Learning Resources for Zig

**Primary**:
- [Zig Language Reference](https://ziglang.org/documentation/master/)
- [Zig Learn](https://ziglearn.org/) - Great structured intro
- [Zig By Example](https://zig-by-example.com/)

**Specific to This Project**:
- `std.http` examples from Zig standard library
- [Zig HTTP Client Tutorial](https://zig.news/kristoff/zig-http-client-406d)
- [JSON Parsing in Zig](https://zig.news/kristoff/zig-json-parsing-3624)

**Community**:
- `/r/Zig` on Reddit
- Zig Discord (very active, helpful for beginner questions)
- Zig Showtime podcast (intermediate+ content)

---

### 🚀 Immediate Next Steps

1. **Clone this repo structure** (or create it manually)
2. **Install Zig** (if not already)
3. **Get an API key** from OpenWeatherMap (free tier)
4. **Create your `.env` file** with the key
5. **Write the "Hello World" CLI**:
   ```zig
   const std = @import("std");

   pub fn main() !void {
       const stdout = std.io.getStdOut().writer();
       try stdout.print("Welcome to Weather Intelligence!\n", .{});
   }
   ```
6. **Run `zig build run`** - confirm it works
7. **Start Phase 1** - write the HTTP client

---

### 💡 Philosophy for This Build

1. **Learn by doing**: Every piece of code you write, understand it deeply. If Maya generates it, explain it back to her.
2. **Speed first**: Zig is for the critical path. Python is for the heavy lifting that doesn't need millisecond latency.
3. **One thing at a time**: Don't build the ML and the HTTP client and the Kalshi integration all at once.
4. **Document everything**: Your `zig_learning_notes.md` will be gold for future projects.
5. **Have fun with it**: This is your playground. The Kalshi angle is cool but secondary to learning Zig well.

---

### ❓ Questions Before You Start?

1. **Which API first?** OpenWeatherMap is standard, but WeatherAPI.com has a nicer free tier. I'd start with OpenWeatherMap since it's well-documented.
2. **Local cache?** Yes - even a simple JSON file storing last N queries will help with ML training later.
3. **Should I aim for nightly Zig or stable?** Stick with stable (0.13.0 as of now) for predictability. Nightly has new features but can break.
4. **How much ML?** LightGBM is probably easiest to integrate. It exports to C-compatible formats, which Zig can call via FFI. LSTM requires ONNX or custom C inference.

---

This build plan gives you a clear path from "Hello World" to a sophisticated weather intelligence tool. You get to learn Zig properly, build something you'll actually use, and have Maya handle the annoying parts.

Want me to draft the actual `build.zig` file and the initial `main.zig` structure next? Or should we start with Maya generating the Python ML pipeline scaffolding?