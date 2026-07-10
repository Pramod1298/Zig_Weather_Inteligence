const std = @import("std");

pub const WeatherResponse = struct {
    raw_json: []u8,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *WeatherResponse) void {
        self.allocator.free(self.raw_json);
    }
};

pub fn fetchWeather(
    allocator: std.mem.Allocator,
    api_key: []const u8,
    location: []const u8,
    verbose: bool,
) !WeatherResponse {
    const stderr = std.io.getStdErr().writer();

    // Build URL
    const url = try std.fmt.allocPrint(allocator,
        "https://api.openweathermap.org/data/2.5/weather?q={s}&units=metric&appid={s}",
        .{ location, api_key },
    );
    defer allocator.free(url);

    if (verbose) {
        try stderr.print("→ Fetching: {s}\n", .{url});
    }

    // Use curl - this works reliably
    var child = std.process.Child.init(&.{ "curl", "-s", url }, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Ignore;
    
    try child.spawn();
    const stdout = try child.stdout.?.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(stdout);
    
    const term = try child.wait();
    if (term != .Exited) {
        return error.ProcessFailed;
    }

    const raw_json = try allocator.dupe(u8, stdout);

    if (verbose) {
        try stderr.print("→ Response: {d} bytes\n", .{raw_json.len});
    }

    return WeatherResponse{
        .raw_json = raw_json,
        .allocator = allocator,
    };
}
