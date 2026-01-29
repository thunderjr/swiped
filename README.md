# swiped

A macOS daemon that executes commands in response to trackpad swipe gestures.

## Requirements

- macOS 13+
- Swift 6.0+

## Installation

```bash
git clone https://github.com/yourusername/swiped.git
cd swiped
swift build -c release
sudo cp .build/release/swiped /usr/local/bin/
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
command = ["/opt/homebrew/bin/aerospace", "workspace", "next"]

[[gestures]]
direction = "right"
fingers = 3
command = ["/opt/homebrew/bin/aerospace", "workspace", "prev"]
```

### Options

| Field | Description |
|-------|-------------|
| `direction` | `left`, `right`, `up`, or `down` |
| `fingers` | Number of fingers (e.g., 3, 4) |
| `command` | Array of strings: `[executable, arg1, arg2, ...]` |

Commands are executed directly without a shell wrapper.

## Running as a Launch Agent

Create `~/Library/LaunchAgents/com.swiped.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.swiped</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/swiped</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Then load it:

```bash
launchctl load ~/Library/LaunchAgents/com.swiped.plist
```

## How It Works

swiped uses [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) to access raw trackpad touch data via Apple's private MultitouchSupport framework. Touch frames arrive at ~90Hz, and a gesture recognizer detects directional swipes based on average finger velocity.

## License

MIT
