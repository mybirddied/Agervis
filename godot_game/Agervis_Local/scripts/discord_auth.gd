class_name DiscordAuth
extends RefCounted




signal auth_completed(user_data: Dictionary)
signal auth_failed(error: String)

const DISCORD_CLIENT_ID: = "YOUR_DISCORD_CLIENT_ID_HERE"
const DISCORD_CLIENT_SECRET: = "YOUR_DISCORD_CLIENT_SECRET_HERE"
const REDIRECT_URI: = "http://localhost:8888/discord-callback"
const SCOPES: = "identify email"

const AUTH_SAVE_PATH: = "user://discord_auth.save"

var _http_server: TCPServer
var _pending_connections: Array[StreamPeerTCP] = []
var _callback_port: = 8888
var _auth_in_progress: = false
var _stored_token: String = ""
var _stored_user: Dictionary = {}

func _init() -> void :
	load_stored_auth()


func load_stored_auth() -> void:
	pass  # TODO: Decompilation incomplete - implement auth loading


func begin_login() -> void :
	if _auth_in_progress:
		push_warning("Discord auth already in progress")
		return

	_auth_in_progress = true


	if not OS.has_feature("web"):
		_start_callback_server()


	var auth_url: = "https://discord.com/oauth2/authorize?client_id=%s&redirect_uri=%s&response_type=code&scope=%s" % [
		DISCORD_CLIENT_ID,
		REDIRECT_URI.uri_encode(),
		SCOPES.uri_encode()
	]


	OS.shell_open(auth_url)


func _start_callback_server() -> void:
	pass  # TODO: Decompilation incomplete - implement callback server


func process_callbacks(delta: float) -> void :
	if not _auth_in_progress or not _http_server:
		return


	if _http_server.is_connection_available():
		pass  # TODO: Decompilation incomplete - implement connection handling
