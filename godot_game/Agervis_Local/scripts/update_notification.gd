extends Control



signal update_accepted()
signal update_declined()

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel / VBoxContainer / TitleLabel
@onready var version_label: Label = $Panel / VBoxContainer / VersionLabel
@onready var message_label: Label = $Panel / VBoxContainer / MessageLabel
@onready var size_label: Label = $Panel / VBoxContainer / SizeLabel
@onready var progress_bar: ProgressBar = $Panel / VBoxContainer / ProgressBar
@onready var button_container: HBoxContainer = $Panel / VBoxContainer / ButtonContainer
@onready var update_button: Button = $Panel / VBoxContainer / ButtonContainer / UpdateButton
@onready var later_button: Button = $Panel / VBoxContainer / ButtonContainer / LaterButton

var latest_version: = ""
var file_size: = 0
var is_mandatory: = false

func _ready() -> void :
	hide()
	update_button.pressed.connect(_on_update_pressed)
	later_button.pressed.connect(_on_later_pressed)
	progress_bar.hide()

func show_update_notification(version: String, size_bytes: int, mandatory: bool, notes: String = "") -> void :
	latest_version = version
	file_size = size_bytes
	is_mandatory = mandatory

	title_label.text = "Update Available" if not mandatory else "Update Required"
	version_label.text = "Version %s is now available" % version

	if notes.is_empty():
		message_label.text = "A new version of Agervis is available with improvements and bug fixes."
	else:
		message_label.text = notes

	size_label.text = "Download size: %s" % format_bytes(size_bytes)

	later_button.visible = not mandatory
	progress_bar.hide()

	show()

func show_download_progress(percent: float) -> void :
	progress_bar.show()
	progress_bar.value = percent
	button_container.hide()
	message_label.text = "Downloading update... %d%%" % int(percent)

func show_install_progress() -> void :
	progress_bar.show()
	progress_bar.value = 100
	button_container.hide()
	message_label.text = "Installing update..."

func show_error(error_message: String) -> void :
	title_label.text = "Update Failed"
	message_label.text = error_message
	progress_bar.hide()
	button_container.show()
	update_button.text = "Retry"
	later_button.show()

func _on_update_pressed() -> void :
	emit_signal("update_accepted")

func _on_later_pressed() -> void :
	emit_signal("update_declined")
	hide()

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return "%d B" % bytes
	elif bytes < 1024 * 1024:
		return "%.1f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.1f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.1f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))
