extends Control




const PrivateSession = preload("res://scripts/private_session.gd")
const AuthSystem = preload("res://scripts/auth_system.gd")

signal command_issued(command: String, args: Dictionary)

enum Tab{
	OVERVIEW, 
	PLAYERS, 
	ECONOMY, 
	ADMIN, 
	LOGS, 
	SETTINGS, 
	CHAT, 
	ANALYTICS
}


var lan_session: PrivateSession
var current_tab: Tab = Tab.OVERVIEW


var scroll_offset: = 0.0
var selected_player_id: int = -1
var selected_log_index: int = -1
var chat_input: = ""
var command_input: = ""
var filter_text: = ""
var auto_scroll_logs: = true
var show_system_messages: = true
var log_level_filter: = "all"


var server_start_time: = 0
var total_connections: = 0
var peak_players: = 0
var total_bytes_sent: = 0
var total_bytes_received: = 0
var avg_ping_ms: = 0.0
var cpu_usage: = 0.0
var memory_usage_mb: = 0.0


const BG_DARK: = Color("#111516")
const BG_MED: = Color("#1a1c1e")
const BG_LIGHT: = Color("#222825")
const ACCENT: = Color("#5a7a5a")
const ACCENT_BRIGHT: = Color("#6a9a6a")
const PAPER: = Color("#e8e0d5")
const PAPER_DIM: = Color("#b9b2a7")
const DANGER: = Color("#aa5555")
const GOOD: = Color("#5a8a5a")
const WARNING: = Color("#aa8855")

func _ready() -> void :
	server_start_time = int(Time.get_unix_time_from_system())
	set_process(true)

func _process(delta: float) -> void :
	queue_redraw()
	_update_statistics()

func _draw() -> void :

	draw_rect(Rect2(0, 0, 1280, 720), BG_DARK)


	_draw_header()


	_draw_tabs()


	match current_tab:
		Tab.OVERVIEW:
			_draw_overview_tab()
		Tab.PLAYERS:
			_draw_players_tab()
		Tab.ECONOMY:
			_draw_economy_tab()
		Tab.ADMIN:
			_draw_admin_tab()
		Tab.LOGS:
			_draw_logs_tab()
		Tab.SETTINGS:
			_draw_settings_tab()
		Tab.CHAT:
			_draw_chat_tab()
		Tab.ANALYTICS:
			_draw_analytics_tab()

func _draw_header() -> void :

	draw_rect(Rect2(0, 0, 1280, 60), BG_LIGHT)
	draw_line(Vector2(0, 60), Vector2(1280, 60), ACCENT, 2.0)


	draw_string(ThemeDB.fallback_font, Vector2(20, 38), "AGERVIS MAIN SERVER", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 28, PAPER)


	var status_color: = GOOD if lan_session and lan_session.active else DANGER
	draw_circle(Vector2(1240, 30), 8.0, status_color)


	var uptime: = int(Time.get_unix_time_from_system()) - server_start_time
	var uptime_str: = _format_uptime(uptime)
	draw_string(ThemeDB.fallback_font, Vector2(1180, 38), uptime_str, 
		HORIZONTAL_ALIGNMENT_RIGHT, -1, 16, PAPER_DIM)

func _draw_tabs() -> void :
	var tab_names: = ["OVERVIEW", "PLAYERS", "ECONOMY", "ADMIN", "LOGS", "SETTINGS", "CHAT", "ANALYTICS"]
	var tab_width: = 160
	var tab_y: = 70

	for i in range(tab_names.size()):
		var tab_rect: = Rect2(i * tab_width, tab_y, tab_width, 40)
		var is_active: = i == current_tab


		draw_rect(tab_rect, BG_LIGHT if is_active else BG_MED)

		if is_active:
			draw_line(Vector2(tab_rect.position.x, tab_y), 
				Vector2(tab_rect.position.x + tab_width, tab_y), ACCENT_BRIGHT, 3.0)


		var text_color: = PAPER if is_active else PAPER_DIM
		draw_string(ThemeDB.fallback_font, 
			Vector2(tab_rect.position.x + tab_width / 2, tab_y + 26), 
			tab_names[i], HORIZONTAL_ALIGNMENT_CENTER, -1, 14, text_color)

