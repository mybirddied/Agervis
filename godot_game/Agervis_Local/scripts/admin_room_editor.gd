class_name AgervisAdminRoomEditor
extends RefCounted

const RoomObjects = preload("res://scripts/room_objects.gd")

const PATCH_SCHEMA_VERSION: = 1
const POSITION_MIN: = Vector2(0.0, 0.0)
const POSITION_MAX: = Vector2(1000.0, 320.0)
const RECORD_TYPES: = ["tile", "object", "collision_line", "warp"]
const COLLISION_KINDS: = ["solid", "one_way", "trigger"]
const EDITABLE_FIELDS: = [
	"record_type", "position", "depth", "priority", "interactive", "action_id", "label", 
	"radius", "graphic_id", "render_mode", "solid_rect", "visible", "layer", 
	"atlas_id", "source_rect", "size", "z_index", "points", "width", "collision_kind", 
	"trigger_size", "target_world", "target_room", "target_position", "contact_only", "deleted", 
]

var offline_authorized: = false
var base_rooms: Dictionary = {}
var working_rooms: Dictionary = {}
var selected_room_key: = ""
var selected_local_id: = ""
var undo_stack: Array[Dictionary] = []
var redo_stack: Array[Dictionary] = []
var active_tool: = "select"
var selected_palette: = {"atlas_id": "release-1", "source_rect": Rect2(0, 0, 256, 256), "size": Vector2(64, 64)}
var continuous_edit_active: = false

func _init(source_rooms: Dictionary = RoomObjects.ROOM_OBJECTS, authorize_offline: bool = false) -> void :
	base_rooms = source_rooms.duplicate(true)
	working_rooms = source_rooms.duplicate(true)
	offline_authorized = authorize_offline

func set_offline_authorized(value: bool) -> void :
	offline_authorized = value

func set_source_rooms(source_rooms: Dictionary, authorize: bool = offline_authorized) -> void :
	base_rooms = source_rooms.duplicate(true)
	working_rooms = source_rooms.duplicate(true)
	offline_authorized = authorize
	selected_room_key = ""
	selected_local_id = ""
	undo_stack.clear()
	redo_stack.clear()
	continuous_edit_active = false

func set_room_records(room_key: String, records: Array, authorize: bool = offline_authorized) -> void :
	if room_key.is_empty():
		return
	base_rooms[room_key] = records.duplicate(true)
	working_rooms[room_key] = records.duplicate(true)
	offline_authorized = authorize
	undo_stack.clear()
	redo_stack.clear()
	continuous_edit_active = false

func room_keys() -> Array[String]:
	var keys: Array[String] = []
	for key_value in working_rooms.keys():
		keys.append(String(key_value))
	keys.sort()
	return keys

func room_records(room_key: String) -> Array:
	return Array(working_rooms.get(room_key, [])).duplicate(true)

func select(room_key: String, local_id: String) -> bool:
	if room_key not in working_rooms:
		return false
	for value in Array(working_rooms[room_key]):
		if value is Dictionary and String((value as Dictionary).get("local_id", "")) == local_id:
			selected_room_key = room_key
			selected_local_id = local_id
			return true
	return false

func selected_record() -> Dictionary:
	var index: = _selected_index()
	if index < 0:
		return {}
	return Dictionary(Array(working_rooms[selected_room_key])[index]).duplicate(true)

func set_tool(tool_name: String) -> bool:
	if tool_name not in ["select", "tile", "object", "npc", "fixture", "collision", "warp", "erase"]:
		return false
	active_tool = tool_name
	return true

func set_palette(atlas_id: String, source_rect: Rect2, size: Vector2 = Vector2(64, 64)) -> bool:
	if atlas_id.strip_edges().is_empty() or not _finite_rect(source_rect) or source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0:
		return false
	if not _finite_vector(size) or size.x <= 0.0 or size.y <= 0.0:
		return false
	selected_palette = {"atlas_id": atlas_id.strip_edges(), "source_rect": source_rect, "size": size}
	return true

