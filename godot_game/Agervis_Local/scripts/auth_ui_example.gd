extends Control




const AuthSystem = preload("res://scripts/auth_system.gd")

enum AuthScreen{
	LOGIN, 
	REGISTER, 
	CHANGE_PASSWORD
}

var current_screen: = AuthScreen.LOGIN
var current_username: = ""


var username_input: = ""
var password_input: = ""
var confirm_password_input: = ""
var old_password_input: = ""
var status_message: = ""
var status_color: = Color.WHITE

func _ready() -> void :

	if not AuthSystem.has_accounts():
		current_screen = AuthScreen.REGISTER
		status_message = "Welcome to Agervis. Create your first account."
		status_color = Color("#b9b2a7")

func _process(_delta: float) -> void :
	queue_redraw()

func _draw() -> void :
	match current_screen:
		AuthScreen.LOGIN:
			_draw_login_screen()
		AuthScreen.REGISTER:
			_draw_register_screen()
		AuthScreen.CHANGE_PASSWORD:
			_draw_change_password_screen()

func _draw_login_screen() -> void :

	draw_rect(Rect2(0, 0, 1280, 720), Color("#1a1c1e"))


	draw_string(ThemeDB.fallback_font, Vector2(640, 150), "AGERVIS LOGIN", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color("#b9b2a7"))


	draw_string(ThemeDB.fallback_font, Vector2(440, 250), "Username:", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 260, 400, 40), Color("#2a2c2e"))
	draw_string(ThemeDB.fallback_font, Vector2(450, 285), username_input, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	draw_string(ThemeDB.fallback_font, Vector2(440, 330), "Password:", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 340, 400, 40), Color("#2a2c2e"))
	var masked: = ""
	for _i in range(password_input.length()):
		masked += "●"
	draw_string(ThemeDB.fallback_font, Vector2(450, 365), masked, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	if not status_message.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(640, 420), status_message, 
			HORIZONTAL_ALIGNMENT_CENTER, -1, 16, status_color)


	draw_rect(Rect2(540, 460, 200, 50), Color("#3a5a3a"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 492), "LOGIN", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)

	draw_string(ThemeDB.fallback_font, Vector2(640, 550), "Don't have an account? Register", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color("#7a9a7a"))

func _draw_register_screen() -> void :

	draw_rect(Rect2(0, 0, 1280, 720), Color("#1a1c1e"))


	draw_string(ThemeDB.fallback_font, Vector2(640, 120), "CREATE ACCOUNT", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color("#b9b2a7"))


	draw_string(ThemeDB.fallback_font, Vector2(440, 200), "Username (3-32 characters):", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 210, 400, 40), Color("#2a2c2e"))
	draw_string(ThemeDB.fallback_font, Vector2(450, 235), username_input, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	draw_string(ThemeDB.fallback_font, Vector2(440, 280), "Password (minimum 8 characters):", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 290, 400, 40), Color("#2a2c2e"))
	var masked: = ""
	for _i in range(password_input.length()):
		masked += "●"
	draw_string(ThemeDB.fallback_font, Vector2(450, 315), masked, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	draw_string(ThemeDB.fallback_font, Vector2(440, 360), "Confirm Password:", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 370, 400, 40), Color("#2a2c2e"))
	var masked_confirm: = ""
	for _i in range(confirm_password_input.length()):
		masked_confirm += "●"
	draw_string(ThemeDB.fallback_font, Vector2(450, 395), masked_confirm, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	if not status_message.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(640, 450), status_message, 
			HORIZONTAL_ALIGNMENT_CENTER, -1, 16, status_color)


	draw_rect(Rect2(540, 490, 200, 50), Color("#3a5a3a"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 522), "CREATE ACCOUNT", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)

	if AuthSystem.has_accounts():
		draw_string(ThemeDB.fallback_font, Vector2(640, 580), "Already have an account? Login", 
			HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color("#7a9a7a"))