func _draw_overview_tab() -> void :
	var content_y: = 120
	var left_col: = 20
	var right_col: = 660


	_draw_panel(Rect2(left_col, content_y, 620, 280), "SERVER STATUS")

	var info_y: = content_y + 50
	if lan_session:
		_draw_label_value("Server Mode:", "Main Server", left_col + 20, info_y)
		_draw_label_value("Port:", str(lan_session.port), left_col + 20, info_y + 30)
		_draw_label_value("World ID:", lan_session.server_world_id, left_col + 20, info_y + 60)
		_draw_label_value("Max Players:", str(lan_session.max_players), left_col + 20, info_y + 90)
		_draw_label_value("Connected:", "%d / %d" % [lan_session.peer_states.size(), lan_session.max_players], 
			left_col + 20, info_y + 120)
		_draw_label_value("Peak Players:", str(peak_players), left_col + 20, info_y + 150)
		_draw_label_value("Total Connections:", str(total_connections), left_col + 20, info_y + 180)


	_draw_panel(Rect2(right_col, content_y, 600, 280), "PERFORMANCE")

	var perf_y: = content_y + 50
	_draw_label_value("Avg Ping:", "%.1f ms" % avg_ping_ms, right_col + 20, perf_y)
	_draw_label_value("CPU Usage:", "%.1f%%" % cpu_usage, right_col + 20, perf_y + 30)
	_draw_label_value("Memory:", "%.1f MB" % memory_usage_mb, right_col + 20, perf_y + 60)
	_draw_label_value("Bytes Sent:", _format_bytes(total_bytes_sent), right_col + 20, perf_y + 90)
	_draw_label_value("Bytes Received:", _format_bytes(total_bytes_received), right_col + 20, perf_y + 120)

	if lan_session:
		_draw_label_value("Snapshots Broadcast:", str(lan_session.snapshot_broadcast_count), 
			right_col + 20, perf_y + 150)
		_draw_label_value("Persistence Writes:", str(lan_session.persistence_write_count), 
			right_col + 20, perf_y + 180)


	_draw_panel(Rect2(left_col, content_y + 300, 1240, 280), "QUICK ACTIONS")

	var action_y: = content_y + 340
	_draw_button(Rect2(left_col + 20, action_y, 280, 50), "BROADCAST MESSAGE", ACCENT)
	_draw_button(Rect2(left_col + 320, action_y, 280, 50), "SAVE ALL PROFILES", ACCENT)
	_draw_button(Rect2(left_col + 620, action_y, 280, 50), "VIEW AUDIT LOG", ACCENT)
	_draw_button(Rect2(left_col + 920, action_y, 280, 50), "BACKUP SERVER DATA", ACCENT)

	action_y += 70
	_draw_button(Rect2(left_col + 20, action_y, 280, 50), "EXPORT STATISTICS", ACCENT)
	_draw_button(Rect2(left_col + 320, action_y, 280, 50), "RELOAD CONFIG", WARNING)
	_draw_button(Rect2(left_col + 620, action_y, 280, 50), "KICK ALL IDLE", WARNING)
	_draw_button(Rect2(left_col + 920, action_y, 280, 50), "SHUTDOWN SERVER", DANGER)

