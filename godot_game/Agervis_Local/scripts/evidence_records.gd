class_name AgervisEvidenceRecords
extends RefCounted

const SCHEMA_VERSION: = 1
const TYPE_BLOOD: = "blood"
const TYPE_BLOOD_SAMPLE: = "blood_sample"
const TYPE_BODY: = "body"
const TYPE_BLOOD_CLEANING: = "blood_cleaning"
const TYPE_CAMERA: = "camera"
const TYPE_WITNESS: = "witness"
const TYPE_INVENTORY_EVIDENCE: = "inventory_evidence"
const STATE_PRESENT: = "present"
const STATE_COLLECTED: = "collected"
const STATE_CLEANED: = "cleaned"
const STATE_DELETED: = "deleted"

static func blood_record(
	evidence_id: String, 
	source_event_id: int, 
	area_name: String, 
	room_name: String, 
	point: Vector2, 
	amount: int, 
	seed_value: int, 
	attacker_peer_id: int, 
	target_peer_id: int, 
	created_at_ms: int, 
	home_instance_id: String = ""
) -> Dictionary:
	return normalize_record({
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_BLOOD, 
		"evidence_id": evidence_id, 
		"type": TYPE_BLOOD, 
		"state": STATE_PRESENT, 
		"source_event_id": source_event_id, 
		"source_kind": "combat", 
		"area": area_name.left(32), 
		"room_id": room_name.left(48), 
		"position": point, 
		"amount": clampi(amount, 1, 12), 
		"seed": seed_value, 
		"attacker_peer_id": attacker_peer_id, 
		"target_peer_id": target_peer_id, 
		"created_at_ms": maxi(0, created_at_ms), 
		"home_instance_id": home_instance_id, 
		"sample_count": 0, 
		"sample_ids": [], 
		"cleaning_history": [], 
		"cleaned_at_ms": 0, 
	})

static func blood_sample_record(
	sample_id: String, 
	parent_evidence_id: String, 
	area_name: String, 
	room_name: String, 
	point: Vector2, 
	collector_account_id: String, 
	collector_resident_slot: int, 
	collected_at_ms: int
) -> Dictionary:
	return normalize_record({
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_BLOOD_SAMPLE, 
		"evidence_id": sample_id, 
		"type": TYPE_BLOOD_SAMPLE, 
		"state": STATE_COLLECTED, 
		"parent_evidence_id": parent_evidence_id, 
		"source_kind": TYPE_BLOOD, 
		"area": area_name.left(32), 
		"room_id": room_name.left(48), 
		"position": point, 
		"collector_account_id": collector_account_id.left(32), 
		"collector_resident_slot": collector_resident_slot, 
		"collected_at_ms": maxi(0, collected_at_ms), 
	})

static func body_record(
	evidence_id: String, 
	source_event_id: int, 
	outcome_id: String, 
	area_name: String, 
	room_name: String, 
	point: Vector2, 
	target_peer_id: int, 
	target_resident_key: String, 
	target_name: String, 
	created_at_ms: int, 
	home_instance_id: String = ""
) -> Dictionary:
	return normalize_record({
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_BODY, 
		"evidence_id": evidence_id, 
		"type": TYPE_BODY, 
		"state": STATE_PRESENT, 
		"source_event_id": source_event_id, 
		"source_kind": "disposition", 
		"outcome_id": outcome_id, 
		"area": area_name.left(32), 
		"room_id": room_name.left(48), 
		"position": point, 
		"target_peer_id": target_peer_id, 
		"target_resident_key": target_resident_key.left(128), 
		"target_name": target_name.left(20), 
		"created_at_ms": maxi(0, created_at_ms), 
		"home_instance_id": home_instance_id, 
	})

static func camera_record(
	evidence_id: String, 
	event_id: int, 
	camera_id: String, 
	area_name: String, 
	room_name: String, 
	point: Vector2, 
	event_type: String, 
	subject: String, 
	description: String, 
	strength: int, 
	time_text: String, 
	recorded_at_ms: int, 
	deleted: bool, 
	exported: bool, 
	substituted: bool
) -> Dictionary:
	return normalize_record({
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_CAMERA, 
		"evidence_id": evidence_id, 
		"type": event_type, 
		"event_type": event_type, 
		"state": STATE_DELETED if deleted else STATE_PRESENT, 
		"id": event_id, 
		"camera": camera_id, 
		"area": area_name, 
		"room_id": room_name, 
		"position": point, 
		"subject": subject, 
		"description": description, 
		"strength": strength, 
		"time": time_text, 
		"created_at_ms": recorded_at_ms, 
		"deleted": deleted, 
		"exported": exported, 
		"substituted": substituted, 
	})

