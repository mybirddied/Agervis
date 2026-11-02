extends Node2D

var screenshot_path: = "C:/Users/Computer Owner/.claude/jobs/34399f65/tmp/courthouse_screenshot.png"
var frames_waited: = 0
var main_scene = null

func _ready() -> void :
	print("Loading main scene...")
	var main_packed = load("res://main.tscn")
	if main_packed:
		main_scene = main_packed.instantiate()
		add_child(main_scene)
		print("Main scene loaded")


		if "mode" in main_scene:

			main_scene.mode = 2
			print("Set mode to PLAY")


		if "area" in main_scene:
			main_scene.area = "courthouse"
			print("Set area to courthouse")


		if "last_input_controller" in main_scene:
			main_scene.last_input_controller = true
			print("Set last_input_controller to true")
	else:
		print("ERROR: Could not load main.tscn")
		get_tree().quit(1)

func _process(_delta: float) -> void :
	frames_waited += 1

	if frames_waited == 60:
		_take_screenshot()

func _take_screenshot() -> void :
	print("Taking screenshot...")
	if main_scene:
		print("Current mode: %s" % main_scene.mode if "mode" in main_scene else "unknown")
		print("Current area: %s" % main_scene.area if "area" in main_scene else "unknown")
		print("Controller mode: %s" % main_scene.last_input_controller if "last_input_controller" in main_scene else "unknown")

	await RenderingServer.frame_post_draw

	var img: = get_viewport().get_texture().get_image()
	if img == null:
		print("ERROR: Failed to get viewport image")
		get_tree().quit(1)
		return

	var err: = img.save_png(screenshot_path)

	if err == OK:
		print("Screenshot saved to: %s" % screenshot_path)
	else:
		print("ERROR saving screenshot: %d" % err)

	get_tree().quit(0)