func _draw_players_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 1240, 560), "CONNECTED PLAYERS")


	var header_y: = content_y + 40
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, header_y), "ID", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 100, header_y), "NAME", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 300, header_y), "LOCATION", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 500, header_y), "ACCOUNT", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 700, header_y), "PING", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 800, header_y), "CONNECTED", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 1000, header_y), "ACTIONS", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ACCENT_BRIGHT)


	if lan_session and not lan_session.peer_states.is_empty():
		var row_y: = header_y + 30
		for peer_id in lan_session.peer_states:
			var state: Dictionary = lan_session.peer_states[peer_id]
			var is_selected: bool = peer_id == selected_player_id


			var row_rect: = Rect2(left_col + 20, row_y - 18, 1200, 26)
			if is_selected:
				draw_rect(row_rect, ACCENT.darkened(0.6))


			draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, row_y), 
				str(peer_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)


			var name: = String(state.get("name", "Unknown"))
			draw_string(ThemeDB.fallback_font, Vector2(left_col + 100, row_y), 
				name.left(20), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)


			var area: = String(state.get("area", ""))
			var room: = String(state.get("room_id", ""))
			var location: = "%s:%s" % [area, room] if not area.is_empty() else "Unknown"
			draw_string(ThemeDB.fallback_font, Vector2(left_col + 300, row_y), 
				location.left(20), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)


			var account_id: = String(lan_session.peer_accounts.get(peer_id, "Guest"))
			draw_string(ThemeDB.fallback_font, Vector2(left_col + 500, row_y), 
				account_id.left(15), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)


			draw_string(ThemeDB.fallback_font, Vector2(left_col + 700, row_y), 
				"%d ms" % (randi() % 100 + 20), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GOOD)


			var connected_time: = "5m"
			draw_string(ThemeDB.fallback_font, Vector2(left_col + 800, row_y), 
				connected_time, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)


			_draw_small_button(Rect2(left_col + 1000, row_y - 15, 60, 22), "KICK", WARNING)
			_draw_small_button(Rect2(left_col + 1070, row_y - 15, 60, 22), "BAN", DANGER)
			_draw_small_button(Rect2(left_col + 1140, row_y - 15, 80, 22), "TELEPORT", ACCENT)

			row_y += 32
	else:
		draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, header_y + 60), 
			"No players connected", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, PAPER_DIM)

func _draw_economy_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 600, 280), "ECONOMY OVERVIEW")

	var econ_y: = content_y + 50
	_draw_label_value("Total Money in Circulation:", "$125,439", left_col + 20, econ_y)
	_draw_label_value("Bank Holdings:", "$87,230", left_col + 20, econ_y + 30)
	_draw_label_value("Active Businesses:", "12", left_col + 20, econ_y + 60)
	_draw_label_value("Recent Transactions:", "1,247", left_col + 20, econ_y + 90)
	_draw_label_value("Arrests Today:", "8", left_col + 20, econ_y + 120)
	_draw_label_value("Evidence Collected:", "34 items", left_col + 20, econ_y + 150)

	_draw_panel(Rect2(640, content_y, 620, 280), "TRANSACTION LOG")


	var trans_y: = content_y + 50
	draw_string(ThemeDB.fallback_font, Vector2(660, trans_y), 
		"Player A -> Store: $50 (cashier shift)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)
	draw_string(ThemeDB.fallback_font, Vector2(660, trans_y + 25), 
		"Player B -> Bank: $200 (deposit)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)
	draw_string(ThemeDB.fallback_font, Vector2(660, trans_y + 50), 
		"Player C -> Pawn: $75 (sale)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)

	_draw_panel(Rect2(left_col, content_y + 300, 1240, 280), "ECONOMY CONTROLS")

	var control_y: = content_y + 350
	_draw_button(Rect2(left_col + 20, control_y, 280, 50), "ADJUST PRICES", ACCENT)
	_draw_button(Rect2(left_col + 320, control_y, 280, 50), "RESET ECONOMY", WARNING)
	_draw_button(Rect2(left_col + 620, control_y, 280, 50), "EXPORT LEDGER", ACCENT)
	_draw_button(Rect2(left_col + 920, control_y, 280, 50), "VIEW AUDIT TRAIL", ACCENT)

func _draw_admin_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 600, 350), "ADMIN ACCOUNTS")

	var admin_y: = content_y + 50
	if lan_session and not lan_session.admin_accounts.is_empty():
		for account_id in lan_session.admin_accounts:
			var admin_data: Dictionary = lan_session.admin_accounts[account_id]
			var role: = String(admin_data.get("role", "admin"))
			draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, admin_y), 
				"%s (%s)" % [account_id, role], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER)
			admin_y += 30
	else:
		draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, admin_y), 
			"No admin accounts configured", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER_DIM)

	_draw_button(Rect2(left_col + 40, admin_y + 20, 200, 40), "ADD ADMIN", ACCENT)
	_draw_button(Rect2(left_col + 260, admin_y + 20, 200, 40), "MANAGE ROLES", ACCENT)

	_draw_panel(Rect2(640, content_y, 620, 350), "PERMISSIONS")

	var perm_y: = content_y + 50
	_draw_checkbox(Vector2(660, perm_y), true, "Can kick players")
	_draw_checkbox(Vector2(660, perm_y + 30), true, "Can ban players")
	_draw_checkbox(Vector2(660, perm_y + 60), true, "Can modify economy")
	_draw_checkbox(Vector2(660, perm_y + 90), false, "Can shutdown server")
	_draw_checkbox(Vector2(660, perm_y + 120), true, "Can edit rooms")
	_draw_checkbox(Vector2(660, perm_y + 150), true, "Can view audit logs")

	_draw_panel(Rect2(left_col, content_y + 370, 1240, 210), "SERVER COMMANDS")

	var cmd_y: = content_y + 420
	draw_rect(Rect2(left_col + 40, cmd_y, 1160, 40), BG_MED)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 50, cmd_y + 26), 
		"> " + command_input, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER)

	draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, cmd_y + 70), 
		"Commands: /kick [id], /ban [id], /broadcast [msg], /tp [id] [area:room], /economy reset", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, PAPER_DIM)

