extends Node




const ServerAdminGUI = preload("res://scripts/server_admin_gui.gd")
const PrivateSession = preload("res://scripts/private_session.gd")

var admin_gui: ServerAdminGUI
var lan_session: PrivateSession

func _ready() -> void :

	lan_session = PrivateSession.new()
	add_child(lan_session)


	var server_port: = 24860
	var profile_path: = "user://agervis_main_server_profiles.save"
	var result: bool = lan_session.host_main_server(server_port, profile_path)

	if result:
		print("Main Server started successfully on port %d" % server_port)


		admin_gui = ServerAdminGUI.new()
		admin_gui.lan_session = lan_session
		add_child(admin_gui)


		admin_gui.command_issued.connect(_on_admin_command)

		print("Admin GUI initialized - open window to manage server")
	else:
		push_error("Failed to start Main Server: %s" % error_string(result))

func _on_admin_command(command: String, args: Dictionary) -> void :

	var parts: = command.strip_edges().split(" ", false)
	if parts.is_empty():
		return

	var cmd: = parts[0].to_lower()

	match cmd:
		"/kick":
			if parts.size() > 1 and parts[1].is_valid_int():
				var peer_id: = int(parts[1])
				_kick_player(peer_id)

		"/ban":
			if parts.size() > 1:
				var target: = parts[1]
				_ban_player(target)

		"/broadcast":
			if parts.size() > 1:
				var message: = " ".join(parts.slice(1))
				_broadcast_message(message)

		"/tp":
			if parts.size() > 2:
				var peer_id: = int(parts[1])
				var location: = parts[2]
				_teleport_player(peer_id, location)

		"/save":
			_save_all_profiles()

		"/shutdown":
			_shutdown_server()

		_:
			print("Unknown command: %s" % cmd)

func _kick_player(peer_id: int) -> void :
	if not lan_session.peer_states.has(peer_id):
		print("Player %d not found" % peer_id)
		return

	var player_name: = String(lan_session.peer_states[peer_id].get("name", "Unknown"))


	if lan_session.enet_peer:
		lan_session.enet_peer.disconnect_peer(peer_id, false)

	print("Kicked player %s (ID: %d)" % [player_name, peer_id])
	_log_admin_action("kick_player", {"peer_id": peer_id, "name": player_name})

func _ban_player(target: String) -> void :

	var peer_id: = -1

	if target.is_valid_int():
		peer_id = int(target)
	else:

		for pid in lan_session.peer_accounts:
			if lan_session.peer_accounts[pid] == target:
				peer_id = pid
				break

	if peer_id < 0:
		print("Player not found: %s" % target)
		return


	var player_name: = String(lan_session.peer_states.get(peer_id, {}).get("name", "Unknown"))
	var account_id: = String(lan_session.peer_accounts.get(peer_id, ""))


	if lan_session.enet_peer:
		lan_session.enet_peer.disconnect_peer(peer_id, true)

	print("Banned player %s (ID: %d, Account: %s)" % [player_name, peer_id, account_id])
	_log_admin_action("ban_player", {"peer_id": peer_id, "name": player_name, "account": account_id})

func _broadcast_message(message: String) -> void :

	if not lan_session.active:
		print("Server not active")
		return


	lan_session._broadcast_chat("[SERVER]", message)

	print("Broadcast message sent: %s" % message)
	_log_admin_action("broadcast", {"message": message})

func _teleport_player(peer_id: int, location: String) -> void :
	if not lan_session.peer_states.has(peer_id):
		print("Player %d not found" % peer_id)
		return


	var parts: = location.split(":", false, 1)
	if parts.size() != 2:
		print("Invalid location format. Use: area:room")
		return

	var area: = parts[0]
	var room: = parts[1]


	var state: Dictionary = lan_session.peer_states[peer_id]
	state["area"] = area
	state["room_id"] = room
	state["position"] = Vector2(400, 300)

	lan_session.snapshot_dirty = true

	var player_name: = String(state.get("name", "Unknown"))
	print("Teleported %s to %s:%s" % [player_name, area, room])
	_log_admin_action("teleport", {"peer_id": peer_id, "area": area, "room": room})

func _save_all_profiles() -> void :
	if not lan_session.profiles_enabled:
		print("Profiles not enabled")
		return

	lan_session.save_main_server_profiles()
	print("All profiles saved to disk")
	_log_admin_action("save_profiles", {})

func _shutdown_server() -> void :
	print("Initiating server shutdown...")


	_broadcast_message("Server shutting down in 10 seconds. Please disconnect.")

	await get_tree().create_timer(10.0).timeout


	if lan_session.profiles_enabled:
		lan_session.save_main_server_profiles()

	_log_admin_action("shutdown_server", {})

	print("Server shutdown complete")
	get_tree().quit()

func _log_admin_action(action: String, data: Dictionary) -> void :

	var entry: = {
		"timestamp": Time.get_datetime_string_from_system(), 
		"action": action, 
		"data": data
	}

	if lan_session:
		lan_session.admin_audit_log.append(entry)


		var log_file: = FileAccess.open("user://admin_audit.log", FileAccess.READ_WRITE)
		if log_file:
			log_file.seek_end()
			log_file.store_line(JSON.stringify(entry))
			log_file.close()



func get_server_statistics() -> Dictionary:
	if not lan_session:
		return {}

	return {
		"active": lan_session.active, 
		"connected_players": lan_session.peer_states.size(), 
		"max_players": lan_session.max_players, 
		"port": lan_session.port, 
		"world_id": lan_session.server_world_id, 
		"snapshot_count": lan_session.snapshot_broadcast_count, 
		"bytes_sent": lan_session.snapshot_bytes_sent_estimate, 
		"disconnect_count": lan_session.disconnect_count, 
		"persistence_writes": lan_session.persistence_write_count, 
	}

func export_server_report(path: String) -> bool:
	var stats: = get_server_statistics()
	var report: = {
		"timestamp": Time.get_datetime_string_from_system(), 
		"statistics": stats, 
		"players": [], 
		"audit_log": lan_session.admin_audit_log if lan_session else []
	}


	if lan_session:
		for peer_id in lan_session.peer_states:
			var state: Dictionary = lan_session.peer_states[peer_id]
			report["players"].append({
				"id": peer_id, 
				"name": state.get("name", "Unknown"), 
				"area": state.get("area", ""), 
				"room": state.get("room_id", ""), 
				"account": lan_session.peer_accounts.get(peer_id, "")
			})

	var file: = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	return true



func _on_auto_save_timer() -> void :

	if lan_session and lan_session.profiles_enabled and lan_session.profiles_dirty:
		lan_session.save_main_server_profiles()
		print("Auto-save completed")

func _on_idle_check_timer() -> void :

	if not lan_session:
		return

	var current_time: = Time.get_ticks_msec()
	var idle_threshold: = 15 * 60 * 1000

	for peer_id in lan_session.peer_states:


		pass

func _on_backup_timer() -> void :

	var timestamp: = Time.get_datetime_string_from_system().replace(":", "-")
	var backup_path: = "user://backups/server_backup_%s.save" % timestamp


	if FileAccess.file_exists(lan_session.profile_path):
		DirAccess.make_dir_recursive_absolute("user://backups")
		DirAccess.copy_absolute(lan_session.profile_path, backup_path)
		print("Backup created: %s" % backup_path)