func select_at(room_key: String, world_position: Vector2) -> bool:
	if room_key not in working_rooms or not _finite_vector(world_position):
		return false
	var best_id: = ""
	var best_distance: = INF
	for value in Array(working_rooms[room_key]):
		if value is not Dictionary:
			continue
		var record: = value as Dictionary
		if bool(record.get("deleted", false)):
			continue
		var center: Variant = record.get("position", null)
		if center is Vector2:
			var distance: = (center as Vector2).distance_to(world_position)
			var hit_radius: = float(record.get("radius", 32.0))
			if String(record.get("record_type", "object")) == "tile":
				var tile_size: Variant = record.get("size", Vector2(64, 64))
				if tile_size is Vector2:
					hit_radius = maxf(hit_radius, maxf((tile_size as Vector2).x, (tile_size as Vector2).y) * 0.5)
			if distance <= hit_radius and distance < best_distance:
				best_distance = distance
				best_id = String(record.get("local_id", ""))
	if best_id.is_empty():
		return false
	return select(room_key, best_id)

func add_record(room_key: String, record: Dictionary) -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is not authorized.")
	if room_key not in working_rooms:
		return _error("UNKNOWN_ROOM", "That room does not exist in the authored registry.")
	var candidate: = working_rooms.duplicate(true)
	var records: Array = Array(candidate[room_key]).duplicate(true)
	var next_record: = record.duplicate(true)
	var local_id: = String(next_record.get("local_id", "")).strip_edges()
	if local_id.is_empty():
		return _error("INVALID_LOCAL_ID", "Map records need a stable local_id.")
	if records.any( func(value:
		Variant): return value is Dictionary and String((value as Dictionary).get("local_id", "")) == local_id):
		return _error("DUPLICATE_LOCAL_ID", "That stable local_id already exists in this room.")
	records.append(next_record)
	candidate[room_key] = records
	var errors: = validate_rooms(candidate)
	if not errors.is_empty():
		return _error("VALIDATION_FAILED", String(errors[0]), {"errors": errors})
	_push_undo()
	working_rooms = candidate
	selected_room_key = room_key
	selected_local_id = local_id
	redo_stack.clear()
	return {"ok": true, "record": selected_record(), "changed": true}

func duplicate_selected(new_local_id: String) -> Dictionary:
	var record: = selected_record()
	if record.is_empty():
		return _error("NO_SELECTION", "Select a room record first.")
	var clean_id: = new_local_id.strip_edges()
	if clean_id.is_empty():
		return _error("INVALID_LOCAL_ID", "The duplicate needs a stable local_id.")
	record["local_id"] = clean_id
	var position: Variant = record.get("position", Vector2.ZERO)
	if position is Vector2:
		record["position"] = (position as Vector2) + Vector2(16, 0)
	return add_record(selected_room_key, record)

func delete_selected() -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is not authorized.")
	var index: = _selected_index()
	if index < 0:
		return _error("NO_SELECTION", "Select a room record first.")
	var candidate: = working_rooms.duplicate(true)
	var records: Array = Array(candidate[selected_room_key]).duplicate(true)
	var deleted_id: = selected_local_id
	records.remove_at(index)
	candidate[selected_room_key] = records
	var errors: = validate_rooms(candidate)
	if not errors.is_empty():
		return _error("VALIDATION_FAILED", String(errors[0]), {"errors": errors})
	_push_undo()
	working_rooms = candidate
	selected_local_id = ""
	redo_stack.clear()
	return {"ok": true, "deleted_local_id": deleted_id, "changed": true}

func paint_tile(room_key: String, world_position: Vector2, local_id: String = "") -> Dictionary:
	var clean_id: = local_id.strip_edges()
	if clean_id.is_empty():
		clean_id = "tile_%d" % _next_record_sequence(room_key, "tile")
	return add_record(room_key, {
		"local_id": clean_id, "record_type": "tile", "object_id": "tile.%s" % String(selected_palette.get("atlas_id", "atlas")), 
		"graphic_id": "atlas.%s" % String(selected_palette.get("atlas_id", "atlas")), "layer": "ground", 
		"atlas_id": String(selected_palette.get("atlas_id", "atlas")), "source_rect": selected_palette.get("source_rect", Rect2(0, 0, 256, 256)), 
		"position": world_position, "size": selected_palette.get("size", Vector2(64, 64)), "z_index": 0, 
	})

