class_name ProximityChat
extends RefCounted





const WHISPER_RANGE: = 150.0
const NORMAL_RANGE: = 400.0
const SHOUT_RANGE: = 800.0
const GLOBAL_RANGE: = 999999.0


enum ChatType{
	WHISPER, 
	NORMAL, 
	SHOUT, 
	GLOBAL, 
	RADIO
}


const CHAT_TYPE_COLORS: = {
	ChatType.WHISPER: Color("#8a9a8a"), 
	ChatType.NORMAL: Color("#e8e0d5"), 
	ChatType.SHOUT: Color("#d8c0a5"), 
	ChatType.GLOBAL: Color("#6a9a6a"), 
	ChatType.RADIO: Color("#7a8aaa"), 
}

const CHAT_TYPE_LABELS: = {
	ChatType.WHISPER: "[whisper]", 
	ChatType.NORMAL: "", 
	ChatType.SHOUT: "[shout]", 
	ChatType.GLOBAL: "[SERVER]", 
	ChatType.RADIO: "[radio]", 
}


static func parse_chat_type(message: String) -> ChatType:
	var lower: = message.to_lower()
	if lower.begins_with("/w ") or lower.begins_with("/whisper "):
		return ChatType.WHISPER
	elif lower.begins_with("/s ") or lower.begins_with("/shout "):
		return ChatType.SHOUT
	elif lower.begins_with("/g ") or lower.begins_with("/global "):
		return ChatType.GLOBAL
	else:
		return ChatType.NORMAL


static func strip_chat_prefix(message: String) -> String:
	var lower: = message.to_lower()
	if lower.begins_with("/w ") or lower.begins_with("/whisper "):
		return message.substr(message.find(" ") + 1)
	elif lower.begins_with("/s ") or lower.begins_with("/shout "):
		return message.substr(message.find(" ") + 1)
	elif lower.begins_with("/g ") or lower.begins_with("/global "):
		return message.substr(message.find(" ") + 1)
	return message


static func get_chat_range(chat_type: ChatType) -> float:
	match chat_type:
		ChatType.WHISPER:
			return WHISPER_RANGE
		ChatType.NORMAL:
			return NORMAL_RANGE
		ChatType.SHOUT:
			return SHOUT_RANGE
		ChatType.GLOBAL:
			return GLOBAL_RANGE
		ChatType.RADIO:
			return GLOBAL_RANGE
		_:
			return NORMAL_RANGE


static func can_hear(sender_state: Dictionary, receiver_state: Dictionary, chat_range: float) -> bool:

	if chat_range >= GLOBAL_RANGE:
		return true


	var sender_area: = String(sender_state.get("area", ""))
	var receiver_area: = String(receiver_state.get("area", ""))
	if sender_area != receiver_area:
		return false


	var sender_room: = String(sender_state.get("room_id", ""))
	var receiver_room: = String(receiver_state.get("room_id", ""))
	if sender_room != receiver_room:
		return false


	var sender_pos: = _extract_position(sender_state)
	var receiver_pos: = _extract_position(receiver_state)
	var distance: = sender_pos.distance_to(receiver_pos)

	return distance <= chat_range


static func _extract_position(state: Dictionary) -> Vector2:
	var value: Variant = state.get("position", Vector2.ZERO)
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO


static func get_receivers(sender_id: int, peer_states: Dictionary, chat_range: float) -> Array[int]:
	var receivers: Array[int] = []

	if sender_id not in peer_states:
		return receivers

	var sender_state: Dictionary = peer_states[sender_id]

	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)


		if peer_id == sender_id:
			continue

		var receiver_state: Dictionary = peer_states[peer_id]

		if can_hear(sender_state, receiver_state, chat_range):
			receivers.append(peer_id)

	return receivers


static func format_message(sender_name: String, message: String, chat_type: ChatType, distance: float = -1.0) -> Dictionary:
	var prefix: String = CHAT_TYPE_LABELS[chat_type]
	var color: Color = CHAT_TYPE_COLORS[chat_type]

	var formatted: = ""
	if not prefix.is_empty():
		formatted = "%s %s: %s" % [prefix, sender_name, message]
	else:
		formatted = "%s: %s" % [sender_name, message]

	return {
		"formatted": formatted, 
		"sender": sender_name, 
		"message": message, 
		"type": chat_type, 
		"color": color, 
		"distance": distance, 
		"audible": true
	}


static func format_out_of_range_message(sender_name: String, chat_type: ChatType) -> Dictionary:
	var type_name: = ""
	match chat_type:
		ChatType.WHISPER:
			type_name = "whisper"
		ChatType.SHOUT:
			type_name = "shout"
		_:
			type_name = "message"

	return {
		"formatted": "[Too far to hear %s's %s]" % [sender_name, type_name], 
		"sender": sender_name, 
		"message": "", 
		"type": chat_type, 
		"color": Color("#5a5a5a"), 
		"distance": -1.0, 
		"audible": false
	}


static func get_chat_mode_indicator(chat_type: ChatType) -> String:
	match chat_type:
		ChatType.WHISPER:
			return "💬 WHISPER (150m)"
		ChatType.NORMAL:
			return "💬 NORMAL (400m)"
		ChatType.SHOUT:
			return "📢 SHOUT (800m)"
		ChatType.GLOBAL:
			return "🌐 GLOBAL"
		ChatType.RADIO:
			return "📻 RADIO"
		_:
			return "💬 CHAT"


static func calculate_volume(distance: float, chat_range: float) -> float:
	if distance >= chat_range:
		return 0.0


	return 1.0 - (distance / chat_range)


static func should_show_distance(chat_type: ChatType) -> bool:
	return chat_type in [ChatType.WHISPER, ChatType.NORMAL, ChatType.SHOUT]


static func get_help_text() -> String:
	return "PROXIMITY CHAT COMMANDS:\n\n/whisper <message> or /w <message>\n  - Quiet voice, 150m range\n  - Only nearby players hear you\n\n/shout <message> or /s <message>\n  - Loud voice, 800m range\n  - Draws attention, more people hear\n\n/global <message> or /g <message>\n  - Admin/server announcements\n  - Everyone hears regardless of location\n\n<message> (no prefix)\n  - Normal speaking voice, 400m range\n  - Standard conversation distance\n\nTIPS:\n- Players must be in the same area:room to hear you\n- Distance shown in meters for proximity messages\n- Use /whisper for private conversations\n- Use /shout to call for help or get attention"
