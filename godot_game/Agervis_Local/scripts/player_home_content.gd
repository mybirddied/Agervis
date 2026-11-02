class_name AgervisPlayerHomeContent
extends RefCounted

const MERCY_COURT_ID: = "mercy_court_apartment"

const CATALOG: = {
	MERCY_COURT_ID: {
		"display_name": "Mercy Court Apartment", 
		"building_area": "apartment", 
		"public_entry_room": "floor_1", 
		"private_room_id": "unit", 
		"storage_capacity": 30, 
	}, 
}

const WALL_STYLES: = {
	"mercy_paint": {"display_name": "Mercy Court Paint", "color": "#585b57"}, 
	"clinic_surplus": {"display_name": "Clinic Surplus Green", "color": "#4f6059"}, 
	"landlord_white": {"display_name": "Landlord White", "color": "#77766f"}, 
}

const FLOOR_STYLES: = {
	"worn_vinyl": {"display_name": "Worn Vinyl", "color": "#45423c"}, 
	"salvaged_wood": {"display_name": "Salvaged Wood", "color": "#594b3d"}, 
	"sealed_concrete": {"display_name": "Sealed Concrete", "color": "#4d5151"}, 
}

const FURNITURE_IDS: = ["questionable_couch"]
const ACCESS_RECORD_LIMIT: = 12

static func catalog_entry(catalog_id: String) -> Dictionary:
	return Dictionary(CATALOG.get(catalog_id, {})).duplicate(true)

static func default_customization() -> Dictionary:
	return {"wall_style": "mercy_paint", "floor_style": "worn_vinyl", "furniture": []}

static func instance_id(world_id: String, account_id: String, resident_slot: int, catalog_id: String = MERCY_COURT_ID) -> String:
	return "POH:%s:%s:%d:%s" % [world_id, account_id, resident_slot, catalog_id]

static func default_mercy_home(world_id: String, account_id: String, resident_slot: int) -> Dictionary:
	return {
		"property_id": "HOME-%s-%d-%s" % [account_id, resident_slot, MERCY_COURT_ID], 
		"type": "player_home", 
		"catalog_id": MERCY_COURT_ID, 
		"display_name": "Mercy Court Apartment", 
		"owner_account_id": account_id, 
		"owner_resident_slot": resident_slot, 
		"world_id": world_id, 
		"home_instance_id": instance_id(world_id, account_id, resident_slot), 
		"customization": default_customization(), 
		"visit_requests": [], 
		"one_time_access": [], 
		"issued_keys": [], 
	}