static func witness_record(
	evidence_id: String, 
	actor: String, 
	description: String, 
	witness_source: String, 
	witness_id: String, 
	area_name: String, 
	room_name: String, 
	point: Vector2, 
	strength: int, 
	time_text: String, 
	created_at_ms: int, 
	account_id: String = "", 
	resident_slot: int = -1, 
	peer_id: int = 0
) -> Dictionary:
	return normalize_record({
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_WITNESS, 
		"evidence_id": evidence_id, 
		"type": TYPE_WITNESS, 
		"state": STATE_PRESENT, 
		"action": "WITNESS", 
		"actor": actor, 
		"description": description, 
		"witness_source": witness_source, 
		"witness_id": witness_id, 
		"area": area_name, 
		"room_id": room_name, 
		"position": point, 
		"strength": strength, 
		"time": time_text, 
		"created_at_ms": created_at_ms, 
		"account_id": account_id, 
		"resident_slot": resident_slot, 
		"peer_id": peer_id, 
	})

static func inventory_evidence_record(
	evidence_id: String, 
	event_type: String, 
	account_id: String, 
	resident_slot: int, 
	subject_account_id: String, 
	subject_resident_slot: int, 
	area_name: String, 
	room_name: String, 
	item_ids: Array, 
	amount_cents: int, 
	details: Dictionary, 
	created_at_ms: int
) -> Dictionary:
	var record: = {
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_INVENTORY_EVIDENCE, 
		"evidence_id": evidence_id, 
		"type": event_type, 
		"event_type": event_type, 
		"state": STATE_PRESENT, 
		"account_id": account_id, 
		"resident_slot": resident_slot, 
		"subject_account_id": subject_account_id, 
		"subject_resident_slot": subject_resident_slot, 
		"area": area_name, 
		"room_id": room_name, 
		"item_ids": item_ids.duplicate(true), 
		"amount_cents": maxi(0, amount_cents), 
		"created_at_ms": created_at_ms, 
	}
	for detail_key in details.keys():
		record[String(detail_key)] = details[detail_key]
	return normalize_record(record)

