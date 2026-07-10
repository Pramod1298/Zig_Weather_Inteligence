const std = @import("std");

pub const Config = struct {
    allocator: std.mem.Allocator,
    openweather_api_key: []u8,

    pub fn deinit(self: *Config) void {
        self.allocator.free(self.openweather_api_key);
    }
};

pub fn load(allocator: std.mem.Allocator) !Config {
    // Try environment variable first
    if (std.process.getEnvVarOwned(allocator, "OPENWEATHER_API_KEY")) |key| {
        return Config{
            .allocator = allocator,
            .openweather_api_key = key,
        };
    } else |_| {
        // Try .env file in the Zig project directory
        const env_path = try std.fs.path.resolve(allocator, &.{"/home/jonathon/gemini-jules/maya/Development/Zig_Weather_Inteligence/.env"});
        defer allocator.free(env_path);
        
        const env_file = std.fs.cwd().openFile(env_path, .{ .mode = .read_only }) catch {
            // Fallback to current directory
            const env_file2 = std.fs.cwd().openFile(".env", .{ .mode = .read_only }) catch {
                @panic("OPENWEATHER_API_KEY not found in environment or .env file");
            };
            defer env_file2.close();
            return loadFromFile(allocator, env_file2);
        };
        defer env_file.close();
        return loadFromFile(allocator, env_file);
    }
}

fn loadFromFile(allocator: std.mem.Allocator, file: std.fs.File) !Config {
    const content = try file.readToEndAlloc(allocator, 1024 * 10);
    defer allocator.free(content);

    var lines = std.mem.splitAny(u8, content, "\n");
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;

        var parts = std.mem.splitAny(u8, trimmed, "=");
        const key = parts.next() orelse continue;
        const value = parts.next() orelse continue;

        if (std.mem.eql(u8, key, "OPENWEATHER_API_KEY")) {
            const cleaned = std.mem.trim(u8, value, " \"'");
            const key_dup = try allocator.dupe(u8, cleaned);
            return Config{
                .allocator = allocator,
                .openweather_api_key = key_dup,
            };
        }
    }

    @panic("OPENWEATHER_API_KEY not found in .env file");
}
