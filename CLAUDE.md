# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build          # Debug build
swift build -c release   # Release build
swift run swiped     # Run (generates default config if missing)
swift run swiped --config /path/to/config.toml  # Run with custom config
```

No test target exists yet.

## Architecture

`swiped` is a macOS CLI that listens for trackpad multitouch gestures and executes arbitrary commands. It uses OpenMultitouchSupport to access raw touch data via a private framework.

### Data Flow

```
OMSManager.touchDataStream (~90Hz)
  → TouchTracker.update()      // compute velocity from position deltas
  → GestureRecognizer.process() // state machine emits SwipeEvent
  → Config.binding(for:)       // lookup gesture → command
  → CommandExecutor.execute()  // fire-and-forget Process()
```

### Key Components

- **SwipedApp.swift** - `@main` entry point with async `for await` loop over touch stream
- **TouchTracker.swift** - Maintains per-finger history, computes velocity as `deltaPos / deltaTime`
- **GestureRecognizer.swift** - 3-state machine: `idle → possibleSwipe → cooldown`. Emits `SwipeEvent` when average finger velocity exceeds threshold
- **Config.swift** - TOML config model using TOMLKit. `load(from:)` decodes, `generateDefault(at:)` encodes sample config

### Config File

Default location: `~/.config/swiped/config.toml`

```toml
[settings]
velocity_threshold = 0.3
cooldown_ms = 250

[[gestures]]
direction = "left"   # left, right, up, down
fingers = 3
command = ["/path/to/executable", "arg1", "arg2"]
```

Commands are executed directly via `Process()` (no shell wrapper).

## Dependencies

- **OpenMultitouchSupport** (exact 3.0.3) - Wraps private MultitouchSupport.framework; pinned exactly due to private API sensitivity
- **TOMLKit** (from 0.6.0) - TOML encoding/decoding