static func normalize_record(value: Dictionary) -> Dictionary:
	var record: = value.duplicate(true)
	record["schema_version"] = SCHEMA_VERSION
	record["evidence_id"] = String(record.get("evidence_id", "")).strip_edges().left(64)
	var raw_type: = String(record.get("type", "")).strip_edges()
	var record_kind: = String(record.get("record_kind", "")).strip_edges().to_lower()
	if record_kind.is_empty():
		var lower_type: = raw_type.to_lower()
		if lower_type in [TYPE_BLOOD, TYPE_BLOOD_SAMPLE, TYPE_BODY, TYPE_BLOOD_CLEANING]:
			record_kind = lower_type
		elif record.has("camera") and record.has("id"):
			record_kind = TYPE_CAMERA
		elif String(record.get("action", "")).to_upper() == "WITNESS":
			record_kind = TYPE_WITNESS
		elif lower_type in ["robbery", "sealed_deposit_tamper"]:
			record_kind = TYPE_INVENTORY_EVIDENCE
	record["record_kind"] = record_kind
	record["type"] = raw_type.left(48) if record_kind in [TYPE_CAMERA, TYPE_INVENTORY_EVIDENCE] else raw_type.to_lower()
	record["state"] = String(record.get("state", STATE_PRESENT)).strip_edges().to_lower()
	record["area"] = String(record.get("area", "")).left(32)
	record["room_id"] = String(record.get("room_id", "")).left(48)
	record["home_instance_id"] = String(record.get("home_instance_id", "")).left(96)
	var position_value: Variant = record.get("position", Vector2.ZERO)
	if position_value is Vector2:
		record["position"] = position_value
	elif position_value is Array and (position_value as Array).size() >= 2:
		record["position"] = Vector2(float((position_value as Array)[0]), float((position_value as Array)[1]))
	else:
		record["position"] = Vector2.ZERO
	if record_kind == TYPE_BLOOD:
		record["type"] = TYPE_BLOOD
		record["amount"] = clampi(int(record.get("amount", 1)), 1, 12)
		record["seed"] = int(record.get("seed", 1))
		record["sample_count"] = maxi(0, int(record.get("sample_count", 0)))
		record["cleaned_at_ms"] = maxi(0, int(record.get("cleaned_at_ms", 0)))
		var cleaning_history: Array[Dictionary] = []
		for trace_value in record.get("cleaning_history", []):
			if trace_value is Dictionary:
				var trace: = (trace_value as Dictionary).duplicate(true)
				trace["trace_id"] = String(trace.get("trace_id", "")).left(96)
				trace["status"] = String(trace.get("status", "")).left(24)
				trace["cleaner_item_id"] = String(trace.get("cleaner_item_id", "")).left(48)
				trace["cleaner_account_id"] = String(trace.get("cleaner_account_id", "")).left(32)
				trace["cleaner_resident_slot"] = int(trace.get("cleaner_resident_slot", -1))
				trace["started_at_ms"] = maxi(0, int(trace.get("started_at_ms", 0)))
				trace["completed_at_ms"] = maxi(0, int(trace.get("completed_at_ms", 0)))
				trace["reason"] = String(trace.get("reason", "")).left(64)
				var witnesses: Array[Dictionary] = []
				for witness_index in range(Array(trace.get("witnesses", [])).size()):
					var witness_value: Variant = Array(trace.get("witnesses", []))[witness_index]
					if witness_value is Dictionary:
						var witness: = witness_value as Dictionary
						if is_witness_record(witness):
							witnesses.append(normalize_record(witness))
						else:
							witnesses.append(witness_record(
								"%s-WITNESS-%d" % [String(trace.get("trace_id", "CLEAN")), witness_index + 1], 
								"Resident", "Resident was nearby during blood-evidence cleaning.", "resident", 
								String(witness.get("account_id", "")), String(record.get("area", "")), String(record.get("room_id", "")), 
								Vector2.ZERO, 0, "", int(trace.get("started_at_ms", 0)), 
								String(witness.get("account_id", "")), int(witness.get("resident_slot", -1)), int(witness.get("peer_id", 0))
							))
				trace["witnesses"] = witnesses
				trace = normalize_record(trace)
				cleaning_history.append(trace)
		record["cleaning_history"] = cleaning_history
	if record_kind == TYPE_BLOOD_SAMPLE:
		record["type"] = TYPE_BLOOD_SAMPLE
		record["parent_evidence_id"] = String(record.get("parent_evidence_id", "")).left(64)
		record["collector_account_id"] = String(record.get("collector_account_id", "")).left(32)
		record["collector_resident_slot"] = int(record.get("collector_resident_slot", -1))
		record["collected_at_ms"] = maxi(0, int(record.get("collected_at_ms", record.get("created_at_ms", 0))))
	if record_kind == TYPE_BODY:
		record["type"] = TYPE_BODY
		record["source_event_id"] = maxi(0, int(record.get("source_event_id", 0)))
		record["outcome_id"] = String(record.get("outcome_id", "")).left(128)
		record["target_peer_id"] = int(record.get("target_peer_id", 0))
		record["target_resident_key"] = String(record.get("target_resident_key", "")).left(128)
		record["target_name"] = String(record.get("target_name", "Resident")).left(20)
	record["created_at_ms"] = maxi(0, int(record.get("created_at_ms", 0)))
	if record_kind == TYPE_BLOOD_CLEANING:
		record["type"] = TYPE_BLOOD_CLEANING
		record["evidence_id"] = String(record.get("evidence_id", record.get("trace_id", ""))).left(96)
		record["trace_id"] = String(record.get("trace_id", record.get("evidence_id", ""))).left(96)
		record["status"] = String(record.get("status", record.get("state", ""))).left(24)
		record["state"] = record["status"]
		record["cleaner_item_id"] = String(record.get("cleaner_item_id", "")).left(48)
		record["cleaner_account_id"] = String(record.get("cleaner_account_id", "")).left(32)
		record["cleaner_resident_slot"] = int(record.get("cleaner_resident_slot", -1))
		record["started_at_ms"] = maxi(0, int(record.get("started_at_ms", 0)))
		record["completed_at_ms"] = maxi(0, int(record.get("completed_at_ms", 0)))
		record["reason"] = String(record.get("reason", "")).left(64)
	if record_kind == TYPE_CAMERA:
		record["event_type"] = String(record.get("event_type", record.get("type", ""))).left(32)
		record["id"] = int(record.get("id", 0))
		record["camera"] = String(record.get("camera", "")).left(48)
		record["subject"] = String(record.get("subject", "")).left(48)
		record["description"] = String(record.get("description", "")).left(240)
		record["strength"] = maxi(0, int(record.get("strength", 0)))
		record["time"] = String(record.get("time", "")).left(16)
		record["deleted"] = bool(record.get("deleted", record.get("state", "") == STATE_DELETED))
		record["exported"] = bool(record.get("exported", false))
		record["substituted"] = bool(record.get("substituted", false))
		record["state"] = STATE_DELETED if record["deleted"] else STATE_PRESENT
	if record_kind == TYPE_WITNESS:
		record["type"] = TYPE_WITNESS
		record["action"] = "WITNESS"
		record["actor"] = String(record.get("actor", "")).left(48)
		record["description"] = String(record.get("description", "")).left(240)
		record["witness_source"] = String(record.get("witness_source", "")).left(24)
		record["witness_id"] = String(record.get("witness_id", "")).left(64)
		record["strength"] = maxi(0, int(record.get("strength", 0)))
		record["time"] = String(record.get("time", "")).left(16)
		record["account_id"] = String(record.get("account_id", "")).left(32)
		record["resident_slot"] = int(record.get("resident_slot", -1))
		record["peer_id"] = int(record.get("peer_id", 0))
	if record_kind == TYPE_INVENTORY_EVIDENCE:
		record["event_type"] = String(record.get("event_type", record.get("type", ""))).left(48)
		record["account_id"] = String(record.get("account_id", "")).left(32)
		record["resident_slot"] = int(record.get("resident_slot", -1))
		record["subject_account_id"] = String(record.get("subject_account_id", "")).left(32)
		record["subject_resident_slot"] = int(record.get("subject_resident_slot", -1))
		record["item_ids"] = Array(record.get("item_ids", [])).duplicate(true)
		record["amount_cents"] = maxi(0, int(record.get("amount_cents", 0)))
	var sample_ids: Array[String] = []
	for sample_id_value in record.get("sample_ids", []):
		var sample_id: = String(sample_id_value).strip_edges().left(64)
		if not sample_id.is_empty() and sample_id not in sample_ids:
			sample_ids.append(sample_id)
	record["sample_ids"] = sample_ids
	return record

