extends Node



const VoiceProximityChat = preload("res://scripts/voice_proximity_chat.gd")
const PrivateSession = preload("res://scripts/private_session.gd")

var voice_chat: VoiceProximityChat
var lan_session: PrivateSession
var voice_indicators: Dictionary = {}
var local_muted: = false
var voice_enabled: = true

func _ready() -> void :
	voice_chat = VoiceProximityChat.new()
	add_child(voice_chat)


	voice_chat.voice_activity_detected.connect(_on_voice_activity)
	voice_chat.voice_packet_received.connect(_on_voice_packet)

func setup(session: PrivateSession) -> void :
	lan_session = session


	if lan_session:
		lan_session.peer_snapshot_received.connect(_on_peer_snapshot)

func _on_peer_snapshot(peer_states: Dictionary) -> void :
	if not voice_chat:
		return


	for peer_id in peer_states:
		if peer_id == multiplayer.get_unique_id():
			continue

		var state: Dictionary = peer_states[peer_id]
		var position: = _extract_position(state)
		voice_chat.update_peer_position(peer_id, position)

func _extract_position(state: Dictionary) -> Vector2:
	var value: Variant = state.get("position", Vector2.ZERO)
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _on_voice_activity(peer_id: int, is_speaking: bool) -> void :

	if peer_id in voice_indicators:
		var indicator = voice_indicators[peer_id]
		indicator["speaking"] = is_speaking


	if is_speaking:
		print("Player %d is speaking" % peer_id)

func _on_voice_packet(peer_id: int, audio_data: PackedByteArray) -> void :

	pass


func set_voice_mode(mode: VoiceProximityChat.VoiceMode) -> void :
	if voice_chat:
		voice_chat.set_voice_mode(mode)


func set_push_to_talk_pressed(pressed: bool) -> void :
	if voice_chat:
		voice_chat.set_push_to_talk(pressed)


func toggle_mute() -> bool:
	local_muted = !local_muted
	if voice_chat:
		voice_chat.set_muted(local_muted)
	return local_muted


func toggle_voice_chat() -> bool:
	voice_enabled = !voice_enabled
	if voice_chat and not voice_enabled:
		voice_chat.set_muted(true)
	elif voice_chat and voice_enabled:
		voice_chat.set_muted(local_muted)
	return voice_enabled


func get_speaking_peers() -> Array[int]:
	if voice_chat:
		return voice_chat.get_speaking_peers()
	return []


func on_peer_disconnected(peer_id: int) -> void :
	if voice_chat:
		voice_chat.remove_peer(peer_id)
	if peer_id in voice_indicators:
		voice_indicators.erase(peer_id)
