# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build release and create DMG installer
./package.sh

# Build only (no packaging)
swift build -c release

# Run during development
swift run
```

The build script creates `OpenClawManager.app` bundle and `OpenClawManager.dmg` installer.

## Architecture

OpenClaw Manager is a native macOS menu bar application (Swift 5.9, SwiftUI, macOS 13+) for managing the OpenClaw Gateway service.

### Core Components

**MoltbotManagerApp** - App entry point with dual UI:
- `WindowGroup` for main settings window (ContentView)
- `MenuBarExtra` for status bar icon and popup (MenuBarContentView)
- Menu bar icon animates and changes color: blue=active, green=running, gray=stopped

**ConfigManager** - Central state manager (@StateObject, shared via environmentObject):
- Loads/saves OpenClaw config JSON from `~/.openclaw/openclaw.json` or `~/.moltbot/openclaw.json`
- Monitors gateway status via TCP connection to localhost:18789
- Tracks activity by watching log file modifications in `/tmp/openclaw/`
- Restarts gateway via `pkill -f 'openclaw gateway' && openclaw gateway`

**MoltbotConfig** - Codable data model matching the OpenClaw config schema:
- Models & Providers (costs, context windows, reasoning capabilities)
- Gateway settings (port, bind address, auth mode)
- Agents, auth profiles, tools, hooks, channels (Discord/Telegram)

**ModelDisplay** - Provider-aware model display names and mappings

### Data Flow

```
Config JSON → ConfigManager → MoltbotConfig → UI Views
                   ↑
         Gateway status (TCP check)
         Activity monitoring (log files)
```

### Key File Locations

- `Sources/OpenClawManager/MoltbotManagerApp.swift` - @main entry point
- `Sources/OpenClawManager/ConfigManager.swift` - State management and gateway control
- `Sources/OpenClawManager/ContentView.swift` - Main window UI
- `Sources/OpenClawManager/MenuBarContentView.swift` - Menu bar popup UI
- `Sources/OpenClawManager/MoltbotConfig.swift` - Config data structures
