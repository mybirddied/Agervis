class_name ReleaseSave
extends RefCounted

const SaveMigration = preload("res://scripts/save_migration.gd")

const SAVE_PATH: = "user://agervis_first_block_release_1.json"
const FREE_SLOTS: = 5
const PREMIUM_SLOTS: = 2
const SAVE_VERSION: = 1
const TUTORIAL_DRAFT_VERSION: = 1

const TUTORIAL_DRAFT_FIELDS: = [
	"draft_id", "revision", "world_id", "updated_unix_ms", 
	"name", "phase", "area", "room_id", "position", "objective", 
	"color", "skin", "pants_color", "hair_style", "body_style", "hair_color", 
	"facial_hair_style", "facial_hair_color", "face_style", "eye_style", "stature", 
	"outfit_style", "surreal_trait", "accessory", "tutorial_flags", 
	"tutorial_path_scores", "tutorial_headstart", 
]

static func empty_tutorial_drafts() -> Array:
	var drafts: Array = []
	for _index in range(FREE_SLOTS):
		drafts.append(null)
	return drafts

static func default_roster() -> Dictionary:
	var slots: Array = []
	for _index in range(FREE_SLOTS):
		slots.append(null)
	return {
		"version": SAVE_VERSION, 
		"active_slot": -1, 
		"tutorial_draft_version": TUTORIAL_DRAFT_VERSION, 
		"active_tutorial_slot": -1, 
		"last_switch_unix": 0, 
		"settings": {"low_spec": false, "tips_enabled": true, "close_chat_after_enter": true}, 
		"slots": slots, 
		"tutorial_drafts": empty_tutorial_drafts(), 
	}

static func legacy_tutorial_draft(value: Dictionary, slot_index: int) -> Dictionary:
	var draft: = {
		"draft_version": TUTORIAL_DRAFT_VERSION, 
		"slot_index": slot_index, 
		"name": "Citizen", 
		"phase": "tutorial", 
		"area": "tutorial", 
		"room_id": "guidance", 
		"position": [112.0, 250.0], 
	}
	for field in TUTORIAL_DRAFT_FIELDS:
		if value.has(field):
			draft[field] = value[field].duplicate(true) if value[field] is Array or value[field] is Dictionary else value[field]
	draft["name"] = "Citizen"
	draft["phase"] = "tutorial"
	draft["slot_index"] = slot_index
	return draft

static func normalize_roster(value: Variant) -> Dictionary:
	var roster: = default_roster()
	if value is not Dictionary:
		return roster
	var source: = value as Dictionary
	roster["active_slot"] = clampi(int(source.get("active_slot", -1)), -1, FREE_SLOTS - 1)
	roster["active_tutorial_slot"] = clampi(int(source.get("active_tutorial_slot", -1)), -1, FREE_SLOTS - 1)
	roster["last_switch_unix"] = maxi(0, int(source.get("last_switch_unix", 0)))
	var source_settings: Variant = source.get("settings", {})
	if source_settings is Dictionary:
		roster["settings"] = {
			"low_spec": bool(source_settings.get("low_spec", false)), 
			"tips_enabled": bool(source_settings.get("tips_enabled", true)), 
			"close_chat_after_enter": bool(source_settings.get("close_chat_after_enter", true)), 
		}
	var source_drafts: Variant = source.get("tutorial_drafts", [])
	if source_drafts is Array:
		for index in range(mini(FREE_SLOTS, source_drafts.size())):
			var source_draft: Variant = source_drafts[index]
			if source_draft is Dictionary:
				roster["tutorial_drafts"][index] = legacy_tutorial_draft(source_draft as Dictionary, index)
	var source_slots: Variant = source.get("slots", [])
	if source_slots is Array:
		for index in range(mini(FREE_SLOTS, source_slots.size())):
			var slot: Variant = source_slots[index]
			if slot is Dictionary and not String(slot.get("name", "")).is_empty():
				if String(slot.get("phase", "adult")).to_lower() == "tutorial":
					if roster["tutorial_drafts"][index] is not Dictionary:
						roster["tutorial_drafts"][index] = legacy_tutorial_draft(slot as Dictionary, index)
				else:
					roster["slots"][index] = SaveMigration.migrate_resident(slot as Dictionary)
					roster["tutorial_drafts"][index] = null
	if int(roster.get("active_tutorial_slot", -1)) < 0:
		for index in range(FREE_SLOTS):
			if roster["tutorial_drafts"][index] is Dictionary:
				roster["active_tutorial_slot"] = index
				break
	elif roster["tutorial_drafts"][int(roster["active_tutorial_slot"])] is not Dictionary:
		roster["active_tutorial_slot"] = -1
	return roster

static func needs_economy_migration(value: Variant) -> bool:
	if value is not Dictionary:
		return false
	var source: = value as Dictionary
	var source_slots: Variant = source.get("slots", [])
	if source_slots is Array:
		for slot in source_slots:
			if slot is Dictionary and String(slot.get("phase", "adult")).to_lower() == "tutorial":
				continue
			if SaveMigration.resident_needs_economy_migration(slot):
				return true
		return false
	if String(source.get("phase", "adult")).to_lower() == "tutorial":
		return false
	return SaveMigration.resident_needs_economy_migration(source)

static func load_roster() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_roster()
	var file: = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return default_roster()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	var normalized: = normalize_roster(parsed)
	if needs_economy_migration(parsed):
		save_roster(normalized)
	return normalized

static func save_roster(roster: Dictionary) -> bool:
	var file: = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(normalize_roster(roster), "\t"))
	file.flush()
	return true

static func delete_resident(value: Dictionary, slot_index: int) -> Dictionary:
	var updated: = normalize_roster(value)
	if slot_index < 0 or slot_index >= FREE_SLOTS:
		return updated
	var had_resident: = updated["slots"][slot_index] is Dictionary
	var had_tutorial_draft: = updated["tutorial_drafts"][slot_index] is Dictionary
	if not had_resident and not had_tutorial_draft:
		return updated
	updated["slots"][slot_index] = null
	updated["tutorial_drafts"][slot_index] = null
	if had_resident and int(updated.get("active_slot", -1)) == slot_index:
		updated["active_slot"] = -1
		for index in range(FREE_SLOTS):
			if updated["slots"][index] is Dictionary:
				updated["active_slot"] = index
				break
	if int(updated.get("active_tutorial_slot", -1)) == slot_index:
		updated["active_tutorial_slot"] = -1
		for index in range(FREE_SLOTS):
			if updated["tutorial_drafts"][index] is Dictionary:
				updated["active_tutorial_slot"] = index
				break
	if had_resident:
		updated["last_switch_unix"] = 0
	return updated

static func populated_slots(roster: Dictionary) -> int:
	var count: = 0
	for slot in roster.get("slots", []):
		if slot is Dictionary:
			count += 1
	return count