func _draw_logs_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 1240, 520), "SERVER LOGS")


	var filter_y: = content_y + 40
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, filter_y), 
		"Filter:", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER_DIM)
	draw_rect(Rect2(left_col + 100, filter_y - 18, 300, 30), BG_MED)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 110, filter_y), 
		filter_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER)

	_draw_checkbox(Vector2(left_col + 450, filter_y - 12), show_system_messages, "System Messages")
	_draw_checkbox(Vector2(left_col + 650, filter_y - 12), auto_scroll_logs, "Auto-scroll")


	_draw_small_button(Rect2(left_col + 850, filter_y - 16, 60, 26), "ALL", 
		ACCENT if log_level_filter == "all" else ACCENT.darkened(0.4))
	_draw_small_button(Rect2(left_col + 920, filter_y - 16, 70, 26), "INFO", 
		ACCENT if log_level_filter == "info" else ACCENT.darkened(0.4))
	_draw_small_button(Rect2(left_col + 1000, filter_y - 16, 80, 26), "WARN", 
		WARNING if log_level_filter == "warning" else WARNING.darkened(0.4))
	_draw_small_button(Rect2(left_col + 1090, filter_y - 16, 80, 26), "ERROR", 
		DANGER if log_level_filter == "error" else DANGER.darkened(0.4))


	var log_y: = filter_y + 40
	var log_entries: = _get_sample_logs()

	for i in range(min(18, log_entries.size())):
		var entry: Dictionary = log_entries[i]
		var level: = String(entry.get("level", "info"))
		var message: = String(entry.get("message", ""))
		var timestamp: = String(entry.get("timestamp", "00:00:00"))

		var level_color: = PAPER_DIM
		match level:
			"info": level_color = GOOD
			"warning": level_color = WARNING
			"error": level_color = DANGER
			"admin": level_color = ACCENT_BRIGHT

		draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, log_y), 
			timestamp, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, PAPER_DIM)
		draw_string(ThemeDB.fallback_font, Vector2(left_col + 140, log_y), 
			"[%s]" % level.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, level_color)
		draw_string(ThemeDB.fallback_font, Vector2(left_col + 240, log_y), 
			message.left(90), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, PAPER)

		log_y += 24


	_draw_button(Rect2(left_col + 40, content_y + 550, 200, 40), "CLEAR LOGS", WARNING)
	_draw_button(Rect2(left_col + 260, content_y + 550, 200, 40), "EXPORT LOGS", ACCENT)
	_draw_button(Rect2(left_col + 480, content_y + 550, 200, 40), "REFRESH", ACCENT)

