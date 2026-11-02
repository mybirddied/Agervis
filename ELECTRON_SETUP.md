# Agervis Desktop App Foundation

Electron-based desktop application for managing Agervis multiplayer RPG servers. Provides one-click setup and management for non-technical users.

## Features

### Setup Wizard
- **API Configuration**: Input Anthropic API key and base URL
- **Network Testing**: Verify connection to server before proceeding
- **Server Configuration**: Set port, server name, and max player count
- **Port Availability Check**: Detect and suggest alternatives for in-use ports
- **Config Validation**: Plain-English error messages for invalid inputs

### Server Management
- **Start/Stop Controls**: Visual buttons with real-time status
- **Status Indicators**: Green (running), Yellow (starting), Red (stopped/error)
- **System Tray Integration**: Minimize to tray, quick access controls
- **Real-time Monitoring**: Uptime tracking and process monitoring
- **Auto-refresh**: Status updates every 2 seconds

### Network & Security
- **Firewall Detection**: Checks if port is blocked and provides OS-specific guidance
- **Network Connectivity Test**: Verifies DNS resolution and connectivity
- **Port Conflict Resolution**: Automatically finds available ports
- **Cross-Platform Support**: Windows, macOS, Linux installers

### Configuration Management
- **Persistent Storage**: Config saved in user's app data directory
- **Validation**: API key, URL, port, server name all validated
- **Error Handling**: User-friendly error messages

## File Structure

```
electron/
├── main.ts                 # Main Electron process
├── preload.ts             # IPC bridge (context isolation)
├── config-manager.ts      # Configuration handling
├── server-process.ts      # Server process management
├── dev-utils.ts           # Development utilities
└── tray/
    └── tray-manager.ts    # System tray integration

src/renderer/
├── main.tsx               # React entry point
├── main/
│   ├── MainWindow.tsx     # Main window component
│   └── ServerControls.tsx # Server control UI
└── setup/
    ├── SetupWizard.tsx    # Setup wizard flow
    ├── ApiKeyForm.tsx     # API key input form
    └── ServerConfig.tsx   # Server configuration form
```

## Building & Running

### Development
```bash
npm install
npm run dev
```

### Production Build
```bash
npm run build          # Build for current platform
npm run package:win    # Windows installer
npm run package:mac    # macOS DMG
npm run package:linux  # Linux AppImage
```

## Key Components

### ConfigManager
- Loads/saves configuration from user app data
- Validates all config fields with clear error messages
- URL validation, port range checking
- Persistent storage in JSON format

### ServerProcess
- Spawns Node.js server with environment variables
- Monitors process status and uptime
- Port availability checking
- Firewall detection (Windows, macOS, Linux)
- Network reachability testing

### SetupWizard
- Two-step configuration process
- Validates inputs before proceeding
- Tests network connectivity
- Confirms port availability
- Saves configuration automatically

### ServerControls
- Visual status display with color coding
- Start/Stop buttons
- Real-time uptime tracking
- Network and firewall status cards
- Manual refresh capability

### TrayManager
- Minimize to system tray
- Click tray icon to show/hide window
- Context menu with quick actions
- Status display in tray menu
- Platform-native behavior

## IPC Handlers

All communication between Electron main and renderer uses IPC:

**Config**: `get-config`, `save-config`, `validate-config`
**Server**: `start-server`, `stop-server`, `get-server-status`
**Network**: `check-port`, `get-suggested-port`, `test-network`, `check-firewall`

## Security Features

- Context isolation enabled
- Preload bridge restricts main process access
- API keys handled securely
- No eval or dynamic code execution
- Config stored locally, never sent to external services

## Success Criteria Met

✓ Electron app launches and shows setup wizard
✓ Setup wizard collects API key, base_url, server settings
✓ Start/Stop buttons control server process
✓ System tray shows status and allows quick access
✓ Config saved and validated
✓ Plain-English error messages for issues
✓ Cross-platform: Windows/Mac/Linux support
✓ One-click installer with NSIS setup
✓ Port conflict detection with suggestions
✓ Firewall helper guide with OS-specific commands
✓ Network test tool included
✓ Auto-update system ready (electron-updater compatible)
