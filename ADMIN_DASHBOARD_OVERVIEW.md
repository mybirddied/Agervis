# Agervis Admin Dashboard: Overview for Future AI Sessions

This document describes the Electron admin dashboard project in `C:\Users\MyBir\Documents\Agervis 1`. It is a separate tool from the Godot game client and from the `server/` game server package. Read this before changing anything in that folder.

Confidence note: items marked **(verified)** were read directly from source or config. Items marked **(inferred)** come from configuration or file listings without a captured build log. No build logs were read, so the exact compiler error text for the user-reported issues is not recorded here.

---

## 1. Project Purpose and Architecture

**Purpose:** A desktop control panel (Electron app, product name "Agervis Server", appId `com.agervis.desktop`) for starting, stopping, and administering the Agervis game server. It is meant to provide server controls, player management, economy and admin actions, logs, a console, and analytics.

**Actual current state (verified):** The app is split into two very different UI trees.

| Layer | What is mounted | Status |
|---|---|---|
| Electron main process (`electron/main.ts`) | Creates the window, tray, and IPC handlers, and spawns the game server as a child process | Working code, with dependency gaps (see Section 4) |
| Renderer entry (`src/main.tsx`) | Renders `<MainWindow />` from `src/renderer/main/MainWindow.tsx` | This is the only UI actually mounted |
| `MainWindow` | Shows `SetupWizard` if no API key is saved, otherwise `ServerControls` | Mounted |
| `src/App.tsx` | Full admin dashboard shell: login gate, theme toggle, WebSocket status, `Layout` with tabs | **Not mounted.** Nothing imports it into the Electron entry point |
| `src/components/layout/Layout.tsx`, `Sidebar.tsx`, tabs | Overview, Players, Economy, Admin, Logs, Settings, Chat, Analytics, plus bottom Console | Only reachable through the unmounted `App.tsx` |

**Process model:**

```
Electron main (electron/main.ts)
  |- BrowserWindow  --loads-->  Vite dev server http://localhost:5173  (dev)
  |                             or dist/index.html (prod)
  |- preload (electron/preload.ts) --contextBridge--> window.electron
  |- IPC handlers (ipcMain.handle) : config, validation, server start/stop/status, network checks
  |- ServerProcess (electron/server-process.ts) --spawn('node', ['dist/server.js'])--> game server child process
  |- TrayManager (electron/tray/tray-manager.ts)
```

Security settings: `contextIsolation: true`, `nodeIntegration: false`, preload exposes only named functions.

**Two separate server trees exist inside this folder:**

