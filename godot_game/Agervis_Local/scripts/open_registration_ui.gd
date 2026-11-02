extends Control




const OpenRegistrationAuth = preload("res://scripts/open_registration_auth.gd")

signal signed_in(username: String, was_new_account: bool)


var username_input: = ""
var password_input: = ""
var status_message: = ""
var status_color: = Color.WHITE
var input_focus: = 0


const BG: = Color("#1a1c1e")
const BG_LIGHT: = Color("#222825")
const PAPER: = Color("#e8e0d5")
const PAPER_DIM: = Color("#b9b2a7")
const ACCENT: = Color("#5a7a5a")
const GOOD: = Color("#5a8a5a")
const DANGER: = Color("#aa5555")
const WARNING: = Color("#aa8855")

func _ready() -> void :
	set_process(true)

func _process(_delta: float) -> void :
	queue_redraw()

func _draw() -> void :

	draw_rect(Rect2(0, 0, 1280, 720), BG)


	var panel_rect: = Rect2(340, 160, 600, 400)
	draw_rect(panel_rect, BG_LIGHT)
	draw_rect(panel_rect, ACCENT.darkened(0.15), false, 3.0)


	draw_string(ThemeDB.fallback_font, Vector2(640, 220), 
		"AGERVIS SIGN IN", HORIZONTAL_ALIGNMENT_CENTER, -1, 34, PAPER)


	draw_string(ThemeDB.fallback_font, Vector2(640, 260), 
		"Enter username and password to sign in or create account", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 14, PAPER_DIM)


	draw_string(ThemeDB.fallback_font, Vector2(380, 310), 
		"Username:", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, PAPER_DIM)

	var username_rect: = Rect2(380, 320, 520, 40)
	draw_rect(username_rect, Color("#2a2c2e"))
	draw_rect(username_rect, ACCENT if input_focus == 0 else ACCENT.darkened(0.5), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(390, 345), 
		username_input + ("|" if input_focus == 0 and int(Time.get_ticks_msec() / 500) % 2 == 0 else ""), 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, PAPER)


	draw_string(ThemeDB.fallback_font, Vector2(380, 390), 
		"Password:", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, PAPER_DIM)

	var password_rect: = Rect2(380, 400, 520, 40)
	draw_rect(password_rect, Color("#2a2c2e"))
	draw_rect(password_rect, ACCENT if input_focus == 1 else ACCENT.darkened(0.5), false, 2.0)

	var masked: = ""
	for _i in range(password_input.length()):
		masked += "●"
	draw_string(ThemeDB.fallback_font, Vector2(390, 425), 
		masked + ("|" if input_focus == 1 and int(Time.get_ticks_msec() / 500) % 2 == 0 else ""), 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, PAPER)


	if not status_message.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(640, 470), 
			status_message, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, status_color)


	var button_rect: = Rect2(490, 490, 300, 50)
	draw_rect(button_rect, ACCENT.darkened(0.3))
	draw_rect(button_rect, ACCENT, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(640, 522), 
		"SIGN IN", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, PAPER)


	draw_string(ThemeDB.fallback_font, Vector2(640, 580), 
		"New users: Your account will be created automatically", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 13, PAPER_DIM)

	draw_string(ThemeDB.fallback_font, Vector2(640, 600), 
		"Minimum 8 characters for password", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(PAPER_DIM, 0.7))


func handle_text_input(character: String) -> void :
	if input_focus == 0 and username_input.length() < 32:
		username_input += character
	elif input_focus == 1 and password_input.length() < 64:
		password_input += character
	queue_redraw()


func handle_backspace() -> void :
	if input_focus == 0 and not username_input.is_empty():
		username_input = username_input.left(username_input.length() - 1)
	elif input_focus == 1 and not password_input.is_empty():
		password_input = password_input.left(password_input.length() - 1)
	queue_redraw()


func handle_tab() -> void :
	input_focus = 1 if input_focus == 0 else 0
	queue_redraw()


func attempt_sign_in(client_ip: String = "") -> void :
	var username: = username_input.strip_edges()
	var password: = password_input

	if username.is_empty():
		status_message = "Please enter a username"
		status_color = WARNING
		queue_redraw()
		return

	if password.is_empty():
		status_message = "Please enter a password"
		status_color = WARNING
		queue_redraw()
		return


	var result: = OpenRegistrationAuth.sign_in(username, password, client_ip)

	match result:
		OpenRegistrationAuth.AuthResult.SUCCESS:
			status_message = OpenRegistrationAuth.get_success_message(result, username)
			status_color = GOOD
			password_input = ""
			queue_redraw()
			await get_tree().create_timer(1.0).timeout
			signed_in.emit(username, false)

		OpenRegistrationAuth.AuthResult.CREATED_ACCOUNT:
			status_message = OpenRegistrationAuth.get_success_message(result, username)
			status_color = GOOD
			password_input = ""
			queue_redraw()
			await get_tree().create_timer(1.5).timeout
			signed_in.emit(username, true)

		OpenRegistrationAuth.AuthResult.IP_LIMIT_REACHED:
			var remaining: = OpenRegistrationAuth.get_ip_cooldown_remaining(client_ip)
			var hours: = remaining / 3600
			status_message = "Account creation limit reached. Try again in %d hours." % hours
			status_color = DANGER
			password_input = ""
			queue_redraw()

		_:
			status_message = OpenRegistrationAuth.get_error_message(result)
			status_color = DANGER
			password_input = ""
			queue_redraw()


func clear_form() -> void :
	username_input = ""
	password_input = ""
	status_message = ""
	input_focus = 0
	queue_redraw()
