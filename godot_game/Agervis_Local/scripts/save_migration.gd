class_name SaveMigration
extends RefCounted

const Rules = preload("res://scripts/prototype_rules.gd")
const EvidenceRecords = preload("res://scripts/evidence_records.gd")
const MothContent = preload("res://scripts/moth_content.gd")
const PlayerHomeContent = preload("res://scripts/player_home_content.gd")

const ECONOMY_SCHEMA_VERSION: = "1.1"
const CENTS_PER_DOLLAR: = 100
const MONEY_FIELDS: = {
	"carried_cash_clean": "cash", 
	"carried_cash_dirty": "dirty_cash", 
	"bank_balance_clean": "bank_balance", 
}

static func resident_needs_economy_migration(value: Variant) -> bool:
	if value is not Dictionary:
		return false
	return migrate_resident(value as Dictionary) != value

static func migrate_resident(value: Dictionary) -> Dictionary:
	var migrated: = value.duplicate(true)
	for canonical_name in MONEY_FIELDS:
		var legacy_name: = String(MONEY_FIELDS[canonical_name])
		if migrated.has(canonical_name):
			migrated[canonical_name] = maxi(0, int(migrated[canonical_name]))
		else:


			migrated[canonical_name] = maxi(0, int(migrated.get(legacy_name, 0))) * CENTS_PER_DOLLAR
	var heat: = Rules.normalized_heat(int(migrated.get("heat", migrated.get("case_strength", 0))))
	migrated["heat"] = heat
	migrated["case_strength"] = heat
	migrated["arrested"] = bool(migrated.get("arrested", false))
	migrated["detained"] = bool(migrated.get("detained", false))
	migrated["detained_by_account_id"] = String(migrated.get("detained_by_account_id", "")).strip_edges().to_upper().left(32)
	migrated["detained_by_resident_slot"] = int(migrated.get("detained_by_resident_slot", -1))
	migrated["detained_at_ms"] = maxi(0, int(migrated.get("detained_at_ms", 0)))
	if heat < Rules.LEO_DETENTION_MIN_HEAT or migrated["arrested"] or bool(migrated.get("deceased", false)):
		migrated["detained"] = false
		migrated["detained_by_account_id"] = ""
		migrated["detained_by_resident_slot"] = -1
		migrated["detained_at_ms"] = 0

	migrated["inventory"] = inventory_records(migrated.get("inventory", []))
	migrated["equipment"] = equipment_records(migrated.get("equipment", {}))
	migrated["evidence_history"] = EvidenceRecords.normalize_history(migrated.get("evidence_history", []))
	var legacy_handoffs: Variant = migrated.get("handoff_items", {})
	if String(migrated.get("economy_schema_version", "")) == ECONOMY_SCHEMA_VERSION:
		legacy_handoffs = {}
	migrated["active_handoffs"] = active_handoff_records(
		migrated.get("active_handoffs", []), 
		legacy_handoffs
	)
	migrated["completed_handoffs"] = completed_handoff_records(migrated.get("completed_handoffs", {}))
	migrated["processed_transactions"] = processed_transaction_records(migrated.get("processed_transactions", {}))
	migrated["employment"] = dictionary_record_array(migrated.get("employment", []))
	migrated["work_experience"] = non_negative_integer_dictionary(migrated.get("work_experience", {}))
	migrated["dealer_relationships"] = dealer_relationship_records(migrated.get("dealer_relationships", {}))
	migrated["active_substance_effects"] = substance_effect_records(migrated.get("active_substance_effects", {}))
	migrated["xp"] = xp_record(migrated.get("xp", migrated.get("skills", {})))
	migrated["school_agility_last_obstacle_id"] = String(migrated.get("school_agility_last_obstacle_id", "")).strip_edges().left(128)
	migrated["property"] = PlayerHomeContent.property_records(migrated.get("property", []))
	migrated["active_home_visit"] = PlayerHomeContent.normalize_active_visit(migrated.get("active_home_visit", {}))
	migrated["insurance"] = dictionary_record_array(migrated.get("insurance", []))
	var legacy_marker: Variant = migrated.get("legacy_marker", null)
	migrated["legacy_marker"] = null if legacy_marker == null else String(legacy_marker)
	migrated["economy_schema_version"] = ECONOMY_SCHEMA_VERSION
	return migrated

