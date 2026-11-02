extends Node




const ProximityChat = preload("res://scripts/proximity_chat.gd")
const PrivateSession = preload("res://scripts/private_session.gd")

signal proximity_chat_received(formatted_message: Dictionary)

var lan_session: PrivateSession
var enabled: = true
var current_chat_mode: = ProximityChat.ChatType.NORMAL
var show_out_of_range_notifications: = false
var chat_history: Array[Dictionary] = []
var max_history: = 100

func _ready() -> void :

	pass


func setup(session: PrivateSession) -> void :
	lan_session = session


	if lan_session:
		lan_session.chat_received.disconnect(_on_original_chat_received)
		lan_session.chat_received.connect(_on_original_chat_received)


func _on_original_chat_received(sender_name: String, message: String) -> void :
	if not enabled:

		proximity_chat_received.emit({
			"formatted": "%s: %s" % [sender_name, message], 
			"sender": sender_name, 
			"message": message, 
			"type": ProximityChat.ChatType.GLOBAL, 
			"color": ProximityChat.CHAT_TYPE_COLORS[ProximityChat.ChatType.GLOBAL], 
			"audible": true
		})
		return


	var formatted: = ProximityChat.format_message(
		sender_name, 
		message, 
		ProximityChat.ChatType.GLOBAL
	)

	_add_to_history(formatted)
	proximity_chat_received.emit(formatted)


func send_proximity_chat(sender_name: String, message: String) -> void :
	if not lan_session or not lan_session.active:
		push_warning("Cannot send chat: session not active")
		return

	var cleaned_message: = message.strip_edges()
	if cleaned_message.is_empty():
		return


	var chat_type: = ProximityChat.parse_chat_type(cleaned_message)
	var actual_message: = ProximityChat.strip_chat_prefix(cleaned_message)

	if actual_message.is_empty():
		return


	current_chat_mode = chat_type


	var chat_range: = ProximityChat.get_chat_range(chat_type)

	if not lan_session.hosting:

		_send_proximity_chat_to_server(sender_name, actual_message, chat_type)
	else:

		_broadcast_proximity_chat(sender_name, actual_message, chat_type, chat_range)


func _send_proximity_chat_to_server(sender_name: String, message: String, chat_type: ProximityChat.ChatType) -> void :

	submit_proximity_chat_server.rpc_id(1, sender_name, message, chat_type)


	var formatted: = ProximityChat.format_message(sender_name, message, chat_type, 0.0)
	_add_to_history(formatted)
	proximity_chat_received.emit(formatted)


@rpc("any_peer", "call_remote", "reliable")
func submit_proximity_chat_server(sender_name: String, message: String, chat_type: ProximityChat.ChatType) -> void :
	if not lan_session.hosting:
		return

	var sender_id: = multiplayer.get_remote_sender_id()


	var authoritative_name: = String(lan_session.peer_states.get(sender_id, {}).get("name", sender_name)).left(20)
	var clean_message: = message.strip_edges().left(120)


	var chat_range: = ProximityChat.get_chat_range(chat_type)
	_broadcast_proximity_chat(authoritative_name, clean_message, chat_type, chat_range)


