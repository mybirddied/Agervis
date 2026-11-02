extends Control




const ProximityChat = preload("res://scripts/proximity_chat.gd")

signal chat_submitted(message: String)
signal chat_mode_changed(new_mode: ProximityChat.ChatType)


const CHAT_LOG_HEIGHT: = 400.0
const CHAT_LOG_WIDTH: = 600.0
const MESSAGE_LINE_HEIGHT: = 24.0
const MAX_VISIBLE_MESSAGES: = 16
const FADE_TIME: = 5.0


const BG: = Color("#1a1c1e")
const BG_ALPHA: = Color(0.1, 0.11, 0.12, 0.85)
const PAPER: = Color("#e8e0d5")
const PAPER_DIM: = Color("#b9b2a7")
const ACCENT: = Color("#5a7a5a")


var messages: Array[Dictionary] = []
var current_input: = ""
var current_mode: ProximityChat.ChatType = ProximityChat.ChatType.NORMAL
var chat_visible: = true
var fade_timer: = 0.0
var input_active: = false

func _ready() -> void :
	set_process(true)

func _process(delta: float) -> void :
	if not input_active:
		fade_timer += delta
	queue_redraw()

func _draw() -> void :
	if not chat_visible:
		return

	var alpha: = 1.0
	if fade_timer > FADE_TIME and not input_active:
		alpha = clampf(1.0 - (fade_timer - FADE_TIME) / 2.0, 0.0, 1.0)

	if alpha <= 0.0:
		return


	var log_rect: Rect2 = Rect2(20, 120, CHAT_LOG_WIDTH, CHAT_LOG_HEIGHT)
	draw_rect(log_rect, Color(BG_ALPHA, alpha * 0.85))
	draw_rect(log_rect, Color(ACCENT, alpha * 0.4), false, 2.0)


	var y_offset: float = log_rect.position.y + log_rect.size.y - 60
	var visible_count: int = min(MAX_VISIBLE_MESSAGES, messages.size())

	for i in range(visible_count):
		var msg_index: int = messages.size() - visible_count + i
		var msg: Dictionary = messages[msg_index]

		var msg_color: Color = msg.get("color", PAPER)
		msg_color.a = alpha

		var formatted: String = String(msg.get("formatted", ""))
		var distance: float = float(msg.get("distance", -1.0))


		draw_string(ThemeDB.fallback_font, Vector2(30, y_offset), 
			formatted.left(70), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, msg_color)


		if distance >= 0.0 and ProximityChat.should_show_distance(msg.get("type", ProximityChat.ChatType.NORMAL)):
			var distance_text: = "(%dm)" % int(distance)
			draw_string(ThemeDB.fallback_font, Vector2(530, y_offset), 
				distance_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color(PAPER_DIM, alpha * 0.7))

		y_offset += MESSAGE_LINE_HEIGHT


	if input_active or fade_timer < FADE_TIME:
		var input_rect: Rect2 = Rect2(20, log_rect.position.y + log_rect.size.y - 45, CHAT_LOG_WIDTH, 35)
		draw_rect(input_rect, Color(BG, alpha))
		draw_rect(input_rect, Color(ACCENT, alpha * 0.6), false, 2.0)


		var mode_text: String = _get_mode_prefix()
		draw_string(ThemeDB.fallback_font, Vector2(30, input_rect.position.y + 23), 
			mode_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(ACCENT, alpha))


		var input_x: = 30 + ThemeDB.fallback_font.get_string_size(mode_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x + 10
		draw_string(ThemeDB.fallback_font, Vector2(input_x, input_rect.position.y + 23), 
			current_input + ("|" if int(Time.get_ticks_msec() / 500) % 2 == 0 else ""), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(PAPER, alpha))


		if input_active:
			var help_y: float = input_rect.position.y - 20
			draw_string(ThemeDB.fallback_font, Vector2(30, help_y), 
				"Tab: Change mode  |  Enter: Send  |  Esc: Cancel", 
				HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(PAPER_DIM, alpha * 0.7))

func _get_mode_prefix() -> String:
	match current_mode:
		ProximityChat.ChatType.WHISPER:
			return "[Whisper]"
		ProximityChat.ChatType.SHOUT:
			return "[Shout]"
		ProximityChat.ChatType.GLOBAL:
			return "[Global]"
		_:
			return "[Say]"


func add_message(formatted_message: Dictionary) -> void :
	messages.append(formatted_message)


	while messages.size() > 100:
		messages.pop_front()


	fade_timer = 0.0
	queue_redraw()


func open_chat_input() -> void :
	input_active = true
	current_input = ""
	fade_timer = 0.0
	queue_redraw()


func close_chat_input() -> void :
	input_active = false
	current_input = ""
	queue_redraw()


func handle_text_input(character: String) -> void :
	if not input_active:
		return

	if current_input.length() < 96:
		current_input += character
		queue_redraw()


func handle_backspace() -> void :
	if not input_active or current_input.is_empty():
		return

	current_input = current_input.left(current_input.length() - 1)
	queue_redraw()


func cycle_mode() -> void :
	match current_mode:
		ProximityChat.ChatType.WHISPER:
			current_mode = ProximityChat.ChatType.NORMAL
		ProximityChat.ChatType.NORMAL:
			current_mode = ProximityChat.ChatType.SHOUT
		ProximityChat.ChatType.SHOUT:
			current_mode = ProximityChat.ChatType.GLOBAL
		ProximityChat.ChatType.GLOBAL:
			current_mode = ProximityChat.ChatType.WHISPER
		_:
			current_mode = ProximityChat.ChatType.NORMAL

	chat_mode_changed.emit(current_mode)
	queue_redraw()


func submit_message() -> void :
	if not input_active or current_input.strip_edges().is_empty():
		return

	var message: String = current_input.strip_edges()


	match current_mode:
		ProximityChat.ChatType.WHISPER:
			message = "/w " + message
		ProximityChat.ChatType.SHOUT:
			message = "/s " + message
		ProximityChat.ChatType.GLOBAL:
			message = "/g " + message

	chat_submitted.emit(message)
	close_chat_input()


func toggle_visibility() -> void :
	chat_visible = !chat_visible
	queue_redraw()


func get_current_mode() -> ProximityChat.ChatType:
	return current_mode


func set_mode(mode: ProximityChat.ChatType) -> void :
	current_mode = mode
	chat_mode_changed.emit(current_mode)
	queue_redraw()
