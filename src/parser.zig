const std = @import("std");

pub const WeatherData = struct {
    temp: f64,
    feels_like: f64,
    pressure: f64,
    humidity: f64,
    wind_speed: f64,
    cloud_cover: f64,
    condition: []u8,
    allocator: std.mem.Allocator,
};

pub const ParsedWeather = struct {
    data: WeatherData,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *ParsedWeather) void {
        self.allocator.free(self.data.condition);
    }
};

pub fn parseWeather(allocator: std.mem.Allocator, json_str: []const u8) !ParsedWeather {
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        allocator,
        json_str,
        .{},
    );
    defer parsed.deinit();

    const root = parsed.value.object;

    const main = root.get("main").?.object;
    const temp = getFloat(main, "temp") orelse 0.0;
    const feels_like = getFloat(main, "feels_like") orelse 0.0;
    const pressure = getFloat(main, "pressure") orelse 0.0;
    const humidity = getFloat(main, "humidity") orelse 0.0;

    const weather_arr = root.get("weather").?.array;
    const weather_first = weather_arr.items[0].object;
    const condition = getString(weather_first, "description") orelse "unknown";

    const wind = root.get("wind").?.object;
    const wind_speed = getFloat(wind, "speed") orelse 0.0;

    const clouds = root.get("clouds").?.object;
    const cloud_cover = getFloat(clouds, "all") orelse 0.0;

    const condition_dup = try allocator.dupe(u8, condition);

    return ParsedWeather{
        .data = WeatherData{
            .temp = temp,
            .feels_like = feels_like,
            .pressure = pressure,
            .humidity = humidity,
            .wind_speed = wind_speed,
            .cloud_cover = cloud_cover,
            .condition = condition_dup,
            .allocator = allocator,
        },
        .allocator = allocator,
    };
}

fn getFloat(obj: std.json.ObjectMap, key: []const u8) ?f64 {
    const val = obj.get(key) orelse return null;
    return switch (val) {
        .float => |f| f,
        .integer => |i| @as(f64, @floatFromInt(i)),
        .number_string => |s| std.fmt.parseFloat(f64, s) catch null,
        else => null,
    };
}

fn getString(obj: std.json.ObjectMap, key: []const u8) ?[]const u8 {
    const val = obj.get(key) orelse return null;
    return switch (val) {
        .string => |s| s,
        else => null,
    };
}
