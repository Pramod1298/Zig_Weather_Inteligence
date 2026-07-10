const std = @import("std");
const parser = @import("src/parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json = 
        \\{"main":{"temp":25.17,"feels_like":25.02,"pressure":1016,"humidity":49},"weather":[{"description":"clear sky"}],"wind":{"speed":1.34},"clouds":{"all":10}}
    ;

    const parsed = try parser.parseWeather(allocator, json);
    defer parsed.deinit();

    const out = std.io.getStdOut().writer();
    try out.print("Temp: {d:.1f}°C\n", .{parsed.data.temp});
    try out.print("Condition: {s}\n", .{parsed.data.condition});
}
EOF

# Compile and run the test
zig build-exe test_parse.zig --dep parser -Mroot=test_parse.zig -Mparser=src/parser.zig
./test_parse# Create a test file
cat > test_parse.zig << 'EOF'
const std = @import("std");
const parser = @import("src/parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json = 
        \\{"main":{"temp":25.17,"feels_like":25.02,"pressure":1016,"humidity":49},"weather":[{"description":"clear sky"}],"wind":{"speed":1.34},"clouds":{"all":10}}
    ;

    const parsed = try parser.parseWeather(allocator, json);
    defer parsed.deinit();

    const out = std.io.getStdOut().writer();
    try out.print("Temp: {d:.1f}°C\n", .{parsed.data.temp});
    try out.print("Condition: {s}\n", .{parsed.data.condition});
}
EOF

# Compile and run the test
zig build-exe test_parse.zig --dep parser -Mroot=test_parse.zig -Mparser=src/parser.zig
./test_parse# Create a test file
cat > test_parse.zig << 'EOF'
const std = @import("std");
const parser = @import("src/parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json = 
        \\{"main":{"temp":25.17,"feels_like":25.02,"pressure":1016,"humidity":49},"weather":[{"description":"clear sky"}],"wind":{"speed":1.34},"clouds":{"all":10}}
    ;

    const parsed = try parser.parseWeather(allocator, json);
    defer parsed.deinit();

    const out = std.io.getStdOut().writer();
    try out.print("Temp: {d:.1f}°C\n", .{parsed.data.temp});
    try out.print("Condition: {s}\n", .{parsed.data.condition});
}
EOF

# Compile and run the test
zig build-exe test_parse.zig --dep parser -Mroot=test_parse.zig -Mparser=src/parser.zig
./test_parse# Create a test file
cat > test_parse.zig << 'EOF'
const std = @import("std");
const parser = @import("src/parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json = 
        \\{"main":{"temp":25.17,"feels_like":25.02,"pressure":1016,"humidity":49},"weather":[{"description":"clear sky"}],"wind":{"speed":1.34},"clouds":{"all":10}}
    ;

    const parsed = try parser.parseWeather(allocator, json);
    defer parsed.deinit();

    const out = std.io.getStdOut().writer();
    try out.print("Temp: {d:.1f}°C\n", .{parsed.data.temp});
    try out.print("Condition: {s}\n", .{parsed.data.condition});
}
EOF

# Compile and run the test
zig build-exe test_parse.zig --dep parser -Mroot=test_parse.zig -Mparser=src/parser.zig
./test_parse# Create a test file
cat > test_parse.zig << 'EOF'
const std = @import("std");
const parser = @import("src/parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json = 
        \\{"main":{"temp":25.17,"feels_like":25.02,"pressure":1016,"humidity":49},"weather":[{"description":"clear sky"}],"wind":{"speed":1.34},"clouds":{"all":10}}
    ;

    const parsed = try parser.parseWeather(allocator, json);
    defer parsed.deinit();

    const out = std.io.getStdOut().writer();
    try out.print("Temp: {d:.1f}°C\n", .{parsed.data.temp});
    try out.print("Condition: {s}\n", .{parsed.data.condition});
}
EOF

# Compile and run the test
zig build-exe test_parse.zig --dep parser -Mroot=test_parse.zig -Mparser=src/parser.zig
./test_parse# Create a test file
cat > test_parse.zig << 'EOF'
const std = @import("std");
const parser = @import("src/parser.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json = 
        \\{"main":{"temp":25.17,"feels_like":25.02,"pressure":1016,"humidity":49},"weather":[{"description":"clear sky"}],"wind":{"speed":1.34},"clouds":{"all":10}}
    ;

    const parsed = try parser.parseWeather(allocator, json);
    defer parsed.deinit();

    const out = std.io.getStdOut().writer();
    try out.print("Temp: {d:.1f}°C\n", .{parsed.data.temp});
    try out.print("Condition: {s}\n", .{parsed.data.condition});
}