# Agervis Server Software - Design Bible

**Version:** 1.0  
**Last Updated:** 2026-10-04  
**Project:** Agervis: First Block - Server Rebuild

---

## Table of Contents
1. [Project Vision](#project-vision)
2. [Core Principles](#core-principles)
3. [Technology Stack](#technology-stack)
4. [Architecture Overview](#architecture-overview)
5. [AI Integration Strategy](#ai-integration-strategy)
6. [Monetization Strategy](#monetization-strategy)
7. [User Experience Goals](#user-experience-goals)
8. [Feature Catalog](#feature-catalog)
9. [Implementation Phases](#implementation-phases)

---

## Project Vision

### Mission Statement
Build a feature-rich, AI-powered multiplayer game server that is **famous and huge** as AI technology gains mainstream attention. The server must be so easy to use that non-technical friends can host their own instances without help.

### Why This Project Matters
- AI is still relatively new and getting significant attention
- Multiplayer RPGs haven't fully leveraged modern AI capabilities
- Easy hosting democratizes game server ownership
- BYOK (Bring Your Own Key) model makes rich AI interactions sustainable

### Success Criteria
1. Non-technical users can set up and run a server in under 5 minutes
2. AI features feel seamless and impressive to players
3. Server admin dashboard is feature-rich yet intuitive
4. Operating costs are sustainable through BYOK and paid tiers
5. Project gains attention as a showcase of AI in gaming

---

## Core Principles

### 1. Easy Hosting First
**Every feature must support non-technical hosting.**
- No terminal commands required
- Visual configuration for everything
- Plain English error messages
- One-click setup and updates
- Bundled dependencies (no manual installs)

### 2. AI-Powered, Not AI-Gimmicky
**AI features must enhance gameplay, not just exist for novelty.**
- Director AI makes meaningful world-state decisions
- NPC conversations feel natural and contextual
- AI-generated content maintains consistency
- Players should forget they're talking to AI

### 3. No Pay-to-Win
**Paid features enhance experience, never gameplay power.**
- Free and paid players achieve the same goals
- Paid features offer convenience, immersion, personalization
- No tactical advantages from AI for paid members
- BYOK keeps power-user costs down

### 4. Feature-Rich Admin Tools
**Admins get an "amazing" dashboard with everything they need.**
- Real-time world visualization
- Deep analytics and reporting
- Moderation tools with context
- AI monitoring and cost tracking
- One-click common operations

### 5. Absolute Persistence
**Never give up on implementing features.**
- Find alternative approaches when blocked
- No "that's too hard" cop-outs
- Ship complete features, not half-implementations
- Keep humor dark and casual when appropriate

---

## Technology Stack

### Desktop Application
- **Framework:** Electron
- **Reason:** Cross-platform (Windows/Mac/Linux), bundles everything, mature ecosystem
- **Alternatives Considered:** Tauri (rejected: less mature, smaller ecosystem)

### Server Backend
- **Runtime:** Node.js (bundled with Electron)
- **Language:** TypeScript
- **Networking:** WebSocket (native, no Socket.io)
- **Reason:** JavaScript ecosystem, easy Electron integration, async-first

### Admin Dashboard
- **Framework:** React 18+
- **Build Tool:** Vite
- **Styling:** TailwindCSS
- **Reason:** Fast dev experience, modern, great with Electron

### Database
- **Primary:** SQLite (bundled)
- **Migration Path:** PostgreSQL for large deployments (future)
- **Reason:** Zero-config, portable, perfect for single-server setups

### AI Integration
- **Provider:** Anthropic Claude API (custom base_url support)
- **Endpoints:** OneProvider, official Anthropic, custom proxies
- **Models:**
  - **Director AI:** Sonnet 5.5 (reasoning, world-state analysis)
  - **NPC Conversations:** Haiku 4.5 (default), Sonnet 5.5 (major NPCs)
  - **Quest Generation:** Sonnet 5.5 (creativity)
  - **Moderation:** Haiku 4.5 (fast, cheap classification)
  - **Lore/Events:** Sonnet 5.5 (narrative quality)

### Game Client Protocol
- **Protocol:** Godot WebSocket (port 10813, protocol v13)
- **Reason:** Compatibility with existing decompiled client

---

## Architecture Overview

### High-Level Structure
```
┌─────────────────────────────────────────────────────────┐
│  Electron Desktop App (Cross-Platform Executable)       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────┐    ┌──────────────────────────┐│
│  │  Setup Wizard GUI  │    │  Admin Dashboard (React) ││
│  │  (React)           │◄──►│  - Live map              ││
│  │  - API key setup   │    │  - Player management     ││
│  │  - Server config   │    │  - AI control center     ││
│  │  - Port selection  │    │  - Analytics             ││
│  └────────────────────┘    └──────────────────────────┘│
│           │                           │                  │
│           ▼                           ▼                  │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Node.js Server (TypeScript)               │  │
│  ├──────────────────────────────────────────────────┤  │
│  │  ┌────────────────┐  ┌───────────────────────┐  │  │
│  │  │ WebSocket      │  │ AI Integration Layer  │  │  │
│  │  │ Server         │  │ - Director AI         │  │  │
│  │  │ (Game Clients) │  │ - NPC conversations   │  │  │
│  │  └────────────────┘  │ - Request queue       │  │  │
│  │                      │ - Token tracking      │  │  │
│  │  ┌────────────────┐  └───────────────────────┘  │  │
│  │  │ Game Logic     │                             │  │
│  │  │ - Combat       │  ┌───────────────────────┐  │  │
│  │  │ - Economy      │  │ Persistent Storage    │  │  │
│  │  │ - Evidence     │  │ (SQLite)              │  │  │
│  │  │ - NPCs         │  │ - Player profiles     │  │  │
│  │  └────────────────┘  │ - World state         │  │  │
│  │                      │ - Conversation history│  │  │
│  │                      │ - Admin accounts      │  │  │
│  │                      └───────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                           │                             │
└───────────────────────────┼─────────────────────────────┘
                            ▼
              ┌──────────────────────────────┐
              │ Anthropic Claude API         │
              │ (or OneProvider/custom)      │
              └──────────────────────────────┘
```

### Threading Model
```
Main Thread (Electron)
├── Renderer Process (React UI)
└── Main Process
    ├── WebSocket Server Thread (game clients)
    ├── Game Logic Thread (world simulation)
    ├── AI Request Thread (queue processor)
    └── Database Thread (writes/reads)
```

---

## AI Integration Strategy

### Configuration
Server admins provide during setup:
- **Base URL:** e.g., `https://api.oneprovider.com/v1` or `https://api.anthropic.com`
- **API Key:** Admin's personal API key
- **Model Selection:** Per-feature model configuration
- **Token Limits:** Daily/monthly budget caps

### Director AI System
**Role:** Persistent agent that monitors entire game world and makes high-level decisions.

**Responsibilities:**
- Track all player actions and world events
- Determine NPC moods and behavioral states
- Generate dynamic events based on player patterns
- Mediate conflicts and spawn consequences
- Maintain narrative coherence

**Implementation:**
- Runs on Sonnet 5.5 (needs strong reasoning)
- Maintains persistent context with periodic summaries
- Updates every 30-60 seconds (configurable)
- Outputs JSON decisions for game systems to execute

**Example Prompt Structure:**
```
You are the Director AI for Agervis, monitoring a multiplayer urban RPG.

Current World State:
- 12 players online
- 3 crimes in progress
- 2 police officers on patrol
- Officer Pike at heat threshold for Player "Marlo"

Recent Events (last 60s):
- Player "Marlo" attacked civilian in alley
- Witness "Janet" saw the attack
- Blood evidence at scene

Your task: Determine NPC reactions and generate events.
Output JSON format: {...}
```

### NPC Conversation System
**Role:** Enable natural language chat between players and NPCs.

**Flow:**
1. Player sends chat directed at NPC
2. Server checks if player has BYOK enabled
3. Route to player's key (if BYOK) or server's fallback key
4. Inject NPC personality + current mood from Director AI
5. Include conversation history (last 10-50 messages)
6. Stream response back to player

**Model Selection:**
- Background NPCs: Haiku 4.5 (cheap, fast)
- Major NPCs (Moth, Officer Pike, Boss): Sonnet 5.5 (richer personalities)
- Configurable per-NPC in admin dashboard

**Example NPC Prompt:**
```
You are "Moth", a drug dealer in Agervis.

Personality: Cautious, trust-based relationships, speaks in street slang.
Current Mood: Nervous (Director AI detected police nearby)
Relationship with Player "Marlo": Neutral (2 prior interactions)

Conversation History:
[last 10 messages]

Player says: "Hey Moth, got anything for me?"

Respond as Moth would, staying in character.
```

### BYOK (Bring Your Own Key) System
**Why:** Offsets server AI costs by letting players use their own API keys.

**Implementation:**
- Players enter API key in-game settings
- Keys encrypted with AES-256 before storage
- Server uses player's key for their NPC conversations
- Falls back to server key if player has none
- Token usage tracked per-player in dashboard

**Security:**
- Keys encrypted at rest in database
- Decrypted only in-memory for API calls
- Never logged or exposed in admin dashboard
- Players can revoke/change keys anytime

### AI Rate Limiting
**Prevent abuse and runaway costs:**
- Max requests per player per minute
- Daily token budget per player (BYOK and free-tier)
- Queue system prioritizes requests (paid > free)
- Graceful degradation when limits hit

---

## Monetization Strategy

### Free Tier
- Full gameplay access (no restrictions)
- NPC conversations using server's API key (rate-limited)
- 10-message conversation history with NPCs
- Standard queue priority

### Paid Tier ($5-10/month)
**Non-P2W features only:**

#### Cosmetic & Social
- AI-generated character backstories
- Custom NPC personalities (create your own)
- Personal AI assistant (answers game questions)
- AI photo captions for in-game screenshots
- AI voice synthesis for NPCs (text for free users)

#### Quality of Life
- Priority AI response times (faster queue)
- Extended conversation history (unlimited)
- Unlimited BYOK tokens (if using own key)
- AI quest recommendations based on playstyle
- Smart inventory suggestions

#### Convenience (Not Power)
- AI skill build advisor (suggestions, no stat advantage)
- AI market price predictions (same opportunities for all)
- Route planning (no teleportation or speed boost)
- Lore companion (explains world events)

#### Exclusive Content
- AI-generated personalized daily newspaper
- Dream journal (AI stories about your character)
- Custom radio DJ (AI comments on your actions)
- Therapy NPC (special counselor NPC)

### What is NEVER Monetized (P2W)
❌ Tactical AI advice during combat  
❌ AI warnings about nearby threats  
❌ AI help finding hidden items/secrets  
❌ Better NPC prices or treatment  
❌ AI revealing other players' locations  
❌ Any gameplay advantage in PvP or PvE

### BYOK Users (Any Tier)
- Bring your own Anthropic API key
- Unlimited conversations (your budget)
- Same model quality as paid tier
- Still get paid-tier perks if subscribed

---

## User Experience Goals

### For Server Admins (Non-Technical)
**Goal:** Get a server running in under 5 minutes.

**Experience:**
1. Download single `.exe` file
2. Run installer (one-click, handles everything)
3. Launch app, see setup wizard
4. Enter API key and base_url (validated immediately)
5. Configure server name, port (auto-detected conflicts)
6. Click "Start Server"
7. Dashboard opens, server is live

**No terminal. No config files. No manual dependency installs.**

### For Server Admins (During Operation)
**Goal:** Feel in control, never overwhelmed.

**Experience:**
- Glanceable status: green = good, yellow = warning, red = issue
- Common actions are one-click buttons
- **Natural language console** — Type commands in plain English instead of clicking through menus
- Errors explain what's wrong in plain English
- Logs are filtered (technical details hidden by default)
- Dashboard tabs organize features logically
- Updates download and install automatically

### For Players
**Goal:** AI feels natural, not like a gimmick.

**Experience:**
- Chat with NPCs like you'd chat with friends
- NPCs remember past conversations
- NPCs react to your reputation and recent actions
- AI-generated events feel organic, not scripted
- Director AI decisions are invisible but impactful

---

---

## AI-Assisted Map Editor

### Concept
Admins can type a RoomID in the server dashboard to open a map editor where they describe what they want ("dark alley with graffiti", "abandoned apartment") and AI suggests tile placement using the existing tileset. This hybrid approach combines pre-made art assets with AI-powered layout assistance.

### Why This Approach Works
- **No expensive image generation** — AI only suggests placement of existing tiles (text-only API calls)
- **Cost-effective** — ~$0.001-0.003 per room generation vs $1+ for image generation
- **Maintains art consistency** — All tiles are pre-made by the developer, ensuring cohesive style
- **Fast iteration** — Admins can quickly prototype room layouts without manual tile-by-tile placement

### User has 60% of graphics already drawn
The project already has a substantial tileset completed. The AI will analyze these existing assets to match descriptions with appropriate tiles.

### Implementation Strategy: Hybrid Vision + Tags

**Phase 1: Vision-Based Matching (Launch)**
- Upload tileset images to Claude with vision
- Admin describes room: "run-down alley with trash and graffiti"
- AI analyzes tileset images and picks appropriate tiles
- Returns tile coordinates and placements as JSON
- Cost: ~$0.01-0.03 per room (vision API calls)

**Phase 2: Learning System (Post-Launch)**
- System learns from Phase 1 usage patterns
- Builds semantic tag database automatically ("brick_wall_dark", "graffiti_red", "trash_pile")
- Gradually transitions to text-only AI calls
- Cost drops to ~$0.001 per room (100x cheaper)

**Phase 3: Full Tag Library (Long-Term)**
- Developer tags remaining tiles manually or via AI batch processing
- System primarily uses text-only calls
- Vision fallback only for new/untagged tiles

### Core Features

1. **Room Template Library**
   - Pre-built templates: urban alley, apartment interior, street corner, store interior
   - AI combines and modifies templates based on descriptions
   - "Cramped abandoned apartment" = apartment template + decay tiles + sparse furniture

2. **Multi-Layer System**
   - Ground layer (floors, roads, grass)
   - Object layer (furniture, decorations, interactive items)
   - Overhead layer (roofs, signs, ceiling elements)
   - Collision layer (auto-generated from object placement)

3. **Semantic Tile Intelligence**
   - Tiles tagged with properties: wall, floor, decoration, interactive, obstacle
   - AI understands spatial relationships
   - "Add a couch" → AI places against wall, not in doorway
   - "Make this dangerous" → AI selects tiles tagged "crime", "decay", "broken"

4. **Smart Collision Generation**
   - One-click auto-generate collision layer
   - Walls = solid collision boxes
   - Furniture = obstacle collision
   - Floor tiles = walkable
   - Manual override available for edge cases

5. **Lighting Hints System**
   - AI suggests light source placement data
   - Windows → ambient light zones
   - Streetlights → point lights at poles
   - Dark alleys → reduced visibility areas
   - Exports lighting data for Godot client

6. **Procedural Detail Layer**
   - AI adds randomized small details automatically
   - Litter placement in alleys
   - Cracks in old pavement
   - Window blinds open/closed variety
   - Makes rooms feel lived-in without manual work

7. **Variation Generator**
   - "Generate 5 apartment variations"
   - AI creates similar but distinct rooms
   - Same tileset, different arrangements
   - Useful for populating large buildings quickly

8. **Undo/History Stack**
   - Track every AI generation with before/after states
   - Step backward through changes
   - Compare versions side-by-side

9. **Multi-Format Export**
   - Godot TileMap format (native client support)
   - JSON room data (for custom loaders)
   - PNG preview (visual documentation)
   - Collision data export

### UI Workflow

1. **Open Editor**
   - Admin enters RoomID or creates new room
   - Editor loads current layout (or blank grid if new)

2. **Describe Layout**
   - Text input: "Make this look like a run-down alley"
   - AI analyzes tileset and generates placement JSON
   - Preview renders immediately

3. **Review & Adjust**
   - Visual preview shows AI-suggested layout
   - Manual tile picker available for adjustments
   - Layer visibility toggles
   - Zoom/pan controls

4. **Auto-Generate Details**
   - Click "Add Details" for procedural decoration
   - Click "Generate Collision" for auto collision layer
   - Click "Suggest Lighting" for light placement hints

5. **Save & Export**
   - Save to database
   - Export to Godot format
   - Push updates to connected clients in real-time

### Technical Architecture

**Backend:**
- Room storage in SQLite (tile coordinates + metadata)
- AI integration via Claude API (vision + text)
- Tile library index with semantic tags
- Template system with JSON definitions
- Export pipeline for multiple formats

**Frontend:**
- HTML5 Canvas for map rendering
- Tile palette sidebar
- Layer management UI
- Real-time preview
- Drag-and-drop tile placement (manual override)

**AI Pipeline:**
```
User description → Claude (vision/text) → Tile selection JSON → Render preview → Export
```

### Cost Analysis

**Vision-based (Phase 1):**
- Tileset analysis: $0.01 per room (one-time per session)
- Layout generation: $0.02 per room
- Total: ~$0.03 per room generation

**Tag-based (Phase 3):**
- Layout generation: $0.001 per room (text-only)
- 100x cheaper at scale

**Comparison to image generation:**
- AI image generation would cost $1-5 per tile
- 60% of graphics already drawn saves ~$10,000-30,000 in generation costs
- Maintains consistent art style

### Example Prompts

```
> Create a dark alley with graffiti and trash
[AI places dark brick walls, spray paint tiles, dumpster, scattered trash items]

> Make this a cozy apartment
[AI places warm wood floors, furniture against walls, window with curtains, plants]

> Generate a crime scene investigation area
[AI places police tape tiles, evidence markers, chalk outline, blood splatter tiles]

> Create 3 variations of a corner store interior
[AI generates 3 layouts: minimal stock, well-stocked, ransacked versions]
```

---

## Natural Language Console

### Concept
Instead of navigating through GUI menus, admins can type commands in plain English directly into a console. The server parses natural language and executes actions.

### Examples
```
> kick player marlo
[Kicked player "Marlo" (ID: 1234)]

> teleport player citizen to downtown:police_station
[Teleported "Citizen" to downtown:police_station]

> show me players with heat above 100
[Found 3 players: Marlo (120), PlayerX (105), Criminal42 (140)]

> ban player 1234 for 7 days reason griefing
[Banned player 1234 for 7 days. Reason: griefing]

> broadcast server restart in 5 minutes
[Broadcast sent to 12 players: "server restart in 5 minutes"]

> what's the total money in circulation
[Total money: $125,439 (clean: $87,230, dirty: $38,209)]

> spawn event fire at downtown:restaurant
[Spawned fire event at downtown:restaurant]

> give player marlo $5000
[Gave $5000 to player "Marlo"]

> reset heat for player citizen
[Reset heat to 0 for player "Citizen"]

> show ai token usage today
[Total tokens today: 45,230 | Server key: 12,450 | BYOK: 32,780]
```

### Implementation
- Text input at bottom of dashboard (always accessible, hotkey: `/` or `Ctrl+K`)
- Parse commands with regex patterns + fallback to AI for complex queries
- Auto-complete suggestions as user types
- Command history (up/down arrows)
- Help command: `> help` or `> ?`

### Command Categories
- **Player Management:** kick, ban, mute, teleport, spectate, freeze
- **Server Control:** restart, shutdown, broadcast, save, backup
- **Economy:** give money, take money, reset economy, adjust prices
- **World State:** spawn event, despawn npc, change weather, set time
- **AI Control:** restart director, clear npc memory, show token usage
- **Queries:** show players, show evidence, show logs, show stats

### AI Fallback
If the command doesn't match known patterns, send it to Claude Haiku to parse intent and generate structured JSON for execution.

```
User types: "show me everyone near the police station"
→ Haiku parses → {action: "query_players", filters: {area: "police_station", radius: 50}}
→ Server executes → Returns player list
```

---

## Feature Catalog

See [FEATURES.md](FEATURES.md) for complete list of 151 features across:
- Core Server Architecture (10)
- AI Infrastructure (20)
- Advanced AI Features (10)
- Admin Dashboard Backend (20)
- Admin Dashboard Frontend (21)
- Game Systems Integration (15)
- Desktop App & Easy Hosting (25)
- Security & Anti-Cheat (8)
- Testing & Development (8)
- Deployment & Operations (8)
- API & Integration (6)

---

## Implementation Phases

### Phase 0: Foundation (Week 1-2)
**Goal:** Electron app skeleton, basic server, database setup.

**Deliverables:**
- Electron app boots and shows placeholder UI
- Node.js WebSocket server accepts connections
- SQLite database initialized with schema
- Basic world state manager (no game logic yet)

**Success Criteria:**
- App installs and launches on Windows
- Server accepts test WebSocket connection
- Database stores dummy player data

---

### Phase 1: Easy Hosting Infrastructure (Week 2-3)
**Goal:** Setup wizard, start/stop controls, bundled dependencies.

**Deliverables:**
- Visual setup wizard (React)
  - API key input form with validation
  - Base URL configuration
  - Port selection with conflict detection
  - Server name and max players
- Start/Stop/Restart buttons
- Server status indicator (green/yellow/red)
- Plain-English error display
- Auto-configure database on first launch

**Success Criteria:**
- Non-technical user can complete setup without help
- Server starts/stops via GUI buttons
- Errors are understandable without technical knowledge

---

### Phase 2: AI Infrastructure (Week 3-5)
**Goal:** AI request queue, token tracking, BYOK system.

**Deliverables:**
- Claude API client with custom base_url support
- AI request queue with prioritization
- Token usage tracker (per-player, real-time)
- BYOK key management (encryption, storage)
- Fallback to server key when no BYOK
- Rate limiting (per-player, per-endpoint)
- Prompt template system
- AI error recovery and retry logic

**Success Criteria:**
- Can send/receive messages from Claude API
- Token usage tracked accurately
- BYOK keys stored encrypted
- Rate limits prevent abuse

---

### Phase 3: Director AI System (Week 5-7)
**Goal:** Persistent AI monitoring game world and making decisions.

**Deliverables:**
- Director AI loop (updates every 30-60s)
- World state serialization for AI context
- Event detection system
- NPC mood/behavior state updates
- Dynamic event spawning based on AI decisions
- JSON output parser for AI responses

**Success Criteria:**
- Director AI receives world state updates
- NPCs react to AI-determined moods
- Events spawn based on player behavior
- Admin dashboard shows Director decisions

---

### Phase 4: NPC Conversation System (Week 7-9)
**Goal:** Players can chat naturally with NPCs.

**Deliverables:**
- Chat routing (player → NPC → AI → response)
- NPC personality profiles (Moth, Pike, Boss, etc.)
- Conversation history storage (per-NPC, per-player)
- Inject Director AI mood into NPC prompts
- Model selection per-NPC (Haiku vs Sonnet)
- Streaming responses back to player

**Success Criteria:**
- Players can type messages to NPCs in-game
- NPCs respond in-character with contextual awareness
- Conversation history persists across sessions
- BYOK and fallback keys both work

---

### Phase 5: Admin Dashboard Frontend (Week 9-11)
**Goal:** Feature-rich React dashboard with real-time data.

**Deliverables:**
- 8-tab interface (Overview, Players, Economy, Admin, Logs, Settings, Chat, Analytics)
- Live 2D world map with player/NPC markers (Canvas)
- AI Control Center UI
  - View Director decisions
  - Monitor active conversations
  - Token usage charts per player
- Player management grid (kick, ban, teleport)
- Economy dashboard (transaction logs, wealth distribution)
- Performance graphs (CPU, memory, bandwidth)
- Chat monitor with moderation tools
- Dark/Light theme toggle

**Success Criteria:**
- Dashboard updates in real-time via WebSocket
- All tabs functional with live data
- Map shows accurate player/NPC positions
- Actions (kick, ban, teleport) work from UI

---

### Phase 6: Game Systems Integration (Week 11-14)
**Goal:** Implement core game mechanics from decompiled client.

**Deliverables:**
- Combat resolution engine (frame-based)
- Evidence tracking (blood, DNA, witnesses)
- Heat/wanted system (0-140 scale)
- NPC AI controller (roaming, schedules, stress)
- Economy transaction processor
- Job system (cashier, delivery, security)
- Skill progression (14 types)
- Property management
- Inventory system
- Time/weather controller
- Arrest & jail system

**Success Criteria:**
- Players can fight, earn money, get arrested
- Evidence persists and affects gameplay
- NPCs follow daily schedules
- Economy transactions tracked

---

### Phase 7: Advanced AI Features (Week 14-16)
**Goal:** AI-powered gameplay enhancements.

**Deliverables:**
- Dynamic quest generation
- Real-time event commentary/narration
- Adaptive difficulty (AI adjusts NPC responses)
- Personality synthesis (generate unique NPCs on-fly)
- Conflict mediation AI
- Economic forecasting AI
- Behavior pattern analysis (anti-cheat)
- Auto-moderation (toxic chat detection)
- Lore generation for locations/NPCs
- Procedural dialogue branching

**Success Criteria:**
- AI generates contextual quests based on player actions
- NPCs feel unique and evolve over time
- Suspicious patterns flagged in admin dashboard
- Toxic behavior auto-flagged for review

---

### Phase 8: Security & Anti-Cheat (Week 16-17)
**Goal:** Protect against exploits and abuse.

**Deliverables:**
- Input validation (all client messages sanitized)
- Action rate limiting (prevent spam)
- Position validation (impossible movement detection)
- Economy sanity checks (flag suspicious transactions)
- Auth token system (secure sessions)
- SQL injection prevention (parameterized queries)
- XSS protection (sanitize user content)
- Automated ban system (cheaters auto-banned)

**Success Criteria:**
- Common exploits blocked
- Suspicious activity flagged automatically
- No SQL injection or XSS vulnerabilities

---

### Phase 9: Testing & Polish (Week 17-18)
**Goal:** Ensure stability and usability.

**Deliverables:**
- Unit test suite (core logic)
- Integration tests (full server behavior)
- Load testing (simulate 25+ players)
- Mock AI system (test without real API)
- Database seeding (generate test data)
- Bug fixes from testing
- Performance optimizations
- UI polish and consistency

**Success Criteria:**
- All tests pass
- Server handles 25 concurrent players smoothly
- No critical bugs
- UI feels polished

---

### Phase 10: Deployment & Operations (Week 18-19)
**Goal:** Packaging, distribution, auto-updates.

**Deliverables:**
- Electron build pipeline (Windows/Mac/Linux)
- One-click installer
- Auto-update system
- Crash report collection
- Log rotation
- Automated backups
- Config import/export
- Documentation (user guide, admin guide)

**Success Criteria:**
- Installer works on all platforms
- Updates download/install automatically
- Crashes generate useful reports
- Documentation is clear

---

### Phase 11: Monetization & BYOK (Week 19-20)
**Goal:** Implement paid tier and BYOK.

**Deliverables:**
- Paid tier account system
- Payment integration (Stripe/PayPal)
- Feature gating (paid vs free)
- BYOK unlimited tokens for paid users
- AI-generated backstories
- Custom NPC creator
- Personal AI assistant
- Priority queue for paid users

**Success Criteria:**
- Users can subscribe and payment works
- Paid features unlock correctly
- No P2W advantages

---

### Phase 12: Community & Polish (Week 20+)
**Goal:** Launch-ready, community features.

**Deliverables:**
- Discord bot integration
- REST API for external tools
- Webhook system
- Plugin system foundation
- Website/landing page
- Marketing materials
- Community Discord server

**Success Criteria:**
- Project is launch-ready
- Community can build external tools
- Discord integration works

---

## Design Decisions Log

### Why Electron over Tauri?
**Decision:** Use Electron  
**Reason:** Mature ecosystem, better Node.js integration, wider community support  
**Trade-off:** Larger binary size, higher memory usage  
**Date:** 2026-10-04

### Why SQLite over PostgreSQL?
**Decision:** Start with SQLite, PostgreSQL for later  
**Reason:** Zero-config for easy hosting, portable, perfect for single-server  
**Trade-off:** Won't scale to massive deployments (acceptable for v1)  
**Date:** 2026-10-04

### Why BYOK Model?
**Decision:** Support player-provided API keys  
**Reason:** Offsets server AI costs, enables unlimited conversations for power users  
**Trade-off:** More complex key management, encryption required  
**Date:** 2026-10-04

### Why No P2W?
**Decision:** Paid features never provide gameplay advantages  
**Reason:** Fairness, long-term community health, aligns with RPG values  
**Trade-off:** Limits monetization potential  
**Date:** 2026-10-04

---

## File Structure

```
Agervis 1/
├── DESIGN_BIBLE.md          (this file)
├── FEATURES.md              (complete feature list)
├── README.md                (project overview)
├── src/
│   ├── main/                (Electron main process)
│   │   ├── server/          (game server logic)
│   │   ├── ai/              (AI integration)
│   │   └── database/        (SQLite management)
│   ├── renderer/            (React UI)
│   │   ├── setup-wizard/    (first-time setup)
│   │   └── dashboard/       (admin dashboard)
│   └── shared/              (types, constants)
├── tests/
├── docs/
└── dist/                    (build output)
```

---

## Tone & Collaboration Style

As specified by user feedback:
- **Fucked up sense of humor** — Keep it casual and darkly humorous when appropriate
- **Absolute persistence** — Never give up on features, find alternative approaches
- **No "too hard" cop-outs** — Ship complete features, not half-implementations
- **Helpful, not instructive** — Show expertise without being condescending

---

## Next Steps

1. ✅ Design bible created
2. ⏳ Review and refine with user
3. ⏳ Set up project structure in `C:\Users\MyBir\Documents\Agervis 1`
4. ⏳ Begin Phase 0: Foundation

**Status:** Awaiting user approval to begin implementation.