static func inventory_records(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var plain_item_indexes: Dictionary = {}
	if value is not Array:
		return records
	for entry in value:
		if entry is String or entry is StringName:
			var item_id: = String(entry).strip_edges()
			if item_id.is_empty():
				push_warning("Discarded an inventory entry with an empty ItemID during economy migration.")
				continue
			if plain_item_indexes.has(item_id):
				var existing_index: = int(plain_item_indexes[item_id])
				records[existing_index]["quantity"] = int(records[existing_index]["quantity"]) + 1
			else:
				plain_item_indexes[item_id] = records.size()
				records.append(default_item_record(item_id))
		elif entry is Dictionary:
			var normalized: = normalize_item_record(entry as Dictionary)
			if not normalized.is_empty():
				records.append(normalized)
		else:
			push_warning("Discarded an inventory entry without a valid ItemID during economy migration.")
	return records

static func equipment_records(value: Variant) -> Dictionary:
	var records: = {}
	if value is not Dictionary:
		return records
	for slot_variant in (value as Dictionary).keys():
		var slot: = String(slot_variant).strip_edges()
		if slot.is_empty():
			continue
		var entry: Variant = value[slot_variant]
		var normalized: = {}
		if entry is String or entry is StringName:
			var item_id: = String(entry).strip_edges()
			if not item_id.is_empty():
				normalized = default_item_record(item_id)
		elif entry is Dictionary:
			normalized = normalize_item_record(entry as Dictionary)
		if not normalized.is_empty():
			normalized["quantity"] = 1
			records[slot] = normalized
	return records

static func default_item_record(item_id: String) -> Dictionary:
	return {
		"item_id": item_id, 
		"quantity": 1, 
		"condition": 100, 
		"metadata": {}, 
	}

static func normalize_item_record(value: Dictionary) -> Dictionary:
	var item_id: = String(value.get("item_id", value.get("ItemID", ""))).strip_edges()
	if item_id.is_empty():
		push_warning("Discarded an inventory record with an empty ItemID during economy migration.")
		return {}
	var metadata: Variant = value.get("metadata", {})
	return {
		"item_id": item_id, 
		"quantity": maxi(1, int(value.get("quantity", 1))), 
		"condition": clampi(int(value.get("condition", 100)), 0, 100), 
		"metadata": (metadata as Dictionary).duplicate(true) if metadata is Dictionary else {}, 
	}

static func active_handoff_records(value: Variant, legacy_handoffs: Variant = {}) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if value is Array:
		for entry in value:
			if entry is Dictionary:
				candidates.append((entry as Dictionary).duplicate(true))
	if candidates.is_empty() and legacy_handoffs is Dictionary:
		for item_id_variant in (legacy_handoffs as Dictionary).keys():
			var entry: Variant = legacy_handoffs[item_id_variant]
			if entry is Dictionary:
				var handoff: = (entry as Dictionary).duplicate(true)
				handoff["id"] = String(handoff.get("id", item_id_variant))
				candidates.append(handoff)

	var active: Array[Dictionary] = []
	for handoff in candidates:
		var state: = String(handoff.get("state", "carried")).to_lower()
		if state not in ["carried", "pending", "in_transit"]:
			continue
		var nonce: = String(handoff.get("authority_nonce", handoff.get("nonce", ""))).strip_edges()
		if nonce.is_empty():
			push_warning("Expired a legacy handoff without an authority nonce during economy migration.")
			continue
		handoff["authority_nonce"] = nonce
		active.append(handoff)
	return active

static func completed_handoff_records(value: Variant) -> Dictionary:
	var completed: = {}
	if value is Dictionary:
		for nonce_variant in (value as Dictionary).keys():
			var nonce: = String(nonce_variant).strip_edges()
			var handoff: Variant = value[nonce_variant]
			if not nonce.is_empty() and handoff is Dictionary:
				completed[nonce] = (handoff as Dictionary).duplicate(true)
	return completed

static func processed_transaction_records(value: Variant) -> Dictionary:
	var processed: = {}
	if value is Dictionary:
		for transaction_variant in (value as Dictionary).keys():
			var transaction_id: = String(transaction_variant).strip_edges()
			var record: Variant = value[transaction_variant]
			if transaction_id.is_empty() or record is not Dictionary:
				continue
			var outcome: Variant = (record as Dictionary).get("outcome", {})
			if outcome is not Dictionary:
				continue
			processed[transaction_id] = {
				"processed_at_ms": maxi(0, int((record as Dictionary).get("processed_at_ms", 0))), 
				"outcome": (outcome as Dictionary).duplicate(true), 
			}
	return processed

static func xp_record(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var normalized: = {}
	for skill_variant in Rules.SKILLS:
		var skill: = String(skill_variant)
		var legacy_skill: = skill
		if skill == "Safety" and not source.has(skill):
			legacy_skill = "Security"
		elif skill == "Endurance" and not source.has(skill):
			legacy_skill = "Conditioning"
		normalized[skill] = maxi(0, int(source.get(legacy_skill, 0)))
	return normalized

static func non_negative_integer_dictionary(value: Variant) -> Dictionary:
	var normalized: = {}
	if value is Dictionary:
		for key in (value as Dictionary).keys():
			normalized[String(key)] = maxi(0, int(value[key]))
	return normalized

static func dealer_relationship_records(value: Variant) -> Dictionary:
	var relationships: = {}
	if value is Dictionary:
		for dealer_variant in (value as Dictionary).keys():
			var dealer_id: = String(dealer_variant).strip_edges().to_lower()
			var relationship: Variant = (value as Dictionary)[dealer_variant]
			if dealer_id.is_empty() or relationship is not Dictionary:
				continue
			if dealer_id == MothContent.DEALER_ID:
				relationships[dealer_id] = MothContent.normalize_relationship(relationship)
			else:
				relationships[dealer_id] = (relationship as Dictionary).duplicate(true)
	if not relationships.has(MothContent.DEALER_ID):
		relationships[MothContent.DEALER_ID] = MothContent.default_relationship()
	return relationships

static func substance_effect_records(value: Variant) -> Dictionary:
	var effects: = {}
	if value is Dictionary:
		for effect_variant in (value as Dictionary).keys():
			var effect_id: = String(effect_variant).strip_edges().to_lower()
			var effect: Variant = (value as Dictionary)[effect_variant]
			if effect_id.is_empty() or effect is not Dictionary:
				continue
			var record: = (effect as Dictionary).duplicate(true)
			record["ends_at_unix_ms"] = maxi(0, int(record.get("ends_at_unix_ms", 0)))
			record["stamina_regen_multiplier"] = clampf(float(record.get("stamina_regen_multiplier", 1.0)), 1.0, 5.0)
			record["health_regen_per_second"] = clampf(float(record.get("health_regen_per_second", 0.0)), 0.0, 5.0)
			effects[effect_id] = record
	return effects

static func dictionary_record_array(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if value is Array:
		for entry in value:
			if entry is Dictionary:
				records.append((entry as Dictionary).duplicate(true))
	return records

static func inventory_names(value: Variant) -> Array[String]:
	var names: Array[String] = []
	if value is not Array:
		return names
	for entry in value:
		if entry is String or entry is StringName:
			names.append(String(entry))
		elif entry is Dictionary:
			var record: = normalize_item_record(entry as Dictionary)
			var item_id: = String(record.get("item_id", ""))
			for _copy in range(maxi(0, int(record.get("quantity", 0)))):
				names.append(item_id)
	return names

static func equipment_names(value: Variant) -> Dictionary:
	var names: = {}
	if value is not Dictionary:
		return names
	for slot_variant in (value as Dictionary).keys():
		var entry: Variant = value[slot_variant]
		if entry is String or entry is StringName:
			names[String(slot_variant)] = String(entry)
		elif entry is Dictionary:
			names[String(slot_variant)] = String((entry as Dictionary).get("item_id", (entry as Dictionary).get("ItemID", "")))
	return names

static func legacy_handoff_dictionary(value: Variant) -> Dictionary:
	var handoffs: = {}
	if value is Array:
		for entry in value:
			if entry is Dictionary:
				var handoff: = (entry as Dictionary).duplicate(true)
				var item_id: = String(handoff.get("id", "")).strip_edges()
				if not item_id.is_empty():
					handoffs[item_id] = handoff
	return handoffs
