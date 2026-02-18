# OpenClaw Manager v1.1.1 Release Notes

This is a maintenance release focused on stability and compatibility.

## Improvements & Fixes
- **Resilient Configuration**: Improved compatibility with newer OpenClaw versions (e.g., 2026.2.15) by relaxing schema requirements.
- **Safe Updates**: Implemented safe configuration updates to prevent data loss for existing settings (e.g., preserving Slack/Discord tokens).
- **Documentation**: Added troubleshooting guide for "App is damaged" errors in macOS Gatekeeper.

## Technical Details
- Refactored core logic into `OpenClawKit` library.
- Updated `MoltbotConfig` structure to support new configuration sections.