func _draw_settings_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 600, 400), "SERVER CONFIGURATION")

	var setting_y: = content_y + 50
	_draw_label_value("Server Name:", "Agervis Main", left_col + 20, setting_y)
	_draw_label_value("Max Players:", "25", left_col + 20, setting_y + 40)
	_draw_label_value("Port:", "24860", left_col + 20, setting_y + 80)
	_draw_label_value("World ID:", "AGERVIS-MAIN-FIRST-BLOCK", left_col + 20, setting_y + 120)
	_draw_label_value("Profile Path:", "user://agervis_main_server_profiles.save", left_col + 20, setting_y + 160)

	_draw_checkbox(Vector2(left_col + 40, setting_y + 220), true, "Enable persistence")
	_draw_checkbox(Vector2(left_col + 40, setting_y + 250), true, "Auto-save profiles")
	_draw_checkbox(Vector2(left_col + 40, setting_y + 280), false, "Debug mode")
	_draw_checkbox(Vector2(left_col + 40, setting_y + 310), true, "Allow public connections")

	_draw_panel(Rect2(640, content_y, 620, 400), "LIMITS & THROTTLING")

	var limit_y: = content_y + 50
	_draw_label_value("Max Connections/IP:", "3", 660, limit_y)
	_draw_label_value("Chat Rate Limit:", "5/min", 660, limit_y + 40)
	_draw_label_value("Snapshot Rate:", "10 Hz", 660, limit_y + 80)
	_draw_label_value("Idle Timeout:", "15 min", 660, limit_y + 120)
	_draw_label_value("Max Bandwidth:", "5 MB/s", 660, limit_y + 160)

	_draw_checkbox(Vector2(660, limit_y + 220), true, "Enable rate limiting")
	_draw_checkbox(Vector2(660, limit_y + 250), true, "Kick idle players")
	_draw_checkbox(Vector2(660, limit_y + 280), false, "Allow reconnection")

	_draw_panel(Rect2(left_col, content_y + 420, 1240, 160), "BACKUP & RESTORE")

	var backup_y: = content_y + 470
	_draw_button(Rect2(left_col + 40, backup_y, 280, 50), "CREATE BACKUP NOW", ACCENT)
	_draw_button(Rect2(left_col + 340, backup_y, 280, 50), "RESTORE FROM BACKUP", WARNING)
	_draw_button(Rect2(left_col + 640, backup_y, 280, 50), "AUTO-BACKUP SETTINGS", ACCENT)
	_draw_button(Rect2(left_col + 940, backup_y, 280, 50), "VIEW BACKUP HISTORY", ACCENT)

