# swiped

A macOS daemon that executes commands in response to trackpad swipe gestures.

## Requirements

- macOS 13+
- Swift 6.0+

## Installation

```bash
git clone https://github.com/yourusername/swiped.git
cd swiped
./install.sh
```

This builds swiped, installs the binary and framework, and sets up a launch agent to run it automatically.

### Manual Installation

If you prefer to install manually:

```bash
swift build -c release

# Install binary and framework
sudo cp .build/release/swiped /usr/local/bin/
sudo cp -R .build/arm64-apple-macosx/release/OpenMultitouchSupportXCF.framework /usr/local/lib/

# Relink binary to find the framework
sudo install_name_tool -change \
  @rpath/OpenMultitouchSupportXCF.framework/Versions/A/OpenMultitouchSupportXCF \
  /usr/local/lib/OpenMultitouchSupportXCF.framework/Versions/A/OpenMultitouchSupportXCF \
  /usr/local/bin/swiped
```

### Disable Default 3-Finger Gestures

To avoid conflicts with swiped, disable or change macOS built-in 3-finger gestures:

1. Open **System Settings** → **Trackpad** → **More Gestures**
2. Set "Swipe between full-screen applications" to **Four Fingers** (or off)
3. Set "Mission Control" to **Four Fingers** (or off)

Alternatively, use 4-finger gestures in your swiped config instead.

## Usage

```bash
swiped                              # Uses ~/.config/swiped/config.toml
swiped --config /path/to/config.toml  # Custom config path
```

On first run, a default config file is generated if none exists.

## Configuration

Config file location: `~/.config/swiped/config.toml`

```toml
[settings]
velocity_threshold = 0.3  # Minimum swipe velocity to trigger
cooldown_ms = 250         # Cooldown between gestures

[[gestures]]
direction = "left"
fingers = 3
command = ["/opt/homebrew/bin/aerospace", "--no-stdin", "workspace", "next"]

[[gestures]]
direction = "right"
fingers = 3
command = ["/opt/homebrew/bin/aerospace", "--no-stdin", "workspace", "prev"]
```

> **Note:** AeroSpace requires `--no-stdin` when running from a launch agent (non-TTY context). See [AeroSpace#1683](https://github.com/nikitabobko/AeroSpace/issues/1683).

### Options

| Field | Description |
|-------|-------------|
| `direction` | `left`, `right`, `up`, or `down` |
| `fingers` | Number of fingers (e.g., 3, 4) |
| `command` | Array of strings: `[executable, arg1, arg2, ...]` |

Commands are executed directly without a shell wrapper.

## Running as a Launch Agent

The `install.sh` script automatically sets up a launch agent. To manage it manually:

```bash
# Reload after changes
launchctl kickstart -k gui/$(id -u)/com.swiped

# Stop
launchctl bootout gui/$(id -u)/com.swiped

# Start
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.swiped.plist
```

Logs are written to `/tmp/swiped.log`.

## How It Works

swiped uses [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) to access raw trackpad touch data via Apple's private MultitouchSupport framework. Touch frames arrive at ~90Hz, and a gesture recognizer detects directional swipes based on average finger velocity.

## License

MIT
