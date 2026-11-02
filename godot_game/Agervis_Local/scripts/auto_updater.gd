extends Node




const VERSION_CHECK_URL: = "https://agervis.com/api/version"
const UPDATE_DOWNLOAD_URL: = "https://agervis.com/api/download"
const LOCAL_VERSION_FILE: = "user://version.txt"
const UPDATE_CHECK_INTERVAL: = 3600.0
const CURRENT_VERSION: = "0.13.0"

var http_request: HTTPRequest
var update_timer: = 0.0
var checking_update: = false
var downloading_update: = false
var latest_version: = ""
var download_url: = ""
var update_available: = false

signal update_check_started()
signal update_available_signal(version: String)
signal update_downloaded(path: String)
signal update_failed(error: String)
signal no_update_available()

func _ready() -> void :

	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)


	await get_tree().create_timer(5.0).timeout
	check_for_updates()

func _process(delta: float) -> void :
	update_timer += delta
	if update_timer >= UPDATE_CHECK_INTERVAL:
		update_timer = 0.0
		check_for_updates()

func check_for_updates() -> void :
	if checking_update or downloading_update:
		return

	checking_update = true
	emit_signal("update_check_started")


	var error: = http_request.request(VERSION_CHECK_URL)
	if error != OK:
		checking_update = false
		emit_signal("update_failed", "Failed to connect to update server")

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	if checking_update:
		_handle_version_check_response(result, response_code, body)
	elif downloading_update:
		_handle_update_download_response(result, response_code, body)

func _handle_version_check_response(result: int, response_code: int, body: PackedByteArray) -> void :
	checking_update = false

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		emit_signal("update_failed", "Version check failed: HTTP %d" % response_code)
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		emit_signal("update_failed", "Failed to parse version response")
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		emit_signal("update_failed", "Invalid version response format")
		return

	latest_version = str(data.get("version", ""))
	download_url = str(data.get("download_url", ""))
	var min_version = str(data.get("min_version", ""))

	if latest_version.is_empty() or download_url.is_empty():
		emit_signal("update_failed", "Invalid version data")
		return


	if _is_newer_version(latest_version, CURRENT_VERSION):
		update_available = true
		emit_signal("update_available_signal", latest_version)


		if not min_version.is_empty() and _is_newer_version(min_version, CURRENT_VERSION):

			download_update()
		else:

			save_update_info()
	else:
		update_available = false
		emit_signal("no_update_available")

func download_update() -> void :
	if downloading_update or download_url.is_empty():
		return

	downloading_update = true
	var error: = http_request.request(download_url)
	if error != OK:
		downloading_update = false
		emit_signal("update_failed", "Failed to start download")

func _handle_update_download_response(result: int, response_code: int, body: PackedByteArray) -> void :
	downloading_update = false

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		emit_signal("update_failed", "Download failed: HTTP %d" % response_code)
		return


	var update_path: = "user://agervis_update.pck"
	var file: = FileAccess.open(update_path, FileAccess.WRITE)
	if file == null:
		emit_signal("update_failed", "Failed to save update file")
		return

	file.store_buffer(body)
	file.close()

	emit_signal("update_downloaded", update_path)


	apply_update(update_path)

func apply_update(update_path: String) -> void :





	var executable_path: = OS.get_executable_path()
	var executable_dir: = executable_path.get_base_dir()


	var script_path: = executable_dir + "/update.bat"
	var script_content: = """@echo off
timeout /t 2 /nobreak > NUL
echo Applying Agervis update...
copy /Y \"%s\" \"%s\"
if exist \"%s\" (
    echo Update applied successfully!
    start \"\" \"%s\"
) else (
    echo Update failed!
    pause
)
del \"%s\"
""" %[update_path, executable_path, executable_path, executable_path, script_path]

	var script_file: = FileAccess.open(script_path, FileAccess.WRITE)
	if script_file == null:
		emit_signal("update_failed", "Failed to create update script")
		return

	script_file.store_string(script_content)
	script_file.close()


	OS.create_process(script_path, [])
	get_tree().quit()

func save_update_info() -> void :
	var file: = FileAccess.open("user://update_available.json", FileAccess.WRITE)
	if file:
		var data: = {
			"version": latest_version, 
			"download_url": download_url, 
			"checked_at": Time.get_unix_time_from_system()
		}
		file.store_string(JSON.stringify(data))
		file.close()

func load_update_info() -> Dictionary:
	var file: = FileAccess.open("user://update_available.json", FileAccess.READ)
	if file == null:
		return {}

	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()

	if parse_result != OK:
		return {}

	return json.data if typeof(json.data) == TYPE_DICTIONARY else {}

func _is_newer_version(new_version: String, current_version: String) -> bool:
	var new_parts: = new_version.split(".")
	var current_parts: = current_version.split(".")

	for i in range(min(new_parts.size(), current_parts.size())):
		var new_num: = int(new_parts[i])
		var current_num: = int(current_parts[i])

		if new_num > current_num:
			return true
		elif new_num < current_num:
			return false


	return new_parts.size() > current_parts.size()

func get_current_version() -> String:
	return CURRENT_VERSION

func is_update_available() -> bool:
	return update_available

func get_latest_version() -> String:
	return latest_version