func _draw_chat_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 1240, 480), "GLOBAL CHAT MONITOR")


	var chat_y: = content_y + 40
	var sample_chats: = [
		{"player": "Marlo", "message": "Anyone want to do the store job?", "time": "14:23"}, 
		{"player": "Citizen", "message": "I can help with that", "time": "14:24"}, 
		{"player": "PlayerX", "message": "Where's the bank?", "time": "14:25"}, 
		{"player": "[ADMIN]", "message": "Server restart in 5 minutes", "time": "14:26", "system": true}, 
	]

	for chat in sample_chats:
		var is_system: bool = chat.get("system", false)
		var color: = ACCENT_BRIGHT if is_system else PAPER
		var time: = String(chat.get("time", ""))
		var player: = String(chat.get("player", ""))
		var message: = String(chat.get("message", ""))

		draw_string(ThemeDB.fallback_font, Vector2(left_col + 40, chat_y), 
			"[%s]" % time, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER_DIM)
		draw_string(ThemeDB.fallback_font, Vector2(left_col + 120, chat_y), 
			"%s:" % player, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, 
			ACCENT_BRIGHT if is_system else GOOD)
		draw_string(ThemeDB.fallback_font, Vector2(left_col + 240, chat_y), 
			message, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)

		chat_y += 26


	_draw_panel(Rect2(left_col, content_y + 500, 1240, 80), "BROADCAST MESSAGE")

	draw_rect(Rect2(left_col + 40, content_y + 540, 1000, 35), BG_MED)
	draw_string(ThemeDB.fallback_font, Vector2(left_col + 50, content_y + 562), 
		chat_input, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER)

	_draw_button(Rect2(left_col + 1060, content_y + 540, 160, 35), "SEND", ACCENT)

func _draw_analytics_tab() -> void :
	var content_y: = 120
	var left_col: = 20

	_draw_panel(Rect2(left_col, content_y, 600, 280), "PLAYER STATISTICS")

	var stats_y: = content_y + 50
	_draw_label_value("Total Players (All Time):", "1,247", left_col + 20, stats_y)
	_draw_label_value("Unique Players Today:", "87", left_col + 20, stats_y + 30)
	_draw_label_value("Avg Session Length:", "42 min", left_col + 20, stats_y + 60)
	_draw_label_value("Peak Concurrent:", "23", left_col + 20, stats_y + 90)
	_draw_label_value("Total Playtime:", "1,892 hours", left_col + 20, stats_y + 120)

	_draw_panel(Rect2(640, content_y, 620, 280), "ACTIVITY HEATMAP")


	var heat_y: = content_y + 50
	draw_string(ThemeDB.fallback_font, Vector2(660, heat_y), 
		"Activity by hour (last 24h):", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER_DIM)


	var bar_x: = 660
	var bar_y: = heat_y + 30
	for hour in range(24):
		var height: = randi() % 100 + 20
		var bar_color: = GOOD.lerp(ACCENT_BRIGHT, float(height) / 120.0)
		draw_rect(Rect2(bar_x + hour * 24, bar_y + 120 - height, 20, height), bar_color)

	_draw_panel(Rect2(left_col, content_y + 300, 1240, 280), "DETAILED REPORTS")

	var report_y: = content_y + 350
	_draw_button(Rect2(left_col + 40, report_y, 280, 50), "PLAYER RETENTION", ACCENT)
	_draw_button(Rect2(left_col + 340, report_y, 280, 50), "ECONOMY REPORT", ACCENT)
	_draw_button(Rect2(left_col + 640, report_y, 280, 50), "PERFORMANCE REPORT", ACCENT)
	_draw_button(Rect2(left_col + 940, report_y, 280, 50), "EXPORT ALL DATA", ACCENT)

	report_y += 70
	_draw_button(Rect2(left_col + 40, report_y, 280, 50), "PEAK TIMES ANALYSIS", ACCENT)
	_draw_button(Rect2(left_col + 340, report_y, 280, 50), "PLAYER BEHAVIOR", ACCENT)
	_draw_button(Rect2(left_col + 640, report_y, 280, 50), "ADMIN ACTIONS LOG", ACCENT)
	_draw_button(Rect2(left_col + 940, report_y, 280, 50), "GENERATE SUMMARY", ACCENT)



func _draw_panel(rect: Rect2, title: String) -> void :
	draw_rect(rect, BG_LIGHT)
	draw_rect(rect, ACCENT.darkened(0.3), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 20, rect.position.y + 26), 
		title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ACCENT_BRIGHT)

func _draw_button(rect: Rect2, text: String, color: Color) -> void :
	draw_rect(rect, color.darkened(0.3))
	draw_rect(rect, color, false, 2.0)
	draw_string(ThemeDB.fallback_font, 
		Vector2(rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y / 2 + 6), 
		text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, PAPER)

