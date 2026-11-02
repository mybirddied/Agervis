class_name AgervisInputGlyphs
extends RefCounted




const ROOT: = "res://assets/ui/gamepad_icons/"

const GENERIC: = {
	"dpad_up": "generic_dpad_up.svg", 
	"dpad_right": "generic_dpad_right.svg", 
	"dpad_down": "generic_dpad_down.svg", 
	"dpad_left": "generic_dpad_left.svg", 
	"left_stick": "generic_left_stick.svg", 
	"left_stick_up": "generic_left_stick_up.svg", 
	"left_stick_right": "generic_left_stick_right.svg", 
	"left_stick_down": "generic_left_stick_down.svg", 
	"left_stick_left": "generic_left_stick_left.svg", 
	"right_stick": "generic_right_stick.svg", 
	"l3": "generic_l3.svg", 
	"r3": "generic_r3.svg", 
	"select": "generic_select.svg", 
	"start": "generic_start.svg", 
}

const XBOX: = {
	"face_south": "xb_a.svg", "face_east": "xb_b.svg", 
	"face_west": "xb_x.svg", "face_north": "xb_y.svg", 
	"l1": "xb_lb.svg", "r1": "xb_rb.svg", 
	"l2": "xb_lt.svg", "r2": "xb_rt.svg", 
	"select": "xb_select.svg", "start": "xb_start.svg", 
	"super": "xb_super.svg", 
}

const PLAYSTATION: = {
	"face_south": "ps_x.svg", "face_east": "ps_circle.svg", 
	"face_west": "ps_square.svg", "face_north": "ps_triangle.svg", 
	"l1": "ps_l1.svg", "r1": "ps_r1.svg", 
	"l2": "ps_l2.svg", "r2": "ps_r2.svg", 
	"super": "ps_super.svg", 
}

const SWITCH: = {

	"face_south": "switch_b.svg", "face_east": "switch_a.svg", 
	"face_west": "switch_y.svg", "face_north": "switch_x.svg", 
	"l1": "switch_l.svg", "r1": "switch_r.svg", 
	"l2": "switch_zl.svg", "r2": "switch_zr.svg", 
	"select": "switch_minus.svg", "start": "switch_plus.svg", 
	"super": "switch_super.svg", 
}

static func normalize_family(family: String) -> String:
	var upper: = family.to_upper()
	if upper in ["PLAYSTATION", "PS", "SONY"]: return "PLAYSTATION"
	if upper in ["SWITCH", "NINTENDO"]: return "SWITCH"
	return "XBOX"

static func family_for_device(device_name: String, override_family: String = "AUTO") -> String:
	if override_family.to_upper() != "AUTO":
		return normalize_family(override_family)
	var lower: = device_name.to_lower()
	if "playstation" in lower or "dualshock" in lower or "dualsense" in lower or "sony" in lower:
		return "PLAYSTATION"
	if "nintendo" in lower or "switch" in lower or "joy-con" in lower or "pro controller" in lower:
		return "SWITCH"
	return "XBOX"

static func file_for(family: String, semantic_button: String) -> String:
	var normalized: = normalize_family(family)
	var branded: Dictionary = PLAYSTATION if normalized == "PLAYSTATION" else SWITCH if normalized == "SWITCH" else XBOX
	return String(branded.get(semantic_button, GENERIC.get(semantic_button, "")))

static func texture_path(family: String, semantic_button: String) -> String:
	var file_name: = file_for(family, semantic_button)
	return ROOT + file_name if not file_name.is_empty() else ""