func add_collision_line(room_key: String, start: Vector2, finish: Vector2, local_id: String = "") -> Dictionary:
	var clean_id: = local_id.strip_edges()
	if clean_id.is_empty():
		clean_id = "collision_%d" % _next_record_sequence(room_key, "collision")
	return add_record(room_key, {
		"local_id": clean_id, "record_type": "collision_line", "object_id": "collision.line", 
		"graphic_id": "editor.collision_line.v1", "points": [start, finish], "width": 8.0, "collision_kind": "solid", 
		"position": start, 
	})

func add_warp(room_key: String, world_position: Vector2, target_world: String, target_room: String, target_position: Vector2, local_id: String = "") -> Dictionary:
	var clean_id: = local_id.strip_edges()
	if clean_id.is_empty():
		clean_id = "warp_%d" % _next_record_sequence(room_key, "warp")
	return add_record(room_key, {
		"local_id": clean_id, "record_type": "warp", "object_id": "world.warp", "graphic_id": "editor.warp.v1", 
		"position": world_position, "trigger_size": Vector2(48, 48), "target_world": target_world, 
		"target_room": target_room, "target_position": target_position, "contact_only": true, 
	})

func _next_record_sequence(room_key: String, prefix: String) -> int:
	var highest: = 0
	for value in Array(working_rooms.get(room_key, [])):
		if value is not Dictionary:
			continue
		var local_id: = String((value as Dictionary).get("local_id", ""))
		if not local_id.begins_with(prefix + "_"):
			continue
		var suffix: = local_id.trim_prefix(prefix + "_")
		if suffix.is_valid_int():
			highest = maxi(highest, int(suffix))
	return highest + 1

func move_selected(delta: Vector2) -> Dictionary:
	var record: = selected_record()
	if record.is_empty():
		return _error("NO_SELECTION", "Select a room object first.")
	var current: Variant = record.get("position", Vector2.ZERO)
	if current is not Vector2 or not _finite_vector(delta):
		return _error("INVALID_POSITION", "The requested movement is invalid.")
	var next: = Vector2(
		clampf((current as Vector2).x + delta.x, POSITION_MIN.x, POSITION_MAX.x), 
		clampf((current as Vector2).y + delta.y, POSITION_MIN.y, POSITION_MAX.y)
	)
	return edit_selected_field("position", next)

func begin_continuous_edit() -> bool:
	if not offline_authorized or _selected_index() < 0:
		return false
	if not continuous_edit_active:
		_push_undo()
		redo_stack.clear()
		continuous_edit_active = true
	return true

func end_continuous_edit() -> void :
	continuous_edit_active = false

func edit_selected_field(field_name: String, value: Variant) -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is limited to offline development mode.")
	if field_name not in EDITABLE_FIELDS:
		return _error("FIELD_NOT_EDITABLE", "That field is not editable in this admin slice.")
	var index: = _selected_index()
	if index < 0:
		return _error("NO_SELECTION", "Select a room object first.")
	var candidate_rooms: = working_rooms.duplicate(true)
	var room_records_value: Array = candidate_rooms[selected_room_key]
	var record: Dictionary = Dictionary(room_records_value[index]).duplicate(true)
	if value == null:
		record.erase(field_name)
	else:
		record[field_name] = value
	room_records_value[index] = record
	candidate_rooms[selected_room_key] = room_records_value
	var errors: = validate_rooms(candidate_rooms)
	if not errors.is_empty():
		return _error("VALIDATION_FAILED", String(errors[0]), {"errors": errors})
	if not continuous_edit_active:
		_push_undo()
	working_rooms = candidate_rooms
	redo_stack.clear()
	return {"ok": true, "record": selected_record(), "changed": true}

func undo() -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is limited to offline development mode.")
	if undo_stack.is_empty():
		return _error("NOTHING_TO_UNDO", "There is no editor change to undo.")
	redo_stack.append(working_rooms.duplicate(true))
	working_rooms = undo_stack.pop_back()
	return {"ok": true, "record": selected_record()}