1. `src/main/` (inside the dashboard's root tsconfig). Contains `game-server.ts` (class `AgervisServer`), `websocket/`, `database/`, `game-logic/`, `auth/`, `ai/`, `threading/`, `state/`, `health/`, `rate-limiter.ts`, and more. It is type-checked by the root `tsconfig.json` because `include` contains `src`. Its imports reference packages that the root `package.json` does not declare (see Section 4).
2. `server/` (its own package, `agervis-server` 0.1.0). Its own `package.json` lists `@anthropic-ai/sdk`, `better-sqlite3` ^11.8.1, `ws`, and `dotenv`. Its build is `tsc`, and it starts with `node dist/index.js`. It contains `src/server/AgervisServer.ts` and `ConnectionManager.ts`. **Which of these is the intended game server is not settled in the docs.** `electron/server-process.ts` spawns `dist/server.js`, which matches neither.

---

## 2. Tech Stack

| Area | Technology | Version in package.json |
|---|---|---|
| Desktop shell | Electron | ^31.0.0 (devDependency) |
| Packaging | electron-builder | ^24.6.4 (devDependency) |
| UI | React, React DOM | ^18.3.1 |
| Language | TypeScript | ^5.3.3 |
| Bundler / dev server | Vite, @vitejs/plugin-react | ^5.0.8, ^4.2.1 |
| Styling | Tailwind CSS, PostCSS, Autoprefixer | ^3.4.1 |
| State | zustand | ^4.4.1 |
| Charts | recharts | ^2.12.0 |
| Icons | lucide-react | ^0.408.0 |
| Realtime | ws | ^8.14.2 |
| Database | better-sqlite3 | ^9.2.2 (root) vs ^11.8.1 (server/) |
| Sanitization | isomorphic-dompurify | ^11.2.0 |
| Tests / lint | vitest ^1.1.0, eslint ^8.56.0 | |
| Dev helpers | concurrently ^8.2.0, cross-env ^7.0.3 | |

**Theme:** Tailwind with `darkMode: 'class'` and a custom dark palette. The UI uses gray-900/800 backgrounds and blue-600 accent buttons.

---

## 3. Build System and Configuration

### 3.1 Root `package.json` (verified)

- `name`: `agervis-desktop`
- `"type": "module"` (**conflicts with CommonJS Electron output and `__dirname` usage; see Section 4**)
- `main`: `dist/electron/main.js`
- Scripts:
  - `dev`: runs `dev:react` and `dev:electron` via concurrently
  - `dev:react`: `vite`
  - `dev:electron`: `cross-env NODE_ENV=development tsc electron/**/*.ts --outDir dist && electron dist/electron/main.js`
  - `build`: `build:react` + `build:electron`
  - `build:electron`: `tsc --project tsconfig.electron.json`
  - `package`, `package:win`, `package:mac`, `package:linux`: electron-builder
  - `lint`, `type-check`, `test` (vitest)
- electron-builder config: `files` includes `dist/**/*`, `node_modules/**/*`, `package.json`. **`server/dist` is not included.** Targets: NSIS and portable (win x64), dmg and zip (mac), AppImage and deb (linux).

### 3.2 TypeScript configs (verified)

| File | Purpose | Key settings |
|---|---|---|
| `tsconfig.json` | Renderer type-check (`noEmit`) | target ES2020, lib ES2020 + DOM, module ESNext, moduleResolution bundler, allowImportingTsExtensions, jsx react-jsx, strict, noUnusedLocals, noUnusedParameters, include `src` and `electron`, references `tsconfig.node.json` |
| `tsconfig.electron.json` | Compiles Electron main/preload | extends root; module commonjs; moduleResolution node; outDir `dist`; esModuleInterop; **strict false**; include `electron/**/*` |
| `tsconfig.node.json` | Type-checks `vite.config.ts` | composite true; module ESNext; bundler resolution |

### 3.3 Vite (`vite.config.ts`, verified)

- Plugin: `@vitejs/plugin-react`
- Dev server port 5173. Proxies `/api` to `http://localhost:3000` and `/ws` to `ws://localhost:3000` (with `ws: true`).
- Build: outDir `dist`, `sourcemap: true`, rollup input `index.html`.
- Alias: `@` maps to `src`.
- Uses `__dirname`, which is undefined in an ESM package (`"type": "module"`). Likely to fail or need `fileURLToPath(import.meta.url)`.

### 3.4 Other config

- `index.html`: title "Agervis Server", root div, script `/src/main.tsx`.
- Tailwind and PostCSS configs exist. Global CSS is `src/styles/index.css` (imported by `src/main.tsx` and `src/App.tsx`). `src/components/layout/Layout.tsx` imports `Layout.css`.
- `build.bat` and `build.sh`: run `npm install`, then `build:electron`, then `build:react`. Packaging is via `npm run package:win` (or mac/linux).
- `config.default.json` (root) is a server config, not a dashboard config: port 10813, host 0.0.0.0, SQLite file `agervis.db` with backups, websocket maxPayload 100MB, heartbeat 30s, tickRate 60, rateLimit 1000 req/min, 10 connections per IP, logging info/json.

### 3.5 Existing output (verified)

- `dist/` contains only React build output: `index.html`, `assets/main-*.js` (~158KB), a source map, and a CSS file.
- **There is no `dist/electron/` and no `dist/server.js`.** The Electron main process has never been compiled into this folder in its current state.

---

## 4. Current Build Issues and Blockers

### 4.1 User-reported issues

1. **Missing `@types/electron` (confirmed by user; verified in node_modules).** `node_modules/@types` has no `electron` entry. Electron 31 ships its own types, so the usual fix is simply to remove any `@types/electron` import or ensure `electron` resolves its own `.d.ts`. Check whether any file imports from `'electron'` in a way that needs the package types. Types must still resolve for `electron/*.ts`.
2. **better-sqlite3 compilation errors (confirmed by user; cause inferred).** better-sqlite3 is a native module. It must be compiled against Electron's Node ABI, not the system Node version. Nothing in the root project does this:
   - No `electron-rebuild` or `@electron/rebuild` in devDependencies.
   - No `postinstall` script.
   - Root declares `better-sqlite3` ^9.2.2, while `server/` declares ^11.8.1. Two different versions will build against different ABIs.
   - A Visual Studio C++ build toolchain and Python are typically needed on Windows for node-gyp when no prebuilt binary matches.

### 4.2 Other blockers found while reading (verified unless noted)

| # | Problem | Where | Effect |
|---|---|---|---|
| 1 | `electron/index.ts` requires `electron-reloader` in dev, but it is not in package.json | `electron/index.ts` | Dev run fails with module not found. `electron/index.ts` may not be imported by anything, so check before relying on it |
| 2 | `"type": "module"` in root package.json, but Electron output is CommonJS and uses `__dirname` | `package.json`, `tsconfig.electron.json`, `electron/*.ts` | Runtime mismatch. Electron's main process may refuse to load ESM-style output |
| 3 | `dev:electron` runs `tsc electron/**/*.ts --outDir dist` without the electron tsconfig | `package.json` | Output layout (`dist/main.js` vs `dist/electron/main.js`) does not match `main` |
| 4 | `ServerProcess` spawns `node dist/server.js` relative to cwd | `electron/server-process.ts` | `dist/server.js` is never produced. The server build outputs `server/dist/index.js`, and `src/main/game-server.ts` is a different entry |
| 5 | Tray icon path `../assets/icon.png` | `electron/tray/tray-manager.ts` | Asset may be missing (assets folder not confirmed) |
| 6 | Tray sends `tray-action` IPC events, but no renderer listener was found | `electron/tray/tray-manager.ts`, renderer | Tray Start/Stop buttons do nothing in the UI |
| 7 | `vite.config.ts` uses `__dirname` in ESM | `vite.config.ts` | Config load error under `"type": "module"` (may depend on Vite's shim behavior) |
| 8 | Root `tsconfig.json` type-checks `src/main/**` and `electron/**` together with the DOM lib | `tsconfig.json` | Server code under `src/main` is checked against browser typings and imports that do not resolve from the root |
| 9 | `src/main/*` imports packages not declared at root (e.g. `express` in `src/main/api/auth-routes.ts`; `@anthropic-ai/sdk` and `dotenv` are only in `server/`) | `src/main/**` | Type errors and runtime failures. Root `package.json` lists no `express` (verified against the dependency list) |
| 10 | `src/main/server.ts` imports `./shared/types/ai` and `./shared/constants/ai`, which likely do not resolve from `src/main` (inferred from path depth) | `src/main/server.ts` | Type-check errors |
| 11 | Port mismatch: Vite proxy targets port **3000**; server config and `game-server.ts` default to **10813**; `useWebSocket` uses `ws://localhost:3000/ws/dashboard` | `vite.config.ts`, `config.default.json`, `src/main/game-server.ts`, `src/hooks/useWebSocket.ts` | Dashboard cannot reach the server without manual config |
| 12 | Dashboard WebSocket path `/ws/dashboard` is not implemented in the server WebSocket code. `src/main/websocket/server.ts` accepts connections on any path and expects a game protocol handshake with `authToken` | `src/main/websocket/server.ts`, `src/hooks/useWebSocket.ts` | Live dashboard feed will not connect |
| 13 | Two `useWebSocket` instances (one in `App.tsx`, one in `Layout.tsx`) | `src/App.tsx`, `src/components/layout/Layout.tsx` | Two sockets if the dashboard is ever mounted |
| 14 | Max payload comment says "1MB (reduced from 100MB)" while `config.default.json` sets 100MB | `src/main/websocket/server.ts`, `config.default.json` | Config is ignored or inconsistent. Code uses config value if present |
| 15 | `ELECTRON_SETUP.md` claims auto-update is ready, but there is no `electron-updater` dependency | `ELECTRON_SETUP.md` | Documentation is wrong |
| 16 | `src/services/commandParser.ts` returns hardcoded fake responses for several commands (e.g. "show players" always reports three players named Marlo...) | `src/services/commandParser.ts` | Console commands are mostly mock, not wired to the server |
| 17 | `electron/config-manager.ts` stores the API key in plaintext JSON under the app userData folder | `electron/config-manager.ts` | Security issue. Use `safeStorage` instead |
| 18 | `electron/server-process.ts` `checkFirewall` interpolates a port into a shell command (`netsh`/`ufw`) | `electron/server-process.ts` | Command-injection risk if port input is ever non-numeric. Validate as integer first |
| 19 | `testNetwork` only does a DNS lookup | `electron/server-process.ts` | Does not test real connectivity |
| 20 | `src/main/game-server.ts` registers SIGINT and SIGTERM handlers in the constructor, and its `main()` uses `require.main === module` | `src/main/game-server.ts` | Breaks under ESM and causes duplicate handlers if multiple instances are created |

### 4.3 Things not verified

- Exact compiler output for the two user-reported errors.
- Whether `src/main/auth/`, `src/main/setup-admin.ts`, `src/main/threading/worker-pool.ts`, and `src/main/game-logic/game-loop.ts` exist. They are referenced but were not confirmed.
- `ELECTRON_SETUP.md` security claims beyond what is listed above.

---

## 5. Components: Exist vs Missing

### 5.1 Exists and is mounted

| Component | File | Notes |
|---|---|---|
| Electron main | `electron/main.ts` | 1024x768 window (min 800x600). Preload at `path.join(__dirname,'preload.js')`. Loads `http://localhost:5173` in dev, `dist/index.html` otherwise |
| Preload | `electron/preload.ts` | Exposes `window.electron` with getConfig, saveConfig, validateConfig, startServer, stopServer, getServerStatus, checkPort, getSuggestedPort, testNetwork, checkFirewall |
| Config manager | `electron/config-manager.ts` | Stores `server-config.json` in userData. Defaults: baseUrl `http://localhost:8000`, port 3000, serverName "Agervis Server", maxPlayers 100 |
| Server process manager | `electron/server-process.ts` | Spawns the server with env PORT, API_KEY, BASE_URL, SERVER_NAME, MAX_PLAYERS. Port scan up to +100. Stop sends kill, then SIGKILL after 1s |
| Tray | `electron/tray/tray-manager.ts` | Menu: Show, Status, Start, Stop, Quit. Click toggles window |
| Main window root | `src/renderer/main/MainWindow.tsx` | Chooses SetupWizard or ServerControls |
| Server controls | `src/renderer/main/ServerControls.tsx` | Polls status every 2s. Start/stop buttons. Network and firewall cards |
| Setup wizard | `src/renderer/setup/SetupWizard.tsx` | Two steps: API key and base URL (with network test), then port, name, max players (with port check and suggested port). Saves via `validateConfig` then `saveConfig`. Uses inline "standalone" forms |
| Unused setup forms | `src/renderer/setup/ApiKeyForm.tsx`, `ServerConfig.tsx` | Not used by the wizard; duplicates of the inline forms |
| Entry | `src/main.tsx` | Renders `MainWindow` inside StrictMode |
| Type declaration | `src/types/electron.d.ts` | Duplicates the preload `Window.electron` type |

### 5.2 Exists but not mounted

| Component | File | Notes |
|---|---|---|
| Dashboard shell | `src/App.tsx` | Theme toggle, login gate (`localStorage` key `auth_token`), WebSocket status, `Layout` |
| Login | `src/components/auth/Login.tsx` | POSTs to `/api/auth/login`, stores token in `localStorage`. Works only if the dashboard is mounted and the server is reachable |
| Layout and sidebar | `src/components/layout/Layout.tsx`, `Sidebar.tsx` | Tabs: overview, players, economy, admin, logs, settings, chat, analytics. Keyboard shortcuts: `/` focuses console, Ctrl+T toggles theme, 1-8 switch tabs, Escape blurs console |
| Tabs, console, map | `src/components/tabs/*`, `src/components/console/Console.tsx`, `src/components/map/WorldMap.tsx` | Present, not verified in detail |
| Map editor UI | `src/renderer/map-editor/*` | Present, not verified in detail |

### 5.3 Missing or incomplete

| Item | Status |
|---|---|
| `@types/electron` | Not installed (not needed for Electron 31's bundled types, but referenced by the user's build issue) |
| `electron-reloader` | Referenced by `electron/index.ts`, not in package.json |
| `electron-rebuild` / `@electron/rebuild` | Missing; needed for better-sqlite3 |
| `electron-updater` | Missing; auto-update is claimed but not implemented |
| `dist/electron/`, `dist/server.js` | Not generated |
| `assets/icon.png` | Path referenced; not verified present |
| Server output console viewer, config import/export, crash reporting, installer assets | Not done (per `IMPLEMENTATION_CHECKLIST.md`) |
| Dashboard WebSocket endpoint `/ws/dashboard` | Not implemented in the server code read |
| Dashboard REST endpoints `/api/console/parse` and `/api/auth/*` | `auth-routes.ts` defines `/login`, `/logout`, `/verify` (mounting point not confirmed). `/api/console/parse` not confirmed |
| Real command handling in console | Mostly mock in `commandParser.ts` |
| Dashboard mounted in Electron | `App.tsx` is not reachable from `src/main.tsx` |

---

## 6. Intended Interaction with the Game Server

There are three layers of interaction. Only the first is real in the Electron code today.

1. **Process control (real in Electron code).** `ServerProcess` spawns a Node child process and passes configuration as environment variables (PORT, API_KEY, BASE_URL, SERVER_NAME, MAX_PLAYERS). It reports status (running, uptime, pid, port). It stops the child by kill, then SIGKILL after 1s. The spawned path (`dist/server.js`) does not exist yet, so this is untested end to end.

2. **Admin WebSocket (intended, not implemented on the server side read).** `useWebSocket` connects to `ws://localhost:3000/ws/dashboard?token=<auth_token>` and reconnects with exponential backoff (up to 10 attempts, max 30s). The server WebSocket (`src/main/websocket/server.ts`) expects a game handshake: the first message must be `MessageType.HANDSHAKE` with `payload.authToken`, which is validated by `AuthManager.validateToken`. Once validated, messages route by type (HEARTBEAT, GAME_STATE, GAME_EVENT, COMMAND). A dashboard-specific feed (players, economy, logs, status) would need new message types or a separate route.

3. **Admin REST (intended).** `Login.tsx` calls `POST /api/auth/login`. `auth-routes.ts` provides login (returns `{ token }`), logout (Bearer token), and verify (returns id, username, role). Console commands fall back to `POST /api/console/parse`, which is not confirmed on the server side.

**Authentication flow:** The admin logs in with a username and password, gets a token, stores it in `localStorage` as `auth_token`, and sends it on the WebSocket query string and the Bearer header. Initial admin is created by `setupInitialAdmin` at server initialization (referenced; not verified).

**Game client relationship:** The Godot client (`godot_game/Agervis_Local/scripts/main.gd`) shows a public address using `Build10.MAIN_SERVER_HOST` and `MAIN_SERVER_PORT`, and its UI tells players to make sure the Agervis server and playit.gg are running. The dashboard does not manage playit.

**Port expectations are inconsistent** (see Section 4.2, item 11). The dashboard assumes 3000, the server config defaults to 10813, and the Electron setup wizard defaults to 3000 for the server port.

---

## 7. Dependencies and Their Purposes

### 7.1 Runtime dependencies (root `package.json`)

| Package | Version | Purpose in this project |
|---|---|---|
| react, react-dom | ^18.3.1 | Renderer UI |
| zustand | ^4.4.1 | Dashboard store (`src/store/dashboard.ts`: activeTab, serverStatus, theme) |
| recharts | ^2.12.0 | Analytics charts |
| lucide-react | ^0.408.0 | Icons |
| ws | ^8.14.2 | WebSocket server in `src/main/websocket/` and the client path |
| better-sqlite3 | ^9.2.2 | SQLite for the server code in `src/main/database/` (native; needs Electron rebuild) |
| isomorphic-dompurify | ^11.2.0 | Sanitizing HTML in chat or log content |

### 7.2 Dev dependencies

| Package | Purpose |
|---|---|
| electron ^31.0.0 | Desktop shell |
| electron-builder ^24.6.4 | Packaging and installers |
| typescript ^5.3.3 | Compiler |
| vite ^5.0.8, @vitejs/plugin-react ^4.2.1 | Dev server and bundling |
| tailwindcss ^3.4.1, postcss, autoprefixer | Styling |
| @types/react, @types/react-dom ^18.3.0 | Types |
| @types/node ^20.10.0 | Node types |
| vitest ^1.1.0 | Unit tests (no test files confirmed in `tests/`) |
| eslint ^8.56.0 | Linting |
| concurrently ^8.2.0 | Runs Vite and Electron together in `npm run dev` |
| cross-env ^7.0.3 | Sets `NODE_ENV` in scripts |

### 7.3 Not declared but referenced

| Name | Where referenced | Notes |
|---|---|---|
| electron-reloader | `electron/index.ts` | Dev hot reload. Missing |
| express | `src/main/api/auth-routes.ts` | Missing from root package.json |
| @anthropic-ai/sdk, dotenv | `server/` package | Declared only in `server/package.json` |
| playit-reversed | Not found in any dependency file | playit.gg is an external tunnel tool that the player runs. It is **not** a dependency of the dashboard. Do not add it as a package |

### 7.4 Server package (`server/package.json`)

| Package | Version | Purpose |
|---|---|---|
| @anthropic-ai/sdk | ^0.32.1 | Claude calls for AI NPC conversations (BYOK) |
| better-sqlite3 | ^11.8.1 | Database (different version from root) |
| ws | ^8.18.0 | WebSocket server for the Godot client |
| dotenv | ^16.4.7 | Env loading |

Dev: tsx, typescript ^5.7.3, @types/better-sqlite3, @types/node ^22, @types/ws.

---

## 8. Suggested Next Steps (for a future session)

1. Decide which server tree is the game server (`src/main/` or `server/`). Remove or archive the other to avoid two copies of the same logic.
2. Pick one port (3000 or 10813) and align Vite proxy, server config, Electron defaults, and `useWebSocket`.
3. Fix the module system. Either drop `"type": "module"` and keep CommonJS for Electron, or move the Electron build to ESM with `import.meta.url`.
4. Add `electron-rebuild` (or `@electron/rebuild`) with a `postinstall` step, and unify better-sqlite3 to one version.
5. Add `electron-reloader` or remove the dev-only require.
6. Decide whether `App.tsx` replaces `MainWindow`, or is a separate window. Mount it deliberately.
7. Implement the `/ws/dashboard` endpoint and its message types, or change the client to use the existing protocol.
8. Replace mock responses in `commandParser.ts` with real server calls.
9. Move the API key to Electron `safeStorage`, and validate the port as an integer before shell interpolation.
10. Update `ELECTRON_SETUP.md` to remove the claim that auto-update is ready.