func _draw_change_password_screen() -> void :

	draw_rect(Rect2(0, 0, 1280, 720), Color("#1a1c1e"))


	draw_string(ThemeDB.fallback_font, Vector2(640, 120), "CHANGE PASSWORD", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color("#b9b2a7"))

	draw_string(ThemeDB.fallback_font, Vector2(640, 160), "Account: %s" % current_username, 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color("#8a8a7a"))


	draw_string(ThemeDB.fallback_font, Vector2(440, 220), "Current Password:", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 230, 400, 40), Color("#2a2c2e"))
	var masked_old: = ""
	for _i in range(old_password_input.length()):
		masked_old += "●"
	draw_string(ThemeDB.fallback_font, Vector2(450, 255), masked_old, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	draw_string(ThemeDB.fallback_font, Vector2(440, 300), "New Password (minimum 8 characters):", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 310, 400, 40), Color("#2a2c2e"))
	var masked_new: = ""
	for _i in range(password_input.length()):
		masked_new += "●"
	draw_string(ThemeDB.fallback_font, Vector2(450, 335), masked_new, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	draw_string(ThemeDB.fallback_font, Vector2(440, 380), "Confirm New Password:", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#b9b2a7"))
	draw_rect(Rect2(440, 390, 400, 40), Color("#2a2c2e"))
	var masked_confirm: = ""
	for _i in range(confirm_password_input.length()):
		masked_confirm += "●"
	draw_string(ThemeDB.fallback_font, Vector2(450, 415), masked_confirm, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)


	if not status_message.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(640, 470), status_message, 
			HORIZONTAL_ALIGNMENT_CENTER, -1, 16, status_color)


	draw_rect(Rect2(540, 510, 200, 50), Color("#3a5a3a"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 542), "CHANGE PASSWORD", 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)


func attempt_login() -> void :
	var result: = AuthSystem.authenticate(username_input, password_input)

	if result == AuthSystem.AuthResult.SUCCESS:
		current_username = username_input
		status_message = "Login successful! Welcome, %s" % current_username
		status_color = Color("#5a8a5a")


	else:
		status_message = AuthSystem.get_error_message(result)
		status_color = Color("#aa5555")
		password_input = ""


func attempt_register() -> void :
	if password_input != confirm_password_input:
		status_message = "Passwords do not match."
		status_color = Color("#aa5555")
		return

	var result: = AuthSystem.create_account(username_input, password_input)

	if result == AuthSystem.AuthResult.SUCCESS:
		current_username = username_input
		status_message = "Account created successfully! You can now log in."
		status_color = Color("#5a8a5a")

		current_screen = AuthScreen.LOGIN
		password_input = ""
		confirm_password_input = ""
	else:
		status_message = AuthSystem.get_error_message(result)
		status_color = Color("#aa5555")
		password_input = ""
		confirm_password_input = ""


func attempt_change_password() -> void :
	if password_input != confirm_password_input:
		status_message = "New passwords do not match."
		status_color = Color("#aa5555")
		return

	var result: = AuthSystem.change_password(current_username, old_password_input, password_input)

	if result == AuthSystem.AuthResult.SUCCESS:
		status_message = "Password changed successfully!"
		status_color = Color("#5a8a5a")
		old_password_input = ""
		password_input = ""
		confirm_password_input = ""
	else:
		status_message = AuthSystem.get_error_message(result)
		status_color = Color("#aa5555")
		old_password_input = ""
		password_input = ""
		confirm_password_input = ""


func switch_to_login() -> void :
	current_screen = AuthScreen.LOGIN
	username_input = ""
	password_input = ""
	status_message = ""

func switch_to_register() -> void :
	current_screen = AuthScreen.REGISTER
	username_input = ""
	password_input = ""
	confirm_password_input = ""
	status_message = ""

func switch_to_change_password() -> void :
	current_screen = AuthScreen.CHANGE_PASSWORD
	old_password_input = ""
	password_input = ""
	confirm_password_input = ""
	status_message = ""
