class_name AgervisLanSession
extends Node

signal status_changed(message: String)
signal peer_snapshot_received(snapshot: Dictionary)
signal chat_received(sender_name: String, message: String)
signal attack_requested(peer_id: int)
signal disposition_requested(peer_id: int, target_peer_id: int, action: String)
signal permanent_outcome_received(payload: Dictionary)

const DEFAULT_PORT: = 24860
const MAX_PLAYERS: = 5

var peer_states: Dictionary = {}
var active: = false
var hosting: = false
var status: = "OFFLINE"
var port: = DEFAULT_PORT

func _ready() -> void :
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_server(initial_state: Dictionary, requested_port: int = DEFAULT_PORT) -> Error:
	close_session()
	var peer: = ENetMultiplayerPeer.new()
	var result: = peer.create_server(requested_port, MAX_PLAYERS)
	if result != OK:
		_set_status("HOST FAILED  -  UDP %d (%s)" % [requested_port, error_string(result)])
		return result
	multiplayer.multiplayer_peer = peer
	port = requested_port
	active = true
	hosting = true
	peer_states[1] = _sanitize_initial_state(initial_state, 1)
	_set_status("HOSTING LAN  -  UDP %d  -  1/%d" % [port, MAX_PLAYERS])
	_broadcast_snapshot()
	return OK

func join_server(address: String, initial_state: Dictionary, requested_port: int = DEFAULT_PORT) -> Error:
	close_session()
	var clean_address: = address.strip_edges()
	if clean_address.is_empty():
		clean_address = "127.0.0.1"
	var peer: = ENetMultiplayerPeer.new()
	var result: = peer.create_client(clean_address, requested_port)
	if result != OK:
		_set_status("JOIN FAILED  -  %s:%d (%s)" % [clean_address, requested_port, error_string(result)])
		return result
	multiplayer.multiplayer_peer = peer
	port = requested_port
	active = true
	hosting = false
	peer_states.clear()
	peer_states[0] = initial_state.duplicate(true)
	_set_status("CONNECTING TO %s:%d..." % [clean_address, port])
	return OK

func close_session() -> void :
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peer_states.clear()
	active = false
	hosting = false
	status = "OFFLINE"

func local_peer_id() -> int:
	if not active:
		return 0
	return multiplayer.get_unique_id()

func connected_player_count() -> int:
	return peer_states.size() if active else 0

func local_addresses() -> Array[String]:
	var result: Array[String] = []
	for value in IP.get_local_addresses():
		var address: = String(value)
		if ":" in address or address.begins_with("127."):
			continue
		if address not in result:
			result.append(address)
	if result.is_empty():
		result.append("127.0.0.1")
	return result

func submit_local_state(state: Dictionary) -> void :
	if not active:
		return
	if not hosting and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	var peer_id: = local_peer_id()
	if hosting:
		peer_states[peer_id] = _sanitize_initial_state(state, peer_id)
		_broadcast_snapshot()
	else:
		submit_state_to_server.rpc_id(1, state)

@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func submit_state_to_server(candidate: Dictionary) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	if sender <= 1:
		return
	var previous: Dictionary = peer_states.get(sender, {})
	peer_states[sender] = _sanitize_client_motion(candidate, previous, sender)
	_broadcast_snapshot()

func request_attack() -> void :
	if not active:
		return
	if hosting:
		attack_requested.emit(local_peer_id())
	else:
		request_attack_server.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func request_attack_server() -> void :
	if hosting:
		attack_requested.emit(multiplayer.get_remote_sender_id())

func request_disposition(target_peer_id: int, action: String) -> void :
	if not active:
		return
	if hosting:
		disposition_requested.emit(local_peer_id(), target_peer_id, action)
	else:
		request_disposition_server.rpc_id(1, target_peer_id, action)

@rpc("any_peer", "call_remote", "reliable")
func request_disposition_server(target_peer_id: int, action: String) -> void :
	if hosting:
		disposition_requested.emit(multiplayer.get_remote_sender_id(), target_peer_id, action)

func submit_chat(sender_name: String, message: String) -> void :
	if not active:
		return
	var clean_name: = sender_name.strip_edges().left(20)
	var clean_message: = message.strip_edges().left(120)
	if clean_message.is_empty():
		return
	if hosting:
		_broadcast_chat(clean_name, clean_message)
	else:
		submit_chat_server.rpc_id(1, clean_name, clean_message)