static func is_blood_record(value: Variant) -> bool:
	return value is Dictionary and String((value as Dictionary).get("record_kind", (value as Dictionary).get("type", ""))) == TYPE_BLOOD

static func is_active_blood(value: Variant) -> bool:
	return is_blood_record(value) and String((value as Dictionary).get("state", "")) == STATE_PRESENT

static func is_body_record(value: Variant) -> bool:
	return value is Dictionary and String((value as Dictionary).get("record_kind", (value as Dictionary).get("type", ""))) == TYPE_BODY

static func is_active_body(value: Variant) -> bool:
	return is_body_record(value) and String((value as Dictionary).get("state", "")) == STATE_PRESENT

static func is_camera_record(value: Variant) -> bool:
	return value is Dictionary and String((value as Dictionary).get("record_kind", "")) == TYPE_CAMERA

static func is_witness_record(value: Variant) -> bool:
	return value is Dictionary and String((value as Dictionary).get("record_kind", "")) == TYPE_WITNESS

static func is_inventory_evidence_record(value: Variant) -> bool:
	return value is Dictionary and String((value as Dictionary).get("record_kind", "")) == TYPE_INVENTORY_EVIDENCE

static func normalize_history(value: Variant) -> Array[Dictionary]:
	var history: Array[Dictionary] = []
	if value is not Array:
		return history
	for index in range((value as Array).size()):
		var entry: Variant = (value as Array)[index]
		if entry is not Dictionary:
			continue
		var normalized: = normalize_record(entry as Dictionary)
		if String(normalized.get("record_kind", "")).is_empty():
			history.append((entry as Dictionary).duplicate(true))
			continue
		if String(normalized.get("evidence_id", "")).is_empty():
			normalized["evidence_id"] = "%s-%d" % [String(normalized.get("record_kind", "EVIDENCE")).to_upper(), index + 1]
		history.append(normalized)
	return history

static func blood_cleaning_trace_record(
	trace_id: String, 
	status: String, 
	cleaner_item_id: String, 
	cleaner_account_id: String, 
	cleaner_resident_slot: int, 
	started_at_ms: int, 
	completed_at_ms: int, 
	reason: String, 
	witnesses: Array
) -> Dictionary:
	return normalize_record({
		"schema_version": SCHEMA_VERSION, 
		"record_kind": TYPE_BLOOD_CLEANING, 
		"trace_id": trace_id.left(96), 
		"evidence_id": trace_id.left(96), 
		"type": "blood_cleaning", 
		"status": status.left(24), 
		"state": status.left(24), 
		"cleaner_item_id": cleaner_item_id.left(48), 
		"cleaner_account_id": cleaner_account_id.left(32), 
		"cleaner_resident_slot": cleaner_resident_slot, 
		"started_at_ms": maxi(0, started_at_ms), 
		"completed_at_ms": maxi(0, completed_at_ms), 
		"reason": reason.left(64), 
		"witnesses": witnesses.duplicate(true), 
	})
