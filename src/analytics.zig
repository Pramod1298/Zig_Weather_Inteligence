const std = @import("std");
const parser = @import("parser.zig");

pub const WeatherAnalysis = struct {
    rain_probability: f64,
    rain_prediction_confidence: f64,
    storm_risk: StormRisk,
    heat_index: f64,
    climbing_score: f64,
    betting_confidence: f64,
    dew_point: f64,
    temp_trend: f64,
};

pub const StormRisk = enum {
    low,
    moderate,
    high,
    extreme,
};

pub fn analyze(weather: *const parser.WeatherData) WeatherAnalysis {
    const dew_point = calculateDewPoint(weather.temp, weather.humidity);
    const rain_prob = calculateRainProbability(weather);
    const heat_idx = calculateHeatIndex(weather.temp, weather.humidity);
    const climb_score = calculateClimbingScore(weather);
    const bet_conf = calculateBettingConfidence(weather);
    const storm_risk = calculateStormRisk(weather);

    return WeatherAnalysis{
        .rain_probability = rain_prob,
        .rain_prediction_confidence = 70.0,
        .storm_risk = storm_risk,
        .heat_index = heat_idx,
        .climbing_score = climb_score,
        .betting_confidence = bet_conf,
        .dew_point = dew_point,
        .temp_trend = 0.0,
    };
}

fn calculateDewPoint(temp: f64, humidity: f64) f64 {
    const a = 17.27;
    const b = 237.7;
    const alpha = (a * temp) / (b + temp) + @log(humidity / 100.0);
    return (b * alpha) / (a - alpha);
}

fn calculateRainProbability(weather: *const parser.WeatherData) f64 {
    var prob: f64 = 0.0;
    if (weather.humidity > 60.0) {
        prob += (weather.humidity - 60.0) * 0.8;
    }
    if (weather.pressure < 1013.0) {
        prob += (1013.0 - weather.pressure) * 0.15;
    }
    prob += weather.cloud_cover * 0.2;
    if (prob > 95.0) prob = 95.0;
    return prob;
}

fn calculateHeatIndex(temp: f64, humidity: f64) f64 {
    const T = temp;
    const R = humidity;
    const HI = -8.78469475556 +
        1.61139411 * T +
        2.33854883889 * R +
        -0.14611605 * T * R +
        -0.012308094 * T * T +
        -0.0164248277778 * R * R +
        0.002211732 * T * T * R +
        0.00072546 * T * R * R +
        -0.000003582 * T * T * R * R;
    return if (HI < temp) temp else HI;
}

fn calculateClimbingScore(weather: *const parser.WeatherData) f64 {
    var score: f64 = 100.0;
    const rain_prob = calculateRainProbability(weather);
    if (rain_prob > 20.0) {
        score -= (rain_prob - 20.0) * 0.5;
    }
    if (weather.wind_speed > 10.0) {
        score -= (weather.wind_speed - 10.0) * 2.0;
    }
    if (weather.temp < 5.0) {
        score -= (5.0 - weather.temp) * 1.5;
    } else if (weather.temp > 32.0) {
        score -= (weather.temp - 32.0) * 1.5;
    }
    return if (score < 0.0) 0.0 else if (score > 100.0) 100.0 else score;
}

fn calculateBettingConfidence(weather: *const parser.WeatherData) f64 {
    var confidence: f64 = 50.0;
    const rain_prob = calculateRainProbability(weather);
    if (rain_prob > 30.0 and rain_prob < 70.0) {
        confidence += 20.0;
    }
    const dew_point = calculateDewPoint(weather.temp, weather.humidity);
    if (dew_point > 15.0 and weather.temp - dew_point < 3.0) {
        confidence += 15.0;
    }
    confidence += 10.0;
    return if (confidence > 95.0) 95.0 else confidence;
}

fn calculateStormRisk(weather: *const parser.WeatherData) StormRisk {
    if (weather.pressure < 990.0 and weather.wind_speed > 20.0) {
        return StormRisk.extreme;
    } else if (weather.pressure < 1000.0 and weather.wind_speed > 15.0) {
        return StormRisk.high;
    } else if (weather.pressure < 1008.0 or weather.wind_speed > 10.0) {
        return StormRisk.moderate;
    } else {
        return StormRisk.low;
    }
}

pub fn displayAnalysis(analysis: *const WeatherAnalysis) !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("│ ☔ Rain Prob:    {d:6.1}%                  │\n", .{analysis.rain_probability});
    try stdout.print("│ 📊 Confidence:  {d:6.1}%                  │\n", .{analysis.rain_prediction_confidence});

    const risk_str = switch (analysis.storm_risk) {
        .low => "LOW",
        .moderate => "MED",
        .high => "HIGH",
        .extreme => "EXTRE",
    };
    try stdout.print("│ ⛈️  Storm Risk:  {s: <6}                  │\n", .{risk_str});
    try stdout.print("│ 🌡️  Heat Index:  {d:6.1}°C              │\n", .{analysis.heat_index});

    const climb_emoji = if (analysis.climbing_score > 70.0) "🧗 ✅" else "🧗 ❌";
    try stdout.print("│ {s}  Climbing:    {d:6.1}/100          │\n", .{
        climb_emoji,
        analysis.climbing_score,
    });

    const bet_emoji = if (analysis.betting_confidence > 60.0) "🎲 🟢" else "🎲 🔴";
    try stdout.print("│ {s}  Bet Conf:   {d:6.1}%              │\n", .{
        bet_emoji,
        analysis.betting_confidence,
    });
}