@rpc("any_peer", "call_remote", "reliable")
func submit_chat_server(sender_name: String, message: String) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	var authoritative_name: = String(peer_states.get(sender, {}).get("name", sender_name)).left(20)
	_broadcast_chat(authoritative_name, message.strip_edges().left(120))

func host_patch_peer(peer_id: int, patch: Dictionary) -> void :
	if not hosting or peer_id not in peer_states:
		return
	var state: Dictionary = peer_states[peer_id]
	for key in patch:
		state[key] = patch[key]
	peer_states[peer_id] = state
	_broadcast_snapshot()

func send_permanent_outcome(peer_id: int, payload: Dictionary) -> void :
	if not hosting or peer_id not in peer_states:
		return
	if peer_id == 1:
		permanent_outcome_received.emit(payload.duplicate(true))
	else:
		receive_permanent_outcome.rpc_id(peer_id, payload)

@rpc("authority", "call_remote", "reliable")
func receive_permanent_outcome(payload: Dictionary) -> void :
	permanent_outcome_received.emit(payload.duplicate(true))

func _broadcast_snapshot() -> void :
	if not hosting:
		return
	var snapshot: = peer_states.duplicate(true)
	peer_snapshot_received.emit(snapshot)
	receive_snapshot.rpc(snapshot)

@rpc("authority", "call_remote", "unreliable_ordered", 2)
func receive_snapshot(snapshot: Dictionary) -> void :
	peer_states = snapshot.duplicate(true)
	peer_snapshot_received.emit(peer_states.duplicate(true))

func _broadcast_chat(sender_name: String, message: String) -> void :
	chat_received.emit(sender_name, message)
	receive_chat.rpc(sender_name, message)

@rpc("authority", "call_remote", "reliable")
func receive_chat(sender_name: String, message: String) -> void :
	chat_received.emit(sender_name, message)

func _sanitize_initial_state(candidate: Dictionary, peer_id: int) -> Dictionary:
	var state: = candidate.duplicate(true)
	state["peer_id"] = peer_id
	state["name"] = String(state.get("name", "Resident %d" % peer_id)).strip_edges().left(20)
	state["health"] = clampf(float(state.get("health", 100.0)), 0.0, 100.0)
	state["downed"] = bool(state.get("downed", false))
	state["mark"] = maxf(0.0, float(state.get("mark", 0.0)))
	return state

func _sanitize_client_motion(candidate: Dictionary, previous: Dictionary, peer_id: int) -> Dictionary:
	if previous.is_empty():
		return _sanitize_initial_state(candidate, peer_id)
	var result: = previous.duplicate(true)
	for key in [
		"name", "area", "phase", "position", "facing", "walking", "color", "skin", 
		"hair_style", "body_style", "hair_color", "facial_hair_style", 
		"facial_hair_color", "face_style", "eye_style", "stature", 
		"outfit_style", "surreal_trait", "accessory", 
	]:
		if candidate.has(key):
			result[key] = candidate[key]
	result["peer_id"] = peer_id
	result["name"] = String(result.get("name", "Resident %d" % peer_id)).strip_edges().left(20)
	return result

func _on_peer_connected(peer_id: int) -> void :
	if hosting:
		peer_states[peer_id] = {
			"peer_id": peer_id, 
			"name": "Connecting Resident", 
			"area": "home", 
			"phase": "adult", 
			"position": Vector2(850, 260), 
			"health": 100.0, 
			"downed": false, 
			"mark": 0.0, 
		}
		_set_status("HOSTING LAN  -  UDP %d  -  %d/%d" % [port, peer_states.size(), MAX_PLAYERS])
		_broadcast_snapshot()

func _on_peer_disconnected(peer_id: int) -> void :
	peer_states.erase(peer_id)
	if hosting:
		_set_status("HOSTING LAN  -  UDP %d  -  %d/%d" % [port, peer_states.size(), MAX_PLAYERS])
		_broadcast_snapshot()
	else:
		_set_status("RESIDENT %d LEFT THE LAN SESSION" % peer_id)

func _on_connected_to_server() -> void :
	var pending: Dictionary = peer_states.get(0, {})
	peer_states.clear()
	_set_status("CONNECTED  -  PEER %d" % local_peer_id())
	submit_state_to_server.rpc_id(1, pending)

func _on_connection_failed() -> void :
	_set_status("LAN CONNECTION FAILED")
	close_session()

func _on_server_disconnected() -> void :
	_set_status("HOST DISCONNECTED")
	close_session()

func _set_status(message: String) -> void :
	status = message
	status_changed.emit(message)
