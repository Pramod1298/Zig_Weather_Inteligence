const std = @import("std");

/// Timer for performance measurement
pub const Timer = struct {
    start_time: i128,

    pub fn start() Timer {
        return Timer{
            .start_time = std.time.nanoTimestamp(),
        };
    }

    pub fn elapsedNs(self: *Timer) i128 {
        const now = std.time.nanoTimestamp();
        return now - self.start_time;
    }

    pub fn elapsedMs(self: *Timer) f64 {
        return @as(f64, @floatFromInt(self.elapsedNs())) / 1_000_000.0;
    }

    pub fn elapsedS(self: *Timer) f64 {
        return @as(f64, @floatFromInt(self.elapsedNs())) / 1_000_000_000.0;
    }
};

/// Simple logging
pub const Logger = struct {
    level: Level,

    pub const Level = enum {
        debug,
        info,
        warn,
        error,
    };

    pub fn init(level: Level) Logger {
        return Logger{ .level = level };
    }

    pub fn debug(self: Logger, comptime fmt: []const u8, args: anytype) !void {
        if (self.level == .debug) {
            const stderr = std.io.getStdErr().writer();
            try stderr.print("[DEBUG] " ++ fmt, args);
        }
    }

    pub fn info(self: Logger, comptime fmt: []const u8, args: anytype) !void {
        if (@intFromEnum(self.level) <= @intFromEnum(Level.info)) {
            const stderr = std.io.getStdErr().writer();
            try stderr.print("[INFO] " ++ fmt, args);
        }
    }

    pub fn warn(self: Logger, comptime fmt: []const u8, args: anytype) !void {
        if (@intFromEnum(self.level) <= @intFromEnum(Level.warn)) {
            const stderr = std.io.getStdErr().writer();
            try stderr.print("[WARN] " ++ fmt, args);
        }
    }

    pub fn err(self: Logger, comptime fmt: []const u8, args: anytype) !void {
        if (@intFromEnum(self.level) <= @intFromEnum(Level.error)) {
            const stderr = std.io.getStdErr().writer();
            try stderr.print("[ERROR] " ++ fmt, args);
        }
    }
};