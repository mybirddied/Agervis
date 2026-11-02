extends RefCounted

# TODO: Missing SVG assets - commented out to allow compilation
# const ART: Texture2D = preload("res://assets/ui/quick_access_radial.svg")
# const PLAYSTATION_ART: Texture2D = preload("res://assets/ui/quick_access_radial_playstation.svg")
# const SYMBOL_FREE_ART: Texture2D = preload("res://assets/ui/quick_access_radial_symbol_free.svg")
const ART: Texture2D = null
const PLAYSTATION_ART: Texture2D = null
const SYMBOL_FREE_ART: Texture2D = null
const CANVAS_SIZE: = Vector2(800, 264)
const SYMBOL_CENTERS: = [Vector2(399, 175), Vector2(448, 130), Vector2(348, 130), Vector2(399, 86)]

static func geometry(anchor: Vector2, viewport_size: Vector2 = Vector2(1280, 720)) -> Dictionary:
	var scale_factor: = minf(0.75, minf((viewport_size.x - 16.0) / CANVAS_SIZE.x, (viewport_size.y - 16.0) / CANVAS_SIZE.y))
	var size: = CANVAS_SIZE * scale_factor
	var position: = anchor - size * 0.5
	position.x = clampf(position.x, 8.0, viewport_size.x - size.x - 8.0)
	position.y = clampf(position.y, 8.0, viewport_size.y - size.y - 8.0)
	return {"anchor": anchor, "center": position + size * 0.5, "rect": Rect2(position, size), "scale": scale_factor}

static func draw(canvas: Node2D, layout: Dictionary, family: String, progress: float, font: Font) -> void :
	var rect: Rect2 = layout["rect"]
	var opacity: = clampf(progress, 0.0, 1.0)
	var texture: = PLAYSTATION_ART if family == "PLAYSTATION" else SYMBOL_FREE_ART if family == "SWITCH" else ART
	canvas.draw_texture_rect(texture, rect, false, Color(1, 1, 1, opacity))
	if family == "SWITCH":

		var labels: = ["B", "A", "Y", "X"]
		var scale_factor: float = layout["scale"]
		for index in range(labels.size()):
			var text_size: = 18
			var width: = font.get_string_size(labels[index], HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
			canvas.draw_set_transform(rect.position, 0.0, Vector2.ONE * scale_factor)
			canvas.draw_string(font, SYMBOL_CENTERS[index] + Vector2( - width * 0.5, 6), labels[index], HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, Color(1, 1, 1, opacity))
		canvas.draw_set_transform(Vector2.ZERO)
