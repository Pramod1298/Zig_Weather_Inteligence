Good questions! Let me clarify both:

---

## 1. Binary vs Source - What I Meant

You're right - I gave you conflicting info. Let me clarify:

**The Binary Route** (what you did):
```bash
# This installs a pre-built binary
wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz
sudo mv zig-linux-x86_64-0.13.0 /opt/zig
```
This gives you the **latest stable release** (0.13.0). It's compiled and ready to go.

**Building from Source** (what I mentioned but you didn't do):
```bash
git clone https://github.com/ziglang/zig.git
cd zig
cmake -B build
cmake --build build
```
This gives you the **absolute bleeding edge** (nightly builds) with the very latest features, but can be unstable.

**What you have:** You installed the binary version (0.13.0 stable). That's the right call for learning. The `std.http.fetch` issue was because that API changed between versions - the binary version uses the older `std.http.Client` approach, which is what we fixed.

---

## 2. 🎯 Zig Command Reference Sheet

Here's a comprehensive cheat sheet for Zig commands:

### Basic Commands

```bash
# Check version
zig version

# Build your project
zig build

# Build with optimizations
zig build -Doptimize=ReleaseFast   # Faster, optimized
zig build -Doptimize=ReleaseSmall  # Smaller binary size
zig build -Doptimize=ReleaseSafe   # Safe with runtime checks

# Build and run
zig build run

# Build and run with arguments
zig build run -- "Seattle" --analytics
# The -- separates build args from program args

# Run a single file directly
zig run src/main.zig

# Run a single file with args
zig run src/main.zig -- "Seattle"
```

### Compilation Commands

```bash
# Compile a single file to executable
zig build-exe src/main.zig

# Compile with optimizations
zig build-exe src/main.zig -OReleaseFast

# Compile to a specific output name
zig build-exe src/main.zig --name myapp

# Compile and run tests
zig test src/analytics.zig

# Compile all tests in a project
zig build test

# Compile to object file (no linking)
zig build-obj src/main.zig

# Compile to shared library
zig build-lib src/main.zig -dynamic
```

### Build System Commands

```bash
# Clean build cache
rm -rf .zig-cache zig-out
# Or if you want to keep cache but force rebuild
zig build --force

# See what build steps are available
zig build --help

# See verbose build output
zig build --verbose

# Show build summary
zig build --summary all
zig build --summary none

# Build with specific target
zig build -Dtarget=x86_64-linux
zig build -Dtarget=wasm32-freestanding

# Cross-compile for Windows
zig build -Dtarget=x86_64-windows
```

### Check and Analysis Commands

```bash
# Check syntax without compiling
zig ast-check src/main.zig

# Show the AST (Abstract Syntax Tree)
zig ast-check -t src/main.zig

# Format code (auto-format)
zig fmt src/          # Format all .zig files in src/
zig fmt src/main.zig  # Format a single file

# Check for unused code
zig build-exe src/main.zig -fno-emit-bin
```

### Package/Module Commands

```bash
# Create a new project
mkdir myproject
cd myproject
zig init-exe          # Create executable project
zig init-lib          # Create library project

# Build with a specific package
zig build-exe src/main.zig --dep mylib
```

### Testing Commands

```bash
# Run tests in a specific file
zig test src/analytics.zig

# Run tests with filter (only tests containing "rain")
zig test src/analytics.zig --test-filter rain

# Run tests in release mode
zig test src/analytics.zig -OReleaseFast
```

### Documentation Commands

```bash
# Generate documentation
zig build docs

# View documentation in browser
# After running zig build docs, open docs/html/index.html

# Build documentation for a single file
zig build-exe src/main.zig -femit-docs
```

### Environment and Debug

```bash
# Show build info
zig env

# Run with debugger
zig build run -- --help  # Just show help

# Show compilation traces
zig build-exe src/main.zig --show-llvm-ir
zig build-exe src/main.zig --show-mlir
zig build-exe src/main.zig -femit-asm    # Output assembly
zig build-exe src/main.zig -femit-h      # Output C header

# Use reference traces for debugging
zig build -freference-trace
```

---

## 📝 Quick Reference Card

Save this for quick access:

```bash
# Most common commands
zig build                    # Build
zig build run -- "Seattle"   # Build and run
zig build -Doptimize=ReleaseFast  # Release build
zig test src/analytics.zig   # Run tests
zig fmt src/                 # Format code

# Clean build
rm -rf .zig-cache zig-out && zig build

# Check syntax
zig ast-check src/main.zig

# Cross-compile
zig build -Dtarget=x86_64-windows   # Windows
zig build -Dtarget=aarch64-linux    # ARM Linux
zig build -Dtarget=wasm32-wasi      # WASM
```

---

## 🔧 Build Optimization Levels

| Flag | Description | Use Case |
|------|-------------|----------|
| `-ODebug` (default) | Fast compilation, slow runtime, includes debug info | Development |
| `-OReleaseFast` | Slower compilation, fast runtime, optimized | Production, speed-critical |
| `-OReleaseSmall` | Optimized for binary size | Embedded, limited storage |
| `-OReleaseSafe` | Balanced, with runtime safety checks | Production with safety |

---

## 💡 Pro Tips

1. **Always use `zig build` for projects**, not `zig build-exe` directly. It handles dependencies and modules properly.

2. **The `--` is important!**
   ```bash
   # Wrong - build receives the args
   zig build run Seattle
   
   # Right - program receives the args
   zig build run -- Seattle
   ```

3. **Check what's in your binary**
   ```bash
   # Show symbols in your binary
   nm zig-out/bin/weather-intel | head -20
   
   # Show binary size
   ls -lh zig-out/bin/weather-intel
   ```

4. **Use `zig fmt` regularly** - it enforces consistent style and catches some errors:
   ```bash
   zig fmt src/
   ```

---

## 🚀 Your Current Project Commands

For your weather-intel project specifically:

```bash
# Build
zig build

# Release build (faster)
zig build -Doptimize=ReleaseFast

# Run with city
zig build run -- "Austin"

# Run with analytics
zig build run -- --city "Austin" --analytics

# Run with JSON output
zig build run -- --city "Tokyo" --json

# Clean rebuild
rm -rf .zig-cache zig-out && zig build

# Run the binary directly (faster after build)
./zig-out/bin/weather-intel "Seattle"
```

---