func redo() -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is limited to offline development mode.")
	if redo_stack.is_empty():
		return _error("NOTHING_TO_REDO", "There is no editor change to redo.")
	undo_stack.append(working_rooms.duplicate(true))
	working_rooms = redo_stack.pop_back()
	return {"ok": true, "record": selected_record()}

func reset_room(room_key: String) -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is limited to offline development mode.")
	if room_key not in base_rooms:
		return _error("UNKNOWN_ROOM", "That room does not exist in the authored registry.")
	_push_undo()
	working_rooms[room_key] = Array(base_rooms[room_key]).duplicate(true)
	redo_stack.clear()
	return {"ok": true, "room_key": room_key}

func validate() -> Array[String]:
	return validate_rooms(working_rooms)

func validate_rooms(rooms: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for key_value in rooms.keys():
		var room_key: = String(key_value)
		if room_key.count(":") != 1 or room_key.begins_with(":") or room_key.ends_with(":"):
			errors.append("Invalid room key: %s" % room_key)
			continue
		var values: Variant = rooms[key_value]
		if values is not Array:
			errors.append("%s placements are not an Array" % room_key)
			continue
		var local_ids: Dictionary = {}
		for source_value in values as Array:
			if source_value is not Dictionary:
				errors.append("%s contains a non-Dictionary placement" % room_key)
				continue
			var record: = source_value as Dictionary
			if bool(record.get("deleted", false)):
				continue
			var local_id: = String(record.get("local_id", "")).strip_edges()
			var instance_id: = "%s/%s" % [room_key, local_id]
			var record_type: = String(record.get("record_type", "object")).strip_edges().to_lower()
			if record_type not in RECORD_TYPES:
				errors.append("%s has an invalid record_type" % instance_id)
			for required in ["local_id", "object_id", "graphic_id"]:
				if String(record.get(required, "")).strip_edges().is_empty():
					errors.append("%s is missing %s" % [instance_id, required])
			if local_id in local_ids:
				errors.append("%s duplicates local_id %s" % [room_key, local_id])
			local_ids[local_id] = true
			var position: Variant = record.get("position", null)
			if position is not Vector2 or not _finite_vector(position as Vector2):
				errors.append("%s has an invalid position" % instance_id)
			elif not Rect2(POSITION_MIN, POSITION_MAX - POSITION_MIN).has_point(position as Vector2) and position != POSITION_MAX:
				errors.append("%s position is outside editor bounds" % instance_id)
			if record_type == "tile":
				var source_rect: Variant = record.get("source_rect", null)
				var tile_size: Variant = record.get("size", null)
				if String(record.get("layer", "")).strip_edges().is_empty() or String(record.get("atlas_id", "")).strip_edges().is_empty():
					errors.append("Tile %s needs layer and atlas_id" % instance_id)
				if not (source_rect is Rect2) or not _finite_rect(source_rect as Rect2) or (source_rect as Rect2).size.x <= 0.0 or (source_rect as Rect2).size.y <= 0.0:
					errors.append("Tile %s needs a valid source_rect" % instance_id)
				if not (tile_size is Vector2) or not _finite_vector(tile_size as Vector2) or (tile_size as Vector2).x <= 0.0 or (tile_size as Vector2).y <= 0.0:
					errors.append("Tile %s needs a positive size" % instance_id)
			elif record_type == "collision_line":
				var points: Variant = record.get("points", null)
				if not (points is Array) or (points as Array).size() < 2:
					errors.append("Collision %s needs at least two points" % instance_id)
				else:
					for point_value in points as Array:
						if not (point_value is Vector2) or not _finite_vector(point_value as Vector2):
							errors.append("Collision %s has an invalid point" % instance_id)
						elif not _in_editor_bounds(point_value as Vector2):
							errors.append("Collision %s has a point outside editor bounds" % instance_id)
				var width: Variant = record.get("width", null)
				if not (width is int or width is float) or not _finite_number(float(width)) or float(width) <= 0.0:
					errors.append("Collision %s needs a positive width" % instance_id)
				if String(record.get("collision_kind", "")).to_lower() not in COLLISION_KINDS:
					errors.append("Collision %s has an invalid collision_kind" % instance_id)
			elif record_type == "warp":
				var trigger_size: Variant = record.get("trigger_size", null)
				if not (trigger_size is Vector2) or not _finite_vector(trigger_size as Vector2) or (trigger_size as Vector2).x <= 0.0 or (trigger_size as Vector2).y <= 0.0:
					errors.append("Warp %s needs a positive trigger_size" % instance_id)
				if String(record.get("target_world", "")).strip_edges().is_empty() or String(record.get("target_room", "")).strip_edges().is_empty():
					errors.append("Warp %s needs target_world and target_room" % instance_id)
				if not (record.get("target_position", null) is Vector2) or not _finite_vector(record.get("target_position", Vector2.ZERO) as Vector2) or not _in_editor_bounds(record.get("target_position", Vector2.ZERO) as Vector2):
					errors.append("Warp %s needs a valid target_position" % instance_id)
				if String(record.get("target_room", "")) not in working_rooms:
					errors.append("Warp %s targets an unknown room" % instance_id)
			if record_type == "object" and bool(record.get("interactive", false)):
				if String(record.get("action_id", "")).strip_edges().is_empty() or String(record.get("label", "")).strip_edges().is_empty():
					errors.append("Interactive %s needs action_id and label" % instance_id)
				var radius: Variant = record.get("radius", null)
				if not (radius is int or radius is float) or not _finite_number(float(radius)) or float(radius) <= 0.0:
					errors.append("Interactive %s needs a positive radius" % instance_id)
			if record.has("solid_rect"):
				var solid: Variant = record["solid_rect"]
				if solid is not Rect2 or not _finite_rect(solid as Rect2) or (solid as Rect2).size.x <= 0.0 or (solid as Rect2).size.y <= 0.0:
					errors.append("%s has an invalid solid_rect" % instance_id)
	return errors

func changed_room_keys() -> Array[String]:
	var changed: Array[String] = []
	for room_key in room_keys():
		if working_rooms.get(room_key, []) != base_rooms.get(room_key, []):
			changed.append(room_key)
	return changed

func export_patch() -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room export is limited to offline development mode.")
	var errors: = validate()
	if not errors.is_empty():
		return _error("VALIDATION_FAILED", String(errors[0]), {"errors": errors})
	var rooms: Array[Dictionary] = []
	for room_key in changed_room_keys():
		var placements: Array[Dictionary] = []
		var changed_by_id: Dictionary = {}
		for value in Array(base_rooms.get(room_key, [])):
			if value is Dictionary:
				changed_by_id[String((value as Dictionary).get("local_id", ""))] = value
		var records: Array = Array(working_rooms.get(room_key, [])).duplicate(true)
		records.sort_custom( func(a: Variant, b: Variant): return String((a as Dictionary).get("local_id", "")) < String((b as Dictionary).get("local_id", "")))
		for value in records:
			var record: = value as Dictionary
			var local_id: = String(record.get("local_id", ""))
			if record != changed_by_id.get(local_id, null):
				placements.append(_json_record(record))
		for base_id in changed_by_id.keys():
			if not records.any( func(value:
				Variant): return value is Dictionary and String((value as Dictionary).get("local_id", "")) == String(base_id)):
				var tombstone: Dictionary = Dictionary(changed_by_id[base_id]).duplicate(true)
				tombstone["deleted"] = true
				placements.append(_json_record(tombstone))
		rooms.append({"room_key": room_key, "placements": placements})
	return {
		"ok": true, 
		"patch_schema": PATCH_SCHEMA_VERSION, 
		"room_object_schema": RoomObjects.SCHEMA_VERSION, 
		"rooms": rooms, 
	}

func export_live_patch() -> Dictionary:
	if not offline_authorized:
		return _error("ADMIN_AUTH_REQUIRED", "Room editing is not authorized.")
	var errors: = validate()
	if not errors.is_empty():
		return _error("VALIDATION_FAILED", String(errors[0]), {"errors": errors})
	var rooms: Array[Dictionary] = []
	for room_key in changed_room_keys():
		var placements: Array[Dictionary] = []
		var base_by_id: Dictionary = {}
		for value in Array(base_rooms.get(room_key, [])):
			if value is Dictionary:
				base_by_id[String((value as Dictionary).get("local_id", ""))] = value
		var working_by_id: Dictionary = {}
		for value in Array(working_rooms.get(room_key, [])):
			if value is not Dictionary:
				continue
			var record: = value as Dictionary
			working_by_id[String(record.get("local_id", ""))] = record
			if record != base_by_id.get(String(record.get("local_id", "")), null):
				placements.append(record.duplicate(true))
		for base_id in base_by_id.keys():
			if not working_by_id.has(base_id):
				var tombstone: Dictionary = Dictionary(base_by_id[base_id]).duplicate(true)
				tombstone["deleted"] = true
				placements.append(tombstone)
		rooms.append({"room_key": room_key, "placements": placements})
	return {
		"ok": true, 
		"patch_schema": PATCH_SCHEMA_VERSION, 
		"room_object_schema": RoomObjects.SCHEMA_VERSION, 
		"rooms": rooms, 
	}

func export_patch_json() -> Dictionary:
	var patch: = export_patch()
	if not bool(patch.get("ok", false)):
		return patch
	return {"ok": true, "json": JSON.stringify(patch, "  ", false), "patch": patch}

func write_patch(path: String = "user://admin-room-patch.json") -> Dictionary:
	var result: = export_patch_json()
	if not bool(result.get("ok", false)):
		return result
	if not path.begins_with("user://"):
		return _error("INVALID_EXPORT_PATH", "Admin patches may only be written under user://.")
	var file: = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _error("EXPORT_FAILED", "The editor could not open the patch file.")
	file.store_string(String(result["json"]))
	file.close()
	return {"ok": true, "path": path, "json": result["json"], "patch": result["patch"]}

func _selected_index() -> int:
	if selected_room_key not in working_rooms:
		return -1
	var records: Array = working_rooms[selected_room_key]
	for index in range(records.size()):
		if records[index] is Dictionary and String((records[index] as Dictionary).get("local_id", "")) == selected_local_id:
			return index
	return -1

func _push_undo() -> void :
	undo_stack.append(working_rooms.duplicate(true))
	if undo_stack.size() > 50:
		undo_stack.pop_front()

func _json_record(record: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var fields: Array[String] = []
	for field_value in record.keys():
		fields.append(String(field_value))
	fields.sort()
	for field_name in fields:
		result[field_name] = _json_value(record[field_name])
	return result

func _json_value(value: Variant) -> Variant:
	if value is Vector2:
		return [(value as Vector2).x, (value as Vector2).y]
	if value is Rect2:
		var rect: = value as Rect2
		return {"x": rect.position.x, "y": rect.position.y, "width": rect.size.x, "height": rect.size.y}
	if value is Color:
		return (value as Color).to_html(true)
	if value is Array:
		var values: Array = []
		for item in value as Array:
			values.append(_json_value(item))
		return values
	if value is Dictionary:
		var mapped: Dictionary = {}
		for key in (value as Dictionary).keys():
			mapped[String(key)] = _json_value((value as Dictionary)[key])
		return mapped
	return value

func _finite_number(value: float) -> bool:
	return not is_nan(value) and not is_inf(value)

func _finite_vector(value: Vector2) -> bool:
	return _finite_number(value.x) and _finite_number(value.y)

func _finite_rect(value: Rect2) -> bool:
	return _finite_vector(value.position) and _finite_vector(value.size)

func _in_editor_bounds(value: Vector2) -> bool:
	return value.x >= POSITION_MIN.x and value.y >= POSITION_MIN.y and value.x <= POSITION_MAX.x and value.y <= POSITION_MAX.y

func _error(code: String, message: String, details: Dictionary = {}) -> Dictionary:
	var result: = {"ok": false, "error_code": code, "message": message}
	result.merge(details, true)
	return result
