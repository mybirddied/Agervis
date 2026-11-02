class_name VoiceProximityChat
extends Node




signal voice_activity_detected(peer_id: int, is_speaking: bool)
signal voice_packet_received(peer_id: int, audio_data: PackedByteArray)


const SAMPLE_RATE: = 48000
const BUFFER_SIZE: = 960
const VOICE_ACTIVATION_THRESHOLD: = 0.02
const SILENCE_TIMEOUT: = 0.5


const MAX_HEARING_DISTANCE: = 800.0
const REFERENCE_DISTANCE: = 400.0
const ROLLOFF_FACTOR: = 1.5


const ENABLE_LOW_PASS_FILTER: = true
const ENABLE_REVERB: = false
const WHISPER_VOLUME_MULTIPLIER: = 0.4
const SHOUT_VOLUME_MULTIPLIER: = 2.0

enum VoiceMode{
	NORMAL, 
	WHISPER, 
	SHOUT, 
	PUSH_TO_TALK
}


var audio_input: AudioStreamPlayer
var audio_effect_capture: AudioEffectCapture
var voice_mode: VoiceMode = VoiceMode.NORMAL
var push_to_talk_held: = false
var is_transmitting: = false
var silence_timer: = 0.0
var peer_audio_players: Dictionary = {}
var peer_voice_activity: Dictionary = {}


var use_opus_encoding: = false

func _ready() -> void :
	_setup_audio_input()
	set_process(true)

func _process(delta: float) -> void :
	if not is_transmitting and voice_mode == VoiceMode.PUSH_TO_TALK and not push_to_talk_held:
		return


	var audio_frames: PackedVector2Array = _capture_audio_frames()
	if audio_frames.size() > 0:
		var rms: = _calculate_rms(audio_frames)


		if rms > VOICE_ACTIVATION_THRESHOLD or voice_mode == VoiceMode.PUSH_TO_TALK:
			if not is_transmitting:
				is_transmitting = true
				voice_activity_detected.emit(multiplayer.get_unique_id(), true)

			silence_timer = 0.0


			var processed_frames: = _apply_voice_effects(audio_frames)


			_transmit_voice_data(processed_frames)
		else:

			silence_timer += delta
			if silence_timer > SILENCE_TIMEOUT and is_transmitting:
				is_transmitting = false
				voice_activity_detected.emit(multiplayer.get_unique_id(), false)


func _setup_audio_input() -> void :

	var capture_bus_index: = AudioServer.bus_count
	AudioServer.add_bus(capture_bus_index)
	AudioServer.set_bus_name(capture_bus_index, "VoiceCapture")


	var capture_effect: = AudioEffectCapture.new()
	AudioServer.add_bus_effect(capture_bus_index, capture_effect)
	audio_effect_capture = capture_effect


	var mic_stream: = AudioStreamMicrophone.new()
	audio_input = AudioStreamPlayer.new()
	audio_input.stream = mic_stream
	audio_input.bus = "VoiceCapture"
	add_child(audio_input)
	audio_input.play()

	print("Voice proximity chat initialized - microphone active")


func _capture_audio_frames() -> PackedVector2Array:
	if not audio_effect_capture or not audio_effect_capture.can_get_buffer(BUFFER_SIZE):
		return PackedVector2Array()

	return audio_effect_capture.get_buffer(BUFFER_SIZE)


func _calculate_rms(frames: PackedVector2Array) -> float:
	if frames.size() == 0:
		return 0.0

	var sum: = 0.0
	for frame in frames:
		sum += frame.x * frame.x + frame.y * frame.y

	return sqrt(sum / (frames.size() * 2.0))


func _apply_voice_effects(frames: PackedVector2Array) -> PackedVector2Array:
	var processed: = frames.duplicate()

	match voice_mode:
		VoiceMode.WHISPER:

			for i in range(processed.size()):
				processed[i] *= WHISPER_VOLUME_MULTIPLIER

		VoiceMode.SHOUT:

			for i in range(processed.size()):
				var sample: = processed[i] * SHOUT_VOLUME_MULTIPLIER

				sample.x = tanh(sample.x)
				sample.y = tanh(sample.y)
				processed[i] = sample

	return processed


func _transmit_voice_data(frames: PackedVector2Array) -> void :

	var byte_array: = _frames_to_bytes(frames)


	receive_voice_data.rpc(multiplayer.get_unique_id(), byte_array)