func _draw_small_button(rect: Rect2, text: String, color: Color) -> void :
	draw_rect(rect, color.darkened(0.4))
	draw_rect(rect, color, false, 1.0)
	draw_string(ThemeDB.fallback_font, 
		Vector2(rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y / 2 + 4), 
		text, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, PAPER)

func _draw_label_value(label: String, value: String, x: float, y: float) -> void :
	draw_string(ThemeDB.fallback_font, Vector2(x, y), 
		label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER_DIM)
	draw_string(ThemeDB.fallback_font, Vector2(x + 250, y), 
		value, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER)

func _draw_checkbox(position: Vector2, checked: bool, label: String) -> void :
	var box_rect: = Rect2(position.x, position.y, 18, 18)
	draw_rect(box_rect, BG_MED)
	draw_rect(box_rect, ACCENT, false, 2.0)

	if checked:
		draw_line(Vector2(position.x + 4, position.y + 9), 
			Vector2(position.x + 8, position.y + 14), ACCENT_BRIGHT, 2.0)
		draw_line(Vector2(position.x + 8, position.y + 14), 
			Vector2(position.x + 15, position.y + 4), ACCENT_BRIGHT, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(position.x + 28, position.y + 14), 
		label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)



func _update_statistics() -> void :
	if not lan_session:
		return


	var current_players: int = lan_session.peer_states.size()
	if current_players > peak_players:
		peak_players = current_players


	avg_ping_ms = 35.0 + randf() * 20.0


	cpu_usage = 15.0 + randf() * 10.0
	memory_usage_mb = 256.0 + randf() * 64.0


	if lan_session.snapshot_bytes_sent_estimate > 0:
		total_bytes_sent += lan_session.snapshot_bytes_sent_estimate

func _format_uptime(seconds: int) -> String:
	var hours: = seconds / 3600
	var mins: = (seconds % 3600) / 60
	return "%dh %dm" % [hours, mins]

func _format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return "%d B" % bytes
	elif bytes < 1024 * 1024:
		return "%.1f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.1f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))

func _get_sample_logs() -> Array:
	return [
		{"level": "info", "message": "Server started successfully", "timestamp": "14:00:00"}, 
		{"level": "info", "message": "Player 'Marlo' connected from 192.168.1.100", "timestamp": "14:05:32"}, 
		{"level": "info", "message": "Player 'Citizen' connected from 192.168.1.101", "timestamp": "14:06:18"}, 
		{"level": "admin", "message": "Admin 'T-309D-9800' performed action: view_profiles", "timestamp": "14:10:45"}, 
		{"level": "warning", "message": "Player 'PlayerX' attempted invalid economy transaction", "timestamp": "14:15:22"}, 
		{"level": "info", "message": "Auto-save completed (127 profiles)", "timestamp": "14:20:00"}, 
		{"level": "info", "message": "Player 'Marlo' disconnected", "timestamp": "14:25:11"}, 
		{"level": "error", "message": "Failed to authenticate player from 192.168.1.105", "timestamp": "14:30:55"}, 
		{"level": "info", "message": "Snapshot broadcast #12847 sent to 3 peers", "timestamp": "14:35:01"}, 
		{"level": "admin", "message": "Server backup created: backup_20260912_1440.save", "timestamp": "14:40:00"}, 
		{"level": "warning", "message": "High ping detected: Player 'Citizen' (285ms)", "timestamp": "14:45:33"}, 
		{"level": "info", "message": "Economy event processed: store_cashier_payment", "timestamp": "14:50:12"}, 
	]



func handle_tab_click(tab_index: int) -> void :
	if tab_index >= 0 and tab_index < Tab.size():
		current_tab = tab_index
		queue_redraw()

func handle_player_select(peer_id: int) -> void :
	selected_player_id = peer_id
	queue_redraw()

func handle_command(cmd: String) -> void :
	command_issued.emit(cmd, {})
