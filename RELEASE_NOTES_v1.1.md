# OpenClaw Manager v1.1 Release Notes

## New Features
- **Menu Bar Status Icon**: Added a menu bar icon that reflects the gateway status:
    - 🟢 Green: Gateway is running.
    - 🔵 Blue: Gateway is running and active (processing requests).
    - ⚪️ Gray: Gateway is stopped.
- **Activity Monitoring**: Implemented real-time monitoring of gateway logs to visualize activity state.
- **Configuration Support**:
    - Added support for configuring **Discord** channels.
    - Added support for **Plugin** system configuration.

## Improvements
- **Enhanced DMG Installer**:
    - Custom background image with "Drag to Applications" instruction.
    - Improved icon alignment for a polished installation experience.
    - `package.sh` update to automate DMG creation with `create-dmg`.
- **Developer Experience**:
    - Added `scripts/create_dmg_bg.swift` for reproducible background image generation.

- **Resilient Configuration**: Improved compatibility with newer OpenClaw versions (e.g., 2026.2.15) by relaxing schema requirements.
- **Safe Updates**: Implemented safe configuration updates to prevent data loss for existing settings (e.g., preserving Slack/Discord tokens).

## Technical Details
- Refactored core logic into `OpenClawKit` library.
- Updated `MoltbotConfig` structure to support new configuration sections.
- Refactored `MoltbotManagerApp` to integrate `MenuBarExtra`.

## Troubleshooting
### "App is damaged" Error
If you encounter this error on launch, run:
```bash
xattr -cr /Applications/OpenClawManager.app
```