func _broadcast_proximity_chat(sender_name: String, message: String, chat_type: ProximityChat.ChatType, chat_range: float) -> void :
	if not lan_session.hosting:
		return


	var sender_id: = -1
	for peer_id in lan_session.peer_states:
		var state: Dictionary = lan_session.peer_states[peer_id]
		if String(state.get("name", "")) == sender_name:
			sender_id = peer_id
			break

	if sender_id < 0:

		_broadcast_global_chat(sender_name, message, chat_type)
		return


	var receivers: = ProximityChat.get_receivers(sender_id, lan_session.peer_states, chat_range)


	var sender_state: Dictionary = lan_session.peer_states[sender_id]
	var sender_pos: = ProximityChat._extract_position(sender_state)


	var formatted: = ProximityChat.format_message(sender_name, message, chat_type, 0.0)
	_add_to_history(formatted)
	proximity_chat_received.emit(formatted)


	for receiver_id in receivers:
		var receiver_state: Dictionary = lan_session.peer_states[receiver_id]
		var receiver_pos: = ProximityChat._extract_position(receiver_state)
		var distance: = sender_pos.distance_to(receiver_pos)


		receive_proximity_chat.rpc_id(receiver_id, sender_name, message, chat_type, distance)


	if show_out_of_range_notifications:
		for peer_id in lan_session.peer_states:
			if peer_id != sender_id and peer_id not in receivers:
				var out_of_range: = ProximityChat.format_out_of_range_message(sender_name, chat_type)
				receive_proximity_chat.rpc_id(peer_id, sender_name, "", chat_type, -1.0)


func _broadcast_global_chat(sender_name: String, message: String, chat_type: ProximityChat.ChatType) -> void :
	var formatted: = ProximityChat.format_message(sender_name, message, chat_type)


	_add_to_history(formatted)
	proximity_chat_received.emit(formatted)


	if lan_session.enet_peer:
		for peer_id in lan_session.peer_states:
			if peer_id > 1:
				receive_proximity_chat.rpc_id(peer_id, sender_name, message, chat_type, 0.0)


@rpc("authority", "call_remote", "reliable")
func receive_proximity_chat(sender_name: String, message: String, chat_type: ProximityChat.ChatType, distance: float) -> void :
	var formatted: Dictionary

	if distance < 0.0:

		formatted = ProximityChat.format_out_of_range_message(sender_name, chat_type)
	else:
		formatted = ProximityChat.format_message(sender_name, message, chat_type, distance)

	_add_to_history(formatted)
	proximity_chat_received.emit(formatted)


func _add_to_history(formatted_message: Dictionary) -> void :
	chat_history.append(formatted_message)


	while chat_history.size() > max_history:
		chat_history.pop_front()


func get_chat_history() -> Array[Dictionary]:
	return chat_history.duplicate()


func cycle_chat_mode() -> ProximityChat.ChatType:
	match current_chat_mode:
		ProximityChat.ChatType.WHISPER:
			current_chat_mode = ProximityChat.ChatType.NORMAL
		ProximityChat.ChatType.NORMAL:
			current_chat_mode = ProximityChat.ChatType.SHOUT
		ProximityChat.ChatType.SHOUT:
			current_chat_mode = ProximityChat.ChatType.WHISPER
		_:
			current_chat_mode = ProximityChat.ChatType.NORMAL

	return current_chat_mode


func get_current_mode_indicator() -> String:
	return ProximityChat.get_chat_mode_indicator(current_chat_mode)


func apply_current_mode_to_message(message: String) -> String:
	if message.begins_with("/"):
		return message

	match current_chat_mode:
		ProximityChat.ChatType.WHISPER:
			return "/w " + message
		ProximityChat.ChatType.SHOUT:
			return "/s " + message
		ProximityChat.ChatType.GLOBAL:
			return "/g " + message
		_:
			return message


func toggle_proximity_chat() -> bool:
	enabled = !enabled
	return enabled


func get_chat_statistics() -> Dictionary:
	var stats: = {
		"total_messages": chat_history.size(), 
		"whispers": 0, 
		"normal": 0, 
		"shouts": 0, 
		"global": 0, 
		"out_of_range": 0
	}

	for msg in chat_history:
		match msg.get("type", ProximityChat.ChatType.NORMAL):
			ProximityChat.ChatType.WHISPER:
				stats["whispers"] += 1
			ProximityChat.ChatType.NORMAL:
				stats["normal"] += 1
			ProximityChat.ChatType.SHOUT:
				stats["shouts"] += 1
			ProximityChat.ChatType.GLOBAL:
				stats["global"] += 1

		if not msg.get("audible", true):
			stats["out_of_range"] += 1

	return stats