static func normalize_visit_requests(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if value is not Array:
		return records
	for entry_variant in value:
		if entry_variant is not Dictionary or records.size() >= ACCESS_RECORD_LIMIT:
			continue
		var entry: Dictionary = entry_variant as Dictionary
		var request_id: = String(entry.get("request_id", "")).strip_edges().left(64)
		var guest_account_id: = String(entry.get("guest_account_id", "")).strip_edges().left(32)
		var guest_slot: = int(entry.get("guest_resident_slot", -1))
		if request_id.is_empty() or guest_account_id.is_empty() or guest_slot < 0:
			continue
		records.append({
			"request_id": request_id, 
			"guest_account_id": guest_account_id, 
			"guest_resident_slot": guest_slot, 
			"guest_name": String(entry.get("guest_name", "Resident")).strip_edges().left(20), 
			"requested_at_ms": maxi(0, int(entry.get("requested_at_ms", 0))), 
		})
	return records

static func normalize_one_time_access(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if value is not Array:
		return records
	for entry_variant in value:
		if entry_variant is not Dictionary or records.size() >= ACCESS_RECORD_LIMIT:
			continue
		var entry: Dictionary = entry_variant as Dictionary
		var grant_id: = String(entry.get("grant_id", "")).strip_edges().left(64)
		var guest_account_id: = String(entry.get("guest_account_id", "")).strip_edges().left(32)
		var guest_slot: = int(entry.get("guest_resident_slot", -1))
		var uses_remaining: = clampi(int(entry.get("uses_remaining", 1)), 0, 1)
		if grant_id.is_empty() or guest_account_id.is_empty() or guest_slot < 0 or uses_remaining <= 0:
			continue
		records.append({
			"grant_id": grant_id, 
			"guest_account_id": guest_account_id, 
			"guest_resident_slot": guest_slot, 
			"guest_name": String(entry.get("guest_name", "Resident")).strip_edges().left(20), 
			"uses_remaining": uses_remaining, 
			"issued_at_ms": maxi(0, int(entry.get("issued_at_ms", 0))), 
		})
	return records

static func normalize_issued_keys(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if value is not Array:
		return records
	for entry_variant in value:
		if entry_variant is not Dictionary or records.size() >= ACCESS_RECORD_LIMIT:
			continue
		var entry: Dictionary = entry_variant as Dictionary
		var key_id: = String(entry.get("key_id", "")).strip_edges().left(64)
		if key_id.is_empty():
			continue
		records.append({
			"key_id": key_id, 
			"item_id": String(entry.get("item_id", "Mercy Court Guest Key")).strip_edges().left(80), 
			"active": bool(entry.get("active", true)), 
			"issued_to_account_id": String(entry.get("issued_to_account_id", "")).strip_edges().left(32), 
			"issued_to_resident_slot": maxi(-1, int(entry.get("issued_to_resident_slot", -1))), 
			"issued_to_name": String(entry.get("issued_to_name", "Resident")).strip_edges().left(20), 
			"issued_at_ms": maxi(0, int(entry.get("issued_at_ms", 0))), 
		})
	return records

static func visit_snapshot(home: Dictionary, owner_name: String = "Resident") -> Dictionary:
	var normalized: = normalize_home_record(home)
	if normalized.is_empty():
		return {}
	return {
		"property_id": String(normalized.get("property_id", "")).left(96), 
		"display_name": String(normalized.get("display_name", "Player Home")).left(48), 
		"home_instance_id": String(normalized.get("home_instance_id", "")).left(160), 
		"owner_name": owner_name.strip_edges().left(20), 
		"customization": normalize_customization(normalized.get("customization", {})), 
	}

static func normalize_active_visit(value: Variant) -> Dictionary:
	if value is not Dictionary:
		return {}
	var source: Dictionary = value as Dictionary
	var visit_id: = String(source.get("visit_id", "")).strip_edges().left(96)
	var home_instance_id: = String(source.get("home_instance_id", "")).strip_edges().left(160)
	var owner_account_id: = String(source.get("owner_account_id", "")).strip_edges().left(32)
	var owner_slot: = int(source.get("owner_resident_slot", -1))
	var access_kind: = String(source.get("access_kind", "")).to_lower()
	if visit_id.is_empty() or home_instance_id.is_empty() or owner_account_id.is_empty() or owner_slot < 0 or access_kind not in ["one_time", "permanent_key"]:
		return {}
	var snapshot: Dictionary = source.get("home_snapshot", {}) if source.get("home_snapshot", {}) is Dictionary else {}
	if String(snapshot.get("home_instance_id", "")) != home_instance_id:
		return {}
	return {
		"visit_id": visit_id, 
		"home_instance_id": home_instance_id, 
		"owner_account_id": owner_account_id, 
		"owner_resident_slot": owner_slot, 
		"access_kind": access_kind, 
		"authorization_id": String(source.get("authorization_id", "")).strip_edges().left(96), 
		"started_at_ms": maxi(0, int(source.get("started_at_ms", 0))), 
		"home_snapshot": {
			"property_id": String(snapshot.get("property_id", "")).left(96), 
			"display_name": String(snapshot.get("display_name", "Player Home")).left(48), 
			"home_instance_id": home_instance_id, 
			"owner_name": String(snapshot.get("owner_name", "Resident")).strip_edges().left(20), 
			"customization": normalize_customization(snapshot.get("customization", {})), 
		}, 
	}

static func normalize_customization(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var wall_style: = String(source.get("wall_style", "mercy_paint"))
	var floor_style: = String(source.get("floor_style", "worn_vinyl"))
	if wall_style not in WALL_STYLES:
		wall_style = "mercy_paint"
	if floor_style not in FLOOR_STYLES:
		floor_style = "worn_vinyl"
	var furniture: Array[String] = []
	var furniture_source: Variant = source.get("furniture", [])
	if furniture_source is Array:
		for item_variant in furniture_source:
			var item_id: = String(item_variant)
			if item_id in FURNITURE_IDS and item_id not in furniture:
				furniture.append(item_id)
	return {"wall_style": wall_style, "floor_style": floor_style, "furniture": furniture}

static func normalize_home_record(value: Dictionary) -> Dictionary:
	var record: = value.duplicate(true)
	if String(record.get("type", "")) != "player_home":
		return record
	var catalog_id: = String(record.get("catalog_id", MERCY_COURT_ID))
	if catalog_id not in CATALOG:
		catalog_id = MERCY_COURT_ID
	record["catalog_id"] = catalog_id
	record["display_name"] = String(CATALOG[catalog_id].get("display_name", "Player Home"))
	record["owner_account_id"] = String(record.get("owner_account_id", ""))
	record["owner_resident_slot"] = maxi(-1, int(record.get("owner_resident_slot", -1)))
	record["world_id"] = String(record.get("world_id", ""))
	var stored_instance_id: = String(record.get("home_instance_id", ""))
	if stored_instance_id.is_empty() and not String(record.get("world_id", "")).is_empty() and not String(record.get("owner_account_id", "")).is_empty() and int(record.get("owner_resident_slot", -1)) >= 0:
		stored_instance_id = instance_id(String(record.get("world_id", "")), String(record.get("owner_account_id", "")), int(record.get("owner_resident_slot", -1)), catalog_id)
	record["home_instance_id"] = stored_instance_id
	record["customization"] = normalize_customization(record.get("customization", {}))
	record["visit_requests"] = normalize_visit_requests(record.get("visit_requests", []))
	record["one_time_access"] = normalize_one_time_access(record.get("one_time_access", []))
	record["issued_keys"] = normalize_issued_keys(record.get("issued_keys", []))
	return record

static func property_records(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if value is Array:
		for entry in value:
			if entry is Dictionary:
				records.append(normalize_home_record(entry as Dictionary))
	return records

static func ensure_mercy_home(value: Variant, world_id: String, account_id: String, resident_slot: int) -> Array[Dictionary]:
	var records: = property_records(value)
	var home_index: = -1
	for index in range(records.size()):
		if String(records[index].get("type", "")) == "player_home" and String(records[index].get("catalog_id", "")) == MERCY_COURT_ID:
			home_index = index
			break
	if home_index < 0:
		records.append(default_mercy_home(world_id, account_id, resident_slot))
		return records
	var home: = records[home_index].duplicate(true)
	if String(home.get("owner_account_id", "")).is_empty():
		home["owner_account_id"] = account_id
	if int(home.get("owner_resident_slot", -1)) < 0:
		home["owner_resident_slot"] = resident_slot
	if String(home.get("world_id", "")).is_empty():
		home["world_id"] = world_id
	records[home_index] = normalize_home_record(home)
	return records

static func first_player_home(properties: Variant, catalog_id: String = "") -> Dictionary:
	for record in property_records(properties):
		if String(record.get("type", "")) != "player_home":
			continue
		if not catalog_id.is_empty() and String(record.get("catalog_id", "")) != catalog_id:
			continue
		return record.duplicate(true)
	return {}

static func visit_request(home: Dictionary, request_id: String) -> Dictionary:
	for entry in normalize_visit_requests(home.get("visit_requests", [])):
		if String(entry.get("request_id", "")) == request_id:
			return entry.duplicate(true)
	return {}

static func one_time_grant(home: Dictionary, account_id: String, resident_slot: int) -> Dictionary:
	for entry in normalize_one_time_access(home.get("one_time_access", [])):
		if String(entry.get("guest_account_id", "")) == account_id and int(entry.get("guest_resident_slot", -1)) == resident_slot:
			return entry.duplicate(true)
	return {}

static func issued_key(home: Dictionary, key_id: String) -> Dictionary:
	for entry in normalize_issued_keys(home.get("issued_keys", [])):
		if String(entry.get("key_id", "")) == key_id and bool(entry.get("active", false)):
			return entry.duplicate(true)
	return {}

static func style_color(style_catalog: Dictionary, style_id: String, fallback: String) -> Color:
	var style: Dictionary = style_catalog.get(style_id, {})
	return Color(String(style.get("color", fallback)))
