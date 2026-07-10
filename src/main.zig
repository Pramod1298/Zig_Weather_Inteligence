const std = @import("std");
const config = @import("config.zig");
const http_client = @import("http_client.zig");
const parser = @import("parser.zig");
const analytics = @import("analytics.zig");

const stdout = std.io.getStdOut().writer();
const stderr = std.io.getStdErr().writer();

const CliArgs = struct {
    city: ?[]const u8 = null,
    analytics: bool = false,
    json: bool = false,
    verbose: bool = false,
    help: bool = false,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try parseArgs(allocator);
    // Free the city string if it was allocated
    defer {
        if (args.city) |city| {
            // Cast to []u8 to free - we know it was allocated by dupe
            allocator.free(@constCast(city));
        }
    }
    
    if (args.help) {
        try printHelp();
        return;
    }

    const location = args.city orelse "Seattle";

    var cfg = try config.load(allocator);
    defer cfg.deinit();

    if (args.verbose) {
        try stdout.print("Fetching weather for: {s}...\n", .{location});
    }

    var weather_result = try http_client.fetchWeather(
        allocator,
        cfg.openweather_api_key,
        location,
        args.verbose,
    );
    defer weather_result.deinit();

    if (args.json) {
        try stdout.print("{s}\n", .{weather_result.raw_json});
        return;
    }

    var parsed = try parser.parseWeather(allocator, weather_result.raw_json);
    defer parsed.deinit();

    try displayBasic(&parsed.data);

    if (args.analytics) {
        try stdout.print("\n┌─────────────────────────────────────────────┐\n", .{});
        try stdout.print("│           📊 WEATHER ANALYSIS              │\n", .{});
        try stdout.print("├─────────────────────────────────────────────┤\n", .{});

        const analysis = analytics.analyze(&parsed.data);
        try analytics.displayAnalysis(&analysis);

        try stdout.print("└─────────────────────────────────────────────┘\n", .{});
    }
}

fn parseArgs(allocator: std.mem.Allocator) !CliArgs {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var result = CliArgs{};

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            result.help = true;
            return result;
        } else if (std.mem.eql(u8, arg, "--city") or std.mem.eql(u8, arg, "-c")) {
            if (i + 1 < args.len) {
                i += 1;
                const city = try allocator.dupe(u8, args[i]);
                result.city = city;
            } else {
                try stderr.print("Error: --city requires a value\n", .{});
                return error.InvalidArgument;
            }
        } else if (std.mem.eql(u8, arg, "--analytics") or std.mem.eql(u8, arg, "-a")) {
            result.analytics = true;
        } else if (std.mem.eql(u8, arg, "--json") or std.mem.eql(u8, arg, "-j")) {
            result.json = true;
        } else if (std.mem.eql(u8, arg, "--verbose") or std.mem.eql(u8, arg, "-v")) {
            result.verbose = true;
        } else {
            if (result.city == null) {
                const city = try allocator.dupe(u8, arg);
                result.city = city;
            } else {
                try stderr.print("Unknown argument: {s}\n", .{arg});
                return error.InvalidArgument;
            }
        }
    }

    return result;
}

fn printHelp() !void {
    try stdout.print(
        \\
        \\Weather Intelligence Engine - High-Performance Weather CLI
        \\
        \\Usage: weather-intel [options] [city]
        \\
        \\Options:
        \\  -c, --city <city>         City name (e.g., "Seattle")
        \\  -a, --analytics           Show detailed weather analysis
        \\  -j, --json                Output raw JSON
        \\  -v, --verbose             Verbose output
        \\  -h, --help                Show this help
        \\
        \\Examples:
        \\  weather-intel "Seattle"
        \\  weather-intel --city "New York" --analytics
        \\  weather-intel --json --city "London"
        \\
    , .{});
}

fn displayBasic(weather: *const parser.WeatherData) !void {
    try stdout.print("\n┌─────────────────────────────────────────────┐\n", .{});
    try stdout.print("│           🌤️  CURRENT WEATHER              │\n", .{});
    try stdout.print("├─────────────────────────────────────────────┤\n", .{});

    try stdout.print("│ 🌡️  Temperature:  {d:6.1}°C / {d:6.1}°F   │\n", .{
        weather.temp,
        weather.temp * 1.8 + 32.0,
    });

    try stdout.print("│ 🌡️  Feels Like:  {d:6.1}°C / {d:6.1}°F   │\n", .{
        weather.feels_like,
        weather.feels_like * 1.8 + 32.0,
    });

    try stdout.print("│ 💧  Humidity:    {d:6.0}%              │\n", .{
        weather.humidity,
    });

    try stdout.print("│ 📊  Pressure:    {d:6.0} hPa          │\n", .{
        weather.pressure,
    });

    try stdout.print("│ 💨  Wind:        {d:5.1} m/s           │\n", .{
        weather.wind_speed,
    });

    try stdout.print("│ ☁️  Conditions:  {s: <18}│\n", .{
        weather.condition,
    });

    try stdout.print("└─────────────────────────────────────────────┘\n", .{});
}