func _frames_to_bytes(frames: PackedVector2Array) -> PackedByteArray:
	var bytes: = PackedByteArray()
	bytes.resize(frames.size() * 8)

	for i in range(frames.size()):
		var offset: = i * 8
		bytes.encode_float(offset, frames[i].x)
		bytes.encode_float(offset + 4, frames[i].y)

	return bytes


func _bytes_to_frames(bytes: PackedByteArray) -> PackedVector2Array:
	var frames: = PackedVector2Array()
	var frame_count: = bytes.size() / 8

	for i in range(frame_count):
		var offset: = i * 8
		var x: = bytes.decode_float(offset)
		var y: = bytes.decode_float(offset + 4)
		frames.append(Vector2(x, y))

	return frames


@rpc("any_peer", "call_remote", "unreliable_ordered")
func receive_voice_data(sender_id: int, audio_bytes: PackedByteArray) -> void :

	voice_packet_received.emit(sender_id, audio_bytes)


	_play_spatial_audio(sender_id, audio_bytes)


func _play_spatial_audio(sender_id: int, audio_bytes: PackedByteArray) -> void :

	var player: = _get_or_create_audio_player(sender_id)
	if not player:
		return


	var frames: = _bytes_to_frames(audio_bytes)


	var stream: = _create_audio_stream(frames)


	player.stream = stream
	player.play()


func _get_or_create_audio_player(peer_id: int) -> AudioStreamPlayer3D:
	if peer_id in peer_audio_players:
		return peer_audio_players[peer_id]


	var player: = AudioStreamPlayer3D.new()
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	player.unit_size = REFERENCE_DISTANCE
	player.max_distance = MAX_HEARING_DISTANCE
	player.attenuation_filter_cutoff_hz = 5000.0
	player.attenuation_filter_db = -24.0

	add_child(player)
	peer_audio_players[peer_id] = player

	return player


func update_peer_position(peer_id: int, position: Vector2) -> void :
	if peer_id not in peer_audio_players:
		return

	var player: AudioStreamPlayer3D = peer_audio_players[peer_id]

	player.global_position = Vector3(position.x, 0, position.y)


func _create_audio_stream(frames: PackedVector2Array) -> AudioStreamWAV:
	var stream: = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = true


	var pcm_data: = PackedByteArray()
	pcm_data.resize(frames.size() * 4)

	for i in range(frames.size()):
		var left: = int(clamp(frames[i].x * 32767.0, -32768.0, 32767.0))
		var right: = int(clamp(frames[i].y * 32767.0, -32768.0, 32767.0))

		pcm_data.encode_s16(i * 4, left)
		pcm_data.encode_s16(i * 4 + 2, right)

	stream.data = pcm_data
	return stream


func calculate_distance_volume(distance: float) -> float:
	if distance <= 0.0:
		return 1.0

	if distance >= MAX_HEARING_DISTANCE:
		return 0.0


	var normalized: = distance / REFERENCE_DISTANCE
	return 1.0 / pow(normalized, ROLLOFF_FACTOR)


func calculate_distance_filter(distance: float) -> float:

	var normalized: = clamp(distance / MAX_HEARING_DISTANCE, 0.0, 1.0)
	return lerp(20000.0, 1000.0, normalized)


func set_voice_mode(mode: VoiceMode) -> void :
	voice_mode = mode
	print("Voice mode changed to: ", VoiceMode.keys()[mode])


func set_push_to_talk(pressed: bool) -> void :
	push_to_talk_held = pressed
	if not pressed and is_transmitting:
		is_transmitting = false
		voice_activity_detected.emit(multiplayer.get_unique_id(), false)


func remove_peer(peer_id: int) -> void :
	if peer_id in peer_audio_players:
		var player: AudioStreamPlayer3D = peer_audio_players[peer_id]
		player.queue_free()
		peer_audio_players.erase(peer_id)
		peer_voice_activity.erase(peer_id)


func is_peer_speaking(peer_id: int) -> bool:
	return peer_voice_activity.get(peer_id, false)


func set_muted(muted: bool) -> void :
	if audio_input:
		audio_input.volume_db = -80.0 if muted else 0.0


func get_speaking_peers() -> Array[int]:
	var speaking: Array[int] = []
	for peer_id in peer_voice_activity:
		if peer_voice_activity[peer_id]:
			speaking.append(peer_id)
	return speaking


func _exit_tree() -> void :
	if audio_input:
		audio_input.stop()
		audio_input.queue_free()

	for player in peer_audio_players.values():
		player.queue_free()

	peer_audio_players.clear()
