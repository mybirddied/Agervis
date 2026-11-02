class_name AgervisPrivateSession
extends Node

const RoomObjects = preload("res://scripts/room_objects.gd")
const AdminRoomEditor = preload("res://scripts/admin_room_editor.gd")
const Build10 = preload("res://scripts/build10_content.gd")
const Build9 = preload("res://scripts/build9_systems.gd")
const EducationQuestions = preload("res://scripts/education_questions.gd")
const ItemUseRules = preload("res://scripts/item_use_rules.gd")

signal status_changed(message: String)
signal peer_snapshot_received(snapshot: Dictionary)
signal chat_received(sender_name: String, message: String)
signal attack_requested(peer_id: int)
signal combat_event_received(payload: Dictionary)
signal xp_event_received(payload: Dictionary)
signal disposition_requested(peer_id: int, target_peer_id: int, action: String)
signal permanent_outcome_received(payload: Dictionary)
signal nearby_hosts_changed(hosts: Array)
signal server_roster_received(roster: Dictionary, world_id: String)
signal resident_name_check_received(result: Dictionary)
signal resident_save_result(result: Dictionary)
signal economy_result_received(result: Dictionary)
signal server_population_received(population: int, capacity: int)
signal blood_evidence_snapshot_received(records: Array)
signal body_evidence_snapshot_received(records: Array)
signal admin_status_received(result: Dictionary)
signal admin_room_received(result: Dictionary)
signal admin_patch_result_received(result: Dictionary)
signal graceful_disconnect_ready

const DEFAULT_PORT: = 24860
const DISCOVERY_PORT: = 24861
const PRIVATE_MAX_PLAYERS: = 5
const MAIN_MAX_PLAYERS: = 25
const MAX_PLAYERS: = PRIVATE_MAX_PLAYERS
const PROTOCOL_VERSION: = 11
const MAIN_PROFILE_PATH: = "user://agervis_main_server_profiles.save"
const ADMIN_PROFILE_PATH: = "user://agervis_admin_accounts.save"
const ADMIN_PATCH_PATH: = "user://agervis_main_server_room_patches.save"
const PRIVATE_PROFILE_PATH: = "user://agervis_private_world_profiles.save"
const PRIVATE_WORLD_ID_PATH: = "user://agervis_private_world_id.txt"
const MAIN_WORLD_ID: = "AGERVIS-MAIN-FIRST-BLOCK"
const LOCAL_TEST_WORLD_ID: = "AGERVIS-LOCAL-TEST-WORLD"
const REMOTE_REPLICATION_FIELDS: = [
	"peer_id", "name", "area", "room_id", "phase", "position", "facing", "walking", 
	"home_instance_id", 
	"color", "pants_color", "skin", "hair_style", "body_style", "hair_color", 
	"facial_hair_style", "facial_hair_color", "face_style", "eye_style", "stature", 
	"outfit_style", "surreal_trait", "accessory", "attack_weapon", "health", "downed", 
	"mark", "deceased", "detained", "arrested", "heat", "warrant", 
]
const REMOTE_IDENTITY_FIELDS: = [
	"peer_id", "resident_key", "name", "color", "pants_color", "skin", "hair_style", "body_style", 
	"hair_color", "facial_hair_style", "facial_hair_color", "face_style", "eye_style", 
	"stature", "outfit_style", "surreal_trait", "accessory", "attack_weapon", 
]
const REMOTE_MOTION_FIELDS: = [
	"area", "room_id", "phase", "home_instance_id", "position", "facing", "walking", "health", "downed", 
	"mark", "deceased", "detained", "arrested", "heat", "warrant", 
]
const SNAPSHOT_CHUNK_TARGET_BYTES: = 1050
const ROSTER_CHUNK_TARGET_BYTES: = 700
const AUTHORITATIVE_SELF_TRANSFER_WORLD: = "__AUTH_SELF__"
const INITIAL_SNAPSHOT_TRANSFER_WORLD: = "__INITIAL_SNAPSHOT__"
const TRANSACTION_TTL_MS: = 24 * 60 * 60 * 1000
const BLOOD_EMPTY_SERVER_RETENTION_SECONDS: = 30.0 * 60.0
const BLOOD_CLEANING_DISTANCE: = 125.0
const BLOOD_CLEANING_POSITION_TOLERANCE: = 2.0
const BLOOD_CLEANING_WITNESS_DISTANCE: = 240.0
const SCHOOL_TRAINING_POSITION_TOLERANCE: = 3.0
const SCHOOL_TRAINING_COMPLETION_GRACE_SECONDS: = 30.0
const SCHOOL_GYM_COMPLETION_RADIUS: = 145.0
const SCHOOL_GYM_PRACTICE_XP: = 95
const SCHOOL_GYM_DURATIONS: = {"rope": 1.8, "ledge": 2.4, "vault": 1.45}
const SCHOOL_DUMMY_PRACTICE_XP: = 75
const SCHOOL_STEALTH_TEACHER_DEFENSE: = 5.0
const SCHOOL_STEALTH_ATTEMPT_COOLDOWN_MS: = 3000
const SCHOOL_STEALTH_ENVELOPE_CENTS: = 100
const SCHOOL_STUDY_QUESTION_COUNT: = 2
const SCHOOL_STUDY_REQUIRED_CORRECT: = 2
const SCHOOL_STUDY_XP: = 95
const SCHOOL_STUDY_TIMEOUT_MS: = 10 * 60 * 1000
const SCHOOL_DUMMY_OUTCOMES: = [
	"down", "rob", "restrain", "stabilize", "leave", "fatal", 
	"injury_leg", "injury_hand", "injury_head", "injury_facial", 
]
const LEO_DETENTION_MIN_HEAT: = Rules.LEO_DETENTION_MIN_HEAT
const LEO_ARREST_MIN_HEAT: = Rules.LEO_ARREST_MIN_HEAT
const BLOOD_CLEANING_AGENTS: = {
	"Crude Bleach": {"duration_seconds": 30.0}, 
	"Bargain Bleach": {"duration_seconds": 20.0}, 
	"Extra Strength Bleach": {"duration_seconds": 10.0}, 
	"Lab-grade Bleach": {"duration_seconds": 5.0}, 
	"Ammonia": {"duration_seconds": 0.0}, 
}
const CASHIER_TASK_WAGE_CENTS: = 1500
const CASHIER_DELIVERY_BONUS_CENTS: = 8000
const CASHIER_DEPOSIT_VALUE_CENTS: = 4200
const CASHIER_DEPOSIT_ACTIVE_SECONDS: = 600.0
const CASHIER_TASK_ROOMS: = {
	"register": "store:sales", 
	"stock": "store:stockroom", 
	"clean": "store:sales", 
}
const SERVICE_JOBS: = {
	"alibis": {
		"job_id": "alibis_carryout", "employer": "Alibi's Carryout", "start_room": "restaurant:dining", 
		"tasks": ["counter", "prep"], "task_rooms": {"counter": "restaurant:dining", "prep": "restaurant:kitchen"}, 
		"task_wage_cents": 500, "task_xp": {"counter": {"Enterprise": 75}, "prep": {"Endurance": 75}}, 
		"deposit_room": "restaurant:delivery", "handoff_id": "restaurant_deposit", "handoff_display": "Sealed Restaurant Deposit", "deposit_bonus_cents": 1200, 
	}, 
	"spin_cycle": {
		"job_id": "spin_cycle_laundry", "employer": "Spin Cycle Laundry", "start_room": "laundromat:floor", 
		"tasks": ["wash", "fold"], "task_rooms": {"wash": "laundromat:floor", "fold": "laundromat:floor"}, 
		"task_wage_cents": 400, "task_xp": {"wash": {"Endurance": 70}, "fold": {"Enterprise": 70}}, 
		"deposit_room": "laundromat:office", "handoff_id": "laundry_deposit", "handoff_display": "Sealed Laundry Deposit", "deposit_bonus_cents": 1000, 
	}, 
}
const JAIL_ASSIGNMENT_REWARDS: = {
	"structured_recovery_session": {"label": "STRUCTURED RECOVERY SESSION", "xp": {"Medicine": 90}}, 
	"administrative_assistance": {"label": "ADMINISTRATIVE ASSISTANCE", "xp": {"Civics": 80}, "jail_street_cred": 1}, 
	"jail_education": {"label": "JAIL EDUCATION", "xp": {"Intelligence": 110, "Civics": 55}, "education_points": 2}, 
	"laundry_sort": {"label": "LAUNDRY SORT", "xp": {"Endurance": 150, "Awareness": 70}}, 
	"structured_recovery_group": {"label": "STRUCTURED RECOVERY GROUP", "xp": {"Medicine": 105, "Influence": 75}}, 
	"mandatory_labor": {"label": "MANDATORY LABOR", "xp": {"Endurance": 110}}, 
}
const BARBER_HAIR_STYLES: = ["bald"]
const BARBER_FACIAL_HAIR_STYLES: = ["none"]
const BARBER_HAIR_COLORS: = ["17191b"]
const BARBER_CATEGORY_PRICES: = {"hair_style": 800, "hair_color": 800, "facial_hair_style": 600, "facial_hair_color": 600}
const ATTACK_DISTANCE: = 94.0
const ATTACK_COOLDOWN_MS: = 580
const ATTACK_WEAPONS: = ["Fists", "Worn Revolver", "Pipe Wrench", "Bolt Cutters", "Box Cutter"]
const LAUNDRY_OFFICE_AREA: = "laundromat"
const LAUNDRY_OFFICE_ROOM: = "office"
const LAUNDRY_MOB_HOSTILITY_MS: = 10 * 60 * 1000
const LAUNDRY_DEFENDER_SPEED: = 150.0
const LAUNDRY_CAPONE_APPROACH_SPEED: = LAUNDRY_DEFENDER_SPEED * 0.25
const LAUNDRY_OFFICE_DESK_CLEARANCE: = Rect2(645, 172, 260, 98)
const LAUNDRY_OFFICE_LEFT_WALK_X: = 365.0
const LAUNDRY_NPC_ATTACK_DISTANCE: = 68.0
const LAUNDRY_NPC_ATTACK_COOLDOWN: = 0.95
const LAUNDRY_NPC_DAMAGE: = 19.0
const LAUNDRY_NPC_DISPOSITION_DISTANCE: = 62.0
const DOWNED_RECOVERY_SECONDS: = 3.0
const MAIM_FIGHTING_LEVEL: = 2
const FATAL_FIGHTING_LEVEL: = 3
const FATAL_STEALTH_LEVEL: = 2
const CAPONE_EMPLOYMENT_JOB_ID: = "capone_criminal_courier"
const CAPONE_EMPLOYMENT_NAME: = "Capone's Courier Desk"
const CAPONE_MOTH_RUN_REQUIREMENT: = 30
const CAPONE_TASK_TIMEOUT_SECONDS: = 300.0
const CAPONE_FAILURE_LIMIT: = 3
const CAPONE_TASKS: = [
	{"id": "capone_tee_drop", "label": "Meet Tee at the bus stop", "recipient_actor_id": "bus_client_tee", "recipient_name": "Tee", "destination_label": "the bus stop", "area": "street", "room_id": "", "point": Vector2(10060.0, 205.0)}, 
	{"id": "capone_nell_drop", "label": "Meet Nell at the Mercy fire-escape landing", "recipient_actor_id": "moth_customer_nell", "recipient_name": "Nell", "destination_label": "the Mercy fire-escape landing", "area": "rooftop", "room_id": "", "point": Vector2(1120.0, 205.0)}, 
	{"id": "capone_mack_drop", "label": "Meet Mack at the gated mechanic lot", "recipient_actor_id": "moth_customer_mack", "recipient_name": "Mack", "destination_label": "the gated mechanic lot", "area": "rear", "room_id": "", "point": Vector2(6200.0, 215.0)}, 
	{"id": "capone_nia_drop", "label": "Meet Nia at the laundromat rear entrance", "recipient_actor_id": "moth_customer_nia", "recipient_name": "Nia", "destination_label": "the laundromat rear entrance", "area": "rear", "room_id": "", "point": Vector2(4540.0, 215.0)}, 
	{"id": "capone_cal_drop", "label": "Meet Cal behind Boss's store", "recipient_actor_id": "moth_customer_cal", "recipient_name": "Cal", "destination_label": "behind Boss's store", "area": "rear", "room_id": "", "point": Vector2(4930.0, 215.0)}, 
]
const HANDOFF_RULES: = {
	"sealed_deposit_bag": {"display": "Sealed Deposit Bag", "employer": "Boss's Corner Store", "sources": ["store:safe", "backroom:stockroom"], "source_point": Vector2(485, 215), "destinations": ["bank:lobby"], "destination_point": Vector2(820, 225), "radius": 180.0}, 
	"restaurant_deposit": {"display": "Sealed Restaurant Deposit", "employer": "Alibi's Carryout", "sources": ["restaurant:delivery"], "source_point": Vector2(500, 215), "destinations": ["bank:lobby"], "destination_point": Vector2(820, 225), "radius": 180.0}, 
	"laundry_deposit": {"display": "Sealed Laundry Deposit", "employer": "Spin Cycle Laundry", "sources": ["laundromat:office"], "source_point": Vector2(740, 205), "destinations": ["bank:lobby"], "destination_point": Vector2(820, 225), "radius": 180.0}, 
	"sealed_dime_bag": {"display": "Sealed Dime Bag", "employer": "Moth's Errand Desk", "sources": ["street:"], "source_point": Vector2(6030, 115), "destinations": ["street:"], "destination_point": Vector2(10060, 205), "radius": 280.0}, 
	"sealed_quarter_bag": {"display": "Sealed Quarter Bag", "employer": "Moth's Errand Desk", "sources": ["street:"], "source_point": Vector2(6030, 115), "destinations": ["street:", "rear:", "rooftop:"], "radius": 280.0}, 
	"sealed_customer_envelope": {"display": "Sealed Customer Envelope", "employer": "Moth's Errand Desk", "sources": ["street:", "rear:", "rooftop:"], "destinations": ["street:"], "destination_point": Vector2(6030, 115), "radius": 280.0}, 
	"evidence_bag": {"display": "Evidence Bag", "employer": "Agervis Precinct", "sources": ["precinct:booking"], "source_point": Vector2(220, 205), "destinations": ["precinct:evidence"], "destination_point": Vector2(500, 205), "radius": 180.0}, 
	"shift_radio": {"display": "Shift Radio", "employer": "First Block Security", "sources": ["apartment:security"], "source_point": Vector2(500, 205), "destinations": ["apartment:security"], "destination_point": Vector2(500, 205), "radius": 180.0}, 
}
const ECONOMY_VENDOR_CATALOG: = {
	"alibis": {
		"Hot Plate": {"price_cents": 600, "accepted_money": ["clean"]}, 
		"Sealed Water": {"price_cents": 300, "accepted_money": ["clean"]}, 
		"Receipt With Timestamp": {"price_cents": 400, "accepted_money": ["clean"]}, 
	}, 
	"pawn": {
		"Used Kevlar": {"price_cents": 6500, "accepted_money": ["clean"]}, 
		"Canvas Backpack": {"price_cents": 4800, "accepted_money": ["clean"]}, 
		"Large Courier Pack": {"price_cents": 8600, "accepted_money": ["clean"]}, 
		"Bolt Cutters": {"price_cents": 4200, "accepted_money": ["clean"]}, 
		"Box Cutter": {"price_cents": 1200, "accepted_money": ["clean"]}, 
		"Pipe Wrench": {"price_cents": 2400, "accepted_money": ["clean"]}, 
		"Pepper Spray": {"price_cents": 1800, "accepted_money": ["clean"]}, 
		"Worn Revolver": {"price_cents": 11000, "accepted_money": ["clean"]}, 
		"Gun Cleaning Cloth": {"price_cents": 900, "accepted_money": ["clean"]}, 
		"Disposable Gloves": {"price_cents": 600, "accepted_money": ["clean"]}, 
		"Small Evidence Bags": {"price_cents": 500, "accepted_money": ["clean"]}, 
		"Pawn Ticket": {"price_cents": 400, "accepted_money": ["clean"]}, 
	}, 
	"boss_store": {
		"Sealed Water": {"price_cents": 300, "accepted_money": ["clean", "dirty"]}, 
		"Emergency Beacon": {"price_cents": 2200, "accepted_money": ["clean", "dirty"]}, 
	}, 
	"hospital_pharmacy": {
		"Clinic Revivar": {"price_cents": 1800, "accepted_money": ["clean"]}, 
		"Basic Bandage": {"price_cents": 500, "accepted_money": ["clean"]}, 
	}, 
	"pillmill": {
		"Pill Organizer": {"price_cents": 700, "accepted_money": ["clean"]}, 
		"Sealed Water": {"price_cents": 300, "accepted_money": ["clean"]}, 
		"Basic Bandage": {"price_cents": 600, "accepted_money": ["clean"]}, 
	}, 
	"clinic": {
		"Clinic Revivar": {"price_cents": 800, "accepted_money": ["clean"]}, 
		"Sterile Supply Pack": {"price_cents": 400, "accepted_money": ["clean"]}, 
		"Meeting Bus Token": {"price_cents": 200, "accepted_money": ["clean"]}, 
	}, 
}
const ECONOMY_VENDOR_ROOMS: = {
	"alibis": "restaurant:dining", 
	"pawn": "pawn:sales", 
	"boss_store": "store:sales", 
	"hospital_pharmacy": "hospital:intake", 
	"pillmill": "pillmill:waiting", 
	"clinic": "clinic:waiting", 
}
const ReleaseSave = preload("res://scripts/release_save.gd")
const SaveMigration = preload("res://scripts/save_migration.gd")
const Rules = preload("res://scripts/prototype_rules.gd")
const EvidenceRecords = preload("res://scripts/evidence_records.gd")
const MothContent = preload("res://scripts/moth_content.gd")
const PlayerHomeContent = preload("res://scripts/player_home_content.gd")

const TUTORIAL_COLOR_VALUES: = ["111315"]
const TUTORIAL_SKIN_VALUES: = ["b97855"]
const TUTORIAL_PANTS_VALUES: = ["101214"]
const TUTORIAL_HAIR_COLOR_VALUES: = ["17191b"]
const TUTORIAL_HAIR_STYLES: = ["bald"]
const TUTORIAL_BODY_STYLES: = ["standard"]
const TUTORIAL_FACE_STYLES: = ["neutral"]
const TUTORIAL_EYE_STYLES: = ["neutral"]
const TUTORIAL_OUTFIT_STYLES: = ["none"]
const TUTORIAL_SURREAL_TRAITS: = ["none"]
const TUTORIAL_ACCESSORIES: = ["none"]
const ADULT_FACIAL_HAIR_STYLES: = ["none"]
const ADULT_STATURES: = ["average"]

const TUTORIAL_LEVEL_5_XP: = 520
const TUTORIAL_HEADSTART_XP: = {
	"civilian": {"Intelligence": TUTORIAL_LEVEL_5_XP, "Enterprise": TUTORIAL_LEVEL_5_XP, "Influence": TUTORIAL_LEVEL_5_XP}, 
	"law": {"Safety": TUTORIAL_LEVEL_5_XP, "Awareness": TUTORIAL_LEVEL_5_XP, "Civics": TUTORIAL_LEVEL_5_XP}, 
	"criminal": {"Stealth": TUTORIAL_LEVEL_5_XP, "Awareness": TUTORIAL_LEVEL_5_XP, "Enterprise": TUTORIAL_LEVEL_5_XP}, 
}
const TUTORIAL_HEADSTART_ITEMS: = {
	"civilian": "Completed Intake Packet", 
	"law": "Hall Monitor Incident Pad", 
	"criminal": "Service Hallway Map", 
}
var peer_states: Dictionary = {}
var authorized_peers: Dictionary = {}
var active: = false
var hosting: = false
var public_hosting: = false
var max_players: = PRIVATE_MAX_PLAYERS
var status: = "OFFLINE"
var port: = DEFAULT_PORT
var enet_peer: ENetMultiplayerPeer
var persistent_profiles: Dictionary = {}
var profiles_dirty: = false
var profile_save_timer: = 10.0
var profiles_enabled: = false
var profile_path: = ""
var admin_profile_path: = ADMIN_PROFILE_PATH
var server_world_id: = ""
var peer_accounts: Dictionary = {}
var admin_accounts: Dictionary = {}
var admin_room_patches: Dictionary = {}
var admin_room_revisions: Dictionary = {}
var admin_audit_log: Array[Dictionary] = []
var admin_operation_sequence: = 0

var session_token: = ""
var external_address: = ""
var router_mapping_ready: = false
var outside_confirmed: = false
var upnp: UPNP

var discovery_listener: PacketPeerUDP
var discovery_broadcaster: PacketPeerUDP
var discovery_active: = false
var discovery_timer: = 0.0
var discovery_name: = "Agervis host"
var nearby_hosts: Dictionary = {}

var ping_timer: = 0.0
var ping_sent: = 0
var ping_received: = 0
var ping_ms: = 0.0
var jitter_ms: = 0.0
var packet_loss_percent: = 0.0
var last_response_ms: = 0

var reconnect_address: = ""
var reconnect_port: = DEFAULT_PORT
var reconnect_token: = ""
var reconnect_state: Dictionary = {}
var reconnect_attempts: = 0
var reconnect_timer: = 0.0
var attack_ready_at_ms: Dictionary = {}
var laundry_office_npcs: Dictionary = {}
var laundry_hostile_until_ms: Dictionary = {}
var laundry_capone_direct_until_ms: Dictionary = {}
var laundry_office_presence: Dictionary = {}
var laundry_defeat_pending: Dictionary = {}
var laundry_capone_disposition_started: Dictionary = {}
var combat_event_sequence: = 0
var evidence_event_sequence: = 0
var blood_evidence_records: Array[Dictionary] = []
var body_evidence_sequence: = 0
var body_evidence_records: Array[Dictionary] = []
var blood_empty_server_elapsed: = 0.0
var blood_cleaning_actions: Dictionary = {}
var school_training_actions: Dictionary = {}
var school_practice_states: Dictionary = {}
var school_study_sessions: Dictionary = {}
var cleaning_trace_sequence: = 0
var xp_event_sequence: = 0
var handoff_event_sequence: = 0
var economy_event_sequence: = 0
var economy_audit_log: Array[Dictionary] = []
var cashier_assignment: Dictionary = {}
var service_assignments: Dictionary = {}
var pending_permanent_outcomes: Array[Dictionary] = []
var permanent_outcome_sequence: = 0
var authoritative_downed_timers: Dictionary = {}
var combat_rng: = RandomNumberGenerator.new()
var snapshot_interval: = 0.1
var snapshot_timer: = 0.0
var snapshot_dirty: = false
var snapshot_broadcast_count: = 0
var snapshot_recipient_count: = 0
var snapshot_chunk_count: = 0
var snapshot_bytes_sent_estimate: = 0
var snapshot_periodic_bytes_sent_estimate: = 0
var self_authority_send_count: = 0
var remote_identity_send_count: = 0
var state_submission_count: = 0
var max_connected_peer_count: = 0
var disconnect_count: = 0
var persistence_write_count: = 0
var persistence_total_ms: = 0
var main_server_population: = 0
var last_population_broadcast: = -1
var last_capacity_broadcast: = -1
var population_dirty: = false
var population_timer: = 0.0
var snapshot_sequence: = 0
var last_self_authority_fingerprints: Dictionary = {}
var last_remote_identity_fingerprints: Dictionary = {}
var authoritative_self_state: Dictionary = {}
var remote_identity_states: Dictionary = {}
var pending_initial_snapshot_peers: Dictionary = {}
const INITIAL_SNAPSHOT_RETRY_INTERVAL_MS: = 100
const INITIAL_SNAPSHOT_RETRY_WINDOW_MS: = 3000
var pending_snapshot_sequence: = -1
var pending_snapshot_chunk_count: = 0
var pending_snapshot_chunks: Dictionary = {}
var roster_transfer_sequence: = 0
var pending_roster_transfer: = -1
var pending_roster_world: = ""
var pending_roster_chunk_count: = 0
var pending_roster_chunks: Dictionary = {}

func _ready() -> void :
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	combat_rng.randomize()
	set_process(true)

func _process(delta: float) -> void :
	if hosting:
		update_authoritative_laundry_office(delta)
		update_authoritative_combat(delta)
		update_authoritative_detentions()
		update_active_blood_cleaning(delta)
		update_active_school_training(delta)
		update_blood_evidence_retention(delta)
		update_active_handoff_clocks(delta)
		if population_dirty:
			population_timer -= delta
			if population_timer <= 0.0:
				_broadcast_population()
		if snapshot_dirty:
			snapshot_timer -= delta
			if snapshot_timer <= 0.0:
				snapshot_dirty = false
				snapshot_timer = snapshot_interval
				_broadcast_snapshot()
		_flush_pending_initial_snapshots()
		if profiles_enabled and profiles_dirty:
			profile_save_timer -= delta
			if profile_save_timer <= 0.0:
				store_all_connected_residents()
				save_server_profiles()
		discovery_timer -= delta
		if discovery_timer <= 0.0:
			discovery_timer = 0.85
			_broadcast_host_announcement()
	if discovery_active:
		_poll_discovery()
		_prune_nearby_hosts()
	if active and not hosting and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		ping_timer -= delta
		if ping_timer <= 0.0:
			ping_timer = 1.0
			ping_sent += 1
			ping_server.rpc_id(1, Time.get_ticks_msec())
			_update_loss()
	elif not active and reconnect_attempts > 0 and reconnect_attempts <= 3:
		reconnect_timer -= delta
		if reconnect_timer <= 0.0:
			_attempt_reconnect()

func connected_resident_count() -> int:
	var count: = 0
	for peer_variant in peer_states.keys():
		var peer_id: = int(peer_variant)
		var state: Dictionary = peer_states[peer_id]
		if peer_id == 1 and String(state.get("phase", "")) == "server":
			continue
		if int(state.get("resident_slot", -1)) >= 0 and not safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", "")))).is_empty():
			count += 1
	return count

func update_blood_evidence_retention(delta: float) -> void :
	var has_physical_evidence: = not blood_evidence_records.is_empty() or not body_evidence_records.is_empty()
	if delta <= 0.0 or not hosting or not has_physical_evidence:
		if connected_resident_count() > 0:
			blood_empty_server_elapsed = 0.0
		return
	if connected_resident_count() > 0:
		blood_empty_server_elapsed = 0.0
		return
	blood_empty_server_elapsed += delta
	if blood_empty_server_elapsed >= BLOOD_EMPTY_SERVER_RETENTION_SECONDS:
		blood_evidence_records.clear()
		body_evidence_records.clear()
		blood_empty_server_elapsed = 0.0

func update_authoritative_detentions() -> void :
	if not hosting:
		return
	var released: = false
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		var state: Dictionary = peer_states[peer_id]
		if not bool(state.get("detained", false)):
			continue
		if authoritative_heat(state) >= LEO_DETENTION_MIN_HEAT:
			continue
		clear_detention_fields(state)
		peer_states[peer_id] = state
		if profiles_enabled:
			store_connected_resident(peer_id)
		released = true
		_broadcast_chat("SYSTEM", "%s is released from temporary detention as Heat falls below 50." % String(state.get("name", "Resident")))
	if released:
		profiles_dirty = true
		_schedule_snapshot()

func blood_evidence_records_for_state(observer: Dictionary) -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for record in blood_evidence_records:
		if not EvidenceRecords.is_active_blood(record):
			continue
		var record_state: = {
			"area": String(record.get("area", "")), 
			"room_id": String(record.get("room_id", "")), 
			"home_instance_id": String(record.get("home_instance_id", "")), 
		}
		if String(observer.get("area", "")) == String(record_state.get("area", "")) and String(observer.get("room_id", "")) == String(record_state.get("room_id", "")):
			if states_share_room_instance(observer, record_state):
				visible.append(record.duplicate(true))
	return visible

func blood_evidence_record(evidence_id: String) -> Dictionary:
	for record in blood_evidence_records:
		if String(record.get("evidence_id", "")) == evidence_id:
			return record
	return {}

func body_evidence_records_for_state(observer: Dictionary) -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for record in body_evidence_records:
		if not EvidenceRecords.is_active_body(record):
			continue
		var record_state: = {
			"area": String(record.get("area", "")), 
			"room_id": String(record.get("room_id", "")), 
			"home_instance_id": String(record.get("home_instance_id", "")), 
		}
		if String(observer.get("area", "")) == String(record_state.get("area", "")) and String(observer.get("room_id", "")) == String(record_state.get("room_id", "")):
			if states_share_room_instance(observer, record_state):
				visible.append(record.duplicate(true))
	return visible

func body_evidence_record(evidence_id: String) -> Dictionary:
	for record in body_evidence_records:
		if String(record.get("evidence_id", "")) == evidence_id:
			return record
	return {}

func add_body_evidence_record(target: Dictionary, outcome_id: String, source_event_id: int) -> Dictionary:
	if target.is_empty():
		return {}
	for existing in body_evidence_records:
		if not outcome_id.is_empty() and String(existing.get("outcome_id", "")) == outcome_id:
			return existing.duplicate(true)
	body_evidence_sequence += 1
	var world_prefix: = server_world_id if not server_world_id.is_empty() else "SESSION"
	var evidence_id: = "%s-BODY-%d" % [world_prefix, body_evidence_sequence]
	var point: = state_position(target)
	var record: = EvidenceRecords.body_record(
		evidence_id, 
		source_event_id, 
		outcome_id, 
		String(target.get("area", "")), 
		String(target.get("room_id", "")), 
		point, 
		int(target.get("peer_id", 0)), 
		String(target.get("resident_key", "")), 
		String(target.get("name", "Resident")), 
		int(Time.get_unix_time_from_system() * 1000.0), 
		String(target.get("home_instance_id", ""))
	)
	body_evidence_records.append(record)
	return record.duplicate(true)

func add_blood_evidence_record(payload: Dictionary) -> Dictionary:
	if not bool(payload.get("hit", false)):
		return {}
	evidence_event_sequence += 1
	var evidence_id: = "%s-BLOOD-%d" % [server_world_id if not server_world_id.is_empty() else "SESSION", evidence_event_sequence]
	var point_value: Variant = payload.get("impact_position", Vector2.ZERO)
	var point: = point_value as Vector2 if point_value is Vector2 else Vector2.ZERO
	var record: = EvidenceRecords.blood_record(
		evidence_id, 
		int(payload.get("event_id", evidence_event_sequence)), 
		String(payload.get("area", "")), 
		String(payload.get("room_id", "")), 
		point, 
		int(payload.get("blood_amount", 1)), 
		int(payload.get("blood_seed", 1)), 
		int(payload.get("attacker_id", 0)), 
		int(payload.get("target_id", 0)), 
		int(Time.get_unix_time_from_system() * 1000.0), 
		String(payload.get("home_instance_id", ""))
	)
	blood_evidence_records.append(record)
	return record.duplicate(true)

func send_blood_evidence_snapshot(peer_id: int, observer: Dictionary) -> void :
	var visible: = blood_evidence_records_for_state(observer)
	if peer_id == 1:
		blood_evidence_snapshot_received.emit(visible)
	else:
		receive_blood_evidence_snapshot.rpc_id(peer_id, visible)

@rpc("authority", "call_remote", "reliable")
func receive_blood_evidence_snapshot(records: Array) -> void :
	blood_evidence_snapshot_received.emit(records.duplicate(true))

func send_body_evidence_snapshot(peer_id: int, observer: Dictionary) -> void :
	var visible: = body_evidence_records_for_state(observer)
	if peer_id == 1:
		body_evidence_snapshot_received.emit(visible)
	else:
		receive_body_evidence_snapshot.rpc_id(peer_id, visible)

@rpc("authority", "call_remote", "reliable")
func receive_body_evidence_snapshot(records: Array) -> void :
	body_evidence_snapshot_received.emit(records.duplicate(true))

func broadcast_body_evidence_snapshots() -> void :
	if not hosting:
		return
	for peer_variant in peer_states.keys():
		var peer_id: = int(peer_variant)
		send_body_evidence_snapshot(peer_id, peer_states[peer_id])

func update_active_handoff_clocks(delta: float) -> void :
	if delta <= 0.0:
		return
	var changed_residents: Array[Dictionary] = []
	var now_ms: = int(Time.get_unix_time_from_system() * 1000.0)
	for account_variant in persistent_profiles.keys():
		var account_id: = String(account_variant)
		var roster: = account_roster(account_id)
		var slots: Array = roster.get("slots", [])
		var roster_changed: = false
		for slot_index in range(slots.size()):
			var resident_value: Variant = slots[slot_index]
			if resident_value is not Dictionary:
				continue
			var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
			if not resident_handoff_clock_runs(account_id, slot_index, resident):
				continue
			var handoffs: Array = resident.get("active_handoffs", [])
			var handoffs_changed: = false
			for index in range(handoffs.size() - 1, -1, -1):
				var handoff: Dictionary = Dictionary(handoffs[index]).duplicate(true)
				if String(handoff.get("state", "")) != "carried":
					continue
				handoff["active_seconds_remaining"] = maxf(0.0, float(handoff.get("active_seconds_remaining", CASHIER_DEPOSIT_ACTIVE_SECONDS)) - delta)
				if float(handoff["active_seconds_remaining"]) <= 0.0:
					if is_moth_handoff(handoff):
						fail_moth_handoff(resident, handoff, now_ms)
						handoffs = resident.get("active_handoffs", [])
						handoffs_changed = true
						roster_changed = true
						changed_residents.append({"account_id": account_id, "resident_slot": slot_index})
						continue
					handoff["expired"] = true
				handoffs[index] = handoff
				handoffs_changed = true
			if handoffs_changed:
				resident["active_handoffs"] = handoffs
				slots[slot_index] = resident
				roster_changed = true
		if roster_changed:
			roster["slots"] = slots
			persistent_profiles[account_id] = ReleaseSave.normalize_roster(roster)
			profiles_dirty = true
	for changed in changed_residents:
		sync_connected_economy_state(String(changed.get("account_id", "")), int(changed.get("resident_slot", -1)))
	if not changed_residents.is_empty() and hosting:
		_schedule_snapshot(true)

func is_moth_handoff(handoff: Dictionary) -> bool:
	return String(handoff.get("id", "")) in ["sealed_dime_bag", "sealed_quarter_bag", "sealed_customer_envelope"]

func fail_moth_handoff(resident: Dictionary, handoff: Dictionary, now_ms: int) -> void :
	var nonce: = String(handoff.get("authority_nonce", ""))
	var active_handoffs: Array = resident.get("active_handoffs", [])
	for index in range(active_handoffs.size() - 1, -1, -1):
		if active_handoffs[index] is Dictionary and String((active_handoffs[index] as Dictionary).get("authority_nonce", "")) == nonce:
			active_handoffs.remove_at(index)
			break
	handoff["state"] = "failed"
	handoff["outcome"] = "FAILED_TIMEOUT"
	handoff["expired"] = true
	handoff["failed_at_ms"] = now_ms
	var custody_events: Array = handoff.get("custody_events", [])
	custody_events.append({"type": "moth_delivery_timeout", "server_unix_ms": now_ms})
	handoff["custody_events"] = custody_events
	resident["active_handoffs"] = active_handoffs
	var completed: Dictionary = resident.get("completed_handoffs", {})
	completed[nonce] = handoff
	resident["completed_handoffs"] = completed
	var inventory: Array = resident.get("inventory", [])
	var inventory_index: = inventory_record_index(inventory, String(handoff.get("id", "")))
	if inventory_index >= 0:
		inventory.remove_at(inventory_index)
	resident["inventory"] = inventory
	resident["sealed_packages"] = 0
	var relationship: = moth_relationship_record(resident)
	relationship["hostile_until_unix_ms"] = max(int(relationship.get("hostile_until_unix_ms", 0)), now_ms + int(MothContent.HOSTILITY_SECONDS * 1000.0))
	set_moth_relationship_record(resident, relationship)
	sync_legacy_money_aliases(resident)
	economy_event_sequence += 1
	economy_audit_log.append({
		"event_sequence": economy_event_sequence, "type": "moth_delivery_failed", "nonce": nonce, 
		"account_id": String(handoff.get("owner_tester_id", "")), "resident_slot": int(handoff.get("owner_resident_slot", -1)), 
		"world_id": server_world_id, "reason": "TIMEOUT", "moth_hostile_until_unix_ms": relationship["hostile_until_unix_ms"], 
		"server_unix_ms": now_ms, 
	})

func resident_handoff_clock_runs(account_id: String, slot_index: int, resident: Dictionary) -> bool:
	if String(resident.get("area", "")) in ["jail", "hospital"]:
		return false
	for peer_variant in peer_states.keys():
		var peer_id: = int(peer_variant)
		if safe_tester_id(String(peer_accounts.get(peer_id, ""))) == account_id and int(peer_states[peer_id].get("resident_slot", -1)) == slot_index:
			return true
	return server_world_id == LOCAL_TEST_WORLD_ID and bool(resident.get("local_test_connected", false))

func host_server(initial_state: Dictionary, requested_port: int = DEFAULT_PORT, announce_private: bool = true, requested_max_players: int = -1) -> Error:
	close_session()
	_reset_network_metrics()
	enet_peer = ENetMultiplayerPeer.new()
	max_players = requested_max_players if requested_max_players > 0 else PRIVATE_MAX_PLAYERS
	var result: = enet_peer.create_server(requested_port, max_players)
	if result != OK:
		_set_status("COULD NOT START HOST  -  UDP %d IS UNAVAILABLE (%s)" % [requested_port, error_string(result)])
		return result
	multiplayer.multiplayer_peer = enet_peer
	port = requested_port
	active = true
	hosting = true
	session_token = _new_token()
	peer_states[1] = _sanitize_initial_state(initial_state, 1)
	authorized_peers[1] = true
	initialize_authoritative_laundry_office()
	discovery_name = String(initial_state.get("name", "Agervis host")) + "'s game"
	if announce_private:
		_start_host_broadcast()
		_set_status("PRIVATE GAME STARTED  -  1/%d  -  CHECKING ROUTER" % max_players)
	_broadcast_snapshot()
	return OK

func host_private_game(initial_state: Dictionary, requested_port: int = DEFAULT_PORT) -> Error:
	var result: = host_server(initial_state, requested_port)
	if result != OK:
		return result
	profiles_enabled = true
	profile_path = PRIVATE_PROFILE_PATH
	server_world_id = load_or_create_private_world_id()
	load_server_profiles()
	var host_account: = safe_tester_id(String(initial_state.get("tester_id", "")))
	if not host_account.is_empty():
		peer_accounts[1] = host_account
	probe_router_mapping()
	return OK
func host_main_server(requested_port: int = DEFAULT_PORT, requested_profile_path: String = MAIN_PROFILE_PATH) -> Error:
	var server_state: = {
		"name": "AGERVIS MAIN SERVER", 
		"area": "street", 
		"phase": "server", 
		"position": Vector2.ZERO, 
		"health": 100.0, 
		"protocol": PROTOCOL_VERSION, 
	}
	var result: = host_server(server_state, requested_port, false, MAIN_MAX_PLAYERS)
	if result != OK: return result
	public_hosting = true
	profiles_enabled = true
	profile_path = requested_profile_path if not requested_profile_path.is_empty() else MAIN_PROFILE_PATH
	server_world_id = MAIN_WORLD_ID
	session_token = ""
	load_server_profiles()
	load_admin_state()
	peer_states.clear()
	authorized_peers[1] = true
	if discovery_broadcaster != null:
		discovery_broadcaster.close()
	discovery_broadcaster = null
	_set_status("MAIN SERVER RUNNING - UDP %d - 0/%d" % [port, max_players])
	return OK

func join_server(address: String, initial_state: Dictionary, requested_port: int = DEFAULT_PORT, token: String = "") -> Error:
	close_session()
	reconnect_address = address.strip_edges()
	if reconnect_address.is_empty():
		reconnect_address = "127.0.0.1"
	reconnect_port = requested_port
	reconnect_token = token
	reconnect_state = initial_state.duplicate(true)
	reconnect_attempts = 0
	return _open_client(reconnect_address, reconnect_state, reconnect_port, reconnect_token)

func join_invitation(invitation: String, initial_state: Dictionary) -> Error:
	var parsed: = parse_invitation(invitation)
	if not bool(parsed.get("valid", false)):
		_set_status("INVITE NOT RECOGNIZED  -  ASK THE HOST TO COPY IT AGAIN")
		return ERR_INVALID_DATA
	return join_server(String(parsed["address"]), initial_state, int(parsed["port"]), String(parsed["token"]))

func _open_client(address: String, initial_state: Dictionary, requested_port: int, token: String) -> Error:
	enet_peer = ENetMultiplayerPeer.new()
	var result: = enet_peer.create_client(address, requested_port)
	if result != OK:
		_set_status("COULD NOT OPEN CONNECTION TO %s:%d (%s)" % [address, requested_port, error_string(result)])
		return result
	multiplayer.multiplayer_peer = enet_peer
	port = requested_port
	active = true
	hosting = false
	session_token = token
	peer_states.clear()
	var pending: = initial_state.duplicate(true)
	pending["invite_token"] = token
	pending["protocol"] = PROTOCOL_VERSION
	peer_states[0] = pending
	_set_status("CONTACTING HOST  -  %s:%d" % [address, port])
	return OK

func close_session() -> void :
	if profiles_enabled and profiles_dirty:
		save_main_server_profiles()
	if public_hosting:
		save_admin_state()
	if upnp != null and router_mapping_ready:
		upnp.delete_port_mapping(port, "UDP")
	public_hosting = false
	max_players = PRIVATE_MAX_PLAYERS
	reconnect_address = ""
	reconnect_port = DEFAULT_PORT
	reconnect_token = ""
	reconnect_state.clear()
	reconnect_attempts = 0
	reconnect_timer = 0.0
	attack_ready_at_ms.clear()
	laundry_office_npcs.clear()
	laundry_hostile_until_ms.clear()
	laundry_capone_direct_until_ms.clear()
	laundry_office_presence.clear()
	laundry_defeat_pending.clear()
	laundry_capone_disposition_started.clear()
	combat_event_sequence = 0
	evidence_event_sequence = 0
	blood_evidence_records.clear()
	body_evidence_sequence = 0
	body_evidence_records.clear()
	blood_empty_server_elapsed = 0.0
	blood_cleaning_actions.clear()
	school_training_actions.clear()
	school_practice_states.clear()
	school_study_sessions.clear()
	cleaning_trace_sequence = 0
	xp_event_sequence = 0
	handoff_event_sequence = 0
	pending_permanent_outcomes.clear()
	permanent_outcome_sequence = 0
	authoritative_downed_timers.clear()
	profiles_enabled = false
	profile_path = ""
	server_world_id = ""

	active = false
	hosting = false
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	if discovery_listener != null:
		discovery_listener.close()
	if discovery_broadcaster != null:
		discovery_broadcaster.close()
	discovery_listener = null
	discovery_broadcaster = null
	discovery_active = false
	nearby_hosts.clear()
	peer_states.clear()
	authorized_peers.clear()
	peer_accounts.clear()
	active = false
	hosting = false
	router_mapping_ready = false
	outside_confirmed = false
	external_address = ""
	session_token = ""
	status = "OFFLINE"
	snapshot_timer = 0.0
	snapshot_dirty = false
	snapshot_sequence = 0
	last_self_authority_fingerprints.clear()
	last_remote_identity_fingerprints.clear()
	pending_initial_snapshot_peers.clear()
	authoritative_self_state.clear()
	remote_identity_states.clear()
	pending_snapshot_sequence = -1
	pending_snapshot_chunk_count = 0
	pending_snapshot_chunks.clear()
	pending_roster_transfer = -1
	pending_roster_world = ""
	pending_roster_chunk_count = 0
	pending_roster_chunks.clear()

func local_peer_id() -> int:
	if not active or not is_inside_tree():
		return 0
	var multiplayer_api: = get_multiplayer()
	return multiplayer_api.get_unique_id() if multiplayer_api != null else 0

func connected_player_count() -> int:
	if not active:
		return 0
	if not hosting:
		return main_server_population if main_server_population > 0 else peer_states.size()
	var count: = 0
	for peer_value in authorized_peers.keys():
		var peer_id: = int(peer_value)
		if peer_id in peer_states and (peer_id == 1 or not String(peer_accounts.get(peer_id, "")).is_empty()):
			count += 1
	return count

func session_capacity() -> int:
	return max_players

func network_metrics() -> Dictionary:
	var metrics: = {
		"players": connected_player_count(), 
		"capacity": max_players, 
		"max_players_seen": max_connected_peer_count, 
		"snapshots": snapshot_broadcast_count, 
		"snapshot_recipients": snapshot_recipient_count, 
		"snapshot_chunks": snapshot_chunk_count, 
		"snapshot_bytes_estimate": snapshot_bytes_sent_estimate, 
		"snapshot_periodic_bytes_estimate": snapshot_periodic_bytes_sent_estimate, 
		"self_authority_sends": self_authority_send_count, 
		"remote_identity_sends": remote_identity_send_count, 
		"state_submissions": state_submission_count, 
		"disconnects": disconnect_count, 
		"persistence_writes": persistence_write_count, 
		"persistence_total_ms": persistence_total_ms, 
		"persistence_average_ms": 0.0 if persistence_write_count <= 0 else float(persistence_total_ms) / float(persistence_write_count), 
	}
	if enet_peer != null:
		var host: = enet_peer.get_host()
		if host != null:
			metrics["enet_sent_bytes"] = host.pop_statistic(ENetConnection.HOST_TOTAL_SENT_DATA)
			metrics["enet_sent_packets"] = host.pop_statistic(ENetConnection.HOST_TOTAL_SENT_PACKETS)
			metrics["enet_received_bytes"] = host.pop_statistic(ENetConnection.HOST_TOTAL_RECEIVED_DATA)
			metrics["enet_received_packets"] = host.pop_statistic(ENetConnection.HOST_TOTAL_RECEIVED_PACKETS)
	return metrics

func _reset_network_metrics() -> void :
	snapshot_broadcast_count = 0
	snapshot_recipient_count = 0
	snapshot_chunk_count = 0
	snapshot_bytes_sent_estimate = 0
	snapshot_periodic_bytes_sent_estimate = 0
	self_authority_send_count = 0
	remote_identity_send_count = 0
	state_submission_count = 0
	max_connected_peer_count = 0
	disconnect_count = 0
	persistence_write_count = 0
	persistence_total_ms = 0
	main_server_population = 0
	last_population_broadcast = -1
	last_capacity_broadcast = -1
	population_dirty = false
	population_timer = 0.0
	snapshot_sequence = 0
	last_self_authority_fingerprints.clear()
	last_remote_identity_fingerprints.clear()
	pending_initial_snapshot_peers.clear()
	authoritative_self_state.clear()
	remote_identity_states.clear()
	pending_snapshot_sequence = -1
	pending_snapshot_chunk_count = 0
	pending_snapshot_chunks.clear()
	roster_transfer_sequence = 0
	pending_roster_transfer = -1
	pending_roster_world = ""
	pending_roster_chunk_count = 0
	pending_roster_chunks.clear()

func local_addresses() -> Array[String]:
	var result: Array[String] = []
	for value in IP.get_local_addresses():
		var address: = String(value)
		if ":" in address or address.begins_with("127.") or address.begins_with("169.254."):
			continue
		if address not in result:
			result.append(address)
	if result.is_empty():
		result.append("127.0.0.1")
	return result

func _new_token() -> String:
	var crypto: = Crypto.new()
	var bytes: = crypto.generate_random_bytes(18)
	return bytes.hex_encode()

func invitation_text() -> String:
	if not hosting or session_token.is_empty():
		return ""
	var address: = external_address if router_mapping_ready and not external_address.is_empty() else local_addresses()[0]
	return "AGV10:%s:%d:%s" % [address, port, session_token]

func parse_invitation(invitation: String) -> Dictionary:
	var clean: = invitation.strip_edges()
	var parts: = clean.split(":", false)
	if parts.size() != 4 or parts[0] != "AGV10":
		return {"valid": false}
	if not String(parts[2]).is_valid_int():
		return {"valid": false}
	var token: = String(parts[3])
	if not _valid_token(token):
		return {"valid": false}
	return {
		"valid": true, 
		"address": String(parts[1]), 
		"port": clampi(int(parts[2]), 1, 65535), 
		"token": token, 
		"protocol": PROTOCOL_VERSION, 
	}

func _valid_token(token: String) -> bool:
	if token.length() < 16 or token.length() > 64:
		return false
	for character in token:
		if character not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_":
			return false
	return true

func test_local_connection(requested_port: int = DEFAULT_PORT) -> Dictionary:
	var probe: = ENetMultiplayerPeer.new()
	var test_port: = requested_port + 7
	var result: = probe.create_server(test_port, 2)
	if result != OK:
		return {
			"ok": false, 
			"summary": "THIS DEVICE COULD NOT OPEN A LOCAL UDP LISTENER", 
			"detail": "Test port %d returned %s." % [test_port, error_string(result)], 
		}
	probe.close()
	return {
		"ok": true, 
		"summary": "DEVICE NETWORK STACK READY", 
		"detail": "A local UDP listener opened successfully. This does not prove that the router accepts internet guests.", 
		"addresses": local_addresses(), 
	}

func probe_router_mapping() -> Dictionary:
	router_mapping_ready = false
	external_address = ""
	upnp = UPNP.new()
	var discovery_result: = upnp.discover(1800, 2, "InternetGatewayDevice")
	if discovery_result != UPNP.UPNP_RESULT_SUCCESS:
		_set_status("PRIVATE GAME RUNNING ON LOCAL WI-FI  -  ROUTER DID NOT OFFER AUTOMATIC INTERNET SETUP")
		return {
			"ok": false, 
			"summary": "LOCAL WI-FI READY; INTERNET INVITE NOT CONFIRMED", 
			"detail": "UPnP discovery failed. Use nearby play, manual port forwarding, or let another tester host.", 
		}
	var gateway: = upnp.get_gateway()
	if gateway == null or not gateway.is_valid_gateway():
		_set_status("PRIVATE GAME RUNNING  -  NO USABLE UPnP GATEWAY")
		return {"ok": false, "summary": "ROUTER FOUND BUT NOT USABLE", "detail": "Try nearby play or manual port forwarding."}
	var mapping_result: = upnp.add_port_mapping(port, port, "Agervis Build 10", "UDP", 0)
	if mapping_result != UPNP.UPNP_RESULT_SUCCESS:
		_set_status("PRIVATE GAME RUNNING  -  ROUTER REFUSED UDP MAPPING")
		return {"ok": false, "summary": "ROUTER REFUSED AUTOMATIC SETUP", "detail": "Nearby play still works. Internet guests need manual forwarding or a different host."}
	external_address = upnp.query_external_address()
	router_mapping_ready = not external_address.is_empty()
	if router_mapping_ready:
		_set_status("ROUTER READY  -  AWAITING OUTSIDE CONFIRMATION")
		return {
			"ok": true, 
			"summary": "ROUTER READY  -  AWAITING OUTSIDE CONFIRMATION", 
			"detail": "The router mapped UDP %d and reported %s. A friend must test the invite before internet play is confirmed." % [port, external_address], 
		}
	_set_status("PRIVATE GAME RUNNING  -  EXTERNAL ADDRESS UNAVAILABLE")
	return {"ok": false, "summary": "ROUTER MAPPED; EXTERNAL ADDRESS UNAVAILABLE", "detail": "This can happen behind carrier-grade NAT."}

func confirm_outside_probe() -> void :
	if hosting:
		outside_confirmed = true
		_set_status("INTERNET CONNECTION CONFIRMED  -  %d/%d" % [connected_player_count(), max_players])

func begin_nearby_discovery() -> Error:
	if discovery_listener != null:
		discovery_listener.close()
	discovery_listener = PacketPeerUDP.new()
	var result: = discovery_listener.bind(DISCOVERY_PORT, "*")
	if result != OK:
		_set_status("NEARBY SCAN COULD NOT LISTEN  -  CHECK LOCAL NETWORK PERMISSION")
		return result
	discovery_listener.set_broadcast_enabled(true)
	discovery_active = true
	nearby_hosts.clear()
	_set_status("LOOKING FOR NEARBY GAMES ON THIS WI-FI...")
	return OK

func stop_nearby_discovery() -> void :
	discovery_active = false
	if discovery_listener != null:
		discovery_listener.close()
	discovery_listener = null

func get_nearby_hosts() -> Array:
	var hosts: Array = nearby_hosts.values()
	hosts.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return String(a.get("name", "")) < String(b.get("name", "")))
	return hosts

func _start_host_broadcast() -> void :
	discovery_broadcaster = PacketPeerUDP.new()
	discovery_broadcaster.set_broadcast_enabled(true)
	discovery_broadcaster.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	discovery_timer = 0.0

func _broadcast_host_announcement() -> void :
	if discovery_broadcaster == null:
		return
	var announcement: = {
		"kind": "AGERVIS_HOST", 
		"protocol": PROTOCOL_VERSION, 
		"name": discovery_name, 
		"port": port, 
		"players": connected_player_count(), 
		"max": max_players, 
		"token": session_token, 
	}
	discovery_broadcaster.put_packet(JSON.stringify(announcement).to_utf8_buffer())

func _poll_discovery() -> void :
	if discovery_listener == null:
		return
	var changed: = false
	while discovery_listener.get_available_packet_count() > 0:
		var packet: = discovery_listener.get_packet().get_string_from_utf8()
		var parsed: Variant = JSON.parse_string(packet)
		if parsed is not Dictionary:
			continue
		var data: = parsed as Dictionary
		if String(data.get("kind", "")) != "AGERVIS_HOST" or int(data.get("protocol", -1)) != PROTOCOL_VERSION:
			continue
		var ip: = discovery_listener.get_packet_ip()
		var key: = "%s:%d" % [ip, int(data.get("port", DEFAULT_PORT))]
		data["address"] = ip
		data["last_seen"] = Time.get_ticks_msec()
		nearby_hosts[key] = data
		changed = true
	if changed:
		nearby_hosts_changed.emit(get_nearby_hosts())
		_set_status("FOUND %d NEARBY GAME%s" % [nearby_hosts.size(), "" if nearby_hosts.size() == 1 else "S"])

func _prune_nearby_hosts() -> void :
	var now: = Time.get_ticks_msec()
	var changed: = false
	for key in nearby_hosts.keys():
		if now - int(nearby_hosts[key].get("last_seen", 0)) > 3500:
			nearby_hosts.erase(key)
			changed = true
	if changed:
		nearby_hosts_changed.emit(get_nearby_hosts())

func connection_report() -> Dictionary:
	var interface_text: = ", ".join(local_addresses())
	return {
		"active": active, 
		"hosting": hosting, 
		"status": status, 
		"players": connected_player_count(), 
		"capacity": max_players, 
		"ping_ms": ping_ms, 
		"jitter_ms": jitter_ms, 
		"loss_percent": packet_loss_percent, 
		"last_response_ms": last_response_ms, 
		"protocol": PROTOCOL_VERSION, 
		"port": port, 
		"interfaces": interface_text, 
		"router_mapping": router_mapping_ready, 
		"outside_confirmed": outside_confirmed, 
		"external_address": external_address, 
	}

func submit_local_state(state: Dictionary) -> void :
	if not hosting:
		remember_reconnect_state(state)
	if not active:
		return
	if not hosting and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	var peer_id: = local_peer_id()
	if hosting:
		peer_states[peer_id] = _sanitize_initial_state(state, peer_id)
		peer_states[peer_id]["resident_key"] = resident_replication_key(
			String(peer_states[peer_id].get("tester_id", "")), 
			int(peer_states[peer_id].get("resident_slot", -1)), 
			server_world_id
		)
		clear_school_study_if_state_invalid(
			String(peer_accounts.get(peer_id, peer_states[peer_id].get("tester_id", ""))), 
			int(peer_states[peer_id].get("resident_slot", -1)), 
			peer_states[peer_id]
		)
		send_blood_evidence_snapshot(peer_id, peer_states[peer_id])
		send_body_evidence_snapshot(peer_id, peer_states[peer_id])
		state_submission_count += 1
		_schedule_snapshot()
	else:
		submit_motion_to_server.rpc_id(1, state)

func remember_reconnect_state(state: Dictionary) -> void :
	reconnect_state = state.duplicate(true)
	reconnect_state["protocol"] = PROTOCOL_VERSION

@rpc("any_peer", "call_remote", "reliable")
func submit_state_to_server(candidate: Dictionary) -> void :
	if not hosting:
		return
	process_submitted_state(multiplayer.get_remote_sender_id(), candidate)

@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func submit_motion_to_server(candidate: Dictionary) -> void :
	if not hosting:
		return
	process_submitted_state(multiplayer.get_remote_sender_id(), candidate)

func process_submitted_state(sender: int, candidate: Dictionary) -> void :
	if sender <= 1:
		return
	var first_packet: = sender not in authorized_peers
	if first_packet:
		if int(candidate.get("protocol", -1)) != PROTOCOL_VERSION:
			_reject_peer(sender, "BUILD PROTOCOL DOES NOT MATCH")
			return
		if not session_token.is_empty() and String(candidate.get("invite_token", "")) != session_token:
			_reject_peer(sender, "INVITE TOKEN WAS NOT ACCEPTED")
			return
		authorized_peers[sender] = true
		if public_hosting:
			print("[AGERVIS SERVER] AUTHORIZED PEER %d" % sender)


		var initial_snapshot_started_ms: = Time.get_ticks_msec()
		pending_initial_snapshot_peers[sender] = {
			"next_retry_ms": initial_snapshot_started_ms, 
			"deadline_ms": initial_snapshot_started_ms + INITIAL_SNAPSHOT_RETRY_WINDOW_MS, 
		}
	var tester_key: = safe_tester_id(String(candidate.get("tester_id", "")))
	if tester_key.is_empty():
		_reject_peer(sender, "ACCOUNT ID WAS NOT ACCEPTED")
		return
	peer_accounts[sender] = tester_key
	if bool(candidate.get("roster_request", false)):
		var previous_roster_state: Dictionary = peer_states.get(sender, {})
		var lobby: = _sanitize_initial_state(candidate, sender)
		lobby["name"] = "Choosing resident"
		lobby["area"] = "server_lobby"
		lobby["room_id"] = ""
		lobby["phase"] = "roster"
		lobby["resident_slot"] = -1
		peer_states[sender] = lobby
		clear_school_study_if_state_invalid(tester_key, int(previous_roster_state.get("resident_slot", -1)), lobby)
		evict_duplicate_account_sessions(tester_key, sender, -1)
		_deliver_server_roster(sender, tester_key)
		max_connected_peer_count = maxi(max_connected_peer_count, connected_player_count())
		_schedule_population()
		_schedule_snapshot()
		return
	var previous: Dictionary = peer_states.get(sender, {})
	var requested_slot: = clampi(int(candidate.get("resident_slot", -1)), -1, ReleaseSave.FREE_SLOTS - 1)
	var needs_economy_hydration: = requested_slot >= 0 and (requested_slot != int(previous.get("resident_slot", -1)) or not previous.has("inventory"))
	peer_states[sender] = _sanitize_client_motion(candidate, previous, sender, false)
	peer_states[sender]["tester_id"] = tester_key
	peer_states[sender]["resident_slot"] = requested_slot
	peer_states[sender]["resident_key"] = resident_replication_key(tester_key, requested_slot, server_world_id)
	evict_duplicate_account_sessions(tester_key, sender, requested_slot)
	if profiles_enabled:
		if needs_economy_hydration:
			hydrate_peer_economy_from_profile(peer_states[sender], sender)
			last_self_authority_fingerprints.erase(sender)
		canonicalize_home_state(peer_states[sender], tester_key, requested_slot)
		profiles_dirty = true
	clear_school_study_if_state_invalid(tester_key, int(previous.get("resident_slot", requested_slot)), peer_states[sender])
	clear_school_study_if_state_invalid(tester_key, requested_slot, peer_states[sender])
	state_submission_count += 1
	max_connected_peer_count = maxi(max_connected_peer_count, connected_player_count())
	if first_packet:
		_schedule_population()


		call_deferred("_schedule_snapshot", true)
	send_blood_evidence_snapshot(sender, peer_states[sender])
	send_body_evidence_snapshot(sender, peer_states[sender])
	_schedule_snapshot()

func safe_tester_id(value: String) -> String:
	var clean: = ""
	for character in value.strip_edges().to_upper():
		if character.is_valid_identifier() or character.is_valid_int():
			clean += character
	return clean.left(32)

func resident_replication_key(account_id: String, resident_slot: int, world_id: String) -> String:
	var clean_account: = safe_tester_id(account_id)
	if clean_account.is_empty() or resident_slot < 0 or world_id.is_empty():
		return ""
	return ("%s|%s|%d" % [world_id, clean_account, resident_slot]).sha256_text().left(24)

func connected_peer_for_resident(account_id: String, resident_slot: int, excluded_peer_id: int = 0) -> int:
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		if peer_id == excluded_peer_id:
			continue
		if safe_tester_id(String(peer_accounts.get(peer_id, ""))) == account_id and int(peer_states[peer_id].get("resident_slot", -1)) == resident_slot:
			return peer_id
	return 0

func release_assignments_for_resident(account_id: String, resident_slot: int) -> void :
	if resident_slot < 0:
		return
	if not cashier_assignment.is_empty() and String(cashier_assignment.get("account_id", "")) == account_id and int(cashier_assignment.get("resident_slot", -1)) == resident_slot:
		cashier_assignment.clear()
		profiles_dirty = true
	for employer_variant in service_assignments.keys().duplicate():
		var employer_id: = String(employer_variant)
		var service_assignment: Dictionary = Dictionary(service_assignments.get(employer_id, {}))
		if String(service_assignment.get("account_id", "")) == account_id and int(service_assignment.get("resident_slot", -1)) == resident_slot:
			service_assignments.erase(employer_id)
			profiles_dirty = true

func evict_duplicate_account_sessions(account_id: String, incoming_peer_id: int, incoming_slot: int) -> Array[int]:
	var evicted: Array[int] = []
	for peer_value in peer_accounts.keys().duplicate():
		var peer_id: = int(peer_value)
		if peer_id == incoming_peer_id or safe_tester_id(String(peer_accounts.get(peer_id, ""))) != account_id:
			continue
		var old_slot: = int(peer_states.get(peer_id, {}).get("resident_slot", -1))
		interrupt_active_blood_cleaning_for_peer(peer_id, "DUPLICATE_SESSION_REPLACED")
		interrupt_school_training_for_peer(peer_id, "DUPLICATE_SESSION_REPLACED")
		school_study_sessions.erase(school_training_key(account_id, old_slot))
		if profiles_enabled:
			store_connected_resident(peer_id)
		peer_states.erase(peer_id)
		authorized_peers.erase(peer_id)
		peer_accounts.erase(peer_id)
		last_self_authority_fingerprints.erase(peer_id)
		last_remote_identity_fingerprints.erase(peer_id)
		if old_slot != incoming_slot:
			release_assignments_for_resident(account_id, old_slot)
		evicted.append(peer_id)
		if enet_peer != null and peer_id > 0 and peer_connection_is_live(peer_id):
			enet_peer.disconnect_peer(peer_id)
	return evicted

func load_or_create_private_world_id() -> String:
	if FileAccess.file_exists(PRIVATE_WORLD_ID_PATH):
		var existing: = FileAccess.get_file_as_string(PRIVATE_WORLD_ID_PATH).strip_edges()
		if not existing.is_empty():
			return existing.left(48)
	var generated: = "PRIVATE-" + _new_token().left(12).to_upper()
	var file: = FileAccess.open(PRIVATE_WORLD_ID_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(generated)
	return generated

func normalize_account_roster(value: Variant) -> Dictionary:
	var normalized: Dictionary
	if value is Dictionary and value.has("slots"):
		normalized = ReleaseSave.normalize_roster(value)
	else:
		var migrated: = ReleaseSave.default_roster()
		if value is Dictionary and not String(value.get("name", "")).is_empty():
			if String(value.get("phase", "adult")).to_lower() == "tutorial":
				migrated["tutorial_drafts"][0] = ReleaseSave.legacy_tutorial_draft(value, 0)
				migrated["active_tutorial_slot"] = 0
			else:
				migrated["slots"][0] = value.duplicate(true)
				migrated["active_slot"] = 0
		normalized = ReleaseSave.normalize_roster(migrated)
	var drafts: Array = normalized.get("tutorial_drafts", ReleaseSave.empty_tutorial_drafts())
	for slot_index in range(mini(ReleaseSave.FREE_SLOTS, drafts.size())):
		if normalized["slots"][slot_index] is Dictionary:
			drafts[slot_index] = null
			continue
		var draft_value: Variant = drafts[slot_index]
		if draft_value is Dictionary:
			var sanitized: = sanitize_tutorial_draft(draft_value as Dictionary, slot_index)
			if bool(sanitized.get("ok", false)):
				var canonical_draft: Dictionary = Dictionary(sanitized["draft"]).duplicate(true)
				if String(canonical_draft.get("draft_id", "")).is_empty():
					canonical_draft["draft_id"] = "TD-" + _new_token().left(20).to_upper()
				canonical_draft["revision"] = maxi(1, int(canonical_draft.get("revision", 0)))
				if String(canonical_draft.get("world_id", "")).is_empty():
					canonical_draft["world_id"] = server_world_id
				if int(canonical_draft.get("updated_unix_ms", 0)) <= 0:
					canonical_draft["updated_unix_ms"] = int(Time.get_unix_time_from_system() * 1000.0)
				drafts[slot_index] = canonical_draft
			else:
				drafts[slot_index] = null
	normalized["tutorial_drafts"] = drafts
	if int(normalized.get("active_tutorial_slot", -1)) >= 0 and drafts[int(normalized["active_tutorial_slot"])] is not Dictionary:
		normalized["active_tutorial_slot"] = -1
	return normalized

func read_server_profile_payload(path: String) -> Variant:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var file: = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return file.get_var(true)

func load_server_profiles() -> void :
	persistent_profiles.clear()
	economy_audit_log.clear()
	cashier_assignment.clear()
	service_assignments.clear()


	blood_evidence_records.clear()
	body_evidence_records.clear()
	body_evidence_sequence = 0
	blood_empty_server_elapsed = 0.0
	var migration_written: = false
	var recovered_previous: = false
	var value: Variant = read_server_profile_payload(profile_path)
	if value is not Dictionary and not profile_path.is_empty():
		var backup_path: = profile_path + ".previous"
		var backup_value: Variant = read_server_profile_payload(backup_path)
		if backup_value is Dictionary:
			var absolute_target: = ProjectSettings.globalize_path(profile_path)
			var absolute_backup: = ProjectSettings.globalize_path(backup_path)
			if FileAccess.file_exists(profile_path):
				DirAccess.remove_absolute(absolute_target)
			if DirAccess.rename_absolute(absolute_backup, absolute_target) == OK:
				value = backup_value
				recovered_previous = true
	if value is Dictionary:
		var source_profiles: Dictionary = value.get("profiles", value)
		if value.has("profiles"):
			var saved_audit: Variant = value.get("economy_audit_log", [])
			if saved_audit is Array:
				for audit_variant in saved_audit:
					if audit_variant is Dictionary:
						economy_audit_log.append((audit_variant as Dictionary).duplicate(true))
			var saved_assignment: Variant = value.get("cashier_assignment", {})
			if saved_assignment is Dictionary:
				cashier_assignment = (saved_assignment as Dictionary).duplicate(true)
			var saved_service_assignments: Variant = value.get("service_assignments", {})
			if saved_service_assignments is Dictionary:
				service_assignments = (saved_service_assignments as Dictionary).duplicate(true)
		for account_key in source_profiles.keys():
			var clean_account: = safe_tester_id(String(account_key))
			if clean_account.is_empty():
				continue
			var saved_roster: Variant = source_profiles[account_key]
			var normalized_roster: = normalize_account_roster(saved_roster)
			migration_written = migration_written or ReleaseSave.needs_economy_migration(saved_roster) or normalized_roster != saved_roster
			persistent_profiles[clean_account] = normalized_roster
	profiles_dirty = migration_written or recovered_previous
	profile_save_timer = 10.0
	if profiles_dirty:
		save_server_profiles()

func save_server_profiles() -> bool:
	if not profiles_enabled or profile_path.is_empty():
		return true
	var save_started_ms: = Time.get_ticks_msec()
	var temporary_path: = profile_path + ".next"
	var file: = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		_set_status("SERVER RESIDENT SAVE FAILED")
		return false
	file.store_var({
		"format": "agervis_server_profiles_1_1", 
		"profiles": persistent_profiles, 
		"economy_audit_log": economy_audit_log, 
		"cashier_assignment": cashier_assignment, 
		"service_assignments": service_assignments, 
	}, true)
	file.flush()
	file.close()
	var absolute_target: = ProjectSettings.globalize_path(profile_path)
	var absolute_temporary: = ProjectSettings.globalize_path(temporary_path)
	var absolute_backup: = ProjectSettings.globalize_path(profile_path + ".previous")
	if FileAccess.file_exists(profile_path + ".previous"):
		DirAccess.remove_absolute(absolute_backup)
	if FileAccess.file_exists(profile_path):
		if DirAccess.rename_absolute(absolute_target, absolute_backup) != OK:
			DirAccess.remove_absolute(absolute_temporary)
			_set_status("SERVER RESIDENT SAVE FAILED")
			return false
	if DirAccess.rename_absolute(absolute_temporary, absolute_target) != OK:
		if FileAccess.file_exists(profile_path + ".previous"):
			DirAccess.rename_absolute(absolute_backup, absolute_target)
		_set_status("SERVER RESIDENT SAVE FAILED")
		return false
	if FileAccess.file_exists(profile_path + ".previous"):
		DirAccess.remove_absolute(absolute_backup)
	profiles_dirty = false
	profile_save_timer = 10.0
	persistence_write_count += 1
	persistence_total_ms += Time.get_ticks_msec() - save_started_ms
	return true

func load_main_server_profiles() -> void :
	profile_path = MAIN_PROFILE_PATH
	load_server_profiles()

func admin_role_level(role: String) -> int:
	match role.to_lower():
		"owner": return 3
		"editor": return 2
		"moderator": return 1
	return 0

func startup_arguments() -> Array[String]:
	var result: Array[String] = []
	for raw_argument in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var argument: = String(raw_argument)
		if not result.has(argument):
			result.append(argument)
	return result

func normalize_storage_argument(value: String) -> String:
	var candidate: = value.strip_edges()
	if candidate.begins_with("user://"):
		return candidate
	if candidate.is_absolute_path() or (candidate.length() > 2 and candidate[1] == ":"):
		return candidate.replace("\\", "/")
	return ""

func admin_role_for_account(account_id: String) -> String:
	return String(admin_accounts.get(safe_tester_id(account_id), "")).to_lower()

func admin_profile_absolute_path() -> String:
	var absolute_path: = ProjectSettings.globalize_path(admin_profile_path)
	var parent_path: = absolute_path.get_base_dir()
	if not parent_path.is_empty() and not DirAccess.dir_exists_absolute(parent_path):
		DirAccess.make_dir_recursive_absolute(parent_path)
	return absolute_path

func admin_authorized_account(account_id: String, minimum_role: String = "moderator") -> bool:
	return admin_role_level(admin_role_for_account(account_id)) >= admin_role_level(minimum_role)

func admin_room_registry() -> Dictionary:
	return RoomObjects.editor_source(Build10.ROOM_LAYOUTS)

func admin_room_is_known(room_key: String) -> bool:
	return room_key in admin_room_registry()

func admin_room_source(room_key: String) -> Array[Dictionary]:
	var source_value: Variant = admin_room_registry().get(room_key, [])
	var result: Array[Dictionary] = []
	for value in Array(source_value):
		if value is Dictionary:
			result.append((value as Dictionary).duplicate(true))
	var patch_value: Variant = admin_room_patches.get(room_key, [])
	for patch_value_item in Array(patch_value):
		if patch_value_item is not Dictionary:
			continue
		var patch_record: = patch_value_item as Dictionary
		var local_id: = String(patch_record.get("local_id", ""))
		if bool(patch_record.get("deleted", false)):
			for delete_index in range(result.size() - 1, -1, -1):
				if String(result[delete_index].get("local_id", "")) == local_id:
					result.remove_at(delete_index)
					break
		var replaced: = false
		for index in range(result.size()):
			if String(result[index].get("local_id", "")) == local_id:
				result[index] = patch_record.duplicate(true)
				replaced = true
				break
		if not replaced and not local_id.is_empty():
			result.append(patch_record.duplicate(true))
	return result

func load_admin_state() -> void :
	admin_profile_path = ADMIN_PROFILE_PATH
	for argument in startup_arguments():
		var path_argument: = String(argument)
		if path_argument.begins_with("--admin-profile-path="):
			var requested_admin_path: = normalize_storage_argument(path_argument.trim_prefix("--admin-profile-path="))
			if not requested_admin_path.is_empty():
				admin_profile_path = requested_admin_path
	admin_accounts.clear()
	admin_room_patches.clear()
	admin_room_revisions.clear()
	admin_audit_log.clear()
	var absolute_profile_path: = admin_profile_absolute_path()
	if FileAccess.file_exists(absolute_profile_path):
		var file: = FileAccess.open(absolute_profile_path, FileAccess.READ)
		var payload: Variant = file.get_var(true) if file != null else null
		if payload is Dictionary:
			for account_value in Dictionary(payload).get("accounts", {}).keys():
				var clean_account: = safe_tester_id(String(account_value))
				var role: = String(Dictionary(payload).get("accounts", {})[account_value]).to_lower()
				if not clean_account.is_empty() and admin_role_level(role) > 0:
					admin_accounts[clean_account] = role
			var saved_patches: Variant = Dictionary(payload).get("rooms", {})
			if saved_patches is Dictionary:
				for room_value in saved_patches.keys():
					var room_key: = String(room_value)
					if not admin_room_is_known(room_key) or saved_patches[room_value] is not Array:
						continue
					admin_room_patches[room_key] = Array(saved_patches[room_value]).duplicate(true)
			var saved_revisions: Variant = Dictionary(payload).get("revisions", {})
			if saved_revisions is Dictionary:
				for room_value in saved_revisions.keys():
					if admin_room_is_known(String(room_value)):
						admin_room_revisions[String(room_value)] = maxi(0, int(saved_revisions[room_value]))
			var saved_audit: Variant = Dictionary(payload).get("audit_log", [])
			if saved_audit is Array:
				for audit_value in saved_audit:
					if audit_value is Dictionary:
						admin_audit_log.append((audit_value as Dictionary).duplicate(true))
	for argument in startup_arguments():
		var text: = String(argument)
		if not text.begins_with("--admin-account="):
			continue
		var spec: = text.trim_prefix("--admin-account=").split(":", false)
		var clean_account: = safe_tester_id(String(spec[0]) if not spec.is_empty() else "")
		var role: = String(spec[1]).to_lower() if spec.size() > 1 else "owner"
		if not clean_account.is_empty() and admin_role_level(role) > 0:
			admin_accounts[clean_account] = role
	if not admin_accounts.is_empty():
		save_admin_state()

func save_admin_state() -> bool:
	if not public_hosting and server_world_id != MAIN_WORLD_ID:
		return true
	var absolute_profile_path: = admin_profile_absolute_path()
	var next_profile_path: = absolute_profile_path + ".next"
	var file: = FileAccess.open(next_profile_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_var({"format": "agervis_admin_state_1", "accounts": admin_accounts, "rooms": admin_room_patches, "revisions": admin_room_revisions, "audit_log": admin_audit_log}, true)
	file.flush()
	file.close()
	var target: = absolute_profile_path
	var next: = next_profile_path
	if FileAccess.file_exists(target):
		DirAccess.remove_absolute(target)
	return DirAccess.rename_absolute(next, target) == OK

func admin_status_for_account(account_id: String) -> Dictionary:
	var clean_account: = safe_tester_id(account_id)
	var role: = admin_role_for_account(clean_account)
	if role.is_empty():
		return {"ok": false, "error_code": "ADMIN_ACCESS_DENIED", "message": "This account is not authorized for the admin panel."}
	var rooms: Array[String] = []
	for room_value in admin_room_registry().keys():
		rooms.append(String(room_value))
	rooms.sort()
	return {"ok": true, "role": role, "account_id": clean_account, "rooms": rooms, "revisions": admin_room_revisions.duplicate(true)}

func admin_room_result(room_key: String) -> Dictionary:
	if not admin_room_is_known(room_key):
		return {"ok": false, "error_code": "UNKNOWN_ADMIN_ROOM", "message": "That room is not in the authored registry.", "room_key": room_key}
	return {"ok": true, "room_key": room_key, "revision": int(admin_room_revisions.get(room_key, 0)), "records": admin_room_source(room_key)}

func request_admin_panel() -> void :
	if not active:
		return
	if hosting:
		admin_status_received.emit(admin_status_for_account(String(peer_accounts.get(local_peer_id(), ""))))
	else:
		request_admin_panel_on_host.rpc_id(1)

func admin_status_wire_result(account_id: String) -> Dictionary:
	var result: = admin_status_for_account(account_id)
	if bool(result.get("ok", false)):
		result.erase("rooms")
	return result

@rpc("any_peer", "call_remote", "reliable")
func request_admin_panel_on_host() -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	if sender <= 0 or sender not in authorized_peers:
		return
	receive_admin_status.rpc_id(sender, admin_status_wire_result(String(peer_accounts.get(sender, ""))))

@rpc("authority", "call_remote", "reliable")
func receive_admin_status(result: Dictionary) -> void :
	admin_status_received.emit(result.duplicate(true))

func request_admin_room(room_key: String) -> void :
	if not active:
		return
	if hosting:
		admin_room_received.emit(admin_room_result(room_key))
	else:
		request_admin_room_on_host.rpc_id(1, room_key)

@rpc("any_peer", "call_remote", "reliable")
func request_admin_room_on_host(room_key: String) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	if not admin_authorized_account(String(peer_accounts.get(sender, ""))):
		receive_admin_room.rpc_id(sender, {"ok": false, "error_code": "ADMIN_ACCESS_DENIED", "message": "Admin access is required to inspect rooms.", "room_key": room_key})
		return
	receive_admin_room.rpc_id(sender, admin_room_result(room_key))

@rpc("authority", "call_remote", "reliable")
func receive_admin_room(result: Dictionary) -> void :
	admin_room_received.emit(result.duplicate(true))

func submit_admin_room_patch(room_key: String, base_revision: int, placements: Array, operation_id: String = "") -> void :
	if not active:
		return
	if hosting:
		admin_patch_result_received.emit(_apply_admin_room_patch(String(peer_accounts.get(local_peer_id(), "")), room_key, base_revision, placements, operation_id))
	else:
		submit_admin_room_patch_on_host.rpc_id(1, room_key, base_revision, placements, operation_id)

@rpc("any_peer", "call_remote", "reliable")
func submit_admin_room_patch_on_host(room_key: String, base_revision: int, placements: Array, operation_id: String) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	var result: = _apply_admin_room_patch(String(peer_accounts.get(sender, "")), room_key, base_revision, placements, operation_id)
	receive_admin_patch_result.rpc_id(sender, result)

@rpc("authority", "call_remote", "reliable")
func receive_admin_patch_result(result: Dictionary) -> void :
	admin_patch_result_received.emit(result.duplicate(true))

func _apply_admin_room_patch(account_id: String, room_key: String, base_revision: int, placements: Array, operation_id: String) -> Dictionary:
	if not admin_authorized_account(account_id, "editor"):
		return {"ok": false, "error_code": "ADMIN_ACCESS_DENIED", "message": "Editor permission is required to apply a room patch.", "room_key": room_key}
	if not admin_room_is_known(room_key):
		return {"ok": false, "error_code": "UNKNOWN_ADMIN_ROOM", "message": "That room is not in the authored registry.", "room_key": room_key}
	var current_revision: = int(admin_room_revisions.get(room_key, 0))
	if base_revision != current_revision:
		return {"ok": false, "error_code": "STALE_ADMIN_REVISION", "message": "This room changed while you were editing. Refresh before applying.", "room_key": room_key, "revision": current_revision, "records": admin_room_source(room_key)}
	var candidate: = {room_key: admin_room_source(room_key)}
	var known_ids: Dictionary = {}
	for index in range(Array(candidate[room_key]).size()):
		known_ids[String(candidate[room_key][index].get("local_id", ""))] = index
	var changed_ids: Array[String] = []
	for value in placements:
		if value is not Dictionary:
			return {"ok": false, "error_code": "INVALID_ADMIN_PATCH", "message": "Every patch placement must be an object.", "room_key": room_key}
		var record: = value as Dictionary
		var local_id: = String(record.get("local_id", ""))
		if local_id.is_empty():
			return {"ok": false, "error_code": "INVALID_ADMIN_PATCH", "message": "Every patch placement needs a stable local_id.", "room_key": room_key}
		if bool(record.get("deleted", false)):
			if local_id not in known_ids:
				var authored_ids: = Array(admin_room_registry().get(room_key, [])).map( func(value: Variant): return String((value as Dictionary).get("local_id", "")) if value is Dictionary else "")
				if local_id not in authored_ids:
					return {"ok": false, "error_code": "UNKNOWN_ADMIN_PLACEMENT", "message": "The patch referenced an unknown placement.", "room_key": room_key}
			else:
				candidate[room_key].remove_at(int(known_ids[local_id]))
				known_ids.clear()
				for index in range(Array(candidate[room_key]).size()):
					known_ids[String(candidate[room_key][index].get("local_id", ""))] = index
			changed_ids.append(local_id)
			continue
		if local_id not in known_ids:
			var new_record: = record.duplicate(true)
			new_record.erase("deleted")
			candidate[room_key].append(new_record)
			known_ids[local_id] = Array(candidate[room_key]).size() - 1
			changed_ids.append(local_id)
			continue
		var merged: = Dictionary(candidate[room_key][int(known_ids[local_id])]).duplicate(true)
		for field_name in AdminRoomEditor.EDITABLE_FIELDS:
			if record.has(field_name):
				merged[field_name] = record[field_name]
		candidate[room_key][int(known_ids[local_id])] = merged
		changed_ids.append(local_id)
	var validator: = AdminRoomEditor.new(admin_room_registry(), true)
	var errors: = validator.validate_rooms(candidate)
	if not errors.is_empty():
		return {"ok": false, "error_code": "INVALID_ADMIN_PATCH", "message": String(errors[0]), "room_key": room_key}
	var changed_records: Array[Dictionary] = []
	var authored_records: Array = Array(admin_room_registry().get(room_key, []))
	var authored_by_id: Dictionary = {}
	for authored_value in authored_records:
		if authored_value is Dictionary:
			authored_by_id[String((authored_value as Dictionary).get("local_id", ""))] = authored_value
	var candidate_ids: Dictionary = {}
	for candidate_value in Array(candidate[room_key]):
		if candidate_value is not Dictionary:
			continue
		var candidate_record: Dictionary = (candidate_value as Dictionary).duplicate(true)
		var candidate_id: = String(candidate_record.get("local_id", ""))
		candidate_ids[candidate_id] = true
		if not authored_by_id.has(candidate_id) or candidate_record != authored_by_id[candidate_id]:
			changed_records.append(candidate_record)
	for authored_id in authored_by_id.keys():
		if not candidate_ids.has(authored_id):
			var tombstone: Dictionary = Dictionary(authored_by_id[authored_id]).duplicate(true)
			tombstone["deleted"] = true
			changed_records.append(tombstone)
	admin_room_patches[room_key] = changed_records
	admin_room_revisions[room_key] = current_revision + 1
	admin_operation_sequence += 1
	admin_audit_log.append({"sequence": admin_operation_sequence, "account_id": safe_tester_id(account_id), "room_key": room_key, "revision": current_revision + 1, "operation_id": operation_id, "changed_local_ids": changed_ids, "record_types": placements.map( func(value: Variant): return String((value as Dictionary).get("record_type", "object")) if value is Dictionary else "invalid"), "server_unix_ms": Time.get_unix_time_from_system() * 1000})
	while admin_audit_log.size() > 500: admin_audit_log.pop_front()
	if not save_admin_state():
		admin_room_patches.erase(room_key)
		admin_room_revisions[room_key] = current_revision
		return {"ok": false, "error_code": "ADMIN_PERSISTENCE_FAILED", "message": "The server could not durably save the room patch.", "room_key": room_key}
	var result: = {"ok": true, "room_key": room_key, "revision": current_revision + 1, "records": admin_room_source(room_key), "changed_local_ids": changed_ids}
	_broadcast_admin_room_update(result)
	return result

func _broadcast_admin_room_update(result: Dictionary) -> void :
	if not hosting:
		return
	for peer_value in authorized_peers.keys():
		var peer_id: = int(peer_value)
		if peer_id == 1:
			admin_room_received.emit(result.duplicate(true))
		elif peer_connection_is_live(peer_id):
			receive_admin_room.rpc_id(peer_id, result)

func save_main_server_profiles() -> bool:
	return save_server_profiles()

func account_roster(tester_key: String) -> Dictionary:
	var clean_key: = safe_tester_id(tester_key)
	if clean_key.is_empty():
		return ReleaseSave.default_roster()
	var stored_roster: Variant = persistent_profiles.get(clean_key, {})
	var normalized: = normalize_account_roster(stored_roster)
	var before_home_repair: = normalized.duplicate(true)
	var slots: Array = normalized.get("slots", [])
	for slot_index in range(slots.size()):
		if slots[slot_index] is not Dictionary:
			continue
		var resident: = SaveMigration.migrate_resident(slots[slot_index] as Dictionary)
		if not bool(resident.get("apartment_leased", false)):
			continue
		var home_world: = String(resident.get("world_id", ""))
		if home_world.is_empty():
			home_world = server_world_id
		resident["property"] = PlayerHomeContent.ensure_mercy_home(resident.get("property", []), home_world, clean_key, slot_index)
		var credentials: Array = resident.get("credentials", [])
		if "Mercy Court Tenant Credential" not in credentials:
			credentials.append("Mercy Court Tenant Credential")
		resident["credentials"] = credentials
		slots[slot_index] = resident
	normalized["slots"] = slots
	persistent_profiles[clean_key] = normalized
	if normalized != before_home_repair or normalized != stored_roster:
		profiles_dirty = true
	return normalized

func normalized_resident_name(value: String) -> String:
	return value.strip_edges().left(20)

func resident_name_key(value: String) -> String:
	return normalized_resident_name(value).to_lower()

func resident_name_available(candidate_name: String, excluded_account: String = "", excluded_slot: int = -1) -> bool:
	var candidate_key: = resident_name_key(candidate_name)
	if candidate_key.length() < 2:
		return false
	for account_variant in persistent_profiles.keys():
		var account_id: = String(account_variant)
		var roster: = normalize_account_roster(persistent_profiles[account_variant])
		var slots: Array = roster.get("slots", [])
		for slot_index in range(slots.size()):
			if account_id == excluded_account and slot_index == excluded_slot:
				continue
			var resident_value: Variant = slots[slot_index]
			if resident_value is Dictionary:
				var resident: Dictionary = resident_value as Dictionary


				if String(resident.get("phase", "adult")).to_lower() == "tutorial":
					continue
				if resident_name_key(String(resident.get("name", ""))) == candidate_key:
					return false
	return true

func resident_name_check_result(candidate_name: String, account_id: String, slot_index: int) -> Dictionary:
	var clean_name: = normalized_resident_name(candidate_name)
	if clean_name.length() < 2:
		return {"ok": false, "error_code": "NAME_TOO_SHORT", "message": "Resident names require at least two characters.", "name": clean_name}
	if not resident_name_available(clean_name, account_id, slot_index):
		return {"ok": false, "error_code": "NAME_ALREADY_TAKEN", "message": "That Resident name is already in use on this server.", "name": clean_name}
	return {"ok": true, "name": clean_name}

func _deliver_server_roster(peer_id: int, tester_key: String) -> void :
	var server_roster: = server_roster_for_delivery(tester_key)
	if peer_id == 1:
		server_roster_received.emit(server_roster, server_world_id)
	else:
		var payload: = var_to_bytes(server_roster)
		if public_hosting and payload.size() > SNAPSHOT_CHUNK_TARGET_BYTES:
			roster_transfer_sequence += 1
			var chunks: = packed_byte_chunks(payload, ROSTER_CHUNK_TARGET_BYTES)
			print("[AGERVIS SERVER] ROSTER RESPONSE TO PEER %d - %d BYTES IN %d CHUNKS" % [peer_id, payload.size(), chunks.size()])
			for chunk_index in range(chunks.size()):
				receive_server_roster_chunk.rpc_id(peer_id, roster_transfer_sequence, chunk_index, chunks.size(), chunks[chunk_index], server_world_id)
		else:
			if public_hosting:
				print("[AGERVIS SERVER] ROSTER RESPONSE TO PEER %d - %d BYTES" % [peer_id, payload.size()])
			receive_server_roster.rpc_id(peer_id, server_roster, server_world_id)

func server_roster_for_delivery(tester_key: String) -> Dictionary:




	var clean_key: = safe_tester_id(tester_key)
	if not persistent_profiles.has(clean_key):
		return ReleaseSave.default_roster()
	return account_roster(clean_key).duplicate(true)

func packed_byte_chunks(payload: PackedByteArray, target_bytes: int) -> Array[PackedByteArray]:
	var chunks: Array[PackedByteArray] = []
	var safe_target: = maxi(1, target_bytes)
	for offset in range(0, payload.size(), safe_target):
		chunks.append(payload.slice(offset, mini(offset + safe_target, payload.size())))
	return chunks

func request_server_roster() -> void :
	if not active:
		return
	var peer_id: = local_peer_id()
	if hosting:
		var tester_key: = safe_tester_id(String(peer_accounts.get(peer_id, peer_states.get(peer_id, {}).get("tester_id", ""))))
		if not tester_key.is_empty():
			peer_accounts[peer_id] = tester_key
			_deliver_server_roster(peer_id, tester_key)
	else:
		request_server_roster_from_host.rpc_id(1)

func request_graceful_disconnect() -> void :
	if not active or hosting or multiplayer.multiplayer_peer == null:
		graceful_disconnect_ready.emit()
		return
	prepare_graceful_disconnect.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func prepare_graceful_disconnect() -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	authorized_peers.erase(sender)
	last_self_authority_fingerprints.erase(sender)
	last_remote_identity_fingerprints.erase(sender)
	graceful_disconnect_ack.rpc_id(sender)

@rpc("authority", "call_remote", "reliable")
func graceful_disconnect_ack() -> void :
	graceful_disconnect_ready.emit()

@rpc("any_peer", "call_remote", "reliable")
func request_server_roster_from_host() -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	var tester_key: = safe_tester_id(String(peer_accounts.get(sender, peer_states.get(sender, {}).get("tester_id", ""))))
	if not tester_key.is_empty():
		peer_accounts[sender] = tester_key
		_deliver_server_roster(sender, tester_key)

func request_resident_name_check(candidate_name: String, slot_index: int) -> void :
	if not active:
		resident_name_check_received.emit({"ok": false, "error_code": "SERVER_UNAVAILABLE", "message": "The server is unavailable."})
		return
	if hosting:
		var peer_id: = local_peer_id()
		var account_id: = safe_tester_id(String(peer_accounts.get(peer_id, peer_states.get(peer_id, {}).get("tester_id", ""))))
		resident_name_check_received.emit(resident_name_check_result(candidate_name, account_id, slot_index))
	else:
		request_resident_name_check_on_host.rpc_id(1, candidate_name, slot_index)

@rpc("any_peer", "call_remote", "reliable")
func request_resident_name_check_on_host(candidate_name: String, slot_index: int) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	var account_id: = safe_tester_id(String(peer_accounts.get(sender, peer_states.get(sender, {}).get("tester_id", ""))))
	receive_resident_name_check.rpc_id(sender, resident_name_check_result(candidate_name, account_id, slot_index))

@rpc("authority", "call_remote", "reliable")
func receive_resident_name_check(result: Dictionary) -> void :
	resident_name_check_received.emit(result.duplicate(true))

@rpc("authority", "call_remote", "reliable")
func receive_server_roster(server_roster: Dictionary, world_id: String) -> void :
	server_roster_received.emit(ReleaseSave.normalize_roster(server_roster), world_id.left(48))

@rpc("authority", "call_remote", "reliable")
func receive_server_roster_chunk(transfer_id: int, chunk_index: int, chunk_count: int, chunk: PackedByteArray, world_id: String) -> void :
	if transfer_id < pending_roster_transfer or chunk_count <= 0 or chunk_count > 256:
		return
	if chunk_index < 0 or chunk_index >= chunk_count or chunk.size() > ROSTER_CHUNK_TARGET_BYTES:
		return
	var clean_world: = world_id.left(48)
	if transfer_id > pending_roster_transfer:
		pending_roster_transfer = transfer_id
		pending_roster_world = clean_world
		pending_roster_chunk_count = chunk_count
		pending_roster_chunks.clear()
	if chunk_count != pending_roster_chunk_count or clean_world != pending_roster_world:
		return
	pending_roster_chunks[chunk_index] = chunk.duplicate()
	if pending_roster_chunks.size() != pending_roster_chunk_count:
		return
	var payload: = PackedByteArray()
	for ordered_index in range(pending_roster_chunk_count):
		var ordered_chunk: Variant = pending_roster_chunks.get(ordered_index, null)
		if ordered_chunk is not PackedByteArray:
			return
		payload.append_array(ordered_chunk as PackedByteArray)
	var decoded: Variant = bytes_to_var(payload)
	pending_roster_world = ""
	pending_roster_chunk_count = 0
	pending_roster_chunks.clear()
	if decoded is Dictionary:
		if clean_world == AUTHORITATIVE_SELF_TRANSFER_WORLD:
			receive_authoritative_self(0, decoded as Dictionary)
		elif clean_world == INITIAL_SNAPSHOT_TRANSFER_WORLD:
			receive_snapshot(decoded as Dictionary)
		else:
			receive_server_roster(decoded as Dictionary, clean_world)

func tutorial_draft_error(code: String, message: String, slot_index: int = -1) -> Dictionary:
	return {"ok": false, "kind": "tutorial_draft", "error_code": code, "message": message, "slot_index": slot_index}

func tutorial_finalize_error(code: String, message: String, slot_index: int = -1) -> Dictionary:
	return {"ok": false, "kind": "tutorial_finalized", "error_code": code, "message": message, "slot_index": slot_index}

func tutorial_rpc_sender_authorized(sender: int) -> bool:

	return sender > 0 and sender in authorized_peers and peer_connection_is_live(sender) and not String(peer_accounts.get(sender, "")).is_empty()

func tutorial_draft_matches_authority(candidate: Dictionary, existing: Dictionary) -> bool:
	var candidate_id: = String(candidate.get("draft_id", "")).strip_edges()
	var existing_id: = String(existing.get("draft_id", "")).strip_edges()
	var candidate_revision: = int(candidate.get("revision", -1))
	var existing_revision: = int(existing.get("revision", 0))
	return not candidate_id.is_empty() and not existing_id.is_empty() and candidate_id == existing_id and candidate_revision == existing_revision

func normalized_authored_color(value: Variant) -> String:
	if value is Color:
		return (value as Color).to_html(false).to_lower()
	return String(value).strip_edges().trim_prefix("#").to_lower()

func sanitize_tutorial_draft(candidate: Dictionary, slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return tutorial_draft_error("INVALID_RESIDENT_SLOT", "The server could not identify that tutorial slot.", slot_index)
	var clean_area: = String(candidate.get("area", "tutorial")).strip_edges().to_lower()
	if clean_area == "school":
		clean_area = "tutorial"
	if clean_area != "tutorial":
		return tutorial_draft_error("INVALID_TUTORIAL_ROOM", "The tutorial draft named an unauthored area.", slot_index)
	var clean_room: = String(candidate.get("room_id", "guidance")).strip_edges().to_lower()
	if clean_room == "class_agility":
		clean_room = "gym_a"
	if clean_room not in Build10.room_ids("tutorial"):
		return tutorial_draft_error("INVALID_TUTORIAL_ROOM", "The tutorial draft named an unauthored room.", slot_index)
	var position: = Vector2(112.0, 250.0)
	var source_position: Variant = candidate.get("position", [position.x, position.y])
	if source_position is Vector2:
		position = source_position as Vector2
	elif source_position is Array and source_position.size() >= 2 and (source_position[0] is int or source_position[0] is float) and (source_position[1] is int or source_position[1] is float):
		position = Vector2(float(source_position[0]), float(source_position[1]))
	else:
		return tutorial_draft_error("INVALID_TUTORIAL_POSITION", "The tutorial draft contained an invalid position.", slot_index)
	if is_nan(position.x) or is_inf(position.x) or is_nan(position.y) or is_inf(position.y):
		return tutorial_draft_error("INVALID_TUTORIAL_POSITION", "The tutorial draft contained an invalid position.", slot_index)
	position.x = clampf(position.x, 35.0, 965.0)
	position.y = clampf(position.y, 85.0, 300.0)

	var source_flags: Variant = candidate.get("tutorial_flags", {})
	if source_flags is not Dictionary:
		return tutorial_draft_error("INVALID_TUTORIAL_FLAGS", "The tutorial draft contained invalid orientation flags.", slot_index)
	var flags: = {"counselor": false, "guidance_exit": false, "officer": false, "detainee": false}
	for flag_name in flags.keys():
		if source_flags.has(flag_name) and source_flags[flag_name] is not bool:
			return tutorial_draft_error("INVALID_TUTORIAL_FLAGS", "The tutorial draft contained a non-boolean orientation flag.", slot_index)
		flags[flag_name] = bool(source_flags.get(flag_name, false))
	var headstart: = String(candidate.get("tutorial_headstart", "")).strip_edges().to_lower()
	if headstart not in ["", "civilian", "law", "criminal"]:
		return tutorial_draft_error("INVALID_TUTORIAL_HEADSTART", "The tutorial draft contained an invalid P.A.T.H. headstart.", slot_index)
	if not headstart.is_empty() and not (bool(flags["counselor"]) and bool(flags["officer"]) and bool(flags["detainee"])):
		return tutorial_draft_error("INVALID_TUTORIAL_HEADSTART", "A P.A.T.H. headstart requires all three orientation statements.", slot_index)
	var source_scores: Variant = candidate.get("tutorial_path_scores", {})
	if source_scores is not Dictionary:
		return tutorial_draft_error("INVALID_TUTORIAL_SCORES", "The tutorial draft contained invalid P.A.T.H. scores.", slot_index)
	for path_name in ["civilian", "law", "criminal"]:
		if source_scores.has(path_name) and source_scores[path_name] is not int and source_scores[path_name] is not float:
			return tutorial_draft_error("INVALID_TUTORIAL_SCORES", "The tutorial draft contained a non-numeric P.A.T.H. score.", slot_index)
	var scores: = {
		"civilian": 1 if bool(flags["counselor"]) else 0, 
		"law": 1 if bool(flags["officer"]) else 0, 
		"criminal": 1 if bool(flags["detainee"]) else 0, 
	}
	if not headstart.is_empty():
		scores[headstart] = clampi(int(scores[headstart]) + 2, 0, 3)

	var authored_fields: = {
		"color": [TUTORIAL_COLOR_VALUES, "111315", true],
		"skin": [TUTORIAL_SKIN_VALUES, "b97855", true],
		"pants_color": [TUTORIAL_PANTS_VALUES, "101214", true],
		"hair_style": [TUTORIAL_HAIR_STYLES, "bald", false],
		"body_style": [TUTORIAL_BODY_STYLES, "standard", false],
		"hair_color": [TUTORIAL_HAIR_COLOR_VALUES, "17191b", true],
		"facial_hair_color": [TUTORIAL_HAIR_COLOR_VALUES, "17191b", true],
		"face_style": [TUTORIAL_FACE_STYLES, "neutral", false],
		"eye_style": [TUTORIAL_EYE_STYLES, "neutral", false],
		"outfit_style": [TUTORIAL_OUTFIT_STYLES, "none", false],
		"surreal_trait": [TUTORIAL_SURREAL_TRAITS, "none", false],
		"accessory": [TUTORIAL_ACCESSORIES, "none", false],
	}
	var appearance: = {}
	for field_name in authored_fields.keys():
		var specification: Array = authored_fields[field_name]
		var clean_value: = normalized_authored_color(candidate.get(field_name, specification[1])) if bool(specification[2]) else String(candidate.get(field_name, specification[1])).strip_edges().to_lower()
		if clean_value not in specification[0]:
			return tutorial_draft_error("INVALID_TUTORIAL_APPEARANCE", "The tutorial draft contained an unauthored child appearance value.", slot_index)
		appearance[field_name] = clean_value
	if String(candidate.get("facial_hair_style", "none")).strip_edges().to_lower() != "none" or String(candidate.get("stature", "child")).strip_edges().to_lower() != "child":
		return tutorial_draft_error("INVALID_TUTORIAL_APPEARANCE", "The tutorial draft contained an invalid child-only appearance value.", slot_index)
	appearance["facial_hair_style"] = "none"
	appearance["stature"] = "child"
	var draft: = {
		"draft_version": ReleaseSave.TUTORIAL_DRAFT_VERSION, 
		"draft_id": String(candidate.get("draft_id", "")).strip_edges().left(48), 
		"revision": maxi(0, int(candidate.get("revision", 0))), 
		"world_id": String(candidate.get("world_id", "")).strip_edges().left(48), 
		"updated_unix_ms": maxi(0, int(candidate.get("updated_unix_ms", 0))), 
		"slot_index": slot_index, 
		"name": "Citizen", 
		"phase": "tutorial", 
		"area": "tutorial", 
		"room_id": clean_room, 
		"position": [position.x, position.y], 
		"tutorial_flags": flags, 
		"tutorial_path_scores": scores, 
		"tutorial_headstart": headstart, 
	}
	for field_name in appearance.keys():
		draft[field_name] = appearance[field_name]
	return {"ok": true, "draft": draft}

func sanitize_adult_creation_appearance(candidate: Dictionary, slot_index: int) -> Dictionary:
	var authored_fields: = {
		"color": [TUTORIAL_COLOR_VALUES, "111315", true],
		"skin": [TUTORIAL_SKIN_VALUES, "b97855", true],
		"pants_color": [TUTORIAL_PANTS_VALUES, "101214", true],
		"hair_style": [TUTORIAL_HAIR_STYLES, "bald", false],
		"body_style": [TUTORIAL_BODY_STYLES, "standard", false],
		"hair_color": [TUTORIAL_HAIR_COLOR_VALUES, "17191b", true],
		"facial_hair_style": [ADULT_FACIAL_HAIR_STYLES, "none", false],
		"facial_hair_color": [TUTORIAL_HAIR_COLOR_VALUES, "17191b", true],
		"face_style": [TUTORIAL_FACE_STYLES, "neutral", false],
		"eye_style": [TUTORIAL_EYE_STYLES, "neutral", false],
		"stature": [ADULT_STATURES, "average", false],
		"outfit_style": [TUTORIAL_OUTFIT_STYLES, "none", false],
		"surreal_trait": [TUTORIAL_SURREAL_TRAITS, "none", false],
		"accessory": [TUTORIAL_ACCESSORIES, "none", false],
	}
	var appearance: = {}
	for field_name in authored_fields.keys():
		var specification: Array = authored_fields[field_name]
		var clean_value: = normalized_authored_color(candidate.get(field_name, specification[1])) if bool(specification[2]) else String(candidate.get(field_name, specification[1])).strip_edges().to_lower()
		if clean_value not in specification[0]:
			return tutorial_draft_error("INVALID_APPEARANCE", "The server rejected an unauthored adult appearance value.", slot_index)
		appearance[field_name] = clean_value
	return {"ok": true, "appearance": appearance}

func server_adult_from_tutorial(name: String, appearance: Dictionary, draft: Dictionary) -> Dictionary:
	var xp: = {}
	for skill_variant in Rules.SKILLS:
		xp[String(skill_variant)] = 0
	var headstart: = String(draft.get("tutorial_headstart", ""))
	for skill_variant in Dictionary(TUTORIAL_HEADSTART_XP.get(headstart, {})).keys():
		xp[String(skill_variant)] = int(Dictionary(TUTORIAL_HEADSTART_XP[headstart])[skill_variant])
	var inventory: = ["Group Home Key", "Phone", String(TUTORIAL_HEADSTART_ITEMS.get(headstart, "Completed Intake Packet"))]
	var equipment: = {"head": "", "face": "", "torso": "", "outerwear": "", "hands": "", "legs": "", "feet": "", "back": "", "contingency_1": "Emergency Beacon", "contingency_2": ""}
	var total: = 0
	for skill_variant in Rules.SKILLS:
		total += Rules.level_from_xp(int(xp.get(String(skill_variant), 0)))
	var resident: = {
		"name": name, "phase": "adult", "area": "home", "room_id": "lobby", "position": [850.0, 260.0], 
		"world_id": server_world_id, "health": 100.0, "stamina": 100.0, 
		"cash": 18, "dirty_cash": 0, "bank_balance": 0, 
		"skills": xp.duplicate(true), "xp": xp.duplicate(true), "credentials": [], "inventory": inventory, 
		"equipment": equipment, "contingencies": ["Emergency Beacon"], "injuries": [], 
		"active_job": "None", "job_contract": {}, "on_duty": false, "duty_pay": 0, 
		"wanted": false, "warrant": false, "arrested": false, "detained": false, "deceased": false, 
		"crimes": [], "property": [], "home_stash": [], "apartment_stash": [], "apartment_leased": false, 
		"active_handoffs": [], "completed_handoffs": {}, "processed_transactions": {}, "evidence_history": [], 
		"employment": [], "work_experience": {}, "insurance": [], "active_substance_effects": {}, 
		"phone_messages": [], "capone_shift_sequence": 0, 
		"tutorial_flags": Dictionary(draft.get("tutorial_flags", {})).duplicate(true), 
		"tutorial_path_scores": Dictionary(draft.get("tutorial_path_scores", {})).duplicate(true), 
		"tutorial_headstart": headstart, "objective": "Use the group home, then choose education, work, or crime.", 
		"total_level": total, "saved_unix": int(Time.get_unix_time_from_system()), 
	}
	for field_name in appearance.keys():
		resident[field_name] = appearance[field_name]
	return SaveMigration.migrate_resident(resident)

func persist_account_roster_atomically(account_id: String, updated_roster: Dictionary, simulate_disk_failure: bool = false) -> bool:
	var had_profile: = persistent_profiles.has(account_id)
	var profile_before: Variant = persistent_profiles.get(account_id, null)
	var dirty_before: = profiles_dirty
	var timer_before: = profile_save_timer
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(updated_roster)
	profiles_dirty = true
	if simulate_disk_failure or not save_server_profiles():
		if had_profile:
			persistent_profiles[account_id] = profile_before
		else:
			persistent_profiles.erase(account_id)
		profiles_dirty = dirty_before
		profile_save_timer = timer_before
		return false
	return true

func _store_tutorial_draft_for_account(tester_key: String, slot_index: int, candidate: Dictionary, simulate_disk_failure: bool = false) -> Dictionary:
	var clean_key: = safe_tester_id(tester_key)
	if clean_key.is_empty() or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return tutorial_draft_error("INVALID_RESIDENT_SLOT", "The server could not identify that tutorial slot.", slot_index)
	var server_roster: = account_roster(clean_key).duplicate(true)
	if server_roster["slots"][slot_index] is Dictionary:
		return tutorial_draft_error("SLOT_OCCUPIED", "A finalized Resident already occupies that slot.", slot_index)
	var sanitized: = sanitize_tutorial_draft(candidate, slot_index)
	if not bool(sanitized.get("ok", false)):
		return sanitized
	var drafts: Array = server_roster.get("tutorial_drafts", ReleaseSave.empty_tutorial_drafts())
	var existing: Variant = drafts[slot_index]
	if existing is Dictionary and not tutorial_draft_matches_authority(candidate, existing as Dictionary):
		return tutorial_draft_error("STALE_TUTORIAL_DRAFT", "That tutorial checkpoint is stale. Reload the current tutorial and try again.", slot_index)
	var draft: Dictionary = Dictionary(sanitized["draft"]).duplicate(true)
	if existing is Dictionary:
		var existing_draft: = existing as Dictionary
		var merged_flags: = Dictionary(draft.get("tutorial_flags", {})).duplicate(true)
		for flag_name in merged_flags.keys():
			merged_flags[flag_name] = bool(merged_flags[flag_name]) or bool(Dictionary(existing_draft.get("tutorial_flags", {})).get(flag_name, false))
		draft["tutorial_flags"] = merged_flags
		var existing_headstart: = String(existing_draft.get("tutorial_headstart", ""))
		if not existing_headstart.is_empty():
			draft["tutorial_headstart"] = existing_headstart
		var headstart: = String(draft.get("tutorial_headstart", ""))
		draft["tutorial_path_scores"] = {
			"civilian": (1 if bool(merged_flags.get("counselor", false)) else 0) + (2 if headstart == "civilian" else 0), 
			"law": (1 if bool(merged_flags.get("officer", false)) else 0) + (2 if headstart == "law" else 0), 
			"criminal": (1 if bool(merged_flags.get("detainee", false)) else 0) + (2 if headstart == "criminal" else 0), 
		}
		draft["draft_id"] = String(existing_draft.get("draft_id", ""))
		draft["revision"] = int(existing_draft.get("revision", 0)) + 1
	else:
		draft["draft_id"] = "TD-" + _new_token().left(20).to_upper()
		draft["revision"] = 1
	draft["world_id"] = server_world_id
	draft["updated_unix_ms"] = int(Time.get_unix_time_from_system() * 1000.0)
	drafts[slot_index] = draft
	server_roster["tutorial_drafts"] = drafts
	server_roster["active_tutorial_slot"] = slot_index
	if not persist_account_roster_atomically(clean_key, server_roster, simulate_disk_failure):
		return tutorial_draft_error("PERSISTENCE_FAILED", "The server could not durably save the tutorial draft.", slot_index)
	return {"ok": true, "kind": "tutorial_draft", "slot_index": slot_index, "draft": draft.duplicate(true), "durable": true}

func _finalize_tutorial_for_account(tester_key: String, slot_index: int, candidate: Dictionary, simulate_disk_failure: bool = false) -> Dictionary:
	var clean_key: = safe_tester_id(tester_key)
	if clean_key.is_empty() or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return tutorial_finalize_error("INVALID_RESIDENT_SLOT", "The server could not identify that Resident slot.", slot_index)
	var server_roster: = account_roster(clean_key).duplicate(true)
	var clean_name: = normalized_resident_name(String(candidate.get("name", "")))
	var existing_adult: Variant = server_roster["slots"][slot_index]
	if existing_adult is Dictionary:
		if resident_name_key(String(existing_adult.get("name", ""))) == resident_name_key(clean_name):
			return {"ok": true, "kind": "tutorial_finalized", "slot_index": slot_index, "name": String(existing_adult.get("name", "")), "resident": (existing_adult as Dictionary).duplicate(true), "draft_deleted": true, "deduplicated": true, "durable": true}
		return tutorial_finalize_error("SLOT_OCCUPIED", "A finalized Resident already occupies that slot.", slot_index)
	var drafts: Array = server_roster.get("tutorial_drafts", ReleaseSave.empty_tutorial_drafts())
	var draft_value: Variant = drafts[slot_index]
	if draft_value is not Dictionary:
		return tutorial_finalize_error("DRAFT_NOT_FOUND", "The server could not find an unfinished tutorial in that slot.", slot_index)
	var draft: = draft_value as Dictionary
	if not tutorial_draft_matches_authority(candidate, draft):
		var stale_result: = tutorial_finalize_error("STALE_TUTORIAL_DRAFT", "The server refreshed this Resident file. Review it once more and confirm again.", slot_index)
		stale_result["draft"] = draft.duplicate(true)
		return stale_result
	if String(draft.get("tutorial_headstart", "")).is_empty():
		return tutorial_finalize_error("INVALID_TUTORIAL_STAGE", "Finish orientation and choose a headstart before adult creation.", slot_index)
	var name_result: = resident_name_check_result(clean_name, clean_key, slot_index)
	if not bool(name_result.get("ok", false)):
		name_result["kind"] = "tutorial_finalized"
		name_result["slot_index"] = slot_index
		return name_result
	var appearance_result: = sanitize_adult_creation_appearance(candidate, slot_index)
	if not bool(appearance_result.get("ok", false)):
		appearance_result["kind"] = "tutorial_finalized"
		return appearance_result
	var resident: = server_adult_from_tutorial(String(name_result["name"]), appearance_result["appearance"], draft)
	server_roster["slots"][slot_index] = resident
	drafts[slot_index] = null
	server_roster["tutorial_drafts"] = drafts
	server_roster["active_slot"] = slot_index
	server_roster["active_tutorial_slot"] = -1
	if not persist_account_roster_atomically(clean_key, server_roster, simulate_disk_failure):
		return tutorial_finalize_error("PERSISTENCE_FAILED", "The server could not durably finalize that Resident.", slot_index)
	return {"ok": true, "kind": "tutorial_finalized", "slot_index": slot_index, "name": String(name_result["name"]), "resident": resident.duplicate(true), "draft_deleted": true, "durable": true}

func save_server_tutorial_draft(slot_index: int, draft: Dictionary) -> void :
	if not active or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return
	if hosting:
		resident_save_result.emit(_store_tutorial_draft_for_account(String(peer_accounts.get(local_peer_id(), "")), slot_index, draft))
	else:
		save_server_tutorial_draft_on_host.rpc_id(1, slot_index, draft)

@rpc("any_peer", "call_remote", "reliable")
func save_server_tutorial_draft_on_host(slot_index: int, draft: Dictionary) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	if not tutorial_rpc_sender_authorized(sender):
		receive_resident_save_result.rpc_id(sender, tutorial_draft_error("UNAUTHORIZED_TUTORIAL_DRAFT", "The server rejected this tutorial checkpoint.", slot_index))
		return
	receive_resident_save_result.rpc_id(sender, _store_tutorial_draft_for_account(String(peer_accounts.get(sender, "")), slot_index, draft))

func finalize_server_tutorial(slot_index: int, candidate: Dictionary) -> void :
	if not active or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return
	if hosting:
		resident_save_result.emit(_finalize_tutorial_for_account(String(peer_accounts.get(local_peer_id(), "")), slot_index, candidate))
	else:
		finalize_server_tutorial_on_host.rpc_id(1, slot_index, candidate)

@rpc("any_peer", "call_remote", "reliable")
func finalize_server_tutorial_on_host(slot_index: int, candidate: Dictionary) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	if not tutorial_rpc_sender_authorized(sender):
		receive_resident_save_result.rpc_id(sender, tutorial_finalize_error("UNAUTHORIZED_TUTORIAL_DRAFT", "The server rejected this tutorial finalization.", slot_index))
		return
	receive_resident_save_result.rpc_id(sender, _finalize_tutorial_for_account(String(peer_accounts.get(sender, "")), slot_index, candidate))

func save_server_resident(slot_index: int, resident: Dictionary, roster_metadata: Dictionary = {}) -> void :
	if not active or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return
	if hosting:
		var peer_id: = local_peer_id()
		var result: = _store_resident_for_account(String(peer_accounts.get(peer_id, "")), slot_index, resident, roster_metadata, false)
		sync_peer_after_resident_save(peer_id, slot_index, result)
		resident_save_result.emit(result)
	else:
		save_server_resident_on_host.rpc_id(1, slot_index, resident, roster_metadata)

@rpc("any_peer", "call_remote", "reliable")
func save_server_resident_on_host(slot_index: int, resident: Dictionary, roster_metadata: Dictionary) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	var result: = _store_resident_for_account(String(peer_accounts.get(sender, "")), slot_index, resident, roster_metadata, false)
	sync_peer_after_resident_save(sender, slot_index, result)
	receive_resident_save_result.rpc_id(sender, result)

@rpc("authority", "call_remote", "reliable")
func receive_resident_save_result(result: Dictionary) -> void :
	resident_save_result.emit(result.duplicate(true))

func sync_peer_after_resident_save(peer_id: int, slot_index: int, result: Dictionary) -> void :
	if not bool(result.get("ok", false)) or not profiles_enabled or peer_id not in peer_states:
		return
	var state: Dictionary = peer_states[peer_id]
	if int(state.get("resident_slot", -1)) != slot_index:
		return
	hydrate_peer_economy_from_profile(state, peer_id)
	peer_states[peer_id] = state
	clear_school_study_if_state_invalid(String(peer_accounts.get(peer_id, state.get("tester_id", ""))), slot_index, state)

func _store_resident_for_account(tester_key: String, slot_index: int, resident: Dictionary, roster_metadata: Dictionary = {}, allow_empty_slot: bool = true) -> Dictionary:
	var clean_key: = safe_tester_id(tester_key)
	if clean_key.is_empty() or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return {"ok": false, "error_code": "INVALID_RESIDENT_SLOT", "message": "The server could not identify that Resident slot."}
	var server_roster: = account_roster(clean_key)
	var clean_resident: = resident.duplicate(true)
	var existing: Variant = server_roster["slots"][slot_index]
	var candidate_phase: = String(clean_resident.get("phase", "adult")).to_lower()
	if candidate_phase != "adult":
		return {"ok": false, "error_code": "INVALID_RESIDENT_PHASE", "message": "The server rejected an invalid Resident phase."}
	clean_resident["phase"] = "adult"
	var clean_name: = normalized_resident_name(String(clean_resident.get("name", "Resident")))
	if existing is not Dictionary and not allow_empty_slot:
		return {"ok": false, "error_code": "TUTORIAL_DRAFT_REQUIRED", "message": "New Residents must be finalized from a server tutorial draft.", "name": clean_name}
	if existing is not Dictionary and not resident_name_available(clean_name, clean_key, slot_index):
		return {"ok": false, "error_code": "NAME_ALREADY_TAKEN", "message": "That Resident name is already in use on this server.", "name": clean_name}
	if existing is Dictionary:
		var existing_resident: Dictionary = existing as Dictionary
		var authority_fields: = [
			"carried_cash_clean", "carried_cash_dirty", "bank_balance_clean", "inventory", "equipment", "credentials", 
			"active_handoffs", "completed_handoffs", "employment", "work_experience", "xp", "skills", "property", 
			"active_home_visit", "home_instance_id", "insurance", "legacy_marker", "processed_transactions", "evidence_history", 
			"school_agility_last_obstacle_id", "dealer_relationships", "phone_messages", "capone_shift_sequence", "crimes", 
		]
		for field in authority_fields:
			if existing_resident.has(field):
				clean_resident[field] = existing_resident[field]
		clean_name = normalized_resident_name(String(existing_resident.get("name", clean_name)))
	clean_resident["name"] = clean_name
	server_roster["slots"][slot_index] = clean_resident
	server_roster["active_slot"] = slot_index
	server_roster["last_switch_unix"] = maxi(0, int(roster_metadata.get("last_switch_unix", server_roster.get("last_switch_unix", 0))))
	persistent_profiles[clean_key] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	return {"ok": true, "name": clean_name, "slot_index": slot_index}

func submit_economy_request(request: Dictionary) -> void :
	if not active:
		economy_result_received.emit(economy_error("", "SERVER_UNAVAILABLE", "The city ledger is unavailable.", {}))
		return
	var peer_id: = local_peer_id()
	var state: Dictionary = peer_states.get(peer_id, {})
	var slot_index: = int(state.get("resident_slot", request.get("resident_slot", -1)))
	if hosting:
		if profiles_enabled:
			store_connected_resident(peer_id)
		var account_id: = String(peer_accounts.get(peer_id, state.get("tester_id", "")))
		economy_result_received.emit(process_economy_request_atomically(account_id, slot_index, request))
	else:
		economy_request.rpc_id(1, request)

func process_economy_request_atomically(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var profiles_before: = persistent_profiles.duplicate(true)
	var audit_before: = economy_audit_log.duplicate(true)
	var assignment_before: = cashier_assignment.duplicate(true)
	var service_assignments_before: = service_assignments.duplicate(true)
	var blood_evidence_before: = blood_evidence_records.duplicate(true)
	var blood_sequence_before: = evidence_event_sequence
	var blood_empty_elapsed_before: = blood_empty_server_elapsed
	var blood_cleaning_before: = blood_cleaning_actions.duplicate(true)
	var school_training_before: = school_training_actions.duplicate(true)
	var school_practice_before: = school_practice_states.duplicate(true)
	var school_study_before: = school_study_sessions.duplicate(true)
	var cleaning_trace_sequence_before: = cleaning_trace_sequence
	var economy_event_sequence_before: = economy_event_sequence
	var dirty_before: = profiles_dirty
	var result: = process_economy_request_for_account(account_id, slot_index, request)
	if not bool(result.get("ok", false)) or bool(result.get("deduplicated", false)) or not profiles_enabled:
		return result
	if bool(request.get("simulate_disk_failure", false)) or not save_server_profiles():
		persistent_profiles = profiles_before
		economy_audit_log = audit_before
		cashier_assignment = assignment_before
		service_assignments = service_assignments_before
		blood_evidence_records = blood_evidence_before
		evidence_event_sequence = blood_sequence_before
		blood_empty_server_elapsed = blood_empty_elapsed_before
		blood_cleaning_actions = blood_cleaning_before
		school_training_actions = school_training_before
		school_practice_states = school_practice_before
		school_study_sessions = school_study_before
		cleaning_trace_sequence = cleaning_trace_sequence_before
		economy_event_sequence = economy_event_sequence_before
		profiles_dirty = dirty_before
		return economy_error(String(request.get("action", "")).to_upper(), "PERSISTENCE_FAILED", "Something on our end. Your stuff is safe. Try again.", {}, String(request.get("transaction_id", "")))
	sync_connected_economy_state(account_id, slot_index)
	if request.has("target_account_id"):
		sync_connected_economy_state(String(request.get("target_account_id", "")), int(request.get("target_resident_slot", -1)))
	if hosting:
		_schedule_snapshot()
	for affected_variant in result.get("_affected_residents", []):
		if affected_variant is Dictionary:
			var affected: Dictionary = affected_variant as Dictionary
			sync_connected_economy_state(String(affected.get("account_id", "")), int(affected.get("resident_slot", -1)))
	result.erase("_affected_residents")
	return result

func sync_connected_economy_state(account_id: String, slot_index: int) -> void :
	var clean_account: = safe_tester_id(account_id)
	if clean_account.is_empty() or slot_index < 0:
		return
	for peer_variant in peer_states.keys():
		var peer_id: = int(peer_variant)
		if safe_tester_id(String(peer_accounts.get(peer_id, ""))) != clean_account:
			continue
		if int(peer_states[peer_id].get("resident_slot", -1)) != slot_index:
			continue
		hydrate_peer_economy_from_profile(peer_states[peer_id], peer_id)

@rpc("any_peer", "call_remote", "reliable")
func economy_request(request: Dictionary) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	if profiles_enabled:
		store_connected_resident(sender)
	var state: Dictionary = peer_states.get(sender, {})
	var account_id: = String(peer_accounts.get(sender, state.get("tester_id", "")))
	var slot_index: = int(state.get("resident_slot", -1))
	var result: = process_economy_request_atomically(account_id, slot_index, request)
	economy_result.rpc_id(sender, result)

@rpc("authority", "call_remote", "reliable")
func economy_result(result: Dictionary) -> void :
	economy_result_received.emit(result)

func process_economy_request_for_account(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var clean_account: = safe_tester_id(account_id)
	var action: = String(request.get("action", "")).to_upper()
	if clean_account.is_empty() or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return economy_error(action, "IDENTITY_MISMATCH", "The ledger could not match this request to a Resident.", {})
	if request.has("account_id") and safe_tester_id(String(request.get("account_id", ""))) != clean_account:
		return economy_error(action, "IDENTITY_MISMATCH", "The ledger could not match this request to a Resident.", {})
	if request.has("resident_slot") and int(request.get("resident_slot", -1)) != slot_index:
		return economy_error(action, "IDENTITY_MISMATCH", "The ledger could not match this request to a Resident.", {})
	var request_world: = String(request.get("world_id", server_world_id))
	if not request_world.is_empty() and not server_world_id.is_empty() and request_world != server_world_id:
		return economy_error(action, "WRONG_WORLD", "That transaction belongs to a different world.", {}, String(request.get("transaction_id", "")))

	var server_roster: = account_roster(clean_account)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return economy_error(action, "RESIDENT_NOT_FOUND", "The city could not find that Resident file.", {})
	var resident: Dictionary = SaveMigration.migrate_resident(resident_value as Dictionary)
	var resident_world: = String(resident.get("world_id", server_world_id))
	if not resident_world.is_empty() and not server_world_id.is_empty() and resident_world != server_world_id:
		return economy_error(action, "WRONG_WORLD", "That Resident belongs to a different world.", resident, String(request.get("transaction_id", "")))
	var jail_custody_action: = action in ["JAIL_ASSIGNMENT_COMPLETE", "JAIL_RELEASE"]
	if bool(resident.get("arrested", false)) and not jail_custody_action:
		return economy_error(action, "RESIDENT_IN_CUSTODY", "That Resident is in playable jail custody.", resident, String(request.get("transaction_id", "")))
	if jail_custody_action and not bool(resident.get("arrested", false)):
		return economy_error(action, "RESIDENT_NOT_IN_CUSTODY", "That Resident is not serving a jail sentence.", resident, String(request.get("transaction_id", "")))
	var transaction_id: = String(request.get("transaction_id", "")).strip_edges()
	var requires_transaction: = action not in ["HANDOFF_COMPLETE", "CASHIER_ACCEPT", "CASHIER_TASK_ASSIGN", "CASHIER_TASK_RELEASE", "SERVICE_ACCEPT", "SERVICE_TASK_ASSIGN", "SERVICE_TASK_RELEASE", "CAPONE_TASK_ASSIGN", "CAPONE_TASK_STATUS", "HOME_ACCESS_DIRECTORY", "SCHOOL_PRACTICE_KIT", "SCHOOL_DUMMY_RESET", "SCHOOL_STUDY_START"]
	if requires_transaction:
		var transaction_error: = validate_transaction_id(transaction_id, request_world, clean_account, slot_index)
		if not transaction_error.is_empty():
			return economy_error(action, String(transaction_error.get("code", "INVALID_TRANSACTION_ID")), String(transaction_error.get("message", "Invalid transaction.")), resident, transaction_id)
		var replay: = prior_transaction_outcome(resident, transaction_id, transaction_now_ms(request))
		if not replay.is_empty():


			var replay_resident: = SaveMigration.migrate_resident(account_roster(clean_account)["slots"][slot_index])
			replay["resident"] = replay_resident
			replay["balances"] = economy_balances(replay_resident)
			replay["inventory"] = Array(replay_resident.get("inventory", [])).duplicate(true)
			replay["deduplicated"] = true
			return replay
	if action in ["DIRECT_HANDOFF", "SEARCH_ROBBERY", "SEARCH_ROBBERY_ALL", "SEIZURE", "ARREST", "DETAIN", "RELEASE_DETENTION"]:
		var cross_result: = process_cross_resident_economy_request(clean_account, slot_index, request)
		if requires_transaction:
			return record_transaction_outcome(clean_account, slot_index, transaction_id, cross_result, transaction_now_ms(request))
		return cross_result
	if action == "HANDOFF_COMPLETE":
		return complete_tracked_handoff(clean_account, slot_index, request)
	if action == "LEGACY_APPLY":
		var legacy_result: = apply_legacy_transfer(clean_account, slot_index, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, legacy_result, transaction_now_ms(request))
	if action in ["CASHIER_ACCEPT", "CASHIER_TASK_ASSIGN", "CASHIER_TASK_COMPLETE", "CASHIER_TASK_RELEASE", "CASHIER_SAFE_ACCESS", "HANDOFF_BREAK_SEAL"]:
		var cashier_result: = process_cashier_action(clean_account, slot_index, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, cashier_result, transaction_now_ms(request)) if requires_transaction else cashier_result
	if action in ["SERVICE_ACCEPT", "SERVICE_TASK_ASSIGN", "SERVICE_TASK_COMPLETE", "SERVICE_TASK_RELEASE", "SERVICE_DEPOSIT_ISSUE"]:
		var service_result: = process_service_action(clean_account, slot_index, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, service_result, transaction_now_ms(request)) if requires_transaction else service_result
	if action in ["CAPONE_EMPLOYMENT_ACCEPT", "CAPONE_TASK_ASSIGN", "CAPONE_TASK_STATUS", "CAPONE_TASK_COMPLETE", "CAPONE_TASK_FAIL"]:
		var capone_result: = process_capone_action(clean_account, slot_index, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, capone_result, transaction_now_ms(request)) if requires_transaction else capone_result
	if action in ["MOTH_RUN_ACCEPT", "MOTH_CUSTOMER_EXCHANGE", "MOTH_TEE_EXCHANGE", "MOTH_RUN_COMPLETE", "MOTH_WHOLESALE_BUY", "POWDER_ANALYZE", "POWDER_USE"]:
		var moth_result: = process_moth_action(clean_account, slot_index, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, moth_result, transaction_now_ms(request))
	if action in ["START_BLOOD_CLEANING", "CANCEL_BLOOD_CLEANING"]:
		var cleaning_result: = process_blood_cleaning_action(clean_account, slot_index, resident, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, cleaning_result, transaction_now_ms(request))
	if action == "COMPLETE_BLOOD_CLEANING":
		var completion_result: = process_blood_cleaning_completion(clean_account, slot_index, resident, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, completion_result, transaction_now_ms(request))
	if action == "COLLECT_BLOOD_SAMPLE":
		var sample_result: = process_blood_sample_action(clean_account, slot_index, resident, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, sample_result, transaction_now_ms(request))
	if action in ["SCHOOL_TRAINING_START", "SCHOOL_TRAINING_COMPLETE", "SCHOOL_TRAINING_CANCEL", "SCHOOL_PRACTICE_KIT", "SCHOOL_DUMMY_RESET", "SCHOOL_DUMMY_OUTCOME", "SCHOOL_STEALTH_ATTEMPT"]:
		var school_result: = process_school_training_action(clean_account, slot_index, resident, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, school_result, transaction_now_ms(request)) if requires_transaction else school_result
	if action in ["SCHOOL_STUDY_START", "SCHOOL_STUDY_COMPLETE"]:
		var study_result: = process_school_study_action(clean_account, slot_index, resident, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, study_result, transaction_now_ms(request)) if requires_transaction else study_result
	if action in ["HOME_ACCESS_DIRECTORY", "HOME_VISIT_REQUEST", "HOME_VISIT_APPROVE_ONCE", "HOME_VISIT_APPROVE_PERMANENT", "HOME_VISIT_DENY", "HOME_KEY_REVOKE", "HOME_VISIT_ENTER", "HOME_VISIT_LEAVE"]:
		var home_access_result: = process_home_access_action(clean_account, slot_index, resident, request)
		return record_transaction_outcome(clean_account, slot_index, transaction_id, home_access_result, transaction_now_ms(request)) if requires_transaction else home_access_result
	var authoritative_request: = request.duplicate(true)
	authoritative_request["server_account_id"] = clean_account
	authoritative_request["server_resident_slot"] = slot_index
	var result: = validate_and_apply_economy_mutation(resident, authoritative_request)
	if not bool(result.get("ok", false)):
		return record_transaction_outcome(clean_account, slot_index, transaction_id, result, transaction_now_ms(request)) if requires_transaction else result

	var updated_resident: Dictionary = result.get("resident", {})
	server_roster["slots"][slot_index] = updated_resident
	server_roster["active_slot"] = slot_index
	persistent_profiles[clean_account] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: Dictionary = Dictionary(result.get("audit", {})).duplicate(true)
	audit["event_sequence"] = economy_event_sequence
	audit["account_id"] = clean_account
	audit["resident_slot"] = slot_index
	audit["world_id"] = server_world_id
	audit["server_unix_ms"] = Time.get_unix_time_from_system() * 1000.0
	economy_audit_log.append(audit)
	result["audit"] = audit
	return record_transaction_outcome(clean_account, slot_index, transaction_id, result, transaction_now_ms(request)) if requires_transaction else result

func process_blood_sample_action(account_id: String, slot_index: int, resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = "COLLECT_BLOOD_SAMPLE"
	var evidence_id: = String(request.get("evidence_id", "")).strip_edges()
	var record_index: = -1
	for index in range(blood_evidence_records.size()):
		if String(blood_evidence_records[index].get("evidence_id", "")) == evidence_id:
			record_index = index
			break
	if record_index < 0 or not EvidenceRecords.is_active_blood(blood_evidence_records[record_index]):
		return economy_error(action, "EVIDENCE_NOT_FOUND", "That blood record is no longer available to collect.", resident, String(request.get("transaction_id", "")))
	if bool(resident.get("downed", false)) or String(resident.get("phase", "adult")) != "adult":
		return economy_error(action, "RESIDENT_UNAVAILABLE", "A downed or unfinished Resident cannot collect evidence.", resident, String(request.get("transaction_id", "")))
	var record: Dictionary = blood_evidence_records[record_index]
	if String(resident.get("area", "")) != String(record.get("area", "")) or String(resident.get("room_id", "")) != String(record.get("room_id", "")):
		return economy_error(action, "WRONG_LOCATION", "The blood is not in this room.", resident, String(request.get("transaction_id", "")))
	var resident_position: = state_position(resident)
	var blood_position: Vector2 = record.get("position", Vector2.ZERO) as Vector2
	if resident_position.distance_to(blood_position) > BLOOD_CLEANING_DISTANCE:
		return economy_error(action, "OUT_OF_REACH", "Stand beside the blood before using the Test Tube.", resident, String(request.get("transaction_id", "")))
	if inventory_record_index(Array(resident.get("inventory", [])), "Test Tube") < 0:
		return economy_error(action, "TEST_TUBE_REQUIRED", "A clean Test Tube is required for that sample.", resident, String(request.get("transaction_id", "")))
	evidence_event_sequence += 1
	var sample_id: = "%s-SAMPLE-%d" % [evidence_id, evidence_event_sequence]
	var sample: = EvidenceRecords.blood_sample_record(
		sample_id, 
		evidence_id, 
		String(record.get("area", "")), 
		String(record.get("room_id", "")), 
		blood_position, 
		account_id, 
		slot_index, 
		transaction_now_ms(request)
	)
	var updated_record: = record.duplicate(true)
	updated_record["sample_count"] = int(updated_record.get("sample_count", 0)) + 1
	var sample_ids: Array = Array(updated_record.get("sample_ids", [])).duplicate(true)
	sample_ids.append(sample_id)
	updated_record["sample_ids"] = sample_ids
	blood_evidence_records[record_index] = EvidenceRecords.normalize_record(updated_record)
	var updated: = resident.duplicate(true)
	var evidence_history: Array = Array(updated.get("evidence_history", [])).duplicate(true)
	evidence_history.append(sample)
	updated["evidence_history"] = evidence_history
	var server_roster: = account_roster(account_id)
	server_roster["slots"][slot_index] = updated
	server_roster["active_slot"] = slot_index
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: = {
		"event_sequence": economy_event_sequence, 
		"type": "blood_sample_collected", 
		"evidence_id": evidence_id, 
		"sample_id": sample_id, 
		"account_id": account_id, 
		"resident_slot": slot_index, 
		"world_id": server_world_id, 
		"server_unix_ms": transaction_now_ms(request), 
	}
	economy_audit_log.append(audit)
	return economy_success(action, updated, audit)

func blood_cleaning_key(account_id: String, slot_index: int) -> String:
	return "%s:%d" % [safe_tester_id(account_id), slot_index]

func blood_cleaning_action_for(account_id: String, slot_index: int) -> Dictionary:
	var key: = blood_cleaning_key(account_id, slot_index)
	var action: Variant = blood_cleaning_actions.get(key, {})
	return action.duplicate(true) if action is Dictionary else {}

func connected_state_for_resident(account_id: String, slot_index: int) -> Dictionary:
	var clean_account: = safe_tester_id(account_id)
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		if safe_tester_id(String(peer_accounts.get(peer_id, peer_states[peer_id].get("tester_id", "")))) == clean_account and int(peer_states[peer_id].get("resident_slot", -1)) == slot_index:
			return peer_states[peer_id].duplicate(true)
	return {}

func cleaning_record_index(evidence_id: String) -> int:
	for index in range(blood_evidence_records.size()):
		if String(blood_evidence_records[index].get("evidence_id", "")) == evidence_id:
			return index
	return -1

func append_cleaning_trace_to_resident(account_id: String, slot_index: int, trace: Dictionary) -> Dictionary:
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return {}
	var updated: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var evidence_history: Array = Array(updated.get("evidence_history", [])).duplicate(true)
	evidence_history.append(trace.duplicate(true))
	updated["evidence_history"] = evidence_history
	server_roster["slots"][slot_index] = updated
	server_roster["active_slot"] = slot_index
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	return updated

func cleaning_witnesses(cleaner_account_id: String, cleaner_slot: int, record: Dictionary) -> Array[Dictionary]:
	var witnesses: Array[Dictionary] = []
	var record_state: = {
		"area": String(record.get("area", "")), 
		"room_id": String(record.get("room_id", "")), 
		"home_instance_id": String(record.get("home_instance_id", "")), 
	}
	var blood_position: Vector2 = record.get("position", Vector2.ZERO) as Vector2
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		var state: Dictionary = peer_states[peer_id]
		var account_id: = safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", ""))))
		var slot_index: = int(state.get("resident_slot", -1))
		if account_id.is_empty() or (account_id == safe_tester_id(cleaner_account_id) and slot_index == cleaner_slot):
			continue
		if String(state.get("phase", "adult")) != "adult" or bool(state.get("downed", false)):
			continue
		if not states_share_room_instance(state, record_state):
			continue
		if state_position(state).distance_to(blood_position) > BLOOD_CLEANING_WITNESS_DISTANCE:
			continue
		witnesses.append(EvidenceRecords.witness_record(
			"%s-WITNESS-%d" % [String(record.get("evidence_id", "EVIDENCE")), witnesses.size() + 1], 
			String(state.get("name", "Resident")), "Resident was nearby during blood-evidence cleaning.", 
			"resident", account_id, String(record.get("area", "")), String(record.get("room_id", "")), 
			state_position(state), 0, "", int(Time.get_unix_time_from_system() * 1000.0), account_id, slot_index, peer_id
		))
	witnesses.sort_custom( func(first: Dictionary, second: Dictionary) -> bool:
		return "%s:%d" % [String(first.get("account_id", "")), int(first.get("resident_slot", -1))] < "%s:%d" % [String(second.get("account_id", "")), int(second.get("resident_slot", -1))]
	)
	return witnesses

func append_blood_cleaning_trace(record_index: int, action: Dictionary, status: String, reason: String, completed_at_ms: int) -> Dictionary:
	if record_index < 0 or record_index >= blood_evidence_records.size():
		return {}
	cleaning_trace_sequence += 1
	var trace: = EvidenceRecords.blood_cleaning_trace_record(
		"%s-CLEAN-%d" % [String(action.get("evidence_id", "BLOOD")), cleaning_trace_sequence], 
		status, 
		String(action.get("cleaner_item_id", "")), 
		String(action.get("account_id", "")), 
		int(action.get("resident_slot", -1)), 
		int(action.get("started_at_ms", 0)), 
		completed_at_ms, 
		reason, 
		cleaning_witnesses(String(action.get("account_id", "")), int(action.get("resident_slot", -1)), blood_evidence_records[record_index])
	)
	var updated_record: = blood_evidence_records[record_index].duplicate(true)
	var history: Array = Array(updated_record.get("cleaning_history", [])).duplicate(true)
	history.append(trace)
	updated_record["cleaning_history"] = history
	blood_evidence_records[record_index] = EvidenceRecords.normalize_record(updated_record)
	return trace

func process_blood_cleaning_action(account_id: String, slot_index: int, resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var key: = blood_cleaning_key(account_id, slot_index)
	if action == "CANCEL_BLOOD_CLEANING":
		var current: = blood_cleaning_action_for(account_id, slot_index)
		if current.is_empty():
			return economy_error(action, "NO_CLEANING_ACTION", "There is no blood-cleaning action to cancel.", resident, String(request.get("transaction_id", "")))
		var reason: = String(request.get("reason", "PLAYER_CANCELLED")).strip_edges().left(64)
		var record_index: = cleaning_record_index(String(current.get("evidence_id", "")))
		var trace: = append_blood_cleaning_trace(record_index, current, "interrupted", reason, transaction_now_ms(request))
		blood_cleaning_actions.erase(key)
		var updated: = append_cleaning_trace_to_resident(account_id, slot_index, trace) if not trace.is_empty() else resident.duplicate(true)
		economy_event_sequence += 1
		var audit: = {"event_sequence": economy_event_sequence, "type": "blood_cleaning_interrupted", "evidence_id": current.get("evidence_id", ""), "cleaner_item_id": current.get("cleaner_item_id", ""), "reason": reason, "witnesses": trace.get("witnesses", []), "account_id": account_id, "resident_slot": slot_index, "world_id": server_world_id, "server_unix_ms": transaction_now_ms(request)}
		economy_audit_log.append(audit)
		return economy_success(action, updated, audit)
	var cleaner_item_id: = String(request.get("cleaner_item_id", "")).strip_edges()
	var definition: Dictionary = BLOOD_CLEANING_AGENTS.get(cleaner_item_id, {})
	if definition.is_empty():
		return economy_error(action, "INVALID_CLEANING_AGENT", "That cleaner is not recognized by the evidence ledger.", resident, String(request.get("transaction_id", "")))
	if not blood_cleaning_action_for(account_id, slot_index).is_empty():
		return economy_error(action, "CLEANING_IN_PROGRESS", "Finish or interrupt the current cleaning action first.", resident, String(request.get("transaction_id", "")))
	var evidence_id: = String(request.get("evidence_id", "")).strip_edges()
	var record_index: = cleaning_record_index(evidence_id)
	if record_index < 0 or not EvidenceRecords.is_active_blood(blood_evidence_records[record_index]):
		return economy_error(action, "EVIDENCE_NOT_FOUND", "That blood record is no longer available to clean.", resident, String(request.get("transaction_id", "")))
	var location_state: = connected_state_for_resident(account_id, slot_index)
	if location_state.is_empty():
		location_state = resident.duplicate(true)
	if bool(location_state.get("downed", false)) or String(location_state.get("phase", "adult")) != "adult":
		return economy_error(action, "RESIDENT_UNAVAILABLE", "A downed or unfinished Resident cannot clean evidence.", resident, String(request.get("transaction_id", "")))
	var record: Dictionary = blood_evidence_records[record_index]
	var record_state: = {"area": String(record.get("area", "")), "room_id": String(record.get("room_id", "")), "home_instance_id": String(record.get("home_instance_id", ""))}
	if not states_share_room_instance(location_state, record_state):
		return economy_error(action, "WRONG_LOCATION", "The blood is not in this room.", resident, String(request.get("transaction_id", "")))
	var resident_position: = state_position(location_state)
	var blood_position: Vector2 = record.get("position", Vector2.ZERO) as Vector2
	if resident_position.distance_to(blood_position) > BLOOD_CLEANING_DISTANCE:
		return economy_error(action, "OUT_OF_REACH", "Stand beside the blood before cleaning it.", resident, String(request.get("transaction_id", "")))
	var inventory: Array = Array(resident.get("inventory", [])).duplicate(true)
	var cleaner_index: = inventory_record_index(inventory, cleaner_item_id)
	if cleaner_index < 0:
		return economy_error(action, "CLEANER_REQUIRED", "That cleaning agent is not in the Resident's carried inventory.", resident, String(request.get("transaction_id", "")))
	var now_ms: = transaction_now_ms(request)
	var cleaning_action: = {"evidence_id": evidence_id, "cleaner_item_id": cleaner_item_id, "account_id": safe_tester_id(account_id), "resident_slot": slot_index, "initial_area": String(location_state.get("area", "")), "initial_room_id": String(location_state.get("room_id", "")), "initial_home_instance_id": String(location_state.get("home_instance_id", "")), "initial_position": resident_position, "initial_health": float(location_state.get("health", 100.0)), "started_at_ms": now_ms, "duration_seconds": float(definition.get("duration_seconds", 0.0))}
	blood_cleaning_actions[key] = cleaning_action
	economy_event_sequence += 1
	var audit: = {"event_sequence": economy_event_sequence, "type": "blood_cleaning_started", "evidence_id": evidence_id, "cleaner_item_id": cleaner_item_id, "duration_seconds": cleaning_action["duration_seconds"], "started_at_ms": now_ms, "account_id": safe_tester_id(account_id), "resident_slot": slot_index, "world_id": server_world_id, "server_unix_ms": now_ms}
	economy_audit_log.append(audit)
	return economy_success(action, resident, audit)

func blood_cleaning_internal_transaction_id(account_id: String, slot_index: int, suffix: String) -> String:
	return "TXN-%s-%s-%d-CLEAN-%s-%d" % [server_world_id, safe_tester_id(account_id), slot_index, suffix, Time.get_ticks_msec()]

func process_blood_cleaning_completion(account_id: String, slot_index: int, resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = "COMPLETE_BLOOD_CLEANING"
	var key: = blood_cleaning_key(account_id, slot_index)
	var current: = blood_cleaning_action_for(account_id, slot_index)
	if current.is_empty():
		return economy_error(action, "NO_CLEANING_ACTION", "There is no active blood-cleaning action to complete.", resident, String(request.get("transaction_id", "")))
	var requested_evidence: = String(request.get("evidence_id", "")).strip_edges()
	if not requested_evidence.is_empty() and requested_evidence != String(current.get("evidence_id", "")):
		return economy_error(action, "CLEANING_ACTION_MISMATCH", "That cleaning action is no longer the active action.", resident, String(request.get("transaction_id", "")))
	var record_index: = cleaning_record_index(String(current.get("evidence_id", "")))
	if record_index < 0 or not EvidenceRecords.is_active_blood(blood_evidence_records[record_index]):
		return economy_error(action, "EVIDENCE_NOT_FOUND", "That blood record is no longer available to clean.", resident, String(request.get("transaction_id", "")))
	var now_ms: = transaction_now_ms(request)
	var required_duration_ms: = maxi(0, int(round(float(current.get("duration_seconds", 0.0)) * 1000.0)))
	if now_ms - int(current.get("started_at_ms", now_ms)) < required_duration_ms:
		return economy_error(action, "CLEANING_NOT_READY", "The cleaning agent has not finished working yet.", resident, String(request.get("transaction_id", "")))
	var location_state: = connected_state_for_resident(account_id, slot_index)
	if location_state.is_empty():
		return economy_error(action, "RESIDENT_DISCONNECTED", "The Resident left before the cleaning completed.", resident, String(request.get("transaction_id", "")))
	if bool(location_state.get("downed", false)) or String(location_state.get("phase", "adult")) != "adult":
		return economy_error(action, "RESIDENT_UNAVAILABLE", "A downed or unfinished Resident cannot complete cleaning.", resident, String(request.get("transaction_id", "")))
	var record: Dictionary = blood_evidence_records[record_index]
	var record_state: = {"area": String(record.get("area", "")), "room_id": String(record.get("room_id", "")), "home_instance_id": String(record.get("home_instance_id", ""))}
	if not states_share_room_instance(location_state, record_state):
		return economy_error(action, "WRONG_LOCATION", "The blood is no longer in this room.", resident, String(request.get("transaction_id", "")))
	var blood_position: Vector2 = record.get("position", Vector2.ZERO) as Vector2
	if state_position(location_state).distance_to(blood_position) > BLOOD_CLEANING_DISTANCE:
		return economy_error(action, "OUT_OF_REACH", "The Resident moved away before cleaning completed.", resident, String(request.get("transaction_id", "")))
	var inventory: Array = Array(resident.get("inventory", [])).duplicate(true)
	var cleaner_item_id: = String(current.get("cleaner_item_id", ""))
	var cleaner_index: = inventory_record_index(inventory, cleaner_item_id)
	if cleaner_index < 0:
		return economy_error(action, "CLEANER_REQUIRED", "The reserved cleaning agent is no longer in the Resident's carried inventory.", resident, String(request.get("transaction_id", "")))
	var completed_at_ms: = now_ms
	var trace: = append_blood_cleaning_trace(record_index, current, "completed", "COMPLETED", completed_at_ms)
	if trace.is_empty():
		return economy_error(action, "EVIDENCE_NOT_FOUND", "The blood record could not be updated.", resident, String(request.get("transaction_id", "")))
	inventory.remove_at(cleaner_index)
	var cleaned_record: = blood_evidence_records[record_index].duplicate(true)
	cleaned_record["state"] = EvidenceRecords.STATE_CLEANED
	cleaned_record["cleaned_at_ms"] = completed_at_ms
	blood_evidence_records[record_index] = EvidenceRecords.normalize_record(cleaned_record)
	var updated: = resident.duplicate(true)
	updated["inventory"] = inventory
	var evidence_history: Array = Array(updated.get("evidence_history", [])).duplicate(true)
	evidence_history.append(trace.duplicate(true))
	updated["evidence_history"] = evidence_history
	var server_roster: = account_roster(account_id)
	server_roster["slots"][slot_index] = updated
	server_roster["active_slot"] = slot_index
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	blood_cleaning_actions.erase(key)
	economy_event_sequence += 1
	var audit: = {
		"event_sequence": economy_event_sequence, 
		"type": "blood_cleaning_completed", 
		"evidence_id": current.get("evidence_id", ""), 
		"cleaner_item_id": cleaner_item_id, 
		"witnesses": trace.get("witnesses", []), 
		"account_id": safe_tester_id(account_id), 
		"resident_slot": slot_index, 
		"world_id": server_world_id, 
		"server_unix_ms": completed_at_ms, 
	}
	economy_audit_log.append(audit)
	return economy_success(action, updated, audit)

func send_blood_cleaning_result(account_id: String, slot_index: int, result: Dictionary) -> void :
	if not hosting:
		return
	var peer_id: = connected_peer_for_resident(safe_tester_id(account_id), slot_index)
	if peer_id == 1:
		economy_result_received.emit(result)
	elif peer_id > 1:
		economy_result.rpc_id(peer_id, result)

func broadcast_blood_evidence_snapshots() -> void :
	if not hosting:
		return
	for peer_variant in peer_states.keys():
		var peer_id: = int(peer_variant)
		send_blood_evidence_snapshot(peer_id, peer_states[peer_id])

func interrupt_active_blood_cleaning(account_id: String, slot_index: int, reason: String) -> Dictionary:
	var current: = blood_cleaning_action_for(account_id, slot_index)
	if current.is_empty():
		return {}
	var request: = {
		"action": "CANCEL_BLOOD_CLEANING", 
		"reason": reason.left(64), 
		"world_id": server_world_id, 
		"account_id": safe_tester_id(account_id), 
		"resident_slot": slot_index, 
		"transaction_id": blood_cleaning_internal_transaction_id(account_id, slot_index, "INTERRUPT"), 
	}
	var result: = process_economy_request_atomically(account_id, slot_index, request)
	if bool(result.get("ok", false)):
		broadcast_blood_evidence_snapshots()
	send_blood_cleaning_result(account_id, slot_index, result)
	return result

func interrupt_active_blood_cleaning_for_peer(peer_id: int, reason: String) -> Dictionary:
	var state: Dictionary = peer_states.get(peer_id, {})
	if state.is_empty():
		return {}
	var account_id: = safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", ""))))
	return interrupt_active_blood_cleaning(account_id, int(state.get("resident_slot", -1)), reason)

func update_active_blood_cleaning(_delta: float) -> void :
	if not hosting:
		return
	var now_ms: = int(Time.get_unix_time_from_system() * 1000.0)
	for key_variant in blood_cleaning_actions.keys().duplicate():
		var key: = String(key_variant)
		var current: = blood_cleaning_action_for(String(key).get_slice(":", 0), int(String(key).get_slice(":", 1)))
		if current.is_empty():
			continue
		var account_id: = safe_tester_id(String(current.get("account_id", "")))
		var slot_index: = int(current.get("resident_slot", -1))
		var state: = connected_state_for_resident(account_id, slot_index)
		var reason: = ""
		if state.is_empty():
			reason = "DISCONNECTED"
		elif String(state.get("phase", "adult")) != "adult":
			reason = "PHASE_CHANGED"
		elif bool(state.get("downed", false)) or bool(state.get("deceased", false)):
			reason = "DOWNED"
		elif String(state.get("area", "")) != String(current.get("initial_area", "")) or String(state.get("room_id", "")) != String(current.get("initial_room_id", "")) or String(state.get("home_instance_id", "")) != String(current.get("initial_home_instance_id", "")):
			reason = "ROOM_CHANGED"
		else:
			var initial_position: Vector2 = current.get("initial_position", Vector2.ZERO) as Vector2
			if state_position(state).distance_to(initial_position) > BLOOD_CLEANING_POSITION_TOLERANCE:
				reason = "MOVED"
			elif float(state.get("health", 100.0)) + 0.01 < float(current.get("initial_health", 100.0)):
				reason = "DAMAGED"
		if not reason.is_empty():
			interrupt_active_blood_cleaning(account_id, slot_index, reason)
			continue
		var duration: = float(current.get("duration_seconds", 0.0))
		if float(now_ms - int(current.get("started_at_ms", now_ms))) < duration * 1000.0:
			continue
		var request: = {
			"action": "COMPLETE_BLOOD_CLEANING", 
			"evidence_id": String(current.get("evidence_id", "")), 
			"world_id": server_world_id, 
			"account_id": account_id, 
			"resident_slot": slot_index, 
			"transaction_id": blood_cleaning_internal_transaction_id(account_id, slot_index, "COMPLETE"), 
		}
		var result: = process_economy_request_atomically(account_id, slot_index, request)
		if bool(result.get("ok", false)):
			broadcast_blood_evidence_snapshots()
			send_blood_cleaning_result(account_id, slot_index, result)
		elif String(result.get("error_code", "")) in ["EVIDENCE_NOT_FOUND", "CLEANER_REQUIRED", "CLEANING_ACTION_MISMATCH"]:
			interrupt_active_blood_cleaning(account_id, slot_index, "COMPLETION_REJECTED")

func school_training_key(account_id: String, slot_index: int) -> String:
	return "%s:%d" % [safe_tester_id(account_id), slot_index]

func school_training_action_for(account_id: String, slot_index: int) -> Dictionary:
	var value: Variant = school_training_actions.get(school_training_key(account_id, slot_index), {})
	return value.duplicate(true) if value is Dictionary else {}

func school_practice_state_for(account_id: String, slot_index: int) -> Dictionary:
	var value: Variant = school_practice_states.get(school_training_key(account_id, slot_index), {})
	var state: Dictionary = value.duplicate(true) if value is Dictionary else {}
	if state.is_empty():
		state = {"kit_issued": false, "dummy_state": "ready", "completed_outcomes": {}}
	return state

func school_study_session_for(account_id: String, slot_index: int) -> Dictionary:
	var value: Variant = school_study_sessions.get(school_training_key(account_id, slot_index), {})
	return value.duplicate(true) if value is Dictionary else {}

func clear_school_study_if_state_invalid(account_id: String, slot_index: int, state: Dictionary) -> void :
	if slot_index < 0:
		return
	var key: = school_training_key(account_id, slot_index)
	var current: = school_study_session_for(account_id, slot_index)
	if current.is_empty():
		return
	var invalid: = state.is_empty() or int(state.get("resident_slot", -1)) != slot_index
	invalid = invalid or String(state.get("phase", "adult")) != "adult"
	invalid = invalid or bool(state.get("downed", false)) or bool(state.get("deceased", false))
	invalid = invalid or bool(state.get("detained", false)) or bool(state.get("arrested", false))
	invalid = invalid or String(state.get("area", "")) != String(current.get("initial_area", "school"))
	invalid = invalid or String(state.get("room_id", "")) != String(current.get("initial_room_id", ""))
	if not invalid:
		var desk: = authoritative_school_record("school", String(current.get("initial_room_id", "")), String(current.get("desk_instance_id", "")), "school_skill")
		var desk_position: Vector2 = desk.get("position", Vector2.ZERO) as Vector2
		invalid = desk.is_empty() or state_position(state).distance_to(desk_position) > maxf(1.0, float(desk.get("radius", 120.0)))
	if invalid:
		school_study_sessions.erase(key)

func shuffled_school_values(values: Array) -> Array:
	var shuffled: = values.duplicate(true)
	for index in range(shuffled.size() - 1, 0, -1):
		var swap_index: = combat_rng.randi_range(0, index)
		var held: Variant = shuffled[index]
		shuffled[index] = shuffled[swap_index]
		shuffled[swap_index] = held
	return shuffled

func prepare_authoritative_school_question(source: Dictionary, requested_choices: int) -> Dictionary:
	var source_answers: Array = source.get("answers", [])
	if source_answers.size() < 2:
		return {}
	var source_correct: = clampi(int(source.get("correct", 0)), 0, source_answers.size() - 1)
	var correct_text: = String(source_answers[source_correct])
	var distractors: Array = []
	for answer in source_answers:
		if String(answer) != correct_text:
			distractors.append(String(answer))
	distractors = shuffled_school_values(distractors)
	var choice_count: = clampi(requested_choices, 2, source_answers.size())
	var visible: Array = [correct_text]
	for index in range(mini(choice_count - 1, distractors.size())):
		visible.append(distractors[index])
	visible = shuffled_school_values(visible)
	return {
		"subject": String(source.get("subject", "Coursework")), 
		"question": String(source.get("question", "Question unavailable")), 
		"answers": visible, 
		"correct": visible.find(correct_text), 
	}

func public_school_study_questions(questions: Array) -> Array[Dictionary]:
	var public_questions: Array[Dictionary] = []
	for question_variant in questions:
		if question_variant is not Dictionary:
			continue
		var question: Dictionary = (question_variant as Dictionary).duplicate(true)
		question.erase("correct")
		public_questions.append(question)
	return public_questions

func process_school_study_action(account_id: String, slot_index: int, resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var key: = school_training_key(account_id, slot_index)
	var location_state: = school_training_location_state(account_id, slot_index, resident)
	var location_error: = validate_school_training_resident(action, resident, location_state)
	if not location_error.is_empty():
		if action == "SCHOOL_STUDY_COMPLETE":
			school_study_sessions.erase(key)
		return location_error
	var room_name: = String(location_state.get("room_id", resident.get("room_id", "")))
	if not room_name.begins_with("class_") or room_name in ["class_endurance", "class_firearms"]:
		if action == "SCHOOL_STUDY_COMPLETE":
			school_study_sessions.erase(key)
		return economy_error(action, "WRONG_LOCATION", "This Study assessment must remain inside its continuation-school classroom.", resident, String(request.get("transaction_id", "")))
	var desk_instance_id: = String(request.get("desk_instance_id", "")).strip_edges()
	var desk: = authoritative_school_record("school", room_name, desk_instance_id, "school_skill")
	var skill_name: = String(desk.get("skill_name", ""))
	if desk.is_empty() or skill_name.is_empty() or skill_name not in Rules.SKILLS:
		if action == "SCHOOL_STUDY_COMPLETE":
			school_study_sessions.erase(key)
		return economy_error(action, "INVALID_STUDY_DESK", "That Study desk is not on the authoritative classroom record.", resident, String(request.get("transaction_id", "")))
	var desk_position: Vector2 = desk.get("position", Vector2.ZERO) as Vector2
	if state_position(location_state).distance_to(desk_position) > maxf(1.0, float(desk.get("radius", 120.0))):
		if action == "SCHOOL_STUDY_COMPLETE":
			school_study_sessions.erase(key)
		return economy_error(action, "OUT_OF_REACH", "Stand beside the room-owned Study desk before filing the assessment.", resident, String(request.get("transaction_id", "")))
	var max_level: = school_room_max_level("school", room_name)
	var xp: Dictionary = Dictionary(resident.get("xp", {}))
	if action == "SCHOOL_STUDY_START":
		if Rules.level_from_xp(maxi(0, int(xp.get(skill_name, 0)))) >= max_level:
			return economy_error(action, "TRAINING_LIMIT_REACHED", "%s classroom Study stops at Level %d." % [skill_name, max_level], resident)
		var intelligence_level: = Rules.level_from_xp(maxi(0, int(xp.get("Intelligence", 0))))
		var choice_count: = 3 if intelligence_level >= max_level else 4
		var pool: Array = shuffled_school_values(EducationQuestions.questions_for_skill(skill_name))
		var questions: Array[Dictionary] = []
		for index in range(mini(SCHOOL_STUDY_QUESTION_COUNT, pool.size())):
			if pool[index] is Dictionary:
				var prepared: = prepare_authoritative_school_question(pool[index], choice_count)
				if not prepared.is_empty():
					questions.append(prepared)
		if questions.size() != SCHOOL_STUDY_QUESTION_COUNT:
			return economy_error(action, "CURRICULUM_UNAVAILABLE", "That classroom does not have a complete authoritative practical.", resident)
		var now_ms: = transaction_now_ms(request)
		var quiz_id: = "SCHOOL-STUDY-%s" % ("%s:%s:%d:%s:%d:%d" % [server_world_id, safe_tester_id(account_id), slot_index, desk_instance_id, now_ms, combat_rng.randi()]).sha256_text().left(24).to_upper()
		var study_session: = {
			"quiz_id": quiz_id, "account_id": safe_tester_id(account_id), "resident_slot": slot_index, 
			"skill": skill_name, "desk_instance_id": desk_instance_id, 
			"initial_area": "school", "initial_room_id": room_name, 
			"questions": questions, "required_correct": SCHOOL_STUDY_REQUIRED_CORRECT, 
			"max_level": max_level, "started_at_ms": now_ms, 
		}
		school_study_sessions[key] = study_session
		return economy_success(action, resident, {
			"type": "school_study_started", "quiz_id": quiz_id, "skill": skill_name, 
			"questions": public_school_study_questions(questions), 
			"required_correct": SCHOOL_STUDY_REQUIRED_CORRECT, "max_level": max_level, 
		})

	var current: = school_study_session_for(account_id, slot_index)
	if current.is_empty():
		return economy_error(action, "NO_STUDY_SESSION", "There is no active authoritative classroom assessment.", resident, String(request.get("transaction_id", "")))
	if String(request.get("quiz_id", "")) != String(current.get("quiz_id", "")) or desk_instance_id != String(current.get("desk_instance_id", "")):
		return economy_error(action, "STUDY_SESSION_MISMATCH", "That assessment does not match the active classroom file.", resident, String(request.get("transaction_id", "")))
	var now_ms: = transaction_now_ms(request)
	if now_ms - int(current.get("started_at_ms", now_ms)) > SCHOOL_STUDY_TIMEOUT_MS:
		school_study_sessions.erase(key)
		return economy_error(action, "STUDY_SESSION_EXPIRED", "That classroom assessment expired before it was filed.", resident, String(request.get("transaction_id", "")))
	var submitted_answers: Variant = request.get("answers", [])
	var questions: Array = current.get("questions", [])
	if submitted_answers is not Array or (submitted_answers as Array).size() != questions.size():
		return economy_error(action, "INVALID_STUDY_ANSWERS", "The server requires one answer for every filed question.", resident, String(request.get("transaction_id", "")))
	var correct_count: = 0
	var point_change: = 0
	for index in range(questions.size()):
		var question: Dictionary = questions[index]
		var answer_index: = int((submitted_answers as Array)[index])
		var answers: Array = question.get("answers", [])
		if answer_index < 0 or answer_index >= answers.size():
			return economy_error(action, "INVALID_STUDY_ANSWERS", "A filed answer does not exist on that question.", resident, String(request.get("transaction_id", "")))
		if answer_index == int(question.get("correct", -1)):
			correct_count += 1
			point_change += Build9.temporary_question_reward(answers.size(), 2)
		else:
			point_change -= 2
	var updated: = resident.duplicate(true)
	updated["education_points"] = maxi(0, int(updated.get("education_points", 0)) + point_change)
	var passed: = correct_count >= int(current.get("required_correct", SCHOOL_STUDY_REQUIRED_CORRECT))
	var current_xp: = maxi(0, int(xp.get(skill_name, 0)))
	var ceiling_xp: = Rules.xp_for_level(max_level + 1) - 1
	var reward: = mini(SCHOOL_STUDY_XP, maxi(0, ceiling_xp - current_xp)) if passed and Rules.level_from_xp(current_xp) < max_level else 0
	if reward > 0:
		xp[skill_name] = current_xp + reward
		updated["xp"] = xp
	school_study_sessions.erase(key)
	store_school_training_resident(account_id, slot_index, updated)
	economy_event_sequence += 1
	var complete_audit: = {
		"event_sequence": economy_event_sequence, "type": "school_study_completed", 
		"quiz_id": current.get("quiz_id", ""), "skill": skill_name, 
		"correct_count": correct_count, "question_count": questions.size(), 
		"required_correct": current.get("required_correct", SCHOOL_STUDY_REQUIRED_CORRECT), 
		"passed": passed, "point_change": point_change, "xp_awarded": reward, 
		"max_level": max_level, "account_id": safe_tester_id(account_id), 
		"resident_slot": slot_index, "world_id": server_world_id, "server_unix_ms": now_ms, 
	}
	economy_audit_log.append(complete_audit)
	return economy_success(action, updated, complete_audit)

func school_room_max_level(area_name: String, room_name: String) -> int:
	for room_variant in Build10.ROOM_LAYOUTS.get(area_name, []):
		if room_variant is Dictionary and String((room_variant as Dictionary).get("id", "")) == room_name:
			return maxi(1, int((room_variant as Dictionary).get("skill_max_level", 5)))
	return 5

func authoritative_school_record(area_name: String, room_name: String, instance_id: String, action_id: String) -> Dictionary:
	if area_name != "school" or instance_id.is_empty():
		return {}
	var room_key: = "%s:%s" % [area_name, room_name]
	if not admin_room_is_known(room_key):
		return {}
	for record in admin_room_source(room_key):
		if String(record.get("instance_id", "")) == instance_id and String(record.get("action_id", "")) == action_id:
			return record.duplicate(true)
	return {}

func store_school_training_resident(account_id: String, slot_index: int, resident: Dictionary) -> void :
	var roster: = account_roster(account_id)
	roster["slots"][slot_index] = resident.duplicate(true)
	roster["active_slot"] = slot_index
	persistent_profiles[safe_tester_id(account_id)] = ReleaseSave.normalize_roster(roster)
	profiles_dirty = true

func school_training_location_state(account_id: String, slot_index: int, resident: Dictionary) -> Dictionary:
	var state: = connected_state_for_resident(account_id, slot_index)
	return state if not state.is_empty() else resident.duplicate(true)

func validate_school_training_resident(action: String, resident: Dictionary, state: Dictionary) -> Dictionary:
	if String(state.get("phase", resident.get("phase", "adult"))) != "adult" or bool(state.get("downed", false)) or bool(state.get("deceased", false)) or bool(state.get("detained", false)) or bool(state.get("arrested", false)):
		return economy_error(action, "RESIDENT_UNAVAILABLE", "That Resident cannot complete classroom practice right now.", resident)
	if String(state.get("area", resident.get("area", ""))) != "school":
		return economy_error(action, "WRONG_LOCATION", "Classroom practice must remain inside the continuation school.", resident)
	return {}

func process_school_training_action(account_id: String, slot_index: int, resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var key: = school_training_key(account_id, slot_index)
	if action == "SCHOOL_TRAINING_CANCEL":
		var interrupted: = school_training_action_for(account_id, slot_index)
		if interrupted.is_empty():
			return economy_error(action, "NO_TRAINING_ACTION", "There is no active classroom drill to cancel.", resident, String(request.get("transaction_id", "")))
		school_training_actions.erase(key)
		economy_event_sequence += 1
		var cancel_audit: = {
			"event_sequence": economy_event_sequence, "type": "school_training_cancelled", 
			"skill": interrupted.get("skill", "Endurance"), "station_kind": interrupted.get("station_kind", ""), 
			"station_instance_id": interrupted.get("station_instance_id", ""), 
			"reason": String(request.get("reason", "INTERRUPTED")).left(64), 
			"account_id": safe_tester_id(account_id), "resident_slot": slot_index, 
			"world_id": server_world_id, "server_unix_ms": transaction_now_ms(request), 
		}
		economy_audit_log.append(cancel_audit)
		profiles_dirty = true
		return economy_success(action, resident, cancel_audit)

	var location_state: = school_training_location_state(account_id, slot_index, resident)
	var location_error: = validate_school_training_resident(action, resident, location_state)
	if not location_error.is_empty():
		return location_error
	var room_name: = String(location_state.get("room_id", resident.get("room_id", "")))

	if action == "SCHOOL_TRAINING_START":
		if room_name not in ["class_endurance", "gym_b"]:
			return economy_error(action, "WRONG_LOCATION", "Timed school practice must begin beside its continuation-school station.", resident)
		if not school_training_action_for(account_id, slot_index).is_empty():
			return economy_error(action, "TRAINING_IN_PROGRESS", "Finish the current classroom drill first.", resident)
		var station_instance_id: = String(request.get("station_instance_id", "")).strip_edges()
		var is_agility_gym: = room_name == "gym_b"
		var station_action_id: = "gym_obstacle" if is_agility_gym else "endurance_station"
		var skill_name: = "Agility" if is_agility_gym else "Endurance"
		var station: = authoritative_school_record("school", room_name, station_instance_id, station_action_id)
		if station.is_empty():
			return economy_error(action, "INVALID_TRAINING_STATION", "That school station is not on the current room record.", resident)
		var station_position: Vector2 = station.get("position", Vector2.ZERO) as Vector2
		var station_radius: = maxf(1.0, float(station.get("radius", 90.0)))
		var resident_position: = state_position(location_state)
		if resident_position.distance_to(station_position) > station_radius:
			return economy_error(action, "OUT_OF_REACH", "Stand beside the school station before starting the drill.", resident)
		var max_level: = school_room_max_level("school", room_name)
		var xp: Dictionary = Dictionary(resident.get("xp", {})).duplicate(true)
		if Rules.level_from_xp(maxi(0, int(xp.get(skill_name, 0)))) >= max_level:
			return economy_error(action, "TRAINING_LIMIT_REACHED", "%s school training stops at Level %d." % [skill_name, max_level], resident)
		var stamina_cost: = maxf(0.0, float(station.get("stamina", 0.0) if is_agility_gym else station.get("stamina_cost", 0.0)))
		var current_stamina: = maxf(0.0, float(resident.get("stamina", 100.0)))
		if not is_agility_gym and current_stamina + 0.001 < stamina_cost:
			return economy_error(action, "INSUFFICIENT_STAMINA", "Rest before starting this Endurance drill.", resident)
		var updated: = resident.duplicate(true)
		updated["stamina"] = maxf(0.0, current_stamina - stamina_cost)
		var now_ms: = transaction_now_ms(request)
		var station_kind: = String(station.get("obstacle_kind", "vault") if is_agility_gym else station.get("station_kind", "weighted_cart"))
		var duration_seconds: = float(SCHOOL_GYM_DURATIONS.get(station_kind, 1.45)) if is_agility_gym else maxf(0.5, float(station.get("duration_seconds", 3.5)))
		var training_action: = {
			"account_id": safe_tester_id(account_id), "resident_slot": slot_index, 
			"skill": skill_name, "station_kind": station_kind, 
			"station_instance_id": station_instance_id, "station_position": station_position, 
			"station_radius": station_radius, "initial_position": resident_position, 
			"initial_area": "school", "initial_room_id": room_name, 
			"duration_seconds": duration_seconds, "stamina_cost": stamina_cost, 
			"xp_reward": SCHOOL_GYM_PRACTICE_XP if is_agility_gym else maxi(0, int(station.get("xp_reward", 0))), 
			"training_id": String(station.get("training_id", station_instance_id)), 
			"movement_allowed": is_agility_gym, 
			"movement_radius": maxf(station_radius, SCHOOL_GYM_COMPLETION_RADIUS) if is_agility_gym else station_radius, 
			"max_level": max_level, "started_at_ms": now_ms, 
		}
		school_training_actions[key] = training_action
		store_school_training_resident(account_id, slot_index, updated)
		economy_event_sequence += 1
		var start_audit: = {
			"event_sequence": economy_event_sequence, "type": "school_training_started", 
			"skill": skill_name, "station_kind": training_action["station_kind"], 
			"station_instance_id": station_instance_id, "duration_seconds": training_action["duration_seconds"], 
			"stamina_cost": stamina_cost, "account_id": safe_tester_id(account_id), 
			"resident_slot": slot_index, "world_id": server_world_id, "server_unix_ms": now_ms, 
		}
		economy_audit_log.append(start_audit)
		return economy_success(action, updated, start_audit)

	if action == "SCHOOL_TRAINING_COMPLETE":
		var current: = school_training_action_for(account_id, slot_index)
		if current.is_empty():
			return economy_error(action, "NO_TRAINING_ACTION", "There is no active classroom drill to complete.", resident, String(request.get("transaction_id", "")))
		var requested_station: = String(request.get("station_instance_id", "")).strip_edges()
		if not requested_station.is_empty() and requested_station != String(current.get("station_instance_id", "")):
			return economy_error(action, "TRAINING_ACTION_MISMATCH", "That is not the active classroom drill.", resident, String(request.get("transaction_id", "")))
		var now_ms: = transaction_now_ms(request)
		var required_ms: = maxi(500, int(round(float(current.get("duration_seconds", 0.5)) * 1000.0)))
		if now_ms - int(current.get("started_at_ms", now_ms)) < required_ms:
			return economy_error(action, "TRAINING_NOT_READY", "The classroom drill has not reached its required time.", resident, String(request.get("transaction_id", "")))
		var connected_state: = connected_state_for_resident(account_id, slot_index)
		if connected_state.is_empty():
			return economy_error(action, "RESIDENT_DISCONNECTED", "The Resident left before the classroom drill completed.", resident, String(request.get("transaction_id", "")))
		var completion_error: = validate_school_training_resident(action, resident, connected_state)
		if not completion_error.is_empty():
			return completion_error
		if String(connected_state.get("room_id", "")) != String(current.get("initial_room_id", "")):
			return economy_error(action, "WRONG_LOCATION", "Leaving the classroom cancels the unfinished drill.", resident, String(request.get("transaction_id", "")))
		var station_position: Vector2 = current.get("station_position", Vector2.ZERO) as Vector2
		var moved_outside_training: = state_position(connected_state).distance_to(station_position) > float(current.get("movement_radius", current.get("station_radius", 90.0)))
		if not bool(current.get("movement_allowed", false)):
			var initial_position: Vector2 = current.get("initial_position", Vector2.ZERO) as Vector2
			moved_outside_training = moved_outside_training or state_position(connected_state).distance_to(initial_position) > SCHOOL_TRAINING_POSITION_TOLERANCE
		if moved_outside_training:
			return economy_error(action, "TRAINING_INTERRUPTED", "Moving away cancels the unfinished classroom drill.", resident, String(request.get("transaction_id", "")))
		var updated: = resident.duplicate(true)
		var xp: Dictionary = Dictionary(updated.get("xp", {})).duplicate(true)
		var skill_name: = String(current.get("skill", "Endurance"))
		var current_xp: = maxi(0, int(xp.get(skill_name, 0)))
		var max_level: = maxi(1, int(current.get("max_level", 5)))
		var ceiling_xp: = Rules.xp_for_level(max_level + 1) - 1
		var repeated_obstacle: = false
		var training_id: = String(current.get("training_id", current.get("station_instance_id", "")))
		if skill_name == "Agility":
			repeated_obstacle = not training_id.is_empty() and training_id == String(updated.get("school_agility_last_obstacle_id", ""))
			updated["school_agility_last_obstacle_id"] = training_id
		var reward: = 0 if repeated_obstacle or Rules.level_from_xp(current_xp) >= max_level else mini(maxi(0, int(current.get("xp_reward", 0))), maxi(0, ceiling_xp - current_xp))
		if reward > 0:
			xp[skill_name] = current_xp + reward
			updated["xp"] = xp
		school_training_actions.erase(key)
		store_school_training_resident(account_id, slot_index, updated)
		economy_event_sequence += 1
		var complete_audit: = {
			"event_sequence": economy_event_sequence, "type": "school_training_completed", 
			"skill": skill_name, "station_kind": current.get("station_kind", ""), 
			"station_instance_id": current.get("station_instance_id", ""), "xp_awarded": reward, 
			"training_id": training_id, "repeated_obstacle": repeated_obstacle, 
			"max_level": max_level, "duration_seconds": current.get("duration_seconds", 0.0), 
			"account_id": safe_tester_id(account_id), "resident_slot": slot_index, 
			"world_id": server_world_id, "server_unix_ms": now_ms, 
		}
		economy_audit_log.append(complete_audit)
		return economy_success(action, updated, complete_audit)

	if action in ["SCHOOL_PRACTICE_KIT", "SCHOOL_DUMMY_RESET", "SCHOOL_DUMMY_OUTCOME"]:
		if room_name != "class_firearms":
			return economy_error(action, "WRONG_LOCATION", "This classroom practice is available only beside its room-owned dummy.", resident)
		var practice_state: = school_practice_state_for(account_id, slot_index)
		if action == "SCHOOL_PRACTICE_KIT":
			practice_state["kit_issued"] = true
			practice_state["dummy_state"] = "ready"
			school_practice_states[key] = practice_state
			return economy_success(action, resident, {"type": "school_practice_kit_issued", "dummy_state": "ready"})
		var dummy_instance_id: = String(request.get("dummy_instance_id", "")).strip_edges()
		var dummy: = authoritative_school_record("school", room_name, dummy_instance_id, "firearms_disposition_dummy")
		if dummy.is_empty():
			return economy_error(action, "INVALID_PRACTICE_DUMMY", "That classroom dummy is not on the current room record.", resident)
		var dummy_position: Vector2 = dummy.get("position", Vector2.ZERO) as Vector2
		if state_position(location_state).distance_to(dummy_position) > maxf(1.0, float(dummy.get("radius", 90.0))):
			return economy_error(action, "OUT_OF_REACH", "Stand beside the classroom dummy before using the practice kit.", resident)
		if not bool(practice_state.get("kit_issued", false)):
			return economy_error(action, "PRACTICE_KIT_REQUIRED", "Speak with the classroom teacher before using the practice dummy.", resident)
		if action == "SCHOOL_DUMMY_RESET":
			practice_state["dummy_state"] = "ready"
			school_practice_states[key] = practice_state
			return economy_success(action, resident, {"type": "school_dummy_reset", "dummy_state": "ready"})
		var outcome_id: = String(request.get("outcome_id", "")).to_lower()
		if outcome_id not in SCHOOL_DUMMY_OUTCOMES:
			return economy_error(action, "INVALID_PRACTICE_OUTCOME", "That outcome is not part of the current classroom exercise.", resident)
		var current_dummy_state: = String(practice_state.get("dummy_state", "ready"))
		if outcome_id == "down":
			if current_dummy_state != "ready":
				return economy_error(action, "PRACTICE_SEQUENCE_INVALID", "Reset the classroom dummy before starting another sequence.", resident)
			practice_state["dummy_state"] = "downed"
		elif current_dummy_state != "downed":
			return economy_error(action, "PRACTICE_SEQUENCE_INVALID", "Complete the first classroom step before selecting that outcome.", resident)
		else:
			practice_state["dummy_state"] = outcome_id
		var completed: Dictionary = Dictionary(practice_state.get("completed_outcomes", {})).duplicate(true)
		var already_completed: = bool(completed.get(outcome_id, false))
		var updated: = resident.duplicate(true)
		var xp: Dictionary = Dictionary(updated.get("xp", {})).duplicate(true)
		var current_xp: = maxi(0, int(xp.get("Firearms", 0)))
		var max_level: = school_room_max_level("school", room_name)
		var ceiling_xp: = Rules.xp_for_level(max_level + 1) - 1
		var reward: = 0
		if not already_completed and Rules.level_from_xp(current_xp) < max_level:
			reward = mini(SCHOOL_DUMMY_PRACTICE_XP, maxi(0, ceiling_xp - current_xp))
		if reward > 0:
			xp["Firearms"] = current_xp + reward
			updated["xp"] = xp
			completed[outcome_id] = true
		practice_state["completed_outcomes"] = completed
		school_practice_states[key] = practice_state
		store_school_training_resident(account_id, slot_index, updated)
		economy_event_sequence += 1
		var outcome_audit: = {
			"event_sequence": economy_event_sequence, "type": "school_dummy_outcome", 
			"outcome_id": outcome_id, "dummy_state": practice_state["dummy_state"], 
			"xp_awarded": reward, "already_completed": already_completed, 
			"max_level": max_level, "account_id": safe_tester_id(account_id), 
			"resident_slot": slot_index, "world_id": server_world_id, 
			"server_unix_ms": transaction_now_ms(request), 
		}
		economy_audit_log.append(outcome_audit)
		return economy_success(action, updated, outcome_audit)

	if action == "SCHOOL_STEALTH_ATTEMPT":
		if room_name != "class_stealth":
			return economy_error(action, "WRONG_LOCATION", "This practice envelope is available only beside the continuation-school Stealth teacher.", resident, String(request.get("transaction_id", "")))
		var teacher_instance_id: = String(request.get("teacher_instance_id", "")).strip_edges()
		var teacher: = authoritative_school_record("school", room_name, teacher_instance_id, "school_teacher")
		if teacher.is_empty() or String(teacher.get("skill_name", "")) != "Stealth":
			return economy_error(action, "INVALID_PRACTICE_TEACHER", "That is not the room-owned Stealth teacher.", resident, String(request.get("transaction_id", "")))
		var teacher_position: Vector2 = teacher.get("position", Vector2.ZERO) as Vector2
		if state_position(location_state).distance_to(teacher_position) > maxf(220.0, float(teacher.get("radius", 90.0))):
			return economy_error(action, "OUT_OF_REACH", "Stand beside the Stealth teacher before attempting the marked practice envelope.", resident, String(request.get("transaction_id", "")))
		var practice_state: = school_practice_state_for(account_id, slot_index)
		var now_ms: = transaction_now_ms(request)
		var ready_at_ms: = maxi(0, int(practice_state.get("stealth_ready_at_ms", 0)))
		if now_ms < ready_at_ms:
			return economy_error(action, "PRACTICE_COOLDOWN", "Wait %.1f seconds before another classroom attempt." % (float(ready_at_ms - now_ms) / 1000.0), resident, String(request.get("transaction_id", "")))
		practice_state["stealth_ready_at_ms"] = now_ms + SCHOOL_STEALTH_ATTEMPT_COOLDOWN_MS
		school_practice_states[key] = practice_state
		var xp: Dictionary = Dictionary(resident.get("xp", {}))
		var stealth_level: = Rules.level_from_xp(maxi(0, int(xp.get("Stealth", 0))))
		var success_chance: = minf(0.9, float(stealth_level) / SCHOOL_STEALTH_TEACHER_DEFENSE)
		var server_roll: = clampf(float(request.get("server_roll", 0.0)), 0.0, 1.0) if bool(request.get("test_roll_override", false)) and server_world_id == LOCAL_TEST_WORLD_ID else combat_rng.randf()
		var succeeded: = server_roll < success_chance
		var updated: = resident.duplicate(true)
		if succeeded:
			updated["carried_cash_clean"] = maxi(0, int(updated.get("carried_cash_clean", 0))) + SCHOOL_STEALTH_ENVELOPE_CENTS
			sync_legacy_money_aliases(updated)
		store_school_training_resident(account_id, slot_index, updated)
		economy_event_sequence += 1
		var attempt_audit: = {
			"event_sequence": economy_event_sequence, "type": "school_stealth_attempt", 
			"skill": "Stealth", "teacher_instance_id": teacher_instance_id, 
			"teacher_defense": SCHOOL_STEALTH_TEACHER_DEFENSE, "stealth_level": stealth_level, 
			"success_chance": success_chance, "server_roll": server_roll, "success": succeeded, 
			"amount_cents": SCHOOL_STEALTH_ENVELOPE_CENTS if succeeded else 0, 
			"cooldown_seconds": float(SCHOOL_STEALTH_ATTEMPT_COOLDOWN_MS) / 1000.0, 
			"account_id": safe_tester_id(account_id), "resident_slot": slot_index, 
			"world_id": server_world_id, "server_unix_ms": now_ms, 
		}
		economy_audit_log.append(attempt_audit)
		return economy_success(action, updated, attempt_audit)

	return economy_error(action, "UNKNOWN_ACTION", "The school ledger does not recognize that classroom request.", resident)

func school_training_internal_transaction_id(account_id: String, slot_index: int, suffix: String) -> String:
	return "TXN-%s-%s-%d-SCHOOL-%s-%d" % [server_world_id, safe_tester_id(account_id), slot_index, suffix, Time.get_ticks_msec()]

func interrupt_school_training(account_id: String, slot_index: int, reason: String) -> Dictionary:
	if school_training_action_for(account_id, slot_index).is_empty():
		return {}
	return process_economy_request_atomically(account_id, slot_index, {
		"action": "SCHOOL_TRAINING_CANCEL", "reason": reason.left(64), 
		"world_id": server_world_id, "account_id": safe_tester_id(account_id), 
		"resident_slot": slot_index, 
		"transaction_id": school_training_internal_transaction_id(account_id, slot_index, "CANCEL"), 
	})

func interrupt_school_training_for_peer(peer_id: int, reason: String) -> Dictionary:
	var state: Dictionary = peer_states.get(peer_id, {})
	if state.is_empty():
		return {}
	var account_id: = safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", ""))))
	return interrupt_school_training(account_id, int(state.get("resident_slot", -1)), reason)

func update_active_school_training(_delta: float) -> void :
	if not hosting:
		return
	var now_ms: = int(Time.get_unix_time_from_system() * 1000.0)
	for key_variant in school_training_actions.keys().duplicate():
		var current_value: Variant = school_training_actions.get(key_variant, {})
		if current_value is not Dictionary:
			continue
		var current: Dictionary = current_value as Dictionary
		var account_id: = safe_tester_id(String(current.get("account_id", "")))
		var slot_index: = int(current.get("resident_slot", -1))
		var state: = connected_state_for_resident(account_id, slot_index)
		var reason: = ""
		if state.is_empty():
			reason = "DISCONNECTED"
		elif String(state.get("phase", "adult")) != "adult":
			reason = "PHASE_CHANGED"
		elif bool(state.get("downed", false)) or bool(state.get("deceased", false)) or bool(state.get("detained", false)) or bool(state.get("arrested", false)):
			reason = "RESIDENT_UNAVAILABLE"
		elif String(state.get("area", "")) != String(current.get("initial_area", "")) or String(state.get("room_id", "")) != String(current.get("initial_room_id", "")):
			reason = "ROOM_CHANGED"
		else:
			if bool(current.get("movement_allowed", false)):
				var station_position: Vector2 = current.get("station_position", Vector2.ZERO) as Vector2
				if state_position(state).distance_to(station_position) > float(current.get("movement_radius", SCHOOL_GYM_COMPLETION_RADIUS)):
					reason = "MOVED"
			else:
				var initial_position: Vector2 = current.get("initial_position", Vector2.ZERO) as Vector2
				if state_position(state).distance_to(initial_position) > SCHOOL_TRAINING_POSITION_TOLERANCE:
					reason = "MOVED"
		var expires_at_ms: = int(current.get("started_at_ms", now_ms)) + int(round((float(current.get("duration_seconds", 0.5)) + SCHOOL_TRAINING_COMPLETION_GRACE_SECONDS) * 1000.0))
		if reason.is_empty() and now_ms > expires_at_ms:
			reason = "COMPLETION_TIMEOUT"
		if not reason.is_empty():
			interrupt_school_training(account_id, slot_index, reason)

func validate_transaction_id(transaction_id: String, request_world: String, account_id: String, slot_index: int) -> Dictionary:
	var prefix: = "TXN-%s-%s-%d-" % [request_world, account_id, slot_index]
	if transaction_id.is_empty() or not transaction_id.begins_with(prefix):
		return {"code": "INVALID_TRANSACTION_ID", "message": "That transaction ID does not match this Resident."}
	return {}

func transaction_now_ms(request: Dictionary) -> int:
	if bool(request.get("test_clock_override", false)) and server_world_id == LOCAL_TEST_WORLD_ID:
		return maxi(0, int(request.get("server_now_ms", 0)))
	return int(Time.get_unix_time_from_system() * 1000.0)

func prior_transaction_outcome(resident: Dictionary, transaction_id: String, now_ms: int) -> Dictionary:
	var processed: Dictionary = resident.get("processed_transactions", {})
	var record: Variant = processed.get(transaction_id, null)
	if record is not Dictionary:
		return {}
	if now_ms - int((record as Dictionary).get("processed_at_ms", 0)) >= TRANSACTION_TTL_MS:
		return {}
	var outcome: Variant = (record as Dictionary).get("outcome", {})
	return (outcome as Dictionary).duplicate(true) if outcome is Dictionary else {}

func record_transaction_outcome(account_id: String, slot_index: int, transaction_id: String, result: Dictionary, now_ms: int) -> Dictionary:
	if transaction_id.is_empty():
		return result
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return result
	var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var processed: Dictionary = resident.get("processed_transactions", {})
	for key_variant in processed.keys():
		var key: = String(key_variant)
		var record: Dictionary = processed[key]
		if now_ms - int(record.get("processed_at_ms", 0)) >= TRANSACTION_TTL_MS:
			processed.erase(key)
	var stored_outcome: = result.duplicate(true)
	stored_outcome.erase("resident")
	stored_outcome.erase("target_resident")
	stored_outcome.erase("_affected_residents")
	stored_outcome["transaction_id"] = transaction_id
	processed[transaction_id] = {"processed_at_ms": now_ms, "outcome": stored_outcome}
	resident["processed_transactions"] = processed
	server_roster["slots"][slot_index] = resident
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	result["transaction_id"] = transaction_id
	return result

func process_cashier_action(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return economy_error(action, "RESIDENT_NOT_FOUND", "The city could not find that Resident file.", {})
	var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var result: = validate_and_apply_cashier_action(resident, account_id, slot_index, request)
	if not bool(result.get("ok", false)):
		return result
	var updated: Dictionary = result.get("resident", {})
	server_roster["slots"][slot_index] = updated
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: Dictionary = Dictionary(result.get("audit", {})).duplicate(true)
	audit["event_sequence"] = economy_event_sequence
	audit["account_id"] = account_id
	audit["resident_slot"] = slot_index
	audit["world_id"] = server_world_id
	audit["server_unix_ms"] = transaction_now_ms(request)
	economy_audit_log.append(audit)
	result["audit"] = audit
	return result

func validate_and_apply_cashier_action(resident: Dictionary, account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var updated: = resident.duplicate(true)
	var employment: = cashier_employment_record(updated)
	match action:
		"CASHIER_ACCEPT":
			if String(updated.get("area", "")) != "store" or String(updated.get("room_id", "")) != "sales":
				return economy_error(action, "WRONG_LOCATION", "Boss hires from the sales floor.", resident)
			if not employment.is_empty() and String(employment.get("status", "")) == "active":
				return economy_error(action, "ALREADY_EMPLOYED", "Boss already has your shift on file.", resident)
			updated["cashier_shift_sequence"] = int(updated.get("cashier_shift_sequence", 0)) + 1
			employment = {
				"job_id": "boss_cashier", "employer_id": "boss_store", "status": "active", 
				"shift_id": next_cashier_shift_id(account_id, slot_index, updated), 
				"completed_tasks": [], "deposit_issued": false, "trust": 20, 
				"last_outcome": "", "warnings": 0, "active_play_absence_seconds": 0.0, 
			}
			var credentials: Array = updated.get("credentials", [])
			if "Store Employee Credential" not in credentials:
				credentials.append("Store Employee Credential")
			updated["credentials"] = credentials
			set_cashier_employment_record(updated, employment)
			return economy_success(action, updated, {"type": "cashier_accept", "shift_id": employment["shift_id"]})
		"CASHIER_TASK_ASSIGN":
			if not cashier_employment_active(employment):
				return economy_error(action, "NOT_EMPLOYED", "Boss does not have an active shift for you.", resident)
			if String(updated.get("area", "")) != "store":
				return economy_error(action, "WRONG_LOCATION", "Boss assigns work inside the store.", resident)
			if not cashier_assignment.is_empty():
				if String(cashier_assignment.get("account_id", "")) == account_id and int(cashier_assignment.get("resident_slot", -1)) == slot_index:
					return economy_success(action, updated, {"type": "cashier_task_assigned", "task_id": cashier_assignment.get("task_id", "")})
				return economy_error(action, "TASK_ALREADY_ASSIGNED", "Boss has one assignment out at a time.", resident)
			var completed_tasks: Array = employment.get("completed_tasks", [])
			var available: Array[String] = []
			for task_id in ["register", "stock", "clean"]:
				if task_id not in completed_tasks:
					available.append(task_id)
			if available.is_empty():
				return economy_error(action, "SHIFT_TASKS_COMPLETE", "The safe is the next assignment.", resident)
			var selected_task: = available[0]
			cashier_assignment = {"account_id": account_id, "resident_slot": slot_index, "task_id": selected_task, "shift_id": employment.get("shift_id", "")}
			return economy_success(action, updated, {"type": "cashier_task_assigned", "task_id": selected_task})
		"CASHIER_TASK_COMPLETE":
			if not cashier_employment_active(employment):
				return economy_error(action, "NOT_EMPLOYED", "Boss does not have an active shift for you.", resident)
			var task_id: = String(request.get("task_id", ""))
			if cashier_assignment.is_empty() or String(cashier_assignment.get("account_id", "")) != account_id or int(cashier_assignment.get("resident_slot", -1)) != slot_index or String(cashier_assignment.get("task_id", "")) != task_id:
				return economy_error(action, "TASK_NOT_ASSIGNED", "Boss did not assign that task to you.", resident)
			var expected_room: = String(CASHIER_TASK_ROOMS.get(task_id, ""))
			if "%s:%s" % [String(updated.get("area", "")), String(updated.get("room_id", ""))] != expected_room:
				return economy_error(action, "WRONG_LOCATION", "That assignment belongs in another room.", resident)
			if not bool(request.get("interaction_sequence_valid", false)):
				return economy_error(action, "INVALID_TASK_SEQUENCE", "The task was not completed through its full interaction.", resident)
			var completed_tasks: Array = employment.get("completed_tasks", [])
			if task_id in completed_tasks:
				return economy_error(action, "TASK_ALREADY_COMPLETED", "That task is already filed.", resident)
			completed_tasks.append(task_id)
			employment["completed_tasks"] = completed_tasks
			set_cashier_employment_record(updated, employment)
			var work_experience: Dictionary = updated.get("work_experience", {})
			work_experience["boss_cashier"] = int(work_experience.get("boss_cashier", 0)) + 1
			updated["work_experience"] = work_experience
			var xp: Dictionary = updated.get("xp", {})
			xp["Enterprise"] = int(xp.get("Enterprise", 0)) + 25
			updated["xp"] = xp
			updated["bank_balance_clean"] = int(updated.get("bank_balance_clean", 0)) + CASHIER_TASK_WAGE_CENTS
			sync_legacy_money_aliases(updated)
			cashier_assignment.clear()
			return economy_success(action, updated, {"type": "cashier_task_completed", "task_id": task_id, "amount_cents": CASHIER_TASK_WAGE_CENTS, "xp": 25})
		"CASHIER_TASK_RELEASE":
			if cashier_assignment.is_empty():
				return economy_success(action, updated, {"type": "cashier_task_released", "task_id": ""})
			if String(cashier_assignment.get("account_id", "")) != account_id or int(cashier_assignment.get("resident_slot", -1)) != slot_index:
				return economy_error(action, "WRONG_OWNER", "That assignment belongs to another Cashier.", resident)
			var released_task: = String(cashier_assignment.get("task_id", ""))
			cashier_assignment.clear()
			return economy_success(action, updated, {"type": "cashier_task_released", "task_id": released_task})
		"CASHIER_SAFE_ACCESS":
			if not cashier_employment_active(employment):
				return economy_error(action, "NOT_EMPLOYED", "Boss does not have an active shift for you.", resident)
			if String(updated.get("area", "")) != "store" or String(updated.get("room_id", "")) != "safe":
				return economy_error(action, "WRONG_LOCATION", "The deposit safe is in Boss's safe room.", resident)
			if resident_saved_position(updated).distance_to(Vector2(485.0, 215.0)) > 150.0:
				return economy_error(action, "OUT_OF_RANGE", "The deposit safe is a little closer.", resident)
			if Array(employment.get("completed_tasks", [])).size() < 3:
				return economy_error(action, "INSUFFICIENT_TASKS", "Complete all three shift tasks first.", resident)
			if bool(employment.get("deposit_issued", false)):
				return economy_error(action, "DEPOSIT_ALREADY_ISSUED", "This shift's deposit is already out.", resident)
			if not add_inventory_quantity(updated, "sealed_deposit_boss", 1):
				return economy_error(action, "INVENTORY_FULL", "Make room before taking responsibility for the deposit.", resident)
			var nonce: = next_handoff_nonce(account_id, slot_index)
			var handoff: = {
				"id": "sealed_deposit_boss", "display_name": "Sealed Deposit Bag", "state": "carried", 
				"authority_nonce": nonce, "owner_tester_id": account_id, "owner_resident_slot": slot_index, 
				"owner_world_id": server_world_id, "source_area": "store", "source_room_id": "safe", 
				"destination_area": "bank", "destination_room_id": "lobby", "deposit_box_id": "job_deposit_box", 
				"active_seconds_remaining": CASHIER_DEPOSIT_ACTIVE_SECONDS, "expired": false, "tampered": false, 
				"sealed_value_cents": CASHIER_DEPOSIT_VALUE_CENTS, "payment_cents": CASHIER_DELIVERY_BONUS_CENTS, 
				"shift_id": employment.get("shift_id", ""), "custody_events": [], 
			}
			var handoffs: Array = updated.get("active_handoffs", [])
			handoffs.append(handoff)
			updated["active_handoffs"] = handoffs
			employment["deposit_issued"] = true
			set_cashier_employment_record(updated, employment)
			return economy_success(action, updated, {"type": "cashier_deposit_issued", "nonce": nonce, "amount_hidden": true})
		"HANDOFF_BREAK_SEAL":
			var nonce: = String(request.get("nonce", ""))
			var handoff_result: = remove_owned_active_handoff(updated, nonce)
			if handoff_result.is_empty():
				return economy_error(action, "HANDOFF_NOT_FOUND", "That sealed deposit is not in your custody.", resident)
			var handoff: Dictionary = handoff_result["handoff"]
			updated = handoff_result["resident"]
			var value_cents: = maxi(0, int(handoff.get("sealed_value_cents", 0)))
			updated["carried_cash_dirty"] = int(updated.get("carried_cash_dirty", 0)) + value_cents
			var evidence: Array = updated.get("evidence_history", [])
			evidence.append(EvidenceRecords.inventory_evidence_record(
				"%s-INVENTORY-%s" % [server_world_id, nonce], "sealed_deposit_tamper", account_id, slot_index, 
				account_id, slot_index, String(updated.get("area", "")), String(updated.get("room_id", "")), 
				["sealed_deposit_boss"], value_cents, {"nonce": nonce}, transaction_now_ms(request)
			))
			updated["evidence_history"] = evidence
			var custody_events: Array = handoff.get("custody_events", [])
			custody_events.append({"type": "seal_broken", "account_id": account_id, "resident_slot": slot_index, "server_unix_ms": transaction_now_ms(request)})
			handoff["custody_events"] = custody_events
			handoff["state"] = "tampered"
			handoff["tampered"] = true
			var completed: Dictionary = updated.get("completed_handoffs", {})
			completed[nonce] = handoff
			updated["completed_handoffs"] = completed
			if not employment.is_empty() and String(handoff.get("original_cashier_account_id", account_id)) == account_id:
				employment["last_outcome"] = "embezzled"
				employment["trust"] = maxi(0, int(employment.get("trust", 20)) - 20)
				set_cashier_employment_record(updated, employment)
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {"type": "sealed_deposit_broken", "nonce": nonce, "amount_cents": value_cents})
		_:
			return economy_error(action, "UNKNOWN_ACTION", "The ledger does not recognize that request.", resident)

func cashier_employment_record(resident: Dictionary) -> Dictionary:
	for record_variant in resident.get("employment", []):
		if record_variant is Dictionary and String((record_variant as Dictionary).get("job_id", "")) == "boss_cashier":
			return (record_variant as Dictionary).duplicate(true)
	return {}

func set_cashier_employment_record(resident: Dictionary, employment_record: Dictionary) -> void :
	var employment: Array = resident.get("employment", [])
	for index in range(employment.size()):
		if employment[index] is Dictionary and String((employment[index] as Dictionary).get("job_id", "")) == "boss_cashier":
			employment[index] = employment_record
			resident["employment"] = employment
			return
	employment.append(employment_record)
	resident["employment"] = employment

func cashier_employment_active(employment: Dictionary) -> bool:
	return not employment.is_empty() and String(employment.get("status", "")) == "active"

func process_service_action(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return economy_error(action, "RESIDENT_NOT_FOUND", "The city could not find that Resident file.", {})
	var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var result: = validate_and_apply_service_action(resident, account_id, slot_index, request)
	if not bool(result.get("ok", false)):
		return result
	server_roster["slots"][slot_index] = Dictionary(result.get("resident", {}))
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: Dictionary = Dictionary(result.get("audit", {})).duplicate(true)
	audit["event_sequence"] = economy_event_sequence
	audit["account_id"] = account_id
	audit["resident_slot"] = slot_index
	audit["world_id"] = server_world_id
	audit["server_unix_ms"] = transaction_now_ms(request)
	economy_audit_log.append(audit)
	result["audit"] = audit
	return result

func service_job_definition(employer_id: String) -> Dictionary:
	return Dictionary(SERVICE_JOBS.get(employer_id.to_lower(), {})).duplicate(true)

func service_employment_record(resident: Dictionary, employer_id: String) -> Dictionary:
	var definition: = service_job_definition(employer_id)
	var job_id: = String(definition.get("job_id", ""))
	for record_variant in resident.get("employment", []):
		if record_variant is Dictionary and String((record_variant as Dictionary).get("job_id", "")) == job_id:
			return (record_variant as Dictionary).duplicate(true)
	return {}

func capone_employment_record(resident: Dictionary) -> Dictionary:
	for record_variant in resident.get("employment", []):
		if record_variant is Dictionary and String((record_variant as Dictionary).get("job_id", "")) == CAPONE_EMPLOYMENT_JOB_ID:
			return (record_variant as Dictionary).duplicate(true)
	return {}

func capone_task_definition(task_id: String) -> Dictionary:
	for task_variant in CAPONE_TASKS:
		if String(task_variant.get("id", "")) == task_id:
			return Dictionary(task_variant).duplicate(true)
	return {}

func set_capone_employment_record(resident: Dictionary, employment_record: Dictionary) -> void :
	var employment: Array = resident.get("employment", [])
	for index in range(employment.size()):
		if employment[index] is Dictionary and String((employment[index] as Dictionary).get("job_id", "")) == CAPONE_EMPLOYMENT_JOB_ID:
			employment[index] = employment_record
			resident["employment"] = employment
			return
	employment.append(employment_record)
	resident["employment"] = employment

func resident_is_criminal_path(resident: Dictionary) -> bool:
	if not Array(resident.get("crimes", [])).is_empty():
		return true
	return int(resident.get("carried_cash_dirty", 0)) > 0 or resident_has_any_moth_handoff(resident)

func append_capone_phone_message(resident: Dictionary, message: String) -> void :
	var messages_value: Variant = resident.get("phone_messages", [])
	var messages: Array = messages_value.duplicate(true) if messages_value is Array else []
	messages.append("Capone: %s" % message)
	while messages.size() > 30:
		messages.pop_front()
	resident["phone_messages"] = messages

func capone_failure_message(failure_count: int) -> String:
	match failure_count:
		1: return "You missed the assignment. Report in before the paperwork gets creative."
		2: return "Second missed assignment. One more and your contract becomes a historical document."
		_: return "Contract terminated for repeated missed assignments. Complete 30 fresh Moth runs before reapplying."

func advance_capone_task_timeout(resident: Dictionary, now_ms: int, force: bool = false) -> Dictionary:
	var employment: = capone_employment_record(resident)
	if employment.is_empty() or String(employment.get("status", "")) != "active":
		return {"changed": false, "employment": employment}
	var active_task: Dictionary = Dictionary(employment.get("active_task", {})).duplicate(true)
	if active_task.is_empty() or ( not force and now_ms < int(active_task.get("due_at_ms", 0))):
		return {"changed": false, "employment": employment}
	var failure_count: = int(employment.get("failure_count", 0)) + 1
	employment["failure_count"] = failure_count
	employment["warning_count"] = failure_count
	employment["last_outcome"] = "missed"
	employment["active_task"] = {}
	employment["last_failure_at_ms"] = now_ms
	var message: = capone_failure_message(failure_count)
	append_capone_phone_message(resident, message)
	if failure_count >= CAPONE_FAILURE_LIMIT:
		employment["status"] = "fired"
		resident["active_job"] = "None"
		employment["fired_at_ms"] = now_ms
		employment["requalification_start_runs"] = int(Dictionary(resident.get("dealer_relationships", {}).get(MothContent.DEALER_ID, {})).get("completed_runs", 0))
		employment["requalification_runs_required"] = CAPONE_MOTH_RUN_REQUIREMENT
		set_capone_employment_record(resident, employment)
		return {"changed": true, "employment": employment, "message": message, "fired": true}
	set_capone_employment_record(resident, employment)
	return {"changed": true, "employment": employment, "message": message, "fired": false}

func process_capone_action(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return economy_error(action, "RESIDENT_NOT_FOUND", "The city could not find that Resident file.", {})
	var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var result: = validate_and_apply_capone_action(resident, account_id, slot_index, request)
	if not bool(result.get("ok", false)):
		return result
	server_roster["slots"][slot_index] = Dictionary(result.get("resident", {}))
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: Dictionary = Dictionary(result.get("audit", {})).duplicate(true)
	audit["event_sequence"] = economy_event_sequence
	audit["account_id"] = account_id
	audit["resident_slot"] = slot_index
	audit["world_id"] = server_world_id
	audit["server_unix_ms"] = transaction_now_ms(request)
	economy_audit_log.append(audit)
	result["audit"] = audit
	return result

func validate_and_apply_capone_action(resident: Dictionary, account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var updated: = resident.duplicate(true)
	var now_ms: = transaction_now_ms(request)
	var current_room: = "%s:%s" % [String(updated.get("area", "")), String(updated.get("room_id", ""))]
	var employment: = capone_employment_record(updated)
	match action:
		"CAPONE_EMPLOYMENT_ACCEPT":
			if current_room != "laundromat:office":
				return economy_error(action, "WRONG_LOCATION", "Capone handles employment from the office desk.", resident)
			if not resident_is_criminal_path(updated):
				return economy_error(action, "PATH_REQUIRED", "Capone only hires Residents the city currently reads as Criminal.", resident)
			var relationship: = moth_relationship_record(updated)
			var completed_runs: = int(relationship.get("completed_runs", 0))
			if completed_runs < CAPONE_MOTH_RUN_REQUIREMENT:
				return economy_error(action, "MOTH_RUNS_REQUIRED", "Capone wants 30 completed Moth runs on the file before opening a desk assignment.", resident)
			if resident_has_active_employment(updated):
				return economy_error(action, "ALREADY_EMPLOYED", "Finish the active contract before taking Capone's assignment.", resident)
			if not employment.is_empty() and String(employment.get("status", "")) == "fired":
				var start_runs: = int(employment.get("requalification_start_runs", completed_runs))
				if completed_runs - start_runs < CAPONE_MOTH_RUN_REQUIREMENT:
					return economy_error(action, "REQUALIFICATION_REQUIRED", "Capone requires 30 fresh Moth runs after a firing before reconsidering the application.", resident)
			employment = {
				"job_id": CAPONE_EMPLOYMENT_JOB_ID, "employer_id": "capone", "employer": CAPONE_EMPLOYMENT_NAME, 
				"status": "active", "shift_id": "CAPONE-%s-%d-%d" % [account_id, slot_index, int(updated.get("capone_shift_sequence", 0)) + 1], 
				"completed_tasks": [], "active_task": {}, "task_sequence": 0, "failure_count": 0, "warning_count": 0, 
				"last_outcome": "accepted", "requalification_start_runs": 0, "requalification_runs_required": 0, 
			}
			updated["capone_shift_sequence"] = int(updated.get("capone_shift_sequence", 0)) + 1
			updated["active_job"] = "Capone Courier"
			set_capone_employment_record(updated, employment)
			append_capone_phone_message(updated, "Your desk assignment is active. Report to the office for a phone-directed task.")
			return economy_success(action, updated, {"type": "capone_employment_accepted", "shift_id": employment["shift_id"], "completed_runs": completed_runs})
		"CAPONE_TASK_ASSIGN":
			if employment.is_empty() or String(employment.get("status", "")) != "active":
				return economy_error(action, "NOT_EMPLOYED", "Capone has no active contract for this Resident.", resident)
			if current_room != "laundromat:office":
				return economy_error(action, "WRONG_LOCATION", "Return to Capone's office for the next phone-directed task.", resident)
			var timeout_result: = advance_capone_task_timeout(updated, now_ms)
			if bool(timeout_result.get("fired", false)):
				return economy_success(action, updated, {"type": "capone_employment_fired", "status": "fired", "phone_message": timeout_result.get("message", "")})
			employment = capone_employment_record(updated)
			var existing_task: Dictionary = Dictionary(employment.get("active_task", {}))
			if not existing_task.is_empty():
				return economy_success(action, updated, {"type": "capone_task_assigned", "task": existing_task, "phone_message": "The assignment remains active. The phone is not a suggestion."})
			var task_index: = posmod(int(employment.get("task_sequence", 0)), CAPONE_TASKS.size())
			var definition: = capone_task_definition(String(CAPONE_TASKS[task_index].get("id", "")))
			employment["task_sequence"] = int(employment.get("task_sequence", 0)) + 1
			var assigned_task: = definition.duplicate(true)
			assigned_task["assigned_at_ms"] = now_ms
			assigned_task["due_at_ms"] = now_ms + int(CAPONE_TASK_TIMEOUT_SECONDS * 1000.0)
			employment["active_task"] = assigned_task
			set_capone_employment_record(updated, employment)
			var assignment_message: = "Go to %s. Check your phone; the city has decided this is a reasonable workflow." % String(definition.get("label", "the assigned location"))
			append_capone_phone_message(updated, assignment_message)
			return economy_success(action, updated, {"type": "capone_task_assigned", "task": assigned_task, "phone_message": assignment_message})
		"CAPONE_TASK_STATUS":
			if employment.is_empty():
				return economy_error(action, "NOT_EMPLOYED", "Capone has no contract record for this Resident.", resident)
			var timeout_status: = advance_capone_task_timeout(updated, now_ms)
			employment = capone_employment_record(updated)
			return economy_success(action, updated, {"type": "capone_task_status", "task": employment.get("active_task", {}), "status": employment.get("status", ""), "phone_message": timeout_status.get("message", "")})
		"CAPONE_TASK_FAIL":
			if employment.is_empty() or String(employment.get("status", "")) != "active":
				return economy_error(action, "NOT_EMPLOYED", "Capone has no active contract for this Resident.", resident)
			if Dictionary(employment.get("active_task", {})).is_empty():
				return economy_error(action, "NO_ACTIVE_TASK", "There is no active Capone assignment to fail.", resident)
			var forced_failure: = advance_capone_task_timeout(updated, now_ms, true)
			return economy_success(action, updated, {"type": "capone_task_failed", "status": capone_employment_record(updated).get("status", ""), "phone_message": forced_failure.get("message", "")})
		"CAPONE_TASK_COMPLETE":
			if employment.is_empty() or String(employment.get("status", "")) != "active":
				return economy_error(action, "NOT_EMPLOYED", "Capone has no active contract for this Resident.", resident)
			var timeout_before_completion: = advance_capone_task_timeout(updated, now_ms)
			if bool(timeout_before_completion.get("changed", false)):
				var expired_employment: Dictionary = Dictionary(timeout_before_completion.get("employment", {}))
				return economy_success(action, updated, {
					"type": "capone_employment_fired" if bool(timeout_before_completion.get("fired", false)) else "capone_task_failed", 
					"status": String(expired_employment.get("status", "active")), 
					"phone_message": timeout_before_completion.get("message", ""), 
				})
			employment = capone_employment_record(updated)
			var active_task: Dictionary = Dictionary(employment.get("active_task", {}))
			var task_id: = String(request.get("task_id", ""))
			if active_task.is_empty() or task_id != String(active_task.get("id", "")):
				return economy_error(action, "TASK_NOT_ASSIGNED", "That Capone assignment is not active for this Resident.", resident)
			if String(request.get("recipient_actor_id", "")) != String(active_task.get("recipient_actor_id", "")):
				return economy_error(action, "WRONG_RECIPIENT", "The phone message names a different recipient.", resident)
			var task_point: Vector2 = active_task.get("point", Vector2.ZERO)
			if current_room != "%s:%s" % [String(active_task.get("area", "")), String(active_task.get("room_id", ""))] or resident_saved_position(updated).distance_to(task_point) > MothContent.INTERACTION_RADIUS:
				return economy_error(action, "WRONG_LOCATION", "The assigned recipient is not at this location.", resident)
			if not bool(request.get("interaction_sequence_valid", false)):
				return economy_error(action, "INVALID_TASK_SEQUENCE", "The recipient interaction did not complete through the authoritative path.", resident)
			var completed_tasks: Array = employment.get("completed_tasks", [])
			completed_tasks.append(task_id)
			employment["completed_tasks"] = completed_tasks
			employment["active_task"] = {}
			employment["last_outcome"] = "completed"
			set_capone_employment_record(updated, employment)
			var work_experience: Dictionary = updated.get("work_experience", {})
			work_experience[CAPONE_EMPLOYMENT_JOB_ID] = int(work_experience.get(CAPONE_EMPLOYMENT_JOB_ID, 0)) + 1
			updated["work_experience"] = work_experience
			var completion_message: = "Recipient confirmed. Report to the office when you are ready for another assignment."
			append_capone_phone_message(updated, completion_message)
			return economy_success(action, updated, {"type": "capone_task_completed", "task_id": task_id, "phone_message": completion_message})
		_:
			return economy_error(action, "UNKNOWN_ACTION", "The Capone desk does not recognize that request.", resident)

func set_service_employment_record(resident: Dictionary, employer_id: String, employment_record: Dictionary) -> void :
	var definition: = service_job_definition(employer_id)
	var job_id: = String(definition.get("job_id", ""))
	var employment: Array = resident.get("employment", [])
	for index in range(employment.size()):
		if employment[index] is Dictionary and String((employment[index] as Dictionary).get("job_id", "")) == job_id:
			employment[index] = employment_record
			resident["employment"] = employment
			return
	employment.append(employment_record)
	resident["employment"] = employment

func resident_has_active_employment(resident: Dictionary) -> bool:
	for record_variant in resident.get("employment", []):
		if record_variant is Dictionary and String((record_variant as Dictionary).get("status", "")) == "active":
			return true
	return false

func next_service_shift_id(account_id: String, slot_index: int, resident: Dictionary, employer_id: String) -> String:
	resident["service_shift_sequence"] = int(resident.get("service_shift_sequence", 0)) + 1
	return "SERVICE-%s-%s-%d-%d" % [employer_id, account_id, slot_index, int(resident["service_shift_sequence"])]

func service_employer_id_for_job(job_id: String) -> String:
	for employer_variant in SERVICE_JOBS.keys():
		var employer_id: = String(employer_variant)
		if String(Dictionary(SERVICE_JOBS[employer_id]).get("job_id", "")) == job_id:
			return employer_id
	return ""

func apply_service_handoff_outcome(resident: Dictionary, handoff: Dictionary, expired: bool) -> void :
	var employer_id: = service_employer_id_for_job(String(handoff.get("job_id", "")))
	if employer_id.is_empty():
		return
	var employment: = service_employment_record(resident, employer_id)
	if employment.is_empty():
		return
	employment["last_outcome"] = "expired" if expired else "delivered"
	employment["warnings"] = int(employment.get("warnings", 0)) + 1 if expired else int(employment.get("warnings", 0))
	employment["trust"] = maxi(0, int(employment.get("trust", 15)) - 5) if expired else mini(100, int(employment.get("trust", 15)) + 1)
	set_service_employment_record(resident, employer_id, employment)
	var xp: Dictionary = resident.get("xp", {})
	xp["Enterprise"] = int(xp.get("Enterprise", 0)) + (20 if expired else 45)
	resident["xp"] = xp

func validate_and_apply_service_action(resident: Dictionary, account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var employer_id: = String(request.get("employer_id", "")).to_lower()
	var definition: = service_job_definition(employer_id)
	if definition.is_empty():
		return economy_error(action, "UNKNOWN_EMPLOYER", "That employer is not on the server work ledger.", resident)
	var updated: = resident.duplicate(true)
	var employment: = service_employment_record(updated, employer_id)
	var current_room: = "%s:%s" % [String(updated.get("area", "")), String(updated.get("room_id", ""))]
	match action:
		"SERVICE_ACCEPT":
			if current_room != String(definition.get("start_room", "")):
				return economy_error(action, "WRONG_LOCATION", "That employer hires from its public work floor.", resident)
			if resident_has_active_employment(updated):
				return economy_error(action, "ALREADY_EMPLOYED", "Finish or leave the active contract before taking another shift.", resident)
			var credential: = "Alibi's Employee Credential" if employer_id == "alibis" else "Spin Cycle Employee Credential"
			var credentials: Array = updated.get("credentials", [])
			if credential not in credentials:
				credentials.append(credential)
			updated["credentials"] = credentials
			employment = {
				"job_id": definition["job_id"], "employer_id": employer_id, "status": "active", 
				"shift_id": next_service_shift_id(account_id, slot_index, updated, employer_id), "completed_tasks": [], 
				"deposit_issued": false, "trust": 15, "warnings": 0, "last_outcome": "", 
			}
			set_service_employment_record(updated, employer_id, employment)
			return economy_success(action, updated, {"type": "service_accept", "employer_id": employer_id, "shift_id": employment["shift_id"]})
		"SERVICE_TASK_ASSIGN":
			if not cashier_employment_active(employment):
				return economy_error(action, "NOT_EMPLOYED", "That employer has no active shift for you.", resident)
			var existing: Dictionary = Dictionary(service_assignments.get(employer_id, {}))
			if not existing.is_empty():
				if String(existing.get("account_id", "")) == account_id and int(existing.get("resident_slot", -1)) == slot_index:
					return economy_success(action, updated, {"type": "service_task_assigned", "employer_id": employer_id, "task_id": existing.get("task_id", ""), "variation": existing.get("variation", 0)})
				return economy_error(action, "TASK_ALREADY_ASSIGNED", "Another employee has that employer's active task.", resident)
			var available: Array[String] = []
			for task_variant in definition.get("tasks", []):
				var task_id: = String(task_variant)
				if task_id not in Array(employment.get("completed_tasks", [])):
					available.append(task_id)
			if available.is_empty():
				return economy_error(action, "SHIFT_TASKS_COMPLETE", "The deposit is the next assignment.", resident)
			var assignment_sequence: = int(updated.get("service_task_sequence", 0)) + 1
			updated["service_task_sequence"] = assignment_sequence
			var assigned_task: = available[0]
			service_assignments[employer_id] = {"account_id": account_id, "resident_slot": slot_index, "task_id": assigned_task, "variation": posmod(assignment_sequence - 1, 3), "shift_id": employment.get("shift_id", "")}
			return economy_success(action, updated, {"type": "service_task_assigned", "employer_id": employer_id, "task_id": assigned_task, "variation": posmod(assignment_sequence - 1, 3)})
		"SERVICE_TASK_COMPLETE":
			var assignment: Dictionary = Dictionary(service_assignments.get(employer_id, {}))
			var task_id: = String(request.get("task_id", ""))
			if assignment.is_empty() or String(assignment.get("account_id", "")) != account_id or int(assignment.get("resident_slot", -1)) != slot_index or String(assignment.get("task_id", "")) != task_id:
				return economy_error(action, "TASK_NOT_ASSIGNED", "That task is not assigned to this Resident.", resident)
			if current_room != String(Dictionary(definition.get("task_rooms", {})).get(task_id, "")):
				return economy_error(action, "WRONG_LOCATION", "That task belongs in another room.", resident)
			if not bool(request.get("interaction_sequence_valid", false)):
				return economy_error(action, "INVALID_TASK_SEQUENCE", "The task was not completed through its full interaction.", resident)
			var completed_tasks: Array = employment.get("completed_tasks", [])
			if task_id in completed_tasks:
				return economy_error(action, "TASK_ALREADY_COMPLETED", "That task is already on the shift record.", resident)
			completed_tasks.append(task_id)
			employment["completed_tasks"] = completed_tasks
			set_service_employment_record(updated, employer_id, employment)
			var work_experience: Dictionary = updated.get("work_experience", {})
			work_experience[String(definition["job_id"])] = int(work_experience.get(String(definition["job_id"]), 0)) + 1
			updated["work_experience"] = work_experience
			var xp: Dictionary = updated.get("xp", {})
			for skill_name in Dictionary(Dictionary(definition.get("task_xp", {})).get(task_id, {})):
				xp[String(skill_name)] = int(xp.get(String(skill_name), 0)) + int(Dictionary(Dictionary(definition.get("task_xp", {})).get(task_id, {})).get(skill_name, 0))
			updated["xp"] = xp
			updated["bank_balance_clean"] = int(updated.get("bank_balance_clean", 0)) + int(definition.get("task_wage_cents", 0))
			sync_legacy_money_aliases(updated)
			service_assignments.erase(employer_id)
			return economy_success(action, updated, {"type": "service_task_completed", "employer_id": employer_id, "task_id": task_id, "amount_cents": definition.get("task_wage_cents", 0)})
		"SERVICE_TASK_RELEASE":
			var active_assignment: Dictionary = Dictionary(service_assignments.get(employer_id, {}))
			if active_assignment.is_empty():
				return economy_success(action, updated, {"type": "service_task_released", "employer_id": employer_id})
			if String(active_assignment.get("account_id", "")) != account_id or int(active_assignment.get("resident_slot", -1)) != slot_index:
				return economy_error(action, "WRONG_OWNER", "That employer task belongs to another Resident.", resident)
			service_assignments.erase(employer_id)
			return economy_success(action, updated, {"type": "service_task_released", "employer_id": employer_id})
		"SERVICE_DEPOSIT_ISSUE":
			if current_room != String(definition.get("deposit_room", "")):
				return economy_error(action, "WRONG_LOCATION", "The sealed deposit is in the employer's designated room.", resident)
			if Array(employment.get("completed_tasks", [])).size() != Array(definition.get("tasks", [])).size():
				return economy_error(action, "INSUFFICIENT_TASKS", "Complete the assigned shift work first.", resident)
			if bool(employment.get("deposit_issued", false)):
				return economy_error(action, "DEPOSIT_ALREADY_ISSUED", "That shift's deposit is already in circulation.", resident)
			var handoff_id: = String(definition.get("handoff_id", ""))
			if not add_inventory_quantity(updated, handoff_id, 1):
				return economy_error(action, "INVENTORY_FULL", "Make room before taking responsibility for that deposit.", resident)
			var nonce: = next_handoff_nonce(account_id, slot_index)
			var handoffs: Array = updated.get("active_handoffs", [])
			handoffs.append({"id": handoff_id, "display_name": definition.get("handoff_display", handoff_id), "state": "carried", "authority_nonce": nonce, "owner_tester_id": account_id, "owner_resident_slot": slot_index, "owner_world_id": server_world_id, "source_area": String(updated.get("area", "")), "source_room_id": String(updated.get("room_id", "")), "destination_area": "bank", "destination_room_id": "lobby", "deposit_box_id": "job_deposit_box", "active_seconds_remaining": CASHIER_DEPOSIT_ACTIVE_SECONDS, "expired": false, "tampered": false, "payment_cents": int(definition.get("deposit_bonus_cents", 0)), "job_id": definition.get("job_id", ""), "custody_events": []})
			updated["active_handoffs"] = handoffs
			employment["deposit_issued"] = true
			set_service_employment_record(updated, employer_id, employment)
			return economy_success(action, updated, {"type": "service_deposit_issued", "employer_id": employer_id, "nonce": nonce, "amount_hidden": true})
		_:
			return economy_error(action, "UNKNOWN_ACTION", "The ledger does not recognize that work request.", resident)

func next_cashier_shift_id(account_id: String, slot_index: int, resident: Dictionary) -> String:
	return "SHIFT-%s-%d-%d" % [account_id, slot_index, int(resident.get("cashier_shift_sequence", 0))]

func process_moth_action(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return economy_error(action, "RESIDENT_NOT_FOUND", "The city could not find that Resident file.", {})
	var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var result: = validate_and_apply_moth_action(resident, account_id, slot_index, request)
	if not bool(result.get("ok", false)):
		return result
	server_roster["slots"][slot_index] = Dictionary(result.get("resident", {}))
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: Dictionary = Dictionary(result.get("audit", {})).duplicate(true)
	audit["event_sequence"] = economy_event_sequence
	audit["account_id"] = account_id
	audit["resident_slot"] = slot_index
	audit["world_id"] = server_world_id
	audit["server_unix_ms"] = transaction_now_ms(request)
	economy_audit_log.append(audit)
	result["audit"] = audit
	return result

func active_handoff_for_id(resident: Dictionary, item_id: String) -> Dictionary:
	for handoff_variant in resident.get("active_handoffs", []):
		if handoff_variant is Dictionary:
			var handoff: = handoff_variant as Dictionary
			if String(handoff.get("id", "")) == item_id and String(handoff.get("state", "")) == "carried":
				return handoff.duplicate(true)
	return {}

func handoff_expired(handoff: Dictionary) -> bool:
	return bool(handoff.get("expired", false)) or float(handoff.get("active_seconds_remaining", CASHIER_DEPOSIT_ACTIVE_SECONDS)) <= 0.0

func append_authoritative_handoff(resident: Dictionary, account_id: String, slot_index: int, item_id: String, display_name: String, source_point: Vector2, destination_point: Vector2, active_seconds: float, details: Dictionary = {}) -> String:
	if not add_inventory_quantity(resident, item_id, 1):
		return ""
	var nonce: = next_handoff_nonce(account_id, slot_index)
	var handoffs: Array = resident.get("active_handoffs", [])
	var handoff: = {
		"id": item_id, "display_name": display_name, "state": "carried", "authority_nonce": nonce, 
		"owner_tester_id": account_id, "owner_resident_slot": slot_index, "owner_world_id": server_world_id, 
		"source_area": "street", "source_room_id": "", "source_point": [source_point.x, source_point.y], 
		"destination_area": "street", "destination_room_id": "", "destination_point": [destination_point.x, destination_point.y], 
		"active_seconds_remaining": active_seconds, "expired": false, "tampered": false, "payment_cents": 0, "custody_events": [], 
	}
	for key_variant in details.keys():
		handoff[String(key_variant)] = details[key_variant]
	handoffs.append(handoff)
	resident["active_handoffs"] = handoffs
	return nonce

func complete_owned_handoff(resident: Dictionary, handoff: Dictionary, request: Dictionary) -> Dictionary:
	var nonce: = String(handoff.get("authority_nonce", ""))
	var removed: = remove_owned_active_handoff(resident, nonce)
	if removed.is_empty():
		return {}
	var updated: Dictionary = removed["resident"]
	var completed_handoff: Dictionary = Dictionary(removed["handoff"]).duplicate(true)
	completed_handoff["state"] = "completed"
	completed_handoff["outcome"] = "COMPLETED"
	completed_handoff["completed_at_ms"] = transaction_now_ms(request)
	var completed: Dictionary = updated.get("completed_handoffs", {})
	completed[nonce] = completed_handoff
	updated["completed_handoffs"] = completed
	return {"resident": updated, "handoff": completed_handoff}

func moth_relationship_record(resident: Dictionary) -> Dictionary:
	var relationships: Dictionary = resident.get("dealer_relationships", {})
	return MothContent.normalize_relationship(relationships.get(MothContent.DEALER_ID, {}))

func set_moth_relationship_record(resident: Dictionary, relationship: Dictionary) -> void :
	var relationships: Dictionary = resident.get("dealer_relationships", {})
	relationships[MothContent.DEALER_ID] = MothContent.normalize_relationship(relationship)
	resident["dealer_relationships"] = relationships

func active_moth_package(resident: Dictionary) -> Dictionary:
	for tier_id_variant in MothContent.RUN_TIERS.keys():
		var tier: = MothContent.run_tier(String(tier_id_variant))
		var package: = active_handoff_for_id(resident, String(tier.get("item_id", "")))
		if not package.is_empty():
			return package
	return {}

func resident_has_any_moth_handoff(resident: Dictionary) -> bool:
	return not active_moth_package(resident).is_empty() or not active_handoff_for_id(resident, "sealed_customer_envelope").is_empty()

func add_inventory_quantity(resident: Dictionary, item_id: String, quantity: int) -> bool:
	if quantity <= 0:
		return false
	var inventory: Array = SaveMigration.inventory_records(resident.get("inventory", []))
	if inventory_unit_count(inventory) + quantity > resident_carry_capacity(resident):
		return false
	var existing_index: = inventory_record_index(inventory, item_id)
	if existing_index >= 0:
		var item_record: Dictionary = Dictionary(inventory[existing_index]).duplicate(true)
		item_record["quantity"] = int(item_record.get("quantity", 1)) + quantity
		inventory[existing_index] = item_record
	else:
		var item_record: = SaveMigration.default_item_record(item_id)
		item_record["quantity"] = quantity
		inventory.append(item_record)
	resident["inventory"] = inventory
	return true

func inventory_unit_count(value: Variant) -> int:
	var total: = 0
	for record in SaveMigration.inventory_records(value):
		total += maxi(0, int(record.get("quantity", 0)))
	return total

func equipment_item_id(equipment_value: Variant, slot_name: String) -> String:
	var equipment_records: = SaveMigration.equipment_records(equipment_value)
	var record: Variant = equipment_records.get(slot_name, {})
	return String((record as Dictionary).get("item_id", "")) if record is Dictionary else ""

func carry_capacity_for_equipment(equipment_value: Variant) -> int:
	return 8 + Build10.backpack_capacity(equipment_item_id(equipment_value, "back"))

func max_stamina_for_equipment(equipment_value: Variant) -> float:
	var back_item: = equipment_item_id(equipment_value, "back")
	var penalty: = int(Build10.EQUIPMENT_CATALOG.get(back_item, {}).get("stamina_cost", 0))
	return maxf(65.0, 100.0 - float(penalty))

func resident_carry_capacity(resident: Dictionary) -> int:
	return carry_capacity_for_equipment(resident.get("equipment", {}))

func inventory_record_matches_expected(actual_record: Dictionary, expected_value: Variant) -> bool:
	if expected_value is not Dictionary:
		return false
	var actual: = SaveMigration.normalize_item_record(actual_record)
	var expected: = SaveMigration.normalize_item_record(expected_value as Dictionary)
	return not actual.is_empty() and actual == expected

func append_inventory_record(inventory_value: Variant, record_value: Dictionary) -> Array[Dictionary]:
	var inventory: = SaveMigration.inventory_records(inventory_value)
	var record: = SaveMigration.normalize_item_record(record_value)
	if record.is_empty():
		return inventory
	record["quantity"] = maxi(1, int(record.get("quantity", 1)))
	for index in range(inventory.size()):
		var existing: Dictionary = inventory[index]
		if String(existing.get("item_id", "")) == String(record.get("item_id", "")) and int(existing.get("condition", 100)) == int(record.get("condition", 100)) and Dictionary(existing.get("metadata", {})) == Dictionary(record.get("metadata", {})):
			existing["quantity"] = int(existing.get("quantity", 1)) + int(record.get("quantity", 1))
			inventory[index] = existing
			return inventory
	inventory.append(record)
	return inventory

func sync_resident_contingencies(resident: Dictionary) -> void :
	var names: = SaveMigration.equipment_names(resident.get("equipment", {}))
	var ready: Array[String] = []
	for slot_name in ["contingency_1", "contingency_2"]:
		var item_name: = String(names.get(slot_name, ""))
		if not item_name.is_empty():
			ready.append(item_name)
	resident["contingencies"] = ready

func add_powder_inventory_record(resident: Dictionary, account_id: String, slot_index: int, item_id: String, relationship: Dictionary) -> bool:
	var inventory: Array = SaveMigration.inventory_records(resident.get("inventory", []))
	if inventory_unit_count(inventory) + 1 > resident_carry_capacity(resident):
		return false
	var purchase_sequence: = int(relationship.get("wholesale_purchases", 0)) + 1
	var purity_tier: = MothContent.powder_purity_for_purchase(account_id, purchase_sequence, item_id)
	var item_record: = SaveMigration.default_item_record(item_id)
	item_record["metadata"] = {
		"substance_id": "powder", "purity_tier": purity_tier, "purity_known": false,
		"batch_id": "POWDER-%s-%d-%d-%d" % [account_id, slot_index, Time.get_ticks_msec(), purchase_sequence],
	}
	inventory.append(item_record)
	resident["inventory"] = inventory
	return true

func powder_inventory_index(resident: Dictionary, batch_id: String) -> int:
	var inventory: Array = resident.get("inventory", [])
	for index in range(inventory.size()):
		var entry: Variant = inventory[index]
		if entry is not Dictionary:
			continue
		var record: = entry as Dictionary
		var metadata: Dictionary = record.get("metadata", {})
		if String(metadata.get("substance_id", "")) == "powder" and String(metadata.get("batch_id", "")) == batch_id:
			return index
	return -1

func validate_and_apply_moth_action(resident: Dictionary, account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var updated: = resident.duplicate(true)
	var current_area: = String(updated.get("area", ""))
	var current_room: = String(updated.get("room_id", ""))
	var position: = resident_saved_position(updated)
	match action:
		"MOTH_RUN_ACCEPT":
			var relationship: = moth_relationship_record(updated)
			if int(relationship.get("hostile_until_unix_ms", 0)) > transaction_now_ms(request):
				return economy_error(action, "MOTH_HOSTILE", "Moth has suspended business with you for ten minutes after the missed delivery.", resident)
			if current_area != "street" or not current_room.is_empty() or position.distance_to(MothContent.MOTH_POINT) > MothContent.INTERACTION_RADIUS:
				return economy_error(action, "WRONG_LOCATION", "Moth only hands over work face to face.", resident)
			if Rules.level_from_xp(int(Dictionary(updated.get("xp", {})).get("Stealth", 0))) < 3:
				return economy_error(action, "SKILL_REQUIRED", "Moth wants Stealth Level 3. Apparently discretion now has continuing-education requirements.", resident)
			if resident_has_any_moth_handoff(updated):
				return economy_error(action, "RUN_ALREADY_ACTIVE", "Finish the package already in your custody.", resident)
			var tier_id: = String(request.get("tier", "dime")).to_lower()
			var tier: = MothContent.run_tier(tier_id)
			if tier.is_empty():
				return economy_error(action, "INVALID_RUN_TIER", "Moth did not offer that package size.", resident)
			if int(relationship.get("trust", 0)) < int(tier.get("trust_required", 0)):
				return economy_error(action, "TRUST_REQUIRED", "Moth has not trusted you with that size yet.", resident)
			var route: = MothContent.route_for_run(account_id, int(relationship.get("completed_runs", 0)))
			var payout_cents: = MothContent.payout_cents(account_id, int(relationship.get("completed_runs", 0)), tier_id)
			var route_point: Vector2 = route.get("point", Vector2.ZERO)
			var nonce: = append_authoritative_handoff(updated, account_id, slot_index, String(tier.get("item_id", "")), String(tier.get("item_display", "Sealed Package")), MothContent.MOTH_POINT, route_point, float(tier.get("active_seconds", 300.0)), {
				"destination_area": String(route.get("area", "street")), "destination_room_id": String(route.get("room_id", "")), 
				"route_id": String(route.get("id", "")), "recipient_actor_id": String(route.get("recipient_actor_id", "")), 
				"recipient_name": String(route.get("recipient_name", "Customer")), "destination_label": String(route.get("destination_label", "the arranged location")), 
				"run_tier": tier_id, "payment_cents": payout_cents, 
			})
			if nonce.is_empty():
				return economy_error(action, "INVENTORY_FULL", "Make room before accepting another sealed package.", resident)
			updated["sealed_packages"] = 1
			return economy_success(action, updated, {"type": "moth_run_accepted", "nonce": nonce, "tier": tier_id, "route_id": route.get("id", ""), "recipient_actor_id": route.get("recipient_actor_id", ""), "recipient_name": route.get("recipient_name", ""), "destination_label": route.get("destination_label", ""), "trust": relationship.get("trust", 0)})
		"MOTH_CUSTOMER_EXCHANGE", "MOTH_TEE_EXCHANGE":
			var package: = active_moth_package(updated)
			if package.is_empty():
				return economy_error(action, "HANDOFF_NOT_FOUND", "The customer cannot sign for a package you do not have.", resident)
			if handoff_expired(package):
				return economy_error(action, "DELIVERY_EXPIRED", "The package window closed before the customer could sign for it.", resident)
			var route: = MothContent.route(String(package.get("route_id", "")))
			var route_point: Vector2 = route.get("point", Vector2.ZERO)
			if route.is_empty() or current_area != String(route.get("area", "")) or current_room != String(route.get("room_id", "")) or position.distance_to(route_point) > MothContent.INTERACTION_RADIUS:
				return economy_error(action, "WRONG_LOCATION", "%s is waiting at %s." % [String(route.get("recipient_name", "The customer")), String(route.get("destination_label", "the arranged location"))], resident)
			var requested_recipient: = String(request.get("recipient_actor_id", ""))
			if not requested_recipient.is_empty() and requested_recipient != String(route.get("recipient_actor_id", "")):
				return economy_error(action, "WRONG_RECIPIENT", "That package belongs to somebody else on Moth's list.", resident)
			var completion: = complete_owned_handoff(updated, package, request)
			if completion.is_empty():
				return economy_error(action, "HANDOFF_NOT_FOUND", "The package custody record could not be completed.", resident)
			updated = completion["resident"]
			var envelope_nonce: = append_authoritative_handoff(updated, account_id, slot_index, "sealed_customer_envelope", "Sealed Customer Envelope", route_point, MothContent.MOTH_POINT, 300.0, {
				"source_area": String(route.get("area", "street")), "source_room_id": String(route.get("room_id", "")), 
				"destination_area": "street", "destination_room_id": "", "route_id": route.get("id", ""), 
				"recipient_name": route.get("recipient_name", "Customer"), "run_tier": package.get("run_tier", "dime"), 
				"payment_cents": int(package.get("payment_cents", 0)), 
			})
			if envelope_nonce.is_empty():
				return economy_error(action, "INVENTORY_FULL", "Make room for the customer's return envelope.", resident)
			updated["sealed_packages"] = 0
			return economy_success(action, updated, {"type": "moth_customer_exchange", "completed_nonce": package.get("authority_nonce", ""), "nonce": envelope_nonce, "recipient_name": route.get("recipient_name", "Customer"), "route_id": route.get("id", "")})
		"MOTH_RUN_COMPLETE":
			if current_area != "street" or not current_room.is_empty() or position.distance_to(MothContent.MOTH_POINT) > MothContent.INTERACTION_RADIUS:
				return economy_error(action, "WRONG_LOCATION", "Moth closes the run in person.", resident)
			var envelope: = active_handoff_for_id(updated, "sealed_customer_envelope")
			if envelope.is_empty():
				return economy_error(action, "HANDOFF_NOT_FOUND", "Moth is waiting for the sealed customer envelope.", resident)
			if handoff_expired(envelope):
				return economy_error(action, "DELIVERY_EXPIRED", "The return-envelope window closed before Moth received it.", resident)
			var completion: = complete_owned_handoff(updated, envelope, request)
			if completion.is_empty():
				return economy_error(action, "HANDOFF_NOT_FOUND", "The return-envelope custody record could not be completed.", resident)
			updated = completion["resident"]
			var tier_id: = String(envelope.get("run_tier", "dime"))
			var tier: = MothContent.run_tier(tier_id)
			if tier.is_empty():
				tier_id = "dime"
				tier = MothContent.run_tier(tier_id)
			var amount_cents: = clampi(int(envelope.get("payment_cents", 0)), int(tier.get("pay_min_cents", 0)), int(tier.get("pay_max_cents", 0)))
			updated["carried_cash_dirty"] = int(updated.get("carried_cash_dirty", 0)) + amount_cents
			var xp: Dictionary = updated.get("xp", {})
			xp["Stealth"] = int(xp.get("Stealth", 0)) + int(tier.get("stealth_xp", 0))
			xp["Enterprise"] = int(xp.get("Enterprise", 0)) + int(tier.get("enterprise_xp", 0))
			updated["xp"] = xp
			updated["criminal_errands_completed"] = int(updated.get("criminal_errands_completed", 0)) + 1
			updated["sealed_packages"] = 0
			var relationship: = moth_relationship_record(updated)
			relationship["trust"] = mini(100, int(relationship.get("trust", 0)) + int(tier.get("trust_gain", 0)))
			relationship["completed_runs"] = int(relationship.get("completed_runs", 0)) + 1
			var completed_by_tier: Dictionary = relationship.get("completed_by_tier", {})
			completed_by_tier[tier_id] = int(completed_by_tier.get(tier_id, 0)) + 1
			relationship["completed_by_tier"] = completed_by_tier
			set_moth_relationship_record(updated, relationship)
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {"type": "moth_run_completed", "nonce": envelope.get("authority_nonce", ""), "amount_cents": amount_cents, "tier": tier_id, "trust": relationship.get("trust", 0), "route_id": envelope.get("route_id", "")})
		"MOTH_WHOLESALE_BUY":
			if current_area != "street" or not current_room.is_empty() or position.distance_to(MothContent.MOTH_POINT) > MothContent.INTERACTION_RADIUS:
				return economy_error(action, "WRONG_LOCATION", "Moth handles wholesale business in person.", resident)
			var item_id: = String(request.get("item_id", ""))
			var offer: = MothContent.wholesale_offer(item_id)
			if offer.is_empty():
				return economy_error(action, "INVALID_PURCHASE", "Moth did not offer that package.", resident)
			var relationship: = moth_relationship_record(updated)
			if int(relationship.get("trust", 0)) < int(offer.get("trust_required", 0)):
				return economy_error(action, "TRUST_REQUIRED", "Moth has not opened that part of the inventory to you.", resident)
			var price_cents: = int(offer.get("price_cents", 0))
			if int(updated.get("carried_cash_dirty", 0)) < price_cents:
				return economy_error(action, "INSUFFICIENT_FUNDS", "Moth counts the dirty side twice and still comes up short.", resident)
			var inventory_added: = add_powder_inventory_record(updated, account_id, slot_index, item_id, relationship) if String(offer.get("substance_id", "")) == "powder" else add_inventory_quantity(updated, item_id, 1)
			if not inventory_added:
				return economy_error(action, "INVENTORY_FULL", "You need room before Moth hands over wholesale weight.", resident)
			updated["carried_cash_dirty"] = int(updated.get("carried_cash_dirty", 0)) - price_cents
			relationship["wholesale_purchases"] = int(relationship.get("wholesale_purchases", 0)) + 1
			set_moth_relationship_record(updated, relationship)
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {"type": "moth_wholesale_purchase", "item_id": item_id, "quantity": 1, "money_type": "dirty", "amount_cents": - price_cents, "trust": relationship.get("trust", 0)})
		"POWDER_ANALYZE":
			return economy_error(action, "FEATURE_DEFERRED", "Chemistry analysis remains deferred until a lab can be purchased and installed in a player-owned home.", resident)
		"POWDER_USE":
			var batch_id: = String(request.get("batch_id", ""))
			var inventory: Array = updated.get("inventory", [])
			var batch_index: = powder_inventory_index(updated, batch_id)
			if batch_index < 0:
				return economy_error(action, "ITEM_NOT_FOUND", "That batch is not in your carried inventory.", resident)
			var item_record: Dictionary = Dictionary(inventory[batch_index]).duplicate(true)
			var metadata: Dictionary = item_record.get("metadata", {})
			var purity: = MothContent.powder_purity(int(metadata.get("purity_tier", 1)))
			inventory.remove_at(batch_index)
			updated["inventory"] = inventory
			var duration_seconds: = float(purity.get("duration_seconds", 60.0))
			var effects: Dictionary = updated.get("active_substance_effects", {})
			effects["powder"] = {
				"source_item_id": item_record.get("item_id", "Powder"), "purity_tier": purity.get("tier", 1),
				"purity_label": purity.get("label", "Unknown"), "ends_at_unix_ms": transaction_now_ms(request) + int(duration_seconds * 1000.0),
				"stamina_regen_multiplier": purity.get("stamina_regen_multiplier", 1.0), "health_regen_per_second": purity.get("health_regen_per_second", 0.0),
			}
			updated["active_substance_effects"] = effects
			return economy_success(action, updated, {"type": "powder_used", "item_id": item_record.get("item_id", "Powder"), "duration_seconds": duration_seconds, "stamina_regen_multiplier": purity.get("stamina_regen_multiplier", 1.0), "health_regen_per_second": purity.get("health_regen_per_second", 0.0), "purity_tier": purity.get("tier", 1), "purity_known": bool(metadata.get("purity_known", false))})
		_:
			return economy_error(action, "UNKNOWN_ACTION", "Moth does not recognize that errand request.", resident)

func next_handoff_nonce(account_id: String, slot_index: int) -> String:
	handoff_event_sequence += 1
	return "HANDOFF-%s-%d-%d-%d" % [account_id, slot_index, Time.get_ticks_msec(), handoff_event_sequence]

func remove_owned_active_handoff(resident: Dictionary, nonce: String) -> Dictionary:
	var updated: = resident.duplicate(true)
	var handoffs: Array = updated.get("active_handoffs", [])
	for index in range(handoffs.size()):
		var handoff_variant: Variant = handoffs[index]
		if handoff_variant is Dictionary and String((handoff_variant as Dictionary).get("authority_nonce", "")) == nonce:
			var handoff: = (handoff_variant as Dictionary).duplicate(true)
			handoffs.remove_at(index)
			updated["active_handoffs"] = handoffs
			var inventory: Array = updated.get("inventory", [])
			var item_index: = inventory_record_index(inventory, String(handoff.get("id", "")))
			if item_index >= 0:
				inventory.remove_at(item_index)
			updated["inventory"] = inventory
			return {"resident": updated, "handoff": handoff}
	return {}

func apply_legacy_transfer(account_id: String, target_slot: int, request: Dictionary) -> Dictionary:
	var deceased_slot: = int(request.get("deceased_resident_slot", -1))
	var server_roster: = account_roster(account_id)
	if deceased_slot < 0 or deceased_slot >= ReleaseSave.FREE_SLOTS or deceased_slot == target_slot:
		return economy_error("LEGACY_APPLY", "INVALID_LEGACY_TARGET", "That legacy transfer cannot be filed.", {})
	var deceased_value: Variant = server_roster["slots"][deceased_slot]
	var target_value: Variant = server_roster["slots"][target_slot]
	if deceased_value is not Dictionary or target_value is not Dictionary:
		return economy_error("LEGACY_APPLY", "RESIDENT_NOT_FOUND", "The legacy records are incomplete.", {})
	var deceased: = SaveMigration.migrate_resident(deceased_value as Dictionary)
	var target: = SaveMigration.migrate_resident(target_value as Dictionary)
	if not bool(deceased.get("deceased", false)):
		return economy_error("LEGACY_APPLY", "RESIDENT_NOT_DECEASED", "That record is not eligible for legacy transfer.", target)
	if bool(deceased.get("legacy_transfer_applied", false)):
		return economy_error("LEGACY_APPLY", "LEGACY_ALREADY_APPLIED", "That legacy was already filed.", target)
	var inherited_cents: = floori(float(deceased.get("bank_balance_clean", 0)) * 0.15 / 100.0) * 100
	target["bank_balance_clean"] = int(target.get("bank_balance_clean", 0)) + inherited_cents
	var property_records: Array = deceased.get("property", [])
	if not property_records.is_empty():
		var target_property: Array = target.get("property", [])
		target_property.append(Dictionary(property_records[0]).duplicate(true))
		target["property"] = target_property
	var insured_item: = first_active_insured_item(deceased)
	if not insured_item.is_empty():
		var target_inventory: Array = target.get("inventory", [])
		target_inventory.append(insured_item)
		target["inventory"] = target_inventory
	target["legacy_marker"] = String(deceased.get("legacy_marker", "")) if deceased.get("legacy_marker", null) != null else null
	deceased["legacy_transfer_applied"] = true
	deceased["bank_balance_clean"] = 0
	deceased["carried_cash_clean"] = 0
	deceased["carried_cash_dirty"] = 0
	deceased["inventory"] = []
	deceased["equipment"] = {}
	deceased["active_handoffs"] = []
	sync_legacy_money_aliases(deceased)
	sync_legacy_money_aliases(target)
	server_roster["slots"][deceased_slot] = deceased
	server_roster["slots"][target_slot] = target
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: = {
		"event_sequence": economy_event_sequence, "type": "legacy_transfer", "account_id": account_id, 
		"resident_slot": target_slot, "deceased_resident_slot": deceased_slot, "world_id": server_world_id, 
		"amount_cents": inherited_cents, "insured_item_id": insured_item.get("item_id", ""), 
		"server_unix_ms": transaction_now_ms(request), 
	}
	economy_audit_log.append(audit)
	return economy_success("LEGACY_APPLY", target, audit)

func first_active_insured_item(resident: Dictionary) -> Dictionary:
	var inventory: Array = resident.get("inventory", [])
	for policy_variant in resident.get("insurance", []):
		if policy_variant is not Dictionary:
			continue
		var policy: = policy_variant as Dictionary
		if not bool(policy.get("active", false)):
			continue
		var item_id: = String(policy.get("item_id", ""))
		var item_index: = inventory_record_index(inventory, item_id)
		if item_index >= 0:
			var record: = Dictionary(inventory[item_index]).duplicate(true)
			record["quantity"] = 1
			return record
	return {}

func home_directory_id(home: Dictionary) -> String:
	var home_instance_id: = String(home.get("home_instance_id", ""))
	return "HOME-DIR-%s" % home_instance_id.sha256_text().left(24).to_upper() if not home_instance_id.is_empty() else ""

func authoritative_home_by_directory_id(directory_id: String) -> Dictionary:
	var clean_directory_id: = directory_id.strip_edges().to_upper().left(40)
	if clean_directory_id.is_empty():
		return {}
	for account_variant in persistent_profiles.keys():
		var account_id: = safe_tester_id(String(account_variant))
		var roster: = account_roster(account_id)
		var slots: Array = roster.get("slots", [])
		for slot_index in range(slots.size()):
			if slots[slot_index] is not Dictionary:
				continue
			var resident: = SaveMigration.migrate_resident(slots[slot_index] as Dictionary)
			for home in PlayerHomeContent.property_records(resident.get("property", [])):
				if String(home.get("world_id", "")) != server_world_id or home_directory_id(home) != clean_directory_id:
					continue
				return {
					"account_id": account_id, 
					"resident_slot": slot_index, 
					"resident": resident, 
					"roster": roster, 
					"home": home, 
				}
	return {}

func authoritative_home_by_instance(home_instance_id: String) -> Dictionary:
	if home_instance_id.is_empty():
		return {}
	return authoritative_home_by_directory_id("HOME-DIR-%s" % home_instance_id.sha256_text().left(24).to_upper())

func set_resident_home_record(resident: Dictionary, home: Dictionary) -> Dictionary:
	var updated: = SaveMigration.migrate_resident(resident)
	var properties: = PlayerHomeContent.property_records(updated.get("property", []))
	var replaced: = false
	for index in range(properties.size()):
		if String(properties[index].get("home_instance_id", "")) == String(home.get("home_instance_id", "")):
			properties[index] = PlayerHomeContent.normalize_home_record(home)
			replaced = true
			break
	if not replaced:
		properties.append(PlayerHomeContent.normalize_home_record(home))
	updated["property"] = properties
	return updated

func store_home_access_resident(account_id: String, resident_slot: int, resident: Dictionary) -> void :
	var roster: = account_roster(account_id)
	var slots: Array = roster.get("slots", [])
	if resident_slot < 0 or resident_slot >= slots.size():
		return
	slots[resident_slot] = SaveMigration.migrate_resident(resident)
	roster["slots"] = slots
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(roster)
	profiles_dirty = true

func home_access_subject_matches(record: Dictionary, account_id: String, resident_slot: int) -> bool:
	return safe_tester_id(String(record.get("guest_account_id", ""))) == safe_tester_id(account_id) and int(record.get("guest_resident_slot", -1)) == resident_slot

func home_visit_request_for_guest(home: Dictionary, account_id: String, resident_slot: int) -> Dictionary:
	for request_record in PlayerHomeContent.normalize_visit_requests(home.get("visit_requests", [])):
		if home_access_subject_matches(request_record, account_id, resident_slot):
			return request_record.duplicate(true)
	return {}

func valid_home_key_record(resident: Dictionary, home: Dictionary) -> Dictionary:
	var issued_keys: = PlayerHomeContent.normalize_issued_keys(home.get("issued_keys", []))
	for item_record in SaveMigration.inventory_records(resident.get("inventory", [])):
		var metadata: Dictionary = item_record.get("metadata", {})
		var key_id: = String(metadata.get("home_key_id", ""))
		if key_id.is_empty() or String(metadata.get("home_instance_id", "")) != String(home.get("home_instance_id", "")):
			continue
		for issued in issued_keys:
			if String(issued.get("key_id", "")) == key_id and bool(issued.get("active", false)) and String(issued.get("item_id", "")) == String(item_record.get("item_id", "")):
				return item_record.duplicate(true)
	return {}

func home_access_directory_payload(account_id: String, resident_slot: int, resident: Dictionary) -> Dictionary:
	var homes: Array[Dictionary] = []
	for account_variant in persistent_profiles.keys():
		var owner_account: = safe_tester_id(String(account_variant))
		var roster: = account_roster(owner_account)
		var slots: Array = roster.get("slots", [])
		for owner_slot in range(slots.size()):
			if slots[owner_slot] is not Dictionary:
				continue
			var owner: = SaveMigration.migrate_resident(slots[owner_slot] as Dictionary)
			var home: = PlayerHomeContent.first_player_home(owner.get("property", []), PlayerHomeContent.MERCY_COURT_ID)
			if home.is_empty() or String(home.get("world_id", "")) != server_world_id or (owner_account == account_id and owner_slot == resident_slot):
				continue
			var access_mode: = "none"
			if not valid_home_key_record(resident, home).is_empty():
				access_mode = "permanent_key"
			elif not PlayerHomeContent.one_time_grant(home, account_id, resident_slot).is_empty():
				access_mode = "one_time"
			elif not home_visit_request_for_guest(home, account_id, resident_slot).is_empty():
				access_mode = "pending"
			homes.append({
				"directory_id": home_directory_id(home), 
				"display_name": String(home.get("display_name", "Player Home")), 
				"owner_name": String(owner.get("name", "Resident")).left(20), 
				"access_mode": access_mode, 
			})
	homes.sort_custom( func(first: Dictionary, second: Dictionary): return String(first.get("owner_name", "")).naturalnocasecmp_to(String(second.get("owner_name", ""))) < 0)
	return {"homes": homes}

func owner_home_access_payload(account_id: String, resident_slot: int, resident: Dictionary) -> Dictionary:
	var home: = PlayerHomeContent.first_player_home(resident.get("property", []), PlayerHomeContent.MERCY_COURT_ID)
	if home.is_empty():
		return {}
	var requests: Array[Dictionary] = []
	for request_record in PlayerHomeContent.normalize_visit_requests(home.get("visit_requests", [])):
		requests.append({
			"request_id": String(request_record.get("request_id", "")), 
			"guest_name": String(request_record.get("guest_name", "Resident")), 
			"requested_at_ms": int(request_record.get("requested_at_ms", 0)), 
		})
	var issued_keys: Array[Dictionary] = []
	for key_record in PlayerHomeContent.normalize_issued_keys(home.get("issued_keys", [])):
		if bool(key_record.get("active", false)):
			issued_keys.append({
				"key_id": String(key_record.get("key_id", "")), 
				"item_id": String(key_record.get("item_id", "Mercy Court Guest Key")), 
				"issued_to_name": String(key_record.get("issued_to_name", "Resident")), 
			})
	var one_time_names: Array[String] = []
	for grant in PlayerHomeContent.normalize_one_time_access(home.get("one_time_access", [])):
		one_time_names.append(String(grant.get("guest_name", "Resident")))
	return {
		"display_name": String(home.get("display_name", "Player Home")), 
		"requests": requests, 
		"issued_keys": issued_keys, 
		"one_time_guests": one_time_names, 
	}

func home_access_result_payload(account_id: String, resident_slot: int, resident: Dictionary) -> Dictionary:
	var payload: = home_access_directory_payload(account_id, resident_slot, resident)
	payload["owner_access"] = owner_home_access_payload(account_id, resident_slot, resident)
	return payload

func finalize_home_access_mutation(action: String, account_id: String, resident_slot: int, audit: Dictionary, affected: Array[Dictionary] = []) -> Dictionary:
	var actor_roster: = account_roster(account_id)
	var actor_value: Variant = actor_roster.get("slots", [])[resident_slot]
	var actor: = SaveMigration.migrate_resident(actor_value as Dictionary) if actor_value is Dictionary else {}
	economy_event_sequence += 1
	var completed_audit: = audit.duplicate(true)
	completed_audit["event_sequence"] = economy_event_sequence
	completed_audit["account_id"] = account_id
	completed_audit["resident_slot"] = resident_slot
	completed_audit["world_id"] = server_world_id
	completed_audit["server_unix_ms"] = int(Time.get_unix_time_from_system() * 1000.0)
	economy_audit_log.append(completed_audit)
	var result: = economy_success(action, actor, completed_audit)
	result["_affected_residents"] = affected.duplicate(true)
	return result

func process_home_access_action(account_id: String, resident_slot: int, resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var actor: = SaveMigration.migrate_resident(resident)
	var at_elevator: = String(actor.get("area", "")) == "apartment" and String(actor.get("room_id", "")) == "stairs"
	if action == "HOME_VISIT_LEAVE":
		var active_visit: = PlayerHomeContent.normalize_active_visit(actor.get("active_home_visit", {}))
		if active_visit.is_empty():
			return economy_error(action, "NO_ACTIVE_VISIT", "This Resident is not inside another Resident's home.", resident)
		actor["active_home_visit"] = {}
		actor["area"] = "apartment"
		actor["room_id"] = "floor_1"
		actor["position"] = [500.0, 270.0]
		actor["home_instance_id"] = ""
		store_home_access_resident(account_id, resident_slot, actor)
		return finalize_home_access_mutation(action, account_id, resident_slot, {"type": "home_visit_left", "visit_id": active_visit.get("visit_id", "")})
	if not at_elevator:
		return economy_error(action, "WRONG_LOCATION", "Visitor permissions are filed at the Mercy Court elevator.", resident)
	if action == "HOME_ACCESS_DIRECTORY":
		return economy_success(action, actor, {"type": "home_access_directory", "directory": home_access_result_payload(account_id, resident_slot, actor)})

	if action in ["HOME_VISIT_APPROVE_ONCE", "HOME_VISIT_APPROVE_PERMANENT", "HOME_VISIT_DENY", "HOME_KEY_REVOKE"]:
		var owner_home: = PlayerHomeContent.first_player_home(actor.get("property", []), PlayerHomeContent.MERCY_COURT_ID)
		if owner_home.is_empty() or not bool(actor.get("apartment_leased", false)):
			return economy_error(action, "HOME_REQUIRED", "A signed Mercy Court lease is required to manage guest access.", resident)
		if action == "HOME_KEY_REVOKE":
			var requested_key_id: = String(request.get("key_id", "")).strip_edges().left(96)
			var issued_keys: = PlayerHomeContent.normalize_issued_keys(owner_home.get("issued_keys", []))
			var revoked: = false
			for key_index in range(issued_keys.size()):
				if String(issued_keys[key_index].get("key_id", "")) == requested_key_id and bool(issued_keys[key_index].get("active", false)):
					issued_keys[key_index]["active"] = false
					revoked = true
					break
			if not revoked:
				return economy_error(action, "KEY_NOT_FOUND", "That permanent key is already invalid or was never issued here.", resident)
			owner_home["issued_keys"] = issued_keys
			actor = set_resident_home_record(actor, owner_home)
			store_home_access_resident(account_id, resident_slot, actor)
			return finalize_home_access_mutation(action, account_id, resident_slot, {"type": "home_key_revoked", "key_id": requested_key_id, "directory": home_access_result_payload(account_id, resident_slot, actor)})

		var request_id: = String(request.get("request_id", "")).strip_edges().left(64)
		var visit_requests: = PlayerHomeContent.normalize_visit_requests(owner_home.get("visit_requests", []))
		var request_index: = -1
		for index in range(visit_requests.size()):
			if String(visit_requests[index].get("request_id", "")) == request_id:
				request_index = index
				break
		if request_index < 0:
			return economy_error(action, "REQUEST_NOT_FOUND", "That visit request is no longer pending.", resident)
		var visit_request: = visit_requests[request_index].duplicate(true)
		var guest_account: = safe_tester_id(String(visit_request.get("guest_account_id", "")))
		var guest_slot: = int(visit_request.get("guest_resident_slot", -1))
		if action == "HOME_VISIT_DENY":
			visit_requests.remove_at(request_index)
			owner_home["visit_requests"] = visit_requests
			actor = set_resident_home_record(actor, owner_home)
			store_home_access_resident(account_id, resident_slot, actor)
			return finalize_home_access_mutation(action, account_id, resident_slot, {"type": "home_visit_denied", "request_id": request_id, "guest_name": visit_request.get("guest_name", "Resident"), "directory": home_access_result_payload(account_id, resident_slot, actor)}, [{"account_id": guest_account, "resident_slot": guest_slot}])

		var guest_roster: = account_roster(guest_account)
		var guest_slots: Array = guest_roster.get("slots", [])
		if guest_slot < 0 or guest_slot >= guest_slots.size() or guest_slots[guest_slot] is not Dictionary:
			return economy_error(action, "GUEST_NOT_FOUND", "That requesting Resident is no longer available.", resident)
		var guest: = SaveMigration.migrate_resident(guest_slots[guest_slot] as Dictionary)
		var now_ms: = transaction_now_ms(request)
		if action == "HOME_VISIT_APPROVE_ONCE":
			var grants: = PlayerHomeContent.normalize_one_time_access(owner_home.get("one_time_access", []))
			if grants.size() >= PlayerHomeContent.ACCESS_RECORD_LIMIT:
				return economy_error(action, "ACCESS_LIST_FULL", "The hidden one-time access list is full.", resident)
			grants.append({
				"grant_id": "HOME-ONCE-%s" % String(request.get("transaction_id", request_id)).sha256_text().left(20).to_upper(), 
				"guest_account_id": guest_account, 
				"guest_resident_slot": guest_slot, 
				"guest_name": String(guest.get("name", visit_request.get("guest_name", "Resident"))), 
				"uses_remaining": 1, 
				"issued_at_ms": now_ms, 
			})
			owner_home["one_time_access"] = grants
		else:
			var guest_inventory: = SaveMigration.inventory_records(guest.get("inventory", []))
			if inventory_unit_count(guest_inventory) + 1 > resident_carry_capacity(guest):
				return economy_error(action, "GUEST_INVENTORY_FULL", "That Resident needs carried inventory space before receiving a permanent key.", resident)
			var key_id: = "HOME-KEY-%s" % String(request.get("transaction_id", request_id)).sha256_text().left(20).to_upper()
			if not PlayerHomeContent.issued_key(owner_home, key_id).is_empty():
				return economy_error(action, "KEY_ALREADY_ISSUED", "That permanent key transaction is already on file.", resident)
			var item_id: = "Mercy Court Guest Key %s" % key_id.right(6)
			var key_item: = SaveMigration.default_item_record(item_id)
			key_item["metadata"] = {
				"home_access_kind": "permanent", 
				"home_key_id": key_id, 
				"home_instance_id": String(owner_home.get("home_instance_id", "")), 
			}
			guest_inventory.append(key_item)
			guest["inventory"] = guest_inventory
			var issued_keys: = PlayerHomeContent.normalize_issued_keys(owner_home.get("issued_keys", []))
			if issued_keys.size() >= PlayerHomeContent.ACCESS_RECORD_LIMIT:
				return economy_error(action, "ACCESS_LIST_FULL", "The permanent-key registry is full.", resident)
			issued_keys.append({
				"key_id": key_id, 
				"item_id": item_id, 
				"active": true, 
				"issued_to_account_id": guest_account, 
				"issued_to_resident_slot": guest_slot, 
				"issued_to_name": String(guest.get("name", visit_request.get("guest_name", "Resident"))), 
				"issued_at_ms": now_ms, 
			})
			owner_home["issued_keys"] = issued_keys
			store_home_access_resident(guest_account, guest_slot, guest)
		visit_requests.remove_at(request_index)
		owner_home["visit_requests"] = visit_requests
		actor = set_resident_home_record(actor, owner_home)
		store_home_access_resident(account_id, resident_slot, actor)
		var grant_kind: = "one_time" if action == "HOME_VISIT_APPROVE_ONCE" else "permanent_key"
		return finalize_home_access_mutation(action, account_id, resident_slot, {"type": "home_visit_approved", "request_id": request_id, "guest_name": visit_request.get("guest_name", "Resident"), "access_kind": grant_kind, "directory": home_access_result_payload(account_id, resident_slot, actor)}, [{"account_id": guest_account, "resident_slot": guest_slot}])

	var directory_id: = String(request.get("directory_id", "")).strip_edges().to_upper().left(40)
	var target_entry: = authoritative_home_by_directory_id(directory_id)
	if target_entry.is_empty():
		return economy_error(action, "HOME_NOT_FOUND", "That apartment is no longer on the server directory.", resident)
	if String(target_entry.get("account_id", "")) == account_id and int(target_entry.get("resident_slot", -1)) == resident_slot:
		return economy_error(action, "USE_OWN_APARTMENT", "Use My apartment for the Resident's assigned unit.", resident)
	var target_home: Dictionary = Dictionary(target_entry.get("home", {})).duplicate(true)
	var target_owner: = SaveMigration.migrate_resident(target_entry.get("resident", {}))
	if action == "HOME_VISIT_REQUEST":
		if not valid_home_key_record(actor, target_home).is_empty() or not PlayerHomeContent.one_time_grant(target_home, account_id, resident_slot).is_empty():
			return economy_error(action, "ACCESS_ALREADY_GRANTED", "This Resident already has entry permission for that apartment.", resident)
		if not home_visit_request_for_guest(target_home, account_id, resident_slot).is_empty():
			return economy_error(action, "REQUEST_PENDING", "That visit request is already waiting for the owner.", resident)
		var visit_requests: = PlayerHomeContent.normalize_visit_requests(target_home.get("visit_requests", []))
		if visit_requests.size() >= PlayerHomeContent.ACCESS_RECORD_LIMIT:
			return economy_error(action, "REQUEST_LIST_FULL", "That apartment cannot accept another pending visit request yet.", resident)
		var request_id: = "HOME-REQ-%s" % String(request.get("transaction_id", "%s-%d" % [account_id, resident_slot])).sha256_text().left(20).to_upper()
		visit_requests.append({
			"request_id": request_id, 
			"guest_account_id": account_id, 
			"guest_resident_slot": resident_slot, 
			"guest_name": String(actor.get("name", "Resident")), 
			"requested_at_ms": transaction_now_ms(request), 
		})
		target_home["visit_requests"] = visit_requests
		target_owner = set_resident_home_record(target_owner, target_home)
		store_home_access_resident(String(target_entry.get("account_id", "")), int(target_entry.get("resident_slot", -1)), target_owner)
		return finalize_home_access_mutation(action, account_id, resident_slot, {"type": "home_visit_requested", "request_id": request_id, "owner_name": target_owner.get("name", "Resident")}, [{"account_id": target_entry.get("account_id", ""), "resident_slot": target_entry.get("resident_slot", -1)}])
	if action == "HOME_VISIT_ENTER":
		var key_record: = valid_home_key_record(actor, target_home)
		var one_time_grant: = PlayerHomeContent.one_time_grant(target_home, account_id, resident_slot)
		if key_record.is_empty() and one_time_grant.is_empty():
			return economy_error(action, "ACCESS_REQUIRED", "The owner has not granted entry to that apartment.", resident)
		var access_kind: = "permanent_key" if not key_record.is_empty() else "one_time"
		var authorization_id: = String(Dictionary(key_record.get("metadata", {})).get("home_key_id", "")) if not key_record.is_empty() else String(one_time_grant.get("grant_id", ""))
		if access_kind == "one_time":
			var grants: = PlayerHomeContent.normalize_one_time_access(target_home.get("one_time_access", []))
			for grant_index in range(grants.size() - 1, -1, -1):
				if String(grants[grant_index].get("grant_id", "")) == authorization_id:
					grants.remove_at(grant_index)
			target_home["one_time_access"] = grants
			target_owner = set_resident_home_record(target_owner, target_home)
			store_home_access_resident(String(target_entry.get("account_id", "")), int(target_entry.get("resident_slot", -1)), target_owner)
		var visit_id: = "HOME-VISIT-%s" % String(request.get("transaction_id", authorization_id)).sha256_text().left(20).to_upper()
		actor["active_home_visit"] = {
			"visit_id": visit_id, 
			"home_instance_id": String(target_home.get("home_instance_id", "")), 
			"owner_account_id": String(target_entry.get("account_id", "")), 
			"owner_resident_slot": int(target_entry.get("resident_slot", -1)), 
			"access_kind": access_kind, 
			"authorization_id": authorization_id, 
			"started_at_ms": transaction_now_ms(request), 
			"home_snapshot": PlayerHomeContent.visit_snapshot(target_home, String(target_owner.get("name", "Resident"))), 
		}
		actor["area"] = "apartment"
		actor["room_id"] = "unit"
		actor["position"] = [340.0, 243.0]
		actor["home_instance_id"] = String(target_home.get("home_instance_id", ""))
		store_home_access_resident(account_id, resident_slot, actor)
		var affected: Array[Dictionary] = []
		if access_kind == "one_time":
			affected.append({"account_id": target_entry.get("account_id", ""), "resident_slot": target_entry.get("resident_slot", -1)})
		return finalize_home_access_mutation(action, account_id, resident_slot, {"type": "home_visit_entered", "visit_id": visit_id, "access_kind": access_kind, "owner_name": target_owner.get("name", "Resident")}, affected)
	return economy_error(action, "UNKNOWN_ACTION", "The housing desk does not recognize that visitor request.", resident)

func validate_and_apply_economy_mutation(resident: Dictionary, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var updated: = SaveMigration.migrate_resident(resident)
	match action:
		"INVENTORY_USE":
			var inventory: = SaveMigration.inventory_records(updated.get("inventory", []))
			var source_index: = int(request.get("source_index", -1))
			if source_index < 0 or source_index >= inventory.size():
				return economy_error(action, "STALE_INVENTORY", "That carried item is no longer at the expected slot.", resident)
			var selected_record: Dictionary = Dictionary(inventory[source_index]).duplicate(true)
			if not inventory_record_matches_expected(selected_record, request.get("expected_record", {})):
				return economy_error(action, "STALE_INVENTORY", "That carried item changed before it could be used.", resident)
			var item_id: = String(selected_record.get("item_id", ""))
			if not ItemUseRules.is_standard_consumable(item_id):
				return economy_error(action, "ITEM_NOT_USABLE", "That item has no standard carry-use action.", resident)
			if bool(updated.get("downed", false)) or String(updated.get("phase", "adult")) != "adult":
				return economy_error(action, "RESIDENT_UNAVAILABLE", "That Resident cannot use a carried item right now.", resident)
			var effect: = ItemUseRules.apply_standard_effect(
				item_id, float(updated.get("health", 100.0)), float(updated.get("stamina", 100.0)), 
				max_stamina_for_equipment(updated.get("equipment", {}))
			)
			if not bool(effect.get("ok", false)):
				return economy_error(action, String(effect.get("error_code", "NO_EFFECT")), "That item would not change the Resident's current condition.", resident)
			var quantity: = maxi(1, int(selected_record.get("quantity", 1)))
			if quantity <= 1:
				inventory.remove_at(source_index)
			else:
				selected_record["quantity"] = quantity - 1
				inventory[source_index] = selected_record
			updated["inventory"] = inventory
			updated["health"] = float(effect.get("health", updated.get("health", 100.0)))
			updated["stamina"] = float(effect.get("stamina", updated.get("stamina", 100.0)))
			return economy_success(action, updated, {
				"type": "inventory_item_used", "item_id": item_id, "source_index": source_index, 
				"remaining_quantity": quantity - 1, "effect_id": effect.get("effect_id", "standard"), 
				"health_restored": effect.get("health_restored", 0.0), 
				"stamina_restored": effect.get("stamina_restored", 0.0), 
			})
		"INVENTORY_MOVE":
			var inventory: = SaveMigration.inventory_records(updated.get("inventory", []))
			var source_index: = int(request.get("source_index", -1))
			var destination_index: = int(request.get("destination_index", -1))
			if source_index < 0 or source_index >= inventory.size():
				return economy_error(action, "STALE_INVENTORY", "That carried stack is no longer at the expected slot.", resident)
			if destination_index < 0 or destination_index >= inventory.size():
				return economy_error(action, "INVALID_INVENTORY_DESTINATION", "Choose a filled carried slot as the destination.", resident)
			var selected_record: Dictionary = Dictionary(inventory[source_index]).duplicate(true)
			if not inventory_record_matches_expected(selected_record, request.get("expected_record", {})):
				return economy_error(action, "STALE_INVENTORY", "That carried stack changed before the move was filed.", resident)
			if source_index == destination_index:
				return economy_error(action, "INVENTORY_NO_CHANGE", "That carried stack is already in the selected slot.", resident)
			inventory.remove_at(source_index)
			inventory.insert(destination_index, selected_record)
			updated["inventory"] = inventory
			return economy_success(action, updated, {
				"type": "inventory_moved", "item_id": selected_record.get("item_id", ""), 
				"quantity": selected_record.get("quantity", 1), "source_index": source_index, 
				"destination_index": destination_index, "carried_units": inventory_unit_count(inventory), 
			})
		"INVENTORY_SPLIT":
			var inventory: = SaveMigration.inventory_records(updated.get("inventory", []))
			var source_index: = int(request.get("source_index", -1))
			if source_index < 0 or source_index >= inventory.size():
				return economy_error(action, "STALE_INVENTORY", "That carried stack is no longer at the expected slot.", resident)
			var source_record: Dictionary = Dictionary(inventory[source_index]).duplicate(true)
			if not inventory_record_matches_expected(source_record, request.get("expected_record", {})):
				return economy_error(action, "STALE_INVENTORY", "That carried stack changed before the split was filed.", resident)
			var source_quantity: = maxi(1, int(source_record.get("quantity", 1)))
			var split_quantity: = int(request.get("split_quantity", 0))
			if source_quantity <= 1:
				return economy_error(action, "STACK_NOT_SPLITTABLE", "That carried item is already a single unit.", resident)
			if split_quantity <= 0 or split_quantity >= source_quantity:
				return economy_error(action, "INVALID_SPLIT_QUANTITY", "Leave at least one unit in each carried stack.", resident)
			var destination_index: = int(request.get("destination_index", source_index + 1))
			if destination_index < 0 or destination_index > inventory.size():
				return economy_error(action, "INVALID_INVENTORY_DESTINATION", "That split destination is outside the carried inventory.", resident)
			var remaining_record: = source_record.duplicate(true)
			remaining_record["quantity"] = source_quantity - split_quantity
			var split_record: = source_record.duplicate(true)
			split_record["quantity"] = split_quantity
			inventory[source_index] = remaining_record
			inventory.insert(destination_index, split_record)
			updated["inventory"] = inventory
			return economy_success(action, updated, {
				"type": "inventory_split", "item_id": source_record.get("item_id", ""), 
				"split_quantity": split_quantity, "remaining_quantity": source_quantity - split_quantity, 
				"source_index": source_index, "destination_index": destination_index, 
				"carried_units": inventory_unit_count(inventory), 
			})
		"EQUIPMENT_EQUIP":
			var item_id: = String(request.get("item_id", "")).strip_edges()
			var definition: Dictionary = Build10.EQUIPMENT_CATALOG.get(item_id, {})
			if definition.is_empty():
				return economy_error(action, "INVALID_EQUIPMENT_ITEM", "That carried item does not fit an equipment slot.", resident)
			var inventory: = SaveMigration.inventory_records(updated.get("inventory", []))
			var inventory_index: = inventory_record_index(inventory, item_id)
			if inventory_index < 0:
				return economy_error(action, "ITEM_NOT_OWNED", "That item is no longer in carried inventory.", resident)
			var slot_name: = String(definition.get("slot", ""))
			var equipment_records: = SaveMigration.equipment_records(updated.get("equipment", {}))
			if slot_name.begins_with("contingency"):
				slot_name = ""
				for candidate in ["contingency_1", "contingency_2"]:
					if not equipment_records.has(candidate):
						slot_name = candidate
						break
				if slot_name.is_empty():
					return economy_error(action, "CONTINGENCY_SLOTS_FULL", "Both ready-item slots are occupied.", resident)
			if slot_name not in Build10.EQUIPMENT_SLOTS:
				return economy_error(action, "INVALID_EQUIPMENT_SLOT", "That equipment slot is not available.", resident)
			var selected_record: Dictionary = Dictionary(inventory[inventory_index]).duplicate(true)
			var selected_quantity: = maxi(1, int(selected_record.get("quantity", 1)))
			selected_record["quantity"] = 1
			if selected_quantity == 1:
				inventory.remove_at(inventory_index)
			else:
				var remaining_record: = Dictionary(inventory[inventory_index]).duplicate(true)
				remaining_record["quantity"] = selected_quantity - 1
				inventory[inventory_index] = remaining_record
			var previous_value: Variant = equipment_records.get(slot_name, {})
			if previous_value is Dictionary and not (previous_value as Dictionary).is_empty():
				inventory = append_inventory_record(inventory, previous_value as Dictionary)
			equipment_records[slot_name] = selected_record
			var projected_capacity: = carry_capacity_for_equipment(equipment_records)
			if inventory_unit_count(inventory) > projected_capacity:
				return economy_error(action, "INVENTORY_OVER_CAPACITY", "Equipping that item would leave more carried items than the backpack allows.", resident)
			updated["inventory"] = inventory
			updated["equipment"] = equipment_records
			updated["stamina"] = minf(float(updated.get("stamina", 100.0)), max_stamina_for_equipment(equipment_records))
			sync_resident_contingencies(updated)
			return economy_success(action, updated, {"type": "equipment_equipped", "item_id": item_id, "slot": slot_name, "carry_capacity": projected_capacity, "carried_units": inventory_unit_count(inventory)})
		"EQUIPMENT_UNEQUIP":
			var slot_name: = String(request.get("slot", "")).strip_edges().to_lower()
			if slot_name not in Build10.EQUIPMENT_SLOTS:
				return economy_error(action, "INVALID_EQUIPMENT_SLOT", "That equipment slot is not available.", resident)
			var equipment_records: = SaveMigration.equipment_records(updated.get("equipment", {}))
			var equipped_value: Variant = equipment_records.get(slot_name, {})
			if equipped_value is not Dictionary or (equipped_value as Dictionary).is_empty():
				return economy_error(action, "EQUIPMENT_SLOT_EMPTY", "That equipment slot is already empty.", resident)
			var item_record: = (equipped_value as Dictionary).duplicate(true)
			var item_id: = String(item_record.get("item_id", ""))
			equipment_records.erase(slot_name)
			var inventory: = append_inventory_record(updated.get("inventory", []), item_record)
			var projected_capacity: = carry_capacity_for_equipment(equipment_records)
			if inventory_unit_count(inventory) > projected_capacity:
				return economy_error(action, "INVENTORY_OVER_CAPACITY", "Make room before removing that backpack.", resident)
			updated["inventory"] = inventory
			updated["equipment"] = equipment_records
			updated["stamina"] = minf(float(updated.get("stamina", 100.0)), max_stamina_for_equipment(equipment_records))
			sync_resident_contingencies(updated)
			return economy_success(action, updated, {"type": "equipment_unequipped", "item_id": item_id, "slot": slot_name, "carry_capacity": projected_capacity, "carried_units": inventory_unit_count(inventory)})
		"JAIL_ASSIGNMENT_COMPLETE":
			if not bool(updated.get("arrested", false)):
				return economy_error(action, "RESIDENT_NOT_IN_CUSTODY", "That Resident is not serving a jail sentence.", resident)
			if String(updated.get("area", "")) != "jail":
				return economy_error(action, "WRONG_LOCATION", "Jail assignments must be completed inside the jail.", resident)
			var credits_before: = maxi(0, int(updated.get("sentence_credits", 0)))
			if credits_before <= 0:
				return economy_error(action, "SENTENCE_COMPLETE", "No assignment credits remain. Report to the release door.", resident)
			var source_id: = String(request.get("source_id", "")).to_lower()
			if source_id not in JAIL_ASSIGNMENT_REWARDS:
				return economy_error(action, "INVALID_JAIL_ASSIGNMENT", "That jail assignment is not on the sentence ledger.", resident)
			var reward: Dictionary = JAIL_ASSIGNMENT_REWARDS[source_id]
			var xp_rewards: Dictionary = Dictionary(reward.get("xp", {})).duplicate(true)
			var xp: Dictionary = Dictionary(updated.get("xp", {})).duplicate(true)
			for skill_variant in xp_rewards.keys():
				var skill_name: = String(skill_variant)
				if skill_name in Rules.SKILLS:
					xp[skill_name] = maxi(0, int(xp.get(skill_name, 0))) + maxi(0, int(xp_rewards[skill_variant]))
			updated["xp"] = xp
			updated["education_points"] = maxi(0, int(updated.get("education_points", 0))) + maxi(0, int(reward.get("education_points", 0)))
			updated["jail_street_cred"] = maxi(0, int(updated.get("jail_street_cred", 0))) + maxi(0, int(reward.get("jail_street_cred", 0)))
			updated["sentence_credits"] = credits_before - 1
			return economy_success(action, updated, {
				"type": "jail_assignment_completed", "source_id": source_id, 
				"source_label": String(reward.get("label", source_id.to_upper())), 
				"credits_before": credits_before, "credits_remaining": updated["sentence_credits"], 
				"xp": xp_rewards, "education_points": maxi(0, int(reward.get("education_points", 0))), 
				"jail_street_cred": maxi(0, int(reward.get("jail_street_cred", 0))), 
			})
		"JAIL_RELEASE":
			if not bool(updated.get("arrested", false)):
				return economy_error(action, "RESIDENT_NOT_IN_CUSTODY", "That Resident is not serving a jail sentence.", resident)
			if String(updated.get("area", "")) != "jail":
				return economy_error(action, "WRONG_LOCATION", "Release is filed from the jail.", resident)
			if maxi(0, int(updated.get("sentence_credits", 0))) > 0:
				return economy_error(action, "SENTENCE_INCOMPLETE", "%d assignment credits remain." % maxi(0, int(updated.get("sentence_credits", 0))), resident)
			updated["arrested"] = false
			clear_detention_fields(updated)
			updated["area"] = "home"
			updated["room_id"] = "lobby"
			updated["position"] = [850.0, 260.0]
			updated["home_instance_id"] = ""
			updated["health"] = 82.0
			updated["stamina"] = 80.0
			updated["sentence_credits"] = 0
			updated["heat"] = 0
			updated["case_strength"] = 0
			updated["wanted"] = false
			updated["warrant"] = false
			updated["mark_timer"] = 0.0
			updated["crimes"] = []
			return economy_success(action, updated, {
				"type": "jail_release", "release_area": "home", "release_room": "lobby", 
				"release_position": [850.0, 260.0], 
			})
		"BARBER_APPEARANCE":
			if String(updated.get("area", "")) != "barber" or String(updated.get("room_id", "")) != "floor" or resident_saved_position(updated).distance_to(Vector2(250.0, 205.0)) > 120.0:
				return economy_error(action, "WRONG_LOCATION", "Style changes are confirmed in the barber chair.", resident)
			var requested: Variant = request.get("appearance", {})
			if requested is not Dictionary:
				return economy_error(action, "INVALID_APPEARANCE", "That style request could not be read.", resident)
			var appearance: Dictionary = requested as Dictionary
			var hair_style: = String(appearance.get("hair_style", ""))
			var hair_color: = String(appearance.get("hair_color", "")).to_lower()
			var facial_hair_style: = String(appearance.get("facial_hair_style", ""))
			var facial_hair_color: = String(appearance.get("facial_hair_color", "")).to_lower()
			if hair_style not in BARBER_HAIR_STYLES or facial_hair_style not in BARBER_FACIAL_HAIR_STYLES or hair_color not in BARBER_HAIR_COLORS or facial_hair_color not in BARBER_HAIR_COLORS:
				return economy_error(action, "INVALID_APPEARANCE", "That style is not on the barber's current board.", resident)
			var changed_categories: Array[String] = []
			for category in BARBER_CATEGORY_PRICES.keys():
				var proposed: Variant = appearance.get(category, "")
				var current: = String(updated.get(category, "")).to_lower() if category.ends_with("color") else String(updated.get(category, ""))
				var normalized: = String(proposed).to_lower() if category.ends_with("color") else String(proposed)
				if normalized != current:
					changed_categories.append(String(category))
			if changed_categories.is_empty():
				return economy_success(action, updated, {"type": "barber_appearance", "changed_categories": [], "amount_cents": 0})
			var money_type: = String(request.get("money_type", "clean")).to_lower()
			var money_field: = money_field_for_type(money_type)
			if money_field.is_empty():
				return economy_error(action, "INVALID_MONEY_TYPE", "The barber cannot take those funds.", resident)
			var total_cents: = 0
			for category in changed_categories:
				total_cents += int(BARBER_CATEGORY_PRICES[category])
			if int(updated.get(money_field, 0)) < total_cents:
				return economy_error(action, "INSUFFICIENT_FUNDS", "Not enough for that.", resident)
			updated[money_field] = int(updated.get(money_field, 0)) - total_cents
			updated["hair_style"] = hair_style
			updated["hair_color"] = hair_color
			updated["facial_hair_style"] = facial_hair_style
			updated["facial_hair_color"] = facial_hair_color
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {"type": "barber_appearance", "changed_categories": changed_categories, "money_type": money_type, "amount_cents": - total_cents})
		"SOCIAL_INTAKE":
			if String(updated.get("area", "")) != "social" or String(updated.get("room_id", "")) != "lobby" or resident_saved_position(updated).distance_to(Vector2(230.0, 205.0)) > 150.0:
				return economy_error(action, "WRONG_LOCATION", "Benefits intake happens at the Human Obstacles lobby desk.", resident)
			if bool(updated.get("benefits_completed", false)):
				return economy_error(action, "ALREADY_COMPLETED", "That intake is already in your file.", resident)
			if not add_inventory_quantity(updated, "Benefits Packet", 1):
				return economy_error(action, "INVENTORY_FULL", "Make room for the benefits packet before filing intake.", resident)
			updated["benefits_completed"] = true
			var xp: Dictionary = updated.get("xp", {})
			xp["Civics"] = int(xp.get("Civics", 0)) + 90
			xp["Influence"] = int(xp.get("Influence", 0)) + 45
			updated["xp"] = xp
			return economy_success(action, updated, {"type": "social_intake_completed"})
		"APARTMENT_APPLICATION":
			if String(updated.get("area", "")) != "social" or String(updated.get("room_id", "")) != "forms" or resident_saved_position(updated).distance_to(Vector2(500.0, 205.0)) > 150.0:
				return economy_error(action, "WRONG_LOCATION", "Apartment applications are filed at the forms window.", resident)
			if not bool(updated.get("benefits_completed", false)):
				return economy_error(action, "INTAKE_REQUIRED", "Complete benefits intake before filing the apartment application.", resident)
			if inventory_record_index(updated.get("inventory", []), "Apartment Application") >= 0:
				return economy_error(action, "ALREADY_COMPLETED", "That application is already in your carried file.", resident)
			if not add_inventory_quantity(updated, "Apartment Application", 1):
				return economy_error(action, "INVENTORY_FULL", "Make room for the apartment application before filing it.", resident)
			return economy_success(action, updated, {"type": "apartment_application_filed"})
		"APARTMENT_LEASE":
			if String(updated.get("area", "")) != "apartment" or String(updated.get("room_id", "")) != "lobby" or resident_saved_position(updated).distance_to(Vector2(225.0, 205.0)) > 150.0:
				return economy_error(action, "WRONG_LOCATION", "Mercy Court leases are signed at the lobby desk.", resident)
			if bool(updated.get("apartment_leased", false)):
				return economy_error(action, "ALREADY_COMPLETED", "That Resident already holds the current Mercy Court lease.", resident)
			if inventory_record_index(updated.get("inventory", []), "Apartment Application") < 0:
				return economy_error(action, "APPLICATION_REQUIRED", "File an apartment application at Social Services first.", resident)
			var lease_cents: = 9000 if bool(updated.get("benefits_completed", false)) else 18000
			if int(updated.get("carried_cash_clean", 0)) < lease_cents:
				return economy_error(action, "INSUFFICIENT_FUNDS", "Mercy Court requires a $%d deposit." % (lease_cents / 100), resident)
			updated["carried_cash_clean"] = int(updated.get("carried_cash_clean", 0)) - lease_cents
			updated["apartment_leased"] = true
			var properties: Array[Dictionary] = PlayerHomeContent.property_records(updated.get("property", []))
			var home: = PlayerHomeContent.first_player_home(properties, PlayerHomeContent.MERCY_COURT_ID)
			if home.is_empty():
				home = PlayerHomeContent.default_mercy_home(server_world_id, String(request.get("server_account_id", "")), int(request.get("server_resident_slot", -1)))
				properties.append(home)
			updated["property"] = properties
			var credentials: Array = updated.get("credentials", [])
			if "Mercy Court Tenant Credential" not in credentials:
				credentials.append("Mercy Court Tenant Credential")
			updated["credentials"] = credentials
			var xp: Dictionary = updated.get("xp", {})
			xp["Enterprise"] = int(xp.get("Enterprise", 0)) + 120
			updated["xp"] = xp
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {"type": "apartment_leased", "amount_cents": - lease_cents})
		"HOME_CUSTOMIZE":
			if String(updated.get("area", "")) != "apartment" or String(updated.get("room_id", "")) != "unit" or resident_saved_position(updated).distance_to(Vector2(340.0, 205.0)) > 150.0:
				return economy_error(action, "WRONG_LOCATION", "Room changes are filed inside the Resident's private unit.", resident)
			var homes: Array[Dictionary] = PlayerHomeContent.property_records(updated.get("property", []))
			var owned_home: = PlayerHomeContent.first_player_home(homes, PlayerHomeContent.MERCY_COURT_ID)
			if owned_home.is_empty() or not bool(updated.get("apartment_leased", false)):
				return economy_error(action, "HOME_REQUIRED", "A signed Mercy Court lease is required before the room can be changed.", resident)
			if state_home_instance_id(updated) != String(owned_home.get("home_instance_id", "")) or not PlayerHomeContent.normalize_active_visit(updated.get("active_home_visit", {})).is_empty():
				return economy_error(action, "OWNER_ONLY", "Only the owner may change this apartment.", resident)
			var requested_customization: Dictionary = PlayerHomeContent.normalize_customization(request.get("customization", {}))
			for home_index in range(homes.size()):
				if String(homes[home_index].get("property_id", "")) == String(owned_home.get("property_id", "")):
					homes[home_index]["customization"] = requested_customization
					owned_home = homes[home_index].duplicate(true)
					break
			updated["property"] = homes
			updated["home_instance_id"] = String(owned_home.get("home_instance_id", ""))
			return economy_success(action, updated, {"type": "player_home_customized", "home_instance_id": updated["home_instance_id"], "customization": requested_customization})
		"STORAGE_TRANSFER":
			if String(updated.get("area", "")) != "apartment" or String(updated.get("room_id", "")) != "unit":
				return economy_error(action, "WRONG_LOCATION", "Private storage is only available inside the Resident's assigned unit.", resident)
			var owned_storage_home: = PlayerHomeContent.first_player_home(updated.get("property", []), PlayerHomeContent.MERCY_COURT_ID)
			if owned_storage_home.is_empty() or not bool(updated.get("apartment_leased", false)):
				return economy_error(action, "HOME_REQUIRED", "A signed Mercy Court lease is required before using private storage.", resident)
			if state_home_instance_id(updated) != String(owned_storage_home.get("home_instance_id", "")) or not PlayerHomeContent.normalize_active_visit(updated.get("active_home_visit", {})).is_empty():
				return economy_error(action, "OWNER_ONLY", "Private storage remains available only to the apartment owner.", resident)
			var storage_id: = String(request.get("storage_id", "apartment")).to_lower()
			if storage_id != "apartment":
				return economy_error(action, "INVALID_STORAGE", "That storage room is not on the property record.", resident)
			var direction: = String(request.get("direction", "")).to_lower()
			var item_id: = String(request.get("item_id", "")).strip_edges()
			if direction not in ["take", "store"] or item_id.is_empty():
				return economy_error(action, "INVALID_TRANSFER", "That storage transfer could not be filed.", resident)
			var stash_field: = "apartment_stash"
			var stash: Array = Array(updated.get(stash_field, [])).duplicate(true)
			if direction == "take":
				var stash_index: = stash.find(item_id)
				if stash_index < 0:
					return economy_error(action, "ITEM_NOT_FOUND", "That item is not in this storage room.", resident)
				if not add_inventory_quantity(updated, item_id, 1):
					return economy_error(action, "INVENTORY_FULL", "Make room in carried inventory before taking that item.", resident)
				stash.remove_at(stash_index)
			else:
				if item_is_protected(updated, item_id) or item_is_sealed_handoff(updated, item_id) or item_id == "Phone":
					return economy_error(action, "ITEM_PROTECTED", "That item must remain carried.", resident)
				var inventory_index: = inventory_record_index(updated.get("inventory", []), item_id)
				if inventory_index < 0:
					return economy_error(action, "ITEM_NOT_OWNED", "That item is no longer carried.", resident)
				if stash.size() >= int(PlayerHomeContent.catalog_entry(PlayerHomeContent.MERCY_COURT_ID).get("storage_capacity", 30)):
					return economy_error(action, "STORAGE_FULL", "That storage room is full.", resident)
				var inventory: Array = updated.get("inventory", []).duplicate(true)
				var record: Dictionary = Dictionary(inventory[inventory_index]).duplicate(true)
				record["quantity"] = int(record.get("quantity", 1)) - 1
				if int(record["quantity"]) <= 0:
					inventory.remove_at(inventory_index)
				else:
					inventory[inventory_index] = record
				updated["inventory"] = inventory
				stash.append(item_id)
			updated[stash_field] = stash
			return economy_success(action, updated, {"type": "storage_transfer", "storage_id": storage_id, "direction": direction, "item_id": item_id})
		"PURCHASE":
			var vendor_id: = String(request.get("vendor_id", "")).to_lower()
			var item_id: = String(request.get("item_id", ""))
			var quantity: = int(request.get("quantity", 1))
			var money_type: = String(request.get("money_type", "clean")).to_lower()
			var vendor: Dictionary = ECONOMY_VENDOR_CATALOG.get(vendor_id, {})
			var offer: Dictionary = vendor.get(item_id, {})
			if offer.is_empty() or quantity <= 0 or quantity > 9:
				return economy_error(action, "INVALID_PURCHASE", "That item is not available in that quantity.", resident)
			var resident_room: = "%s:%s" % [String(updated.get("area", "")), String(updated.get("room_id", ""))]
			if resident_room != String(ECONOMY_VENDOR_ROOMS.get(vendor_id, "")):
				return economy_error(action, "WRONG_LOCATION", "That purchase belongs at its actual counter.", resident)
			var accepted_money: Array = offer.get("accepted_money", [])
			if money_type not in accepted_money:
				return economy_error(action, "INVALID_MONEY_TYPE", "That counter does not accept those funds.", resident)
			var money_field: = money_field_for_type(money_type)
			if money_field.is_empty():
				return economy_error(action, "INVALID_MONEY_TYPE", "That counter does not accept those funds.", resident)
			var total_cents: = int(offer.get("price_cents", 0)) * quantity
			if int(updated.get(money_field, 0)) < total_cents:
				var message: = "You're a little short on the dirty side." if money_type == "dirty" else "Not enough for that."
				return economy_error(action, "INSUFFICIENT_FUNDS", message, resident)
			var inventory: Array = SaveMigration.inventory_records(updated.get("inventory", []))
			var existing_index: = inventory_record_index(inventory, item_id)
			if inventory_unit_count(inventory) + quantity > resident_carry_capacity(updated):
				return economy_error(action, "INVENTORY_FULL", "You're already carrying as much as you can.", resident)
			updated[money_field] = int(updated.get(money_field, 0)) - total_cents
			if existing_index >= 0:
				var item_record: Dictionary = Dictionary(inventory[existing_index]).duplicate(true)
				item_record["quantity"] = int(item_record.get("quantity", 1)) + quantity
				inventory[existing_index] = item_record
			else:
				var item_record: = SaveMigration.default_item_record(item_id)
				item_record["quantity"] = quantity
				inventory.append(item_record)
			updated["inventory"] = inventory
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {
				"type": "purchase", "vendor_id": vendor_id, "item_id": item_id, 
				"quantity": quantity, "money_type": money_type, "amount_cents": - total_cents, 
			})
		"BANK_DEPOSIT":
			var money_type: = String(request.get("money_type", "clean")).to_lower()
			var amount_cents: = int(request.get("amount_cents", 0))
			if String(updated.get("area", "")) != "bank" or String(updated.get("room_id", "")) != "lobby" or resident_saved_position(updated).distance_to(Vector2(390.0, 200.0)) > 140.0:
				return economy_error(action, "WRONG_LOCATION", "Personal deposits require the teller window.", resident)
			if money_type != "clean":
				return economy_error(action, "INVALID_MONEY_TYPE", "The bank only accepts clean funds.", resident)
			if amount_cents <= 0:
				return economy_error(action, "INVALID_AMOUNT", "Enter an amount greater than zero.", resident)
			if int(updated.get("carried_cash_clean", 0)) < amount_cents:
				return economy_error(action, "INSUFFICIENT_FUNDS", "Not enough for that.", resident)
			updated["carried_cash_clean"] = int(updated.get("carried_cash_clean", 0)) - amount_cents
			updated["bank_balance_clean"] = int(updated.get("bank_balance_clean", 0)) + amount_cents
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {
				"type": "bank_deposit", "money_type": "clean", "amount_cents": amount_cents, 
			})
		"BANK_WITHDRAW":
			var amount_cents: = int(request.get("amount_cents", 0))
			if String(updated.get("area", "")) != "bank" or String(updated.get("room_id", "")) != "lobby" or resident_saved_position(updated).distance_to(Vector2(390.0, 200.0)) > 140.0:
				return economy_error(action, "WRONG_LOCATION", "Withdrawals require the teller window.", resident)
			if amount_cents <= 0:
				return economy_error(action, "INVALID_AMOUNT", "Enter an amount greater than zero.", resident)
			if int(updated.get("bank_balance_clean", 0)) < amount_cents:
				return economy_error(action, "INSUFFICIENT_FUNDS", "Not enough bank funds for that withdrawal.", resident)
			updated["bank_balance_clean"] = int(updated.get("bank_balance_clean", 0)) - amount_cents
			updated["carried_cash_clean"] = int(updated.get("carried_cash_clean", 0)) + amount_cents
			sync_legacy_money_aliases(updated)
			return economy_success(action, updated, {
				"type": "bank_withdrawal", "money_type": "clean", "amount_cents": amount_cents, 
			})
		"LAUNDER_DIRTY_CASH":
			return economy_error(action, "FEATURE_DEFERRED", "Capone's laundering terms are not active in this build.", resident)
		_:
			return economy_error(action, "UNKNOWN_ACTION", "The ledger does not recognize that request.", resident)

func process_cross_resident_economy_request(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var target_account: = safe_tester_id(String(request.get("target_account_id", "")))
	var target_slot: = int(request.get("target_resident_slot", -1))
	if target_account.is_empty() or target_slot < 0 or target_slot >= ReleaseSave.FREE_SLOTS:
		return economy_error(action, "TARGET_NOT_FOUND", "That Resident is not available.", {})
	var actor_roster: = account_roster(account_id)
	var target_roster: = account_roster(target_account)
	var actor_value: Variant = actor_roster["slots"][slot_index]
	var target_value: Variant = target_roster["slots"][target_slot]
	if actor_value is not Dictionary or target_value is not Dictionary:
		return economy_error(action, "TARGET_NOT_FOUND", "That Resident is not available.", {})
	var authoritative_request: = request.duplicate(true)
	authoritative_request["actor_account_id"] = account_id
	authoritative_request["actor_resident_slot"] = slot_index
	var result: = validate_and_apply_cross_resident_mutation(actor_value as Dictionary, target_value as Dictionary, authoritative_request)
	if not bool(result.get("ok", false)):
		return result

	actor_roster["slots"][slot_index] = result.get("resident", {})
	target_roster["slots"][target_slot] = result.get("target_resident", {})
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(actor_roster)
	persistent_profiles[target_account] = ReleaseSave.normalize_roster(target_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: Dictionary = Dictionary(result.get("audit", {})).duplicate(true)
	audit["event_sequence"] = economy_event_sequence
	audit["account_id"] = account_id
	audit["resident_slot"] = slot_index
	audit["target_account_id"] = target_account
	audit["target_resident_slot"] = target_slot
	audit["world_id"] = server_world_id
	audit["server_unix_ms"] = Time.get_unix_time_from_system() * 1000.0
	economy_audit_log.append(audit)
	result["audit"] = audit
	return result

func validate_and_apply_cross_resident_mutation(actor: Dictionary, target: Dictionary, request: Dictionary) -> Dictionary:
	var action: = String(request.get("action", "")).to_upper()
	var updated_actor: = SaveMigration.migrate_resident(actor)
	var updated_target: = SaveMigration.migrate_resident(target)
	if not residents_share_interaction_space(updated_actor, updated_target):
		return cross_resident_economy_error(action, "OUT_OF_RANGE", "A little closer.", actor, target)

	if action == "ARREST":
		if not resident_has_leo_authority(updated_actor):
			return cross_resident_economy_error(action, "INSUFFICIENT_AUTHORITY", "You do not have authority for that.", actor, target)
		if bool(updated_target.get("deceased", false)) or bool(updated_target.get("arrested", false)):
			return cross_resident_economy_error(action, "TARGET_UNAVAILABLE", "A deceased or arrested Resident cannot enter custody again.", actor, target)
		if not Rules.arrest_is_eligible(authoritative_heat(updated_target), bool(updated_target.get("warrant", false))):
			return cross_resident_economy_error(action, "HEAT_TOO_LOW", "There is not enough lawful cause for an arrest.", actor, target)
		var arrest_audit: = complete_authoritative_arrest(updated_target, request)
		return cross_resident_economy_success(action, updated_actor, updated_target, arrest_audit)
	if action == "DETAIN":
		if not resident_has_leo_authority(updated_actor):
			return cross_resident_economy_error(action, "INSUFFICIENT_AUTHORITY", "You do not have authority for temporary detention.", actor, target)
		if bool(updated_target.get("deceased", false)) or bool(updated_target.get("arrested", false)):
			return cross_resident_economy_error(action, "TARGET_UNAVAILABLE", "A deceased or arrested Resident cannot enter temporary detention.", actor, target)
		if bool(updated_target.get("detained", false)):
			return cross_resident_economy_error(action, "ALREADY_DETAINED", "That Resident is already held for review.", actor, target)
		var target_heat: = authoritative_heat(updated_target)
		if target_heat < LEO_DETENTION_MIN_HEAT:
			return cross_resident_economy_error(action, "HEAT_TOO_LOW", "Temporary detention ends below Heat 50.", actor, target)
		updated_target["detained"] = true
		updated_target["detained_by_account_id"] = safe_tester_id(String(request.get("actor_account_id", "")))
		updated_target["detained_by_resident_slot"] = int(request.get("actor_resident_slot", -1))
		updated_target["detained_at_ms"] = transaction_now_ms(request)
		if bool(updated_target.get("downed", false)):
			updated_target["health"] = maxf(70.0, float(updated_target.get("health", 0.0)))
			updated_target["downed"] = false
		return cross_resident_economy_success(action, updated_actor, updated_target, {"type": "temporary_detention", "heat": target_heat, "release_below_heat": LEO_DETENTION_MIN_HEAT})
	if action == "RELEASE_DETENTION":
		if not bool(updated_target.get("detained", false)):
			return cross_resident_economy_error(action, "NO_DETENTION", "That Resident is not temporarily detained.", actor, target)
		var detaining_account: = safe_tester_id(String(updated_target.get("detained_by_account_id", "")))
		var detaining_slot: = int(updated_target.get("detained_by_resident_slot", -1))
		var actor_account: = safe_tester_id(String(request.get("actor_account_id", "")))
		var actor_slot: = int(request.get("actor_resident_slot", -1))
		if detaining_account != actor_account or detaining_slot != actor_slot:
			return cross_resident_economy_error(action, "DETENTION_OWNER_MISMATCH", "Only the detaining authority can release this hold.", actor, target)
		clear_detention_fields(updated_target)
		return cross_resident_economy_success(action, updated_actor, updated_target, {"type": "temporary_detention_released", "reason": "LEO_RELEASED"})
	if action == "SEARCH_ROBBERY" and request.has("money_type"):
		if not bool(updated_target.get("downed", false)) or bool(updated_target.get("arrested", false)):
			return cross_resident_economy_error(action, "TARGET_NOT_DOWNED", "That Resident cannot be searched this way.", actor, target)
		var money_type: = String(request.get("money_type", "")).to_lower()
		var money_field: = money_field_for_type(money_type)
		if money_field not in ["carried_cash_clean", "carried_cash_dirty"]:
			return cross_resident_economy_error(action, "INVALID_MONEY_TYPE", "That money cannot be taken this way.", actor, target)
		var amount_cents: = mini(maxi(0, int(request.get("amount_cents", 0))), int(updated_target.get(money_field, 0)))
		if amount_cents <= 0:
			return cross_resident_economy_error(action, "INSUFFICIENT_FUNDS", "There is no carried cash of that type to take.", actor, target)
		updated_target[money_field] = int(updated_target.get(money_field, 0)) - amount_cents
		updated_actor[money_field] = int(updated_actor.get(money_field, 0)) + amount_cents
		var evidence: Array = updated_actor.get("evidence_history", [])
		evidence.append(EvidenceRecords.inventory_evidence_record(
			"%s-ROBBERY-%s-%d" % [server_world_id, String(request.get("actor_account_id", "")), economy_event_sequence + 1], "robbery", String(request.get("actor_account_id", "")), 
			int(request.get("actor_resident_slot", -1)), String(request.get("target_account_id", "")), int(request.get("target_resident_slot", -1)), 
			String(updated_actor.get("area", "")), String(updated_actor.get("room_id", "")), [], amount_cents, 
			{"money_type": money_type}, transaction_now_ms(request)
		))
		updated_actor["evidence_history"] = evidence
		sync_legacy_money_aliases(updated_actor)
		sync_legacy_money_aliases(updated_target)
		return cross_resident_economy_success(action, updated_actor, updated_target, {"type": "cash_robbery", "money_type": money_type, "amount_cents": amount_cents})
	if action == "SEARCH_ROBBERY_ALL":
		if not bool(updated_target.get("downed", false)) or bool(updated_target.get("arrested", false)):
			return cross_resident_economy_error(action, "TARGET_NOT_DOWNED", "That Resident cannot be searched this way.", actor, target)
		var clean_cents: = maxi(0, int(updated_target.get("carried_cash_clean", 0)))
		var dirty_cents: = maxi(0, int(updated_target.get("carried_cash_dirty", 0)))
		updated_target["carried_cash_clean"] = 0
		updated_target["carried_cash_dirty"] = 0
		updated_actor["carried_cash_clean"] = int(updated_actor.get("carried_cash_clean", 0)) + clean_cents
		updated_actor["carried_cash_dirty"] = int(updated_actor.get("carried_cash_dirty", 0)) + dirty_cents
		var transferred_items: Array[String] = []
		var target_inventory: Array = Array(updated_target.get("inventory", [])).duplicate(true)
		for inventory_variant in target_inventory:
			if inventory_variant is not Dictionary:
				continue
			var item_record: = inventory_variant as Dictionary
			var item_id: = String(item_record.get("item_id", ""))
			if item_id.is_empty() or item_is_protected(updated_target, item_id):
				continue
			var quantity: = maxi(1, int(item_record.get("quantity", 1)))
			if not transfer_inventory_item(updated_target, updated_actor, item_id, quantity):
				continue
			transferred_items.append(item_id)
			if item_is_sealed_handoff(updated_target, item_id):
				var sealed_transfer: = transfer_sealed_handoff_custody(updated_target, updated_actor, item_id, request)
				if not sealed_transfer.is_empty():
					updated_target = sealed_transfer["source"]
					updated_actor = sealed_transfer["destination"]
		if clean_cents <= 0 and dirty_cents <= 0 and transferred_items.is_empty():
			return cross_resident_economy_error(action, "NOTHING_TAKEABLE", "There is nothing unprotected to take.", actor, target)
		var evidence: Array = updated_actor.get("evidence_history", [])
		evidence.append(EvidenceRecords.inventory_evidence_record(
			"%s-ROBBERY-%s-%d" % [server_world_id, String(request.get("actor_account_id", "")), economy_event_sequence + 1], "robbery", String(request.get("actor_account_id", "")), 
			int(request.get("actor_resident_slot", -1)), String(request.get("target_account_id", "")), int(request.get("target_resident_slot", -1)), 
			String(updated_actor.get("area", "")), String(updated_actor.get("room_id", "")), transferred_items, 
			clean_cents + dirty_cents, {"money_type": "all_carried"}, transaction_now_ms(request)
		))
		updated_actor["evidence_history"] = evidence
		sync_legacy_money_aliases(updated_actor)
		sync_legacy_money_aliases(updated_target)
		return cross_resident_economy_success(action, updated_actor, updated_target, {
			"type": "downed_resident_robbery", "clean_cents": clean_cents, "dirty_cents": dirty_cents, 
			"item_ids": transferred_items, 
		})

	var item_id: = String(request.get("item_id", "")).strip_edges()
	var quantity: = maxi(1, int(request.get("quantity", 1)))
	if item_id.is_empty():
		return cross_resident_economy_error(action, "INVALID_ITEM", "That item is not available.", actor, target)

	match action:
		"DIRECT_HANDOFF":
			if bool(updated_actor.get("downed", false)) or bool(updated_actor.get("arrested", false)) or bool(updated_target.get("downed", false)) or bool(updated_target.get("arrested", false)):
				return cross_resident_economy_error(action, "INVALID_STATE", "That handoff cannot happen right now.", actor, target)
			if item_is_protected(updated_actor, item_id) or item_is_sealed_handoff(updated_actor, item_id):
				return cross_resident_economy_error(action, "ITEM_PROTECTED", "That's not something you can hand over.", actor, target)
			if not transfer_inventory_item(updated_actor, updated_target, item_id, quantity):
				return cross_resident_economy_error(action, "ITEM_NOT_OWNED", "That item is no longer available.", actor, target)
			return cross_resident_economy_success(action, updated_actor, updated_target, {"type": "direct_handoff", "item_id": item_id, "quantity": quantity})
		"SEARCH_ROBBERY":
			if not bool(updated_target.get("downed", false)) or bool(updated_target.get("arrested", false)):
				return cross_resident_economy_error(action, "TARGET_NOT_DOWNED", "That Resident cannot be searched this way.", actor, target)
			if item_is_protected(updated_target, item_id):
				return cross_resident_economy_error(action, "ITEM_PROTECTED", "That item stays protected.", actor, target)
			if not transfer_inventory_item(updated_target, updated_actor, item_id, quantity):
				return cross_resident_economy_error(action, "ITEM_NOT_OWNED", "That item is no longer available.", actor, target)
			var robbery_detail: = {"type": "search_robbery", "item_id": item_id, "quantity": quantity}
			if item_is_sealed_handoff(updated_target, item_id):
				var sealed_transfer: = transfer_sealed_handoff_custody(updated_target, updated_actor, item_id, request)
				if sealed_transfer.is_empty():
					return cross_resident_economy_error(action, "HANDOFF_NOT_FOUND", "The sealed handoff record is unavailable.", actor, target)
				updated_target = sealed_transfer["source"]
				updated_actor = sealed_transfer["destination"]
				robbery_detail["nonce"] = sealed_transfer["nonce"]
			return cross_resident_economy_success(action, updated_actor, updated_target, robbery_detail)
		"SEIZURE":
			if not resident_has_leo_authority(updated_actor):
				return cross_resident_economy_error(action, "INSUFFICIENT_AUTHORITY", "You do not have authority for that seizure.", actor, target)
			if not Rules.arrest_is_eligible(authoritative_heat(updated_target), bool(updated_target.get("warrant", false))):
				return cross_resident_economy_error(action, "HEAT_TOO_LOW", "There is not enough lawful cause for that seizure.", actor, target)
			if item_is_protected(updated_target, item_id):
				return cross_resident_economy_error(action, "ITEM_PROTECTED", "That item stays protected.", actor, target)
			if not transfer_inventory_item(updated_target, updated_actor, item_id, quantity):
				return cross_resident_economy_error(action, "ITEM_NOT_OWNED", "That item is no longer available.", actor, target)
			return cross_resident_economy_success(action, updated_actor, updated_target, {"type": "seizure", "item_id": item_id, "quantity": quantity})
		_:
			return cross_resident_economy_error(action, "UNKNOWN_ACTION", "The ledger does not recognize that request.", actor, target)

func transfer_inventory_item(source: Dictionary, destination: Dictionary, item_id: String, quantity: int) -> bool:
	var source_inventory: Array = Array(source.get("inventory", [])).duplicate(true)
	var destination_inventory: Array = Array(destination.get("inventory", [])).duplicate(true)
	var source_index: = inventory_record_index(source_inventory, item_id)
	if source_index < 0:
		return false
	var source_record: Dictionary = Dictionary(source_inventory[source_index]).duplicate(true)
	if int(source_record.get("quantity", 0)) < quantity:
		return false
	if inventory_unit_count(destination_inventory) + quantity > resident_carry_capacity(destination):
		return false
	var destination_index: = inventory_record_index(destination_inventory, item_id)
	source_record["quantity"] = int(source_record.get("quantity", 0)) - quantity
	if int(source_record["quantity"]) <= 0:
		source_inventory.remove_at(source_index)
	else:
		source_inventory[source_index] = source_record
	if destination_index >= 0:
		var destination_record: Dictionary = Dictionary(destination_inventory[destination_index]).duplicate(true)
		destination_record["quantity"] = int(destination_record.get("quantity", 0)) + quantity
		destination_inventory[destination_index] = destination_record
	else:
		var received_record: = source_record.duplicate(true)
		received_record["quantity"] = quantity
		destination_inventory.append(received_record)
	source["inventory"] = source_inventory
	destination["inventory"] = destination_inventory
	return true

func item_is_protected(resident: Dictionary, item_id: String) -> bool:
	var equipment: Dictionary = resident.get("equipment", {})
	for equipped_variant in equipment.values():
		if equipped_variant is Dictionary and String((equipped_variant as Dictionary).get("item_id", "")) == item_id:
			return true
	for credential_variant in resident.get("credentials", []):
		if String(credential_variant) == item_id:
			return true
	return item_id == "Group Home Key" or item_id.ends_with(" Housing Key")

func item_is_sealed_handoff(resident: Dictionary, item_id: String) -> bool:
	for handoff_variant in resident.get("active_handoffs", []):
		if handoff_variant is Dictionary:
			var handoff: = handoff_variant as Dictionary
			if String(handoff.get("id", "")) == item_id or String(handoff.get("display_name", "")) == item_id:
				return true
	return false

func transfer_sealed_handoff_custody(source: Dictionary, destination: Dictionary, item_id: String, request: Dictionary) -> Dictionary:
	var source_handoffs: Array = source.get("active_handoffs", [])
	for index in range(source_handoffs.size()):
		var handoff_variant: Variant = source_handoffs[index]
		if handoff_variant is not Dictionary:
			continue
		var handoff: = (handoff_variant as Dictionary).duplicate(true)
		if String(handoff.get("id", "")) != item_id and String(handoff.get("display_name", "")) != item_id:
			continue
		var source_account: = String(handoff.get("owner_tester_id", ""))
		var source_slot: = int(handoff.get("owner_resident_slot", -1))
		handoff["original_cashier_account_id"] = String(handoff.get("original_cashier_account_id", source_account))
		handoff["original_cashier_resident_slot"] = int(handoff.get("original_cashier_resident_slot", source_slot))
		handoff["owner_tester_id"] = safe_tester_id(String(request.get("actor_account_id", "")))
		handoff["owner_resident_slot"] = int(request.get("actor_resident_slot", -1))
		var custody_events: Array = handoff.get("custody_events", [])
		custody_events.append({
			"type": "robbery", "taken_from_account_id": source_account, "taken_from_resident_slot": source_slot, 
			"taken_by_account_id": handoff["owner_tester_id"], "taken_by_resident_slot": handoff["owner_resident_slot"], 
			"room_id": String(source.get("room_id", "")), "server_unix_ms": transaction_now_ms(request), 
		})
		handoff["custody_events"] = custody_events
		source_handoffs.remove_at(index)
		var destination_handoffs: Array = destination.get("active_handoffs", [])
		destination_handoffs.append(handoff)
		source["active_handoffs"] = source_handoffs
		destination["active_handoffs"] = destination_handoffs
		var employment: = cashier_employment_record(source)
		if not employment.is_empty():
			employment["last_outcome"] = "stolen_not_at_fault"
			set_cashier_employment_record(source, employment)
		return {"source": source, "destination": destination, "nonce": handoff.get("authority_nonce", "")}
	return {}

func resident_has_leo_authority(resident: Dictionary) -> bool:
	for credential_variant in resident.get("credentials", []):
		if String(credential_variant) in ["Law Enforcement Credential", "Police Officer Credential"]:
			return true
	return String(resident.get("official_function", "")) == "Law Enforcement Officer"

func authoritative_heat(resident: Dictionary) -> int:
	return Rules.normalized_heat(int(resident.get("heat", resident.get("case_strength", 0))))

func clear_detention_fields(resident: Dictionary) -> void :
	resident["detained"] = false
	resident["detained_by_account_id"] = ""
	resident["detained_by_resident_slot"] = -1
	resident["detained_at_ms"] = 0

func complete_authoritative_arrest(resident: Dictionary, request: Dictionary) -> Dictionary:



	var crimes: Array[String] = []
	for crime_variant in resident.get("crimes", []):
		crimes.append(String(crime_variant))
	var sentence: = Rules.sentence_credits(crimes)
	resident["arrested"] = true
	resident["downed"] = false
	resident["health"] = maxf(1.0, float(resident.get("health", 100.0)))
	resident["stamina"] = 70.0
	resident["area"] = "jail"
	resident["room_id"] = "tier"
	resident["position"] = [100.0, 220.0]
	resident["home_instance_id"] = ""
	resident["sentence_credits"] = sentence
	resident["crimes"] = []
	resident["warrant"] = false
	resident["wanted"] = false
	resident["mark_timer"] = 0.0
	resident["carried_cash_dirty"] = 0
	resident["dirty_cash"] = 0
	resident["active_handoffs"] = []
	resident["handoff_items"] = {}
	resident["deposit_active"] = false
	resident["deposit_value"] = 0
	resident["deposit_source"] = "store"
	var inventory: Array = SaveMigration.inventory_records(resident.get("inventory", []))
	var custody_invalid_items: = ["Entrusted Deposit Bag", "Restaurant Deposit", "Laundry Deposit", "Sealed Deposit Bag", "Sealed Restaurant Deposit", "Sealed Laundry Deposit"]
	for index in range(inventory.size() - 1, -1, -1):
		if String(Dictionary(inventory[index]).get("item_id", "")) in custody_invalid_items:
			inventory.remove_at(index)
	resident["inventory"] = inventory
	return {
		"type": "arrest", 
		"heat": authoritative_heat(resident), 
		"sentence_credits": sentence, 
		"crimes_cleared": crimes, 
		"transport_area": "jail", 
		"transport_room": "tier", 
		"transport_position": [100.0, 220.0], 
		"server_unix_ms": transaction_now_ms(request), 
	}

func residents_share_interaction_space(first: Dictionary, second: Dictionary) -> bool:
	if not states_share_room_instance(first, second):
		return false
	return resident_saved_position(first).distance_to(resident_saved_position(second)) <= 110.0

func resident_saved_position(resident: Dictionary) -> Vector2:
	var value: Variant = resident.get("position", [0.0, 0.0])
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func find_handoff_owner(nonce: String) -> Dictionary:
	if nonce.is_empty():
		return {}
	for account_variant in persistent_profiles.keys():
		var account_id: = String(account_variant)
		var roster: = account_roster(account_id)
		var slots: Array = roster.get("slots", [])
		for slot_index in range(slots.size()):
			var resident_value: Variant = slots[slot_index]
			if resident_value is not Dictionary:
				continue
			for handoff_variant in (resident_value as Dictionary).get("active_handoffs", []):
				if handoff_variant is Dictionary and String((handoff_variant as Dictionary).get("authority_nonce", "")) == nonce:
					return {"account_id": account_id, "resident_slot": slot_index, "handoff": (handoff_variant as Dictionary).duplicate(true)}
	return {}

func complete_tracked_handoff(account_id: String, slot_index: int, request: Dictionary) -> Dictionary:
	var nonce: = String(request.get("nonce", "")).strip_edges()
	var server_roster: = account_roster(account_id)
	var resident_value: Variant = server_roster["slots"][slot_index]
	if resident_value is not Dictionary:
		return economy_error("HANDOFF_COMPLETE", "RESIDENT_NOT_FOUND", "The city could not find that Resident file.", {})
	var resident: = SaveMigration.migrate_resident(resident_value as Dictionary)
	var completed: Dictionary = resident.get("completed_handoffs", {})
	if completed.has(nonce):
		return economy_error("HANDOFF_COMPLETE", "ALREADY_COMPLETED", "That handoff was already completed.", resident)
	var owner: = find_handoff_owner(nonce)
	if owner.is_empty() or String(owner.get("account_id", "")) != account_id or int(owner.get("resident_slot", -1)) != slot_index:
		return economy_error("HANDOFF_COMPLETE", "WRONG_OWNER", "That handoff belongs to a different Resident file.", resident)
	var active_handoffs: Array = resident.get("active_handoffs", [])
	var handoff_index: = -1
	for index in range(active_handoffs.size()):
		var handoff_variant: Variant = active_handoffs[index]
		if handoff_variant is Dictionary and String((handoff_variant as Dictionary).get("authority_nonce", "")) == nonce:
			handoff_index = index
			break
	if handoff_index < 0:
		return economy_error("HANDOFF_COMPLETE", "HANDOFF_NOT_FOUND", "Something went wrong with the delivery. Try again.", resident)
	var handoff: Dictionary = Dictionary(active_handoffs[handoff_index]).duplicate(true)
	var destination_area: = String(handoff.get("destination_area", "bank"))
	var destination_room: = String(handoff.get("destination_room_id", "lobby"))
	if String(request.get("area", "")) != destination_area or String(request.get("room_id", "")) != destination_room:
		return economy_error("HANDOFF_COMPLETE", "WRONG_DESTINATION", "That delivery belongs somewhere else.", resident)
	if destination_area == "bank" and destination_room == "lobby" and resident_saved_position(resident).distance_to(Vector2(820.0, 225.0)) > 110.0:
		return economy_error("HANDOFF_COMPLETE", "OUT_OF_RANGE", "The sealed-job box is a little closer.", resident)
	var expired: = bool(handoff.get("expired", false)) or float(handoff.get("active_seconds_remaining", 1.0)) <= 0.0
	active_handoffs.remove_at(handoff_index)
	handoff["state"] = "completed"
	handoff["outcome"] = "COMPLETED"
	handoff["completed_at_ms"] = transaction_now_ms(request)
	completed[nonce] = handoff
	resident["active_handoffs"] = active_handoffs
	resident["completed_handoffs"] = completed
	var inventory: Array = resident.get("inventory", [])
	var display_name: = String(handoff.get("display_name", handoff.get("id", "")))
	var item_id: = String(handoff.get("id", display_name))
	var inventory_index: = inventory_record_index(inventory, item_id)
	if inventory_index < 0:
		inventory_index = inventory_record_index(inventory, display_name)
	if inventory_index >= 0:
		inventory.remove_at(inventory_index)
	resident["inventory"] = inventory
	var payment_cents: = 0 if expired else maxi(0, int(handoff.get("payment_cents", 0)))
	resident["bank_balance_clean"] = int(resident.get("bank_balance_clean", 0)) + payment_cents
	var employment: = cashier_employment_record(resident)
	if not employment.is_empty():
		if expired:
			employment["last_outcome"] = "expired"
			employment["warnings"] = int(employment.get("warnings", 0)) + 1
			employment["trust"] = maxi(0, int(employment.get("trust", 20)) - 5)
		else:
			employment["last_outcome"] = "delivered"
			employment["trust"] = mini(100, int(employment.get("trust", 20)) + 1)
		var xp: Dictionary = resident.get("xp", {})
		xp["Enterprise"] = int(xp.get("Enterprise", 0)) + (25 if expired else 50)
		resident["xp"] = xp
		set_cashier_employment_record(resident, employment)
	apply_service_handoff_outcome(resident, handoff, expired)
	sync_legacy_money_aliases(resident)
	server_roster["slots"][slot_index] = resident
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(server_roster)
	profiles_dirty = true
	economy_event_sequence += 1
	var audit: = {
		"event_sequence": economy_event_sequence, "type": "handoff_completed", "nonce": nonce, 
		"account_id": account_id, "resident_slot": slot_index, "world_id": server_world_id, 
		"amount_cents": payment_cents, "expired": expired, "server_unix_ms": transaction_now_ms(request), 
	}
	economy_audit_log.append(audit)
	return economy_success("HANDOFF_COMPLETE", resident, audit)

func cross_resident_economy_success(action: String, resident: Dictionary, target: Dictionary, audit: Dictionary) -> Dictionary:
	var result: = economy_success(action, resident, audit)
	result["target_resident"] = target
	return result

func cross_resident_economy_error(action: String, code: String, message: String, resident: Dictionary, target: Dictionary) -> Dictionary:
	var result: = economy_error(action, code, message, resident)
	result["target_resident"] = SaveMigration.migrate_resident(target)
	return result

func economy_success(action: String, resident: Dictionary, audit: Dictionary) -> Dictionary:
	return {
		"ok": true, 
		"action": action, 
		"error_code": "", 
		"error_message": "", 
		"resident": resident, 
		"balances": economy_balances(resident), 
		"inventory": Array(resident.get("inventory", [])).duplicate(true), 
		"audit": audit, 
	}

func economy_error(action: String, code: String, message: String, resident: Dictionary, transaction_id: String = "") -> Dictionary:
	var authoritative: = SaveMigration.migrate_resident(resident) if not resident.is_empty() else {}
	return {
		"ok": false, 
		"action": action, 
		"transaction_id": transaction_id, 
		"error_code": code, 
		"error_message": message, 
		"resident": authoritative, 
		"balances": economy_balances(authoritative), 
		"inventory": Array(authoritative.get("inventory", [])).duplicate(true), 
	}

func economy_balances(resident: Dictionary) -> Dictionary:
	return {
		"carried_cash_clean": maxi(0, int(resident.get("carried_cash_clean", 0))), 
		"carried_cash_dirty": maxi(0, int(resident.get("carried_cash_dirty", 0))), 
		"bank_balance_clean": maxi(0, int(resident.get("bank_balance_clean", 0))), 
	}

func money_field_for_type(money_type: String) -> String:
	match money_type:
		"clean": return "carried_cash_clean"
		"dirty": return "carried_cash_dirty"
		"bank": return "bank_balance_clean"
		_: return ""

func inventory_record_index(inventory: Array, item_id: String) -> int:
	for index in range(inventory.size()):
		var entry: Variant = inventory[index]
		if entry is Dictionary and String((entry as Dictionary).get("item_id", "")) == item_id:
			return index
	return -1

func sync_legacy_money_aliases(resident: Dictionary) -> void :
	resident["cash"] = floori(float(resident.get("carried_cash_clean", 0)) / 100.0)
	resident["dirty_cash"] = floori(float(resident.get("carried_cash_dirty", 0)) / 100.0)
	resident["bank_balance"] = floori(float(resident.get("bank_balance_clean", 0)) / 100.0)

func store_connected_resident(peer_id: int) -> void :
	if peer_id not in peer_states:
		return
	var state: Dictionary = peer_states[peer_id]
	var slot_index: = int(state.get("resident_slot", -1))
	var tester_key: = safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", ""))))
	if slot_index < 0 or tester_key.is_empty():
		return
	var server_roster: = account_roster(tester_key)
	var existing: Variant = server_roster["slots"][slot_index]
	if existing is not Dictionary:
		return
	var merged: Dictionary = (existing as Dictionary).duplicate(true)
	var state_only_keys: = ["peer_id", "tester_id", "resident_slot", "invite_token", "roster_request", "cash", "dirty_cash", "bank_balance", "inventory", "equipment", "credentials", "skills", "active_job", "apartment_leased", "home_stash", "apartment_stash", "property", "home_instance_id", "active_home_visit", "case_strength", "heat", "detained", "detained_by_account_id", "detained_by_resident_slot", "detained_at_ms", "wanted", "warrant", "arrested", "sentence_credits", "education_points", "jail_street_cred", "jail_favors", "jail_snitch_heat", "handoff_items", "dealer_relationships", "active_substance_effects", "phone_messages", "crimes"]
	var color_keys: = ["color", "skin", "pants_color", "hair_color", "facial_hair_color"]
	for key in state.keys():
		if key not in state_only_keys:
			var state_value: Variant = state[key]
			merged[key] = (state_value as Color).to_html(false) if key in color_keys and state_value is Color else state_value
	if merged.get("position", null) is Vector2:
		var point: Vector2 = merged["position"]
		merged["position"] = [point.x, point.y]
	var heat: = authoritative_heat(state)
	merged["heat"] = heat
	merged["case_strength"] = heat
	merged["detained"] = bool(state.get("detained", false))
	merged["detained_by_account_id"] = String(state.get("detained_by_account_id", ""))
	merged["detained_by_resident_slot"] = int(state.get("detained_by_resident_slot", -1))
	merged["detained_at_ms"] = maxi(0, int(state.get("detained_at_ms", 0)))
	merged["arrested"] = bool(state.get("arrested", false))
	_store_resident_for_account(tester_key, slot_index, merged)

func store_all_connected_residents() -> void :
	for peer_variant in peer_states.keys():
		store_connected_resident(int(peer_variant))

func delete_server_resident(slot_index: int) -> void :
	if not active or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return
	if hosting:
		resident_save_result.emit(_delete_resident_for_account(String(peer_accounts.get(local_peer_id(), "")), slot_index, local_peer_id()))
	else:
		delete_server_resident_on_host.rpc_id(1, slot_index)

@rpc("any_peer", "call_remote", "reliable")
func delete_server_resident_on_host(slot_index: int) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	receive_resident_save_result.rpc_id(sender, _delete_resident_for_account(String(peer_accounts.get(sender, "")), slot_index, sender))

func _delete_resident_for_account(tester_key: String, slot_index: int, peer_id: int, simulate_disk_failure: bool = false) -> Dictionary:
	var clean_key: = safe_tester_id(tester_key)
	if clean_key.is_empty() or slot_index < 0 or slot_index >= ReleaseSave.FREE_SLOTS:
		return {"ok": false, "kind": "resident_deleted", "error_code": "INVALID_RESIDENT_SLOT", "message": "The server could not identify that Resident slot.", "slot_index": slot_index}
	var previous_roster: = account_roster(clean_key).duplicate(true)
	var resident_value: Variant = previous_roster["slots"][slot_index]
	var draft_value: Variant = previous_roster["tutorial_drafts"][slot_index]
	var had_resident: = resident_value is Dictionary
	var had_tutorial_draft: = draft_value is Dictionary
	if not had_resident and not had_tutorial_draft:
		return {"ok": false, "kind": "resident_deleted", "error_code": "RESIDENT_SLOT_EMPTY", "message": "That Resident file is already empty.", "slot_index": slot_index}
	var deleted_name: = String((resident_value as Dictionary).get("name", "UNNAMED")) if had_resident else "UNFINISHED TUTORIAL"
	var deleted_kind: = "resident_and_tutorial" if had_resident and had_tutorial_draft else "resident" if had_resident else "tutorial_draft"
	var server_roster: = ReleaseSave.delete_resident(previous_roster, slot_index)
	if not persist_account_roster_atomically(clean_key, server_roster, simulate_disk_failure):
		return {"ok": false, "kind": "resident_deleted", "error_code": "PERSISTENCE_FAILED", "message": "The server could not durably delete that Resident file. Nothing was changed.", "slot_index": slot_index}
	if peer_id in peer_states and int(Dictionary(peer_states[peer_id]).get("resident_slot", -1)) == slot_index:
		var cleared_state: Dictionary = Dictionary(peer_states[peer_id]).duplicate(true)
		cleared_state["resident_slot"] = -1
		cleared_state["resident_key"] = ""
		peer_states[peer_id] = cleared_state
	return {
		"ok": true, 
		"kind": "resident_deleted", 
		"slot_index": slot_index, 
		"deleted_kind": deleted_kind, 
		"deleted_name": deleted_name, 
		"roster": server_roster.duplicate(true), 
		"durable": true, 
	}
func _reject_peer(peer_id: int, reason: String) -> void :
	if enet_peer != null:
		enet_peer.disconnect_peer(peer_id)
	peer_states.erase(peer_id)
	authorized_peers.erase(peer_id)
	peer_accounts.erase(peer_id)
	_set_status("A CONNECTION WAS REJECTED  -  " + reason)

func initialize_authoritative_laundry_office() -> void :
	laundry_office_npcs.clear()
	laundry_hostile_until_ms.clear()
	laundry_capone_direct_until_ms.clear()
	laundry_office_presence.clear()
	laundry_defeat_pending.clear()
	laundry_capone_disposition_started.clear()
	var defender_index: = 0
	for record_value in RoomObjects.records_for(LAUNDRY_OFFICE_AREA, LAUNDRY_OFFICE_ROOM, "adult"):
		var record: Dictionary = record_value
		if String(record.get("render_mode", "")) != "runtime_actor":
			continue
		var actor_id: = String(record.get("actor_id", ""))
		if actor_id.is_empty():
			continue
		var is_capone: = actor_id == "laundry_capone"
		var point: Vector2 = record.get("position", Vector2.ZERO)
		var roam_points: Array = Array(record.get("roam_points", [])).duplicate(true)
		laundry_office_npcs[actor_id] = {
			"actor_id": actor_id, 
			"display_name": "Capone" if is_capone else "Union Member %d" % (defender_index + 1), 
			"role": "Capone" if is_capone else "Union Defender", 
			"area": LAUNDRY_OFFICE_AREA, 
			"room_id": LAUNDRY_OFFICE_ROOM, 
			"position": point, 
			"home_position": point, 
			"health": 100.0, 
			"downed": false, 
			"removed": false, 
			"restrained": false, 
			"maimed": false, 
			"ai_state": "idle" if is_capone else "laundry_union_idle", 
			"roam_points": roam_points, 
			"roam_index": 0, 
			"roam_wait_timer": 0.0 if is_capone else 25.0 + float(defender_index), 
			"move_speed": 72.0, 
			"attack_cooldown": 0.0, 
			"downed_elapsed": 0.0, 
			"respawn_timer": 0.0, 
		}
		if not is_capone:
			defender_index += 1

func laundry_office_actor_id_is_known(actor_id: String) -> bool:
	return actor_id in laundry_office_npcs and (actor_id == "laundry_capone" or actor_id.begins_with("laundry_union_"))

func peer_is_in_laundry_office(state: Dictionary) -> bool:
	return String(state.get("phase", "adult")) == "adult" and String(state.get("area", "")) == LAUNDRY_OFFICE_AREA and String(state.get("room_id", "")) == LAUNDRY_OFFICE_ROOM

func peer_has_law_path(state: Dictionary) -> bool:
	return bool(state.get("on_duty", false)) or String(state.get("active_job", "")) == "Security Guard" or resident_has_leo_authority(state)

func laundry_hostility_active_for_peer(peer_id: int, now_ms: int = -1) -> bool:
	var checked_at: = Time.get_ticks_msec() if now_ms < 0 else now_ms
	return checked_at < int(laundry_hostile_until_ms.get(peer_id, 0))

func laundry_capone_direct_for_peer(peer_id: int, now_ms: int = -1) -> bool:
	var checked_at: = Time.get_ticks_msec() if now_ms < 0 else now_ms
	return checked_at < int(laundry_capone_direct_until_ms.get(peer_id, 0))

func activate_laundry_hostility_for_peer(peer_id: int, directly_attacked_actor_id: String = "", now_ms: int = -1) -> bool:
	if peer_id not in peer_states:
		return false
	var activated_at: = Time.get_ticks_msec() if now_ms < 0 else now_ms
	laundry_hostile_until_ms[peer_id] = maxi(int(laundry_hostile_until_ms.get(peer_id, 0)), activated_at + LAUNDRY_MOB_HOSTILITY_MS)
	if directly_attacked_actor_id == "laundry_capone":
		laundry_capone_direct_until_ms[peer_id] = maxi(int(laundry_capone_direct_until_ms.get(peer_id, 0)), activated_at + LAUNDRY_MOB_HOSTILITY_MS)
	_schedule_snapshot()
	return true

func clear_laundry_hostility_for_peer(peer_id: int) -> void :
	laundry_hostile_until_ms.erase(peer_id)
	laundry_capone_direct_until_ms.erase(peer_id)
	laundry_defeat_pending.erase(peer_id)
	laundry_capone_disposition_started.erase(peer_id)

func laundry_money_desk_success_chance_for_peer(peer_id: int) -> float:
	if peer_id not in peer_states:
		return 0.0
	return minf(0.9, maxf(0.0, float(state_skill_level(peer_states[peer_id], "Stealth"))) / 20.0)

func resolve_laundry_money_desk_detection(peer_id: int, roll: float, now_ms: int = -1) -> Dictionary:
	if not hosting or peer_id not in peer_states or not peer_is_in_laundry_office(peer_states[peer_id]):
		return {"accepted": false, "error_code": "WRONG_LOCATION"}
	var chance: = laundry_money_desk_success_chance_for_peer(peer_id)
	var detected: = clampf(roll, 0.0, 1.0) >= chance
	if detected:
		activate_laundry_hostility_for_peer(peer_id, "", now_ms)
	return {"accepted": true, "detected": detected, "success_chance": chance, "payout": "FEATURE_DEFERRED"}

func laundry_office_position_is_valid(point: Vector2) -> bool:
	return point.x >= LAUNDRY_OFFICE_LEFT_WALK_X and point.x <= 955.0 and point.y >= 135.0 and point.y <= 290.0 and not LAUNDRY_OFFICE_DESK_CLEARANCE.has_point(point)

func laundry_office_navigation_target(origin: Vector2, target: Vector2) -> Vector2:
	var segment_bounds: = Rect2(
		Vector2(minf(origin.x, target.x), minf(origin.y, target.y)), 
		Vector2(maxf(1.0, absf(target.x - origin.x)), maxf(1.0, absf(target.y - origin.y)))
	)
	if not LAUNDRY_OFFICE_DESK_CLEARANCE.intersects(segment_bounds, true):
		return target
	var left_x: = LAUNDRY_OFFICE_DESK_CLEARANCE.position.x - 18.0
	var right_x: = LAUNDRY_OFFICE_DESK_CLEARANCE.end.x + 18.0
	var side_x: = left_x if absf(target.x - left_x) <= absf(target.x - right_x) else right_x
	if origin.x > LAUNDRY_OFFICE_DESK_CLEARANCE.position.x and origin.x < LAUNDRY_OFFICE_DESK_CLEARANCE.end.x:
		return Vector2(side_x, origin.y)
	if (origin.y < LAUNDRY_OFFICE_DESK_CLEARANCE.position.y and target.y > LAUNDRY_OFFICE_DESK_CLEARANCE.end.y) or (origin.y > LAUNDRY_OFFICE_DESK_CLEARANCE.end.y and target.y < LAUNDRY_OFFICE_DESK_CLEARANCE.position.y):
		return Vector2(origin.x, LAUNDRY_OFFICE_DESK_CLEARANCE.position.y - 18.0 if origin.y < LAUNDRY_OFFICE_DESK_CLEARANCE.position.y else LAUNDRY_OFFICE_DESK_CLEARANCE.end.y + 18.0)
	return Vector2(side_x, target.y)

func move_authoritative_laundry_actor(actor: Dictionary, target: Vector2, distance: float) -> bool:
	var origin: = state_position(actor)
	var navigation_target: = laundry_office_navigation_target(origin, target)
	var candidate: = origin.move_toward(navigation_target, maxf(0.0, distance))
	var result: = origin
	if laundry_office_position_is_valid(candidate):
		result = candidate
	else:
		var horizontal: = Vector2(candidate.x, origin.y)
		var vertical: = Vector2(origin.x, candidate.y)
		if laundry_office_position_is_valid(horizontal):
			result = horizontal
		elif laundry_office_position_is_valid(vertical):
			result = vertical
	actor["position"] = result
	return result != origin

func nearest_laundry_target_for_actor(actor: Dictionary, require_downed: bool = false, require_direct_capone_attack: bool = false, now_ms: int = -1) -> int:
	var checked_at: = Time.get_ticks_msec() if now_ms < 0 else now_ms
	var best_peer: = 0
	var best_distance: = INF
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		var peer: Dictionary = peer_states[peer_id]
		if not peer_is_in_laundry_office(peer) or bool(peer.get("arrested", false)):
			continue
		if not laundry_hostility_active_for_peer(peer_id, checked_at):
			continue
		if require_direct_capone_attack and not laundry_capone_direct_for_peer(peer_id, checked_at):
			continue
		if bool(peer.get("downed", false)) != require_downed:
			continue
		if require_downed and not bool(laundry_defeat_pending.get(peer_id, false)):
			continue
		var distance: = state_position(actor).distance_to(state_position(peer))
		if distance < best_distance:
			best_distance = distance
			best_peer = peer_id
	return best_peer

func authoritative_laundry_actor_attack(actor_id: String, target_peer_id: int) -> Dictionary:
	if actor_id not in laundry_office_npcs or target_peer_id not in peer_states:
		return {}
	var actor: Dictionary = laundry_office_npcs[actor_id]
	var target: Dictionary = peer_states[target_peer_id]
	if bool(actor.get("downed", false)) or bool(actor.get("removed", false)) or bool(target.get("downed", false)):
		return {}
	if state_position(actor).distance_to(state_position(target)) > LAUNDRY_NPC_ATTACK_DISTANCE:
		return {}
	var damage: = LAUNDRY_NPC_DAMAGE
	var new_health: = maxf(0.0, float(target.get("health", 100.0)) - damage)
	target["health"] = new_health
	target["downed"] = new_health <= 0.0
	peer_states[target_peer_id] = target
	actor["attack_cooldown"] = LAUNDRY_NPC_ATTACK_COOLDOWN
	laundry_office_npcs[actor_id] = actor
	combat_event_sequence += 1
	var payload: = {
		"event_id": combat_event_sequence, 
		"attacker_id": 0, 
		"attacker_actor_id": actor_id, 
		"target_id": target_peer_id, 
		"area": LAUNDRY_OFFICE_AREA, 
		"room_id": LAUNDRY_OFFICE_ROOM, 
		"home_instance_id": "", 
		"attacker_position": state_position(actor), 
		"impact_position": state_position(target), 
		"weapon": "Fists", 
		"duration": 0.24, 
		"damage": damage, 
		"hit": true, 
		"downed": new_health <= 0.0, 
		"blood_amount": 10 if new_health <= 0.0 else 5, 
		"blood_seed": combat_event_sequence * 7919 + actor_id.hash(), 
	}
	payload["blood_evidence"] = add_blood_evidence_record(payload)
	if new_health <= 0.0:
		laundry_defeat_pending[target_peer_id] = true
		authoritative_downed_timers.erase(target_peer_id)
		_broadcast_chat("SYSTEM", "%s downed %s in the laundromat office." % [String(actor.get("display_name", "Union member")), String(target.get("name", "Resident"))])
	if profiles_enabled:
		store_connected_resident(target_peer_id)
	_schedule_snapshot()
	broadcast_combat_event(payload)
	return payload

func resolve_capone_disposition(target_peer_id: int) -> Dictionary:
	if target_peer_id not in peer_states or bool(laundry_capone_disposition_started.get(target_peer_id, false)) or target_has_pending_outcome(target_peer_id):
		return {}
	var target: Dictionary = peer_states[target_peer_id]
	if not bool(target.get("downed", false)) or not laundry_hostility_active_for_peer(target_peer_id):
		return {}
	laundry_capone_disposition_started[target_peer_id] = true
	laundry_defeat_pending.erase(target_peer_id)
	var fatal_attempt: = float(target.get("mark", 0.0)) > 0.0 or bool(target.get("wanted", false))
	var roll: = combat_rng.randi_range(1, 16)
	var success: = Rules.fatality_succeeds(roll, fatal_attempt)
	var interrupted: = fatal_attempt and success and bool(target.get("contingency", false))
	if interrupted:
		success = false
	var duration: = combat_rng.randf_range(5.0, 8.0)
	permanent_outcome_sequence += 1
	var outcome_id: = "%s-CAPONE-%d" % [server_world_id if not server_world_id.is_empty() else "SESSION", permanent_outcome_sequence]
	pending_permanent_outcomes.append({"target": target_peer_id, "fatal": fatal_attempt, "success": success, "remaining": duration, "outcome_id": outcome_id, "outcome_sequence": permanent_outcome_sequence})
	var payload: = {"lan": true, "fatal": fatal_attempt, "success": success, "roll": roll, "duration": duration, "attacker": "Capone", "interrupted": interrupted, "outcome_id": outcome_id}
	send_permanent_outcome(target_peer_id, payload)
	_broadcast_chat("SYSTEM", "Capone reached a downed hostile Resident. The result is sealed.")
	clear_laundry_hostility_for_peer(target_peer_id)
	_schedule_snapshot()
	return payload

func update_authoritative_laundry_office(delta: float) -> void :
	if laundry_office_npcs.is_empty():
		initialize_authoritative_laundry_office()
	var now_ms: = Time.get_ticks_msec()
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		var inside: = peer_is_in_laundry_office(peer_states[peer_id])
		var was_inside: = bool(laundry_office_presence.get(peer_id, false))
		if inside and not was_inside and peer_has_law_path(peer_states[peer_id]):
			activate_laundry_hostility_for_peer(peer_id, "", now_ms)
		if inside:
			laundry_office_presence[peer_id] = true
		else:
			laundry_office_presence.erase(peer_id)
	var changed: = false
	for actor_id_value in laundry_office_npcs.keys():
		var actor_id: = String(actor_id_value)
		var actor: Dictionary = laundry_office_npcs[actor_id]
		if bool(actor.get("removed", false)):
			actor["respawn_timer"] = float(actor.get("respawn_timer", 0.0)) - delta
			if float(actor["respawn_timer"]) <= 0.0:
				actor["removed"] = false
				actor["downed"] = false
				actor["restrained"] = false
				actor["health"] = 100.0
				actor["position"] = actor.get("home_position", Vector2.ZERO)
				actor["ai_state"] = "idle" if actor_id == "laundry_capone" else "laundry_union_idle"
				changed = true
			laundry_office_npcs[actor_id] = actor
			continue
		if bool(actor.get("downed", false)) or bool(actor.get("restrained", false)):
			actor["downed_elapsed"] = float(actor.get("downed_elapsed", 0.0)) + delta
			if float(actor["downed_elapsed"]) >= 3.0:
				actor["removed"] = true
				actor["respawn_timer"] = combat_rng.randf_range(55.0, 105.0)
				changed = true
			laundry_office_npcs[actor_id] = actor
			continue
		actor["attack_cooldown"] = maxf(0.0, float(actor.get("attack_cooldown", 0.0)) - delta)
		if actor_id == "laundry_capone":
			var combat_target: = nearest_laundry_target_for_actor(actor, false, true, now_ms)
			if combat_target > 0:
				actor["ai_state"] = "laundry_capone_defense"
				changed = move_authoritative_laundry_actor(actor, state_position(peer_states[combat_target]), LAUNDRY_DEFENDER_SPEED * delta) or changed
				laundry_office_npcs[actor_id] = actor
				if float(actor.get("attack_cooldown", 0.0)) <= 0.0:
					authoritative_laundry_actor_attack(actor_id, combat_target)
				continue
			var downed_target: = nearest_laundry_target_for_actor(actor, true, false, now_ms)
			if downed_target > 0:
				actor["ai_state"] = "laundry_capone_disposition"
				changed = move_authoritative_laundry_actor(actor, state_position(peer_states[downed_target]), LAUNDRY_CAPONE_APPROACH_SPEED * delta) or changed
				laundry_office_npcs[actor_id] = actor
				if state_position(actor).distance_to(state_position(peer_states[downed_target])) <= LAUNDRY_NPC_DISPOSITION_DISTANCE:
					resolve_capone_disposition(downed_target)
				continue
			actor["ai_state"] = "idle"
			changed = move_authoritative_laundry_actor(actor, actor.get("home_position", Vector2.ZERO), float(actor.get("move_speed", 72.0)) * delta) or changed
			laundry_office_npcs[actor_id] = actor
			continue
		var defender_target: = nearest_laundry_target_for_actor(actor, false, false, now_ms)
		if defender_target > 0:
			actor["ai_state"] = "laundry_union_defense"
			changed = move_authoritative_laundry_actor(actor, state_position(peer_states[defender_target]), LAUNDRY_DEFENDER_SPEED * delta) or changed
			laundry_office_npcs[actor_id] = actor
			if float(actor.get("attack_cooldown", 0.0)) <= 0.0:
				authoritative_laundry_actor_attack(actor_id, defender_target)
			continue
		actor["ai_state"] = "laundry_union_idle"
		var roam_points: Array = actor.get("roam_points", [])
		if not roam_points.is_empty():
			actor["roam_wait_timer"] = maxf(0.0, float(actor.get("roam_wait_timer", 0.0)) - delta)
			if float(actor["roam_wait_timer"]) <= 0.0:
				var roam_index: = clampi(int(actor.get("roam_index", 0)), 0, roam_points.size() - 1)
				var roam_target: Vector2 = roam_points[roam_index]
				actor["ai_state"] = "laundry_union_roam"
				changed = move_authoritative_laundry_actor(actor, roam_target, float(actor.get("move_speed", 72.0)) * delta) or changed
				if state_position(actor).distance_to(roam_target) <= 3.0:
					var next_index: = combat_rng.randi_range(0, roam_points.size() - 1)
					if roam_points.size() > 1 and next_index == roam_index:
						next_index = (next_index + 1) % roam_points.size()
					actor["roam_index"] = next_index
					actor["roam_wait_timer"] = combat_rng.randf_range(25.0, 30.0)
		laundry_office_npcs[actor_id] = actor
	var capone: Dictionary = laundry_office_npcs.get("laundry_capone", {})
	if capone.is_empty() or bool(capone.get("downed", false)) or bool(capone.get("removed", false)):
		for peer_value in laundry_defeat_pending.keys():
			laundry_defeat_pending.erase(int(peer_value))
	if changed:
		_schedule_snapshot()

func request_attack(target_actor_id: String = "", latest_state: Dictionary = {}) -> void :
	if not active:
		return
	if hosting:
		resolve_attack_request(local_peer_id(), target_actor_id)
	else:
		if not target_actor_id.is_empty() and not latest_state.is_empty():
			var state_with_target: = latest_state.duplicate(true)
			state_with_target["office_attack_actor_id"] = target_actor_id
			submit_state_to_server.rpc_id(1, state_with_target)
		request_attack_server.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func request_attack_server() -> void :
	if hosting:
		var sender: = multiplayer.get_remote_sender_id()
		var state: Dictionary = peer_states.get(sender, {})
		var target_actor_id: = String(state.get("office_attack_actor_id", ""))
		state.erase("office_attack_actor_id")
		peer_states[sender] = state
		resolve_attack_request(sender, target_actor_id)

func request_blood_sample(evidence_id: String) -> void :
	if not active or evidence_id.strip_edges().is_empty():
		return
	if hosting:
		var peer_id: = local_peer_id()
		var state: Dictionary = peer_states.get(peer_id, {})
		var account_id: = safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", ""))))
		var slot_index: = int(state.get("resident_slot", -1))
		if profiles_enabled:
			store_connected_resident(peer_id)
		var request: = {
			"action": "COLLECT_BLOOD_SAMPLE", 
			"evidence_id": evidence_id, 
			"world_id": server_world_id, 
			"account_id": account_id, 
			"resident_slot": slot_index, 
			"transaction_id": "TXN-%s-%s-%d-%d-BLOOD" % [server_world_id, account_id, slot_index, Time.get_ticks_msec()], 
		}
		var result: = process_economy_request_atomically(account_id, slot_index, request)
		if peer_id == 1:
			economy_result_received.emit(result)
		else:
			economy_result.rpc_id(peer_id, result)
		return
	request_blood_sample_server.rpc_id(1, evidence_id)

@rpc("any_peer", "call_remote", "reliable")
func request_blood_sample_server(evidence_id: String) -> void :
	if not hosting or evidence_id.strip_edges().is_empty():
		return
	var sender: = multiplayer.get_remote_sender_id()
	var state: Dictionary = peer_states.get(sender, {})
	var account_id: = safe_tester_id(String(peer_accounts.get(sender, state.get("tester_id", ""))))
	var slot_index: = int(state.get("resident_slot", -1))
	if profiles_enabled:
		store_connected_resident(sender)
	var request: = {
		"action": "COLLECT_BLOOD_SAMPLE", 
		"evidence_id": evidence_id, 
		"world_id": server_world_id, 
		"account_id": account_id, 
		"resident_slot": slot_index, 
		"transaction_id": "TXN-%s-%s-%d-%d-BLOOD" % [server_world_id, account_id, slot_index, Time.get_ticks_msec()], 
	}
	var result: = process_economy_request_atomically(account_id, slot_index, request)
	economy_result.rpc_id(sender, result)

func sanitize_attack_weapon(value: Variant) -> String:
	var weapon: = String(value)
	return weapon if weapon in ATTACK_WEAPONS else "Fists"

func state_position(state: Dictionary) -> Vector2:
	var value: Variant = state.get("position", Vector2.ZERO)
	if value is Vector2:
		return value
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func state_is_in_facing_direction(attacker: Dictionary, target: Dictionary) -> bool:
	var horizontal_delta: = state_position(target).x - state_position(attacker).x
	return absf(horizontal_delta) <= 1.0 or horizontal_delta * (-1.0 if float(attacker.get("facing", 1.0)) < 0.0 else 1.0) > 0.0

func attack_target_for(attacker_id: int, weapon_override: String = "") -> int:
	if attacker_id not in peer_states:
		return 0
	var attacker: Dictionary = peer_states[attacker_id]
	var weapon: = sanitize_attack_weapon(weapon_override if not weapon_override.is_empty() else attacker.get("attack_weapon", "Fists"))
	var attacker_position: = state_position(attacker)
	var target_id: = 0
	var target_distance: = ATTACK_DISTANCE
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		if peer_id == attacker_id:
			continue
		var target: Dictionary = peer_states[peer_id]
		if bool(target.get("downed", false)) or bool(target.get("arrested", false)):
			continue
		if not states_share_room_instance(attacker, target):
			continue
		if weapon == "Fists" and not state_is_in_facing_direction(attacker, target):
			continue
		var distance: = attacker_position.distance_to(state_position(target))
		if distance < target_distance:
			target_distance = distance
			target_id = peer_id
	return target_id

func resolve_attack_request(attacker_id: int, requested_actor_id: String = "") -> Dictionary:
	if not hosting or attacker_id not in peer_states:
		return {}
	var attacker: Dictionary = peer_states[attacker_id]
	if bool(attacker.get("downed", false)) or bool(attacker.get("arrested", false)) or String(attacker.get("phase", "adult")) != "adult":
		return {}
	interrupt_active_blood_cleaning_for_peer(attacker_id, "COMBAT_STARTED")
	interrupt_school_training_for_peer(attacker_id, "COMBAT_STARTED")
	var now: = Time.get_ticks_msec()
	if now < int(attack_ready_at_ms.get(attacker_id, 0)):
		return {}
	attack_ready_at_ms[attacker_id] = now + ATTACK_COOLDOWN_MS
	var attacker_position: = state_position(attacker)
	var weapon: = sanitize_attack_weapon(attacker.get("attack_weapon", "Fists"))
	if not requested_actor_id.is_empty():
		combat_event_sequence += 1
		var rejected_payload: = {
			"event_id": combat_event_sequence, 
			"attacker_id": attacker_id, 
			"target_id": 0, 
			"target_actor_id": requested_actor_id, 
			"area": String(attacker.get("area", "")), 
			"room_id": String(attacker.get("room_id", "")), 
			"home_instance_id": state_home_instance_id(attacker), 
			"attacker_position": attacker_position, 
			"impact_position": attacker_position + Vector2(float(attacker.get("facing", 1.0)) * 52.0, 0.0), 
			"weapon": weapon, 
			"duration": 0.24, 
			"damage": 0.0, 
			"hit": false, 
			"downed": false, 
			"blood_amount": 0, 
			"blood_seed": combat_event_sequence * 7919 + attacker_id * 131, 
		}
		if not laundry_office_actor_id_is_known(requested_actor_id):
			rejected_payload["rejected"] = "UNKNOWN_ACTOR_ID"
			broadcast_combat_event(rejected_payload)
			return rejected_payload
		var office_actor: Dictionary = laundry_office_npcs[requested_actor_id]
		if not peer_is_in_laundry_office(attacker) or bool(office_actor.get("removed", false)) or bool(office_actor.get("downed", false)):
			rejected_payload["rejected"] = "WRONG_ROOM_OR_STATE"
			broadcast_combat_event(rejected_payload)
			return rejected_payload
		if attacker_position.distance_to(state_position(office_actor)) >= ATTACK_DISTANCE:
			rejected_payload["rejected"] = "OUT_OF_RANGE"
			broadcast_combat_event(rejected_payload)
			return rejected_payload
		if weapon == "Fists" and not state_is_in_facing_direction(attacker, office_actor):
			rejected_payload["rejected"] = "WRONG_FACING"
			broadcast_combat_event(rejected_payload)
			return rejected_payload
		var damage: = 34.0 + minf(10.0, float(state_skill_level(attacker, "Fighting")) * 0.4)
		var new_health: = maxf(0.0, float(office_actor.get("health", 100.0)) - damage)
		office_actor["health"] = new_health
		office_actor["downed"] = new_health <= 0.0
		office_actor["downed_elapsed"] = 0.0
		office_actor["ai_state"] = "downed" if new_health <= 0.0 else office_actor.get("ai_state", "idle")
		laundry_office_npcs[requested_actor_id] = office_actor
		attacker["mark"] = 55.0
		attacker["attack_weapon"] = weapon
		peer_states[attacker_id] = attacker
		activate_laundry_hostility_for_peer(attacker_id, requested_actor_id)
		rejected_payload["impact_position"] = state_position(office_actor)
		rejected_payload["damage"] = damage
		rejected_payload["hit"] = true
		rejected_payload["downed"] = new_health <= 0.0
		rejected_payload["blood_amount"] = 10 if new_health <= 0.0 else 5
		rejected_payload["blood_evidence"] = add_blood_evidence_record(rejected_payload)
		if profiles_enabled:
			store_connected_resident(attacker_id)
		_schedule_snapshot(true)
		broadcast_combat_event(rejected_payload)
		return rejected_payload
	var target_id: = attack_target_for(attacker_id, weapon)
	combat_event_sequence += 1
	var payload: = {
		"event_id": combat_event_sequence, 
		"attacker_id": attacker_id, 
		"target_id": target_id, 
		"area": String(attacker.get("area", "")), 
		"room_id": String(attacker.get("room_id", "")), 
		"home_instance_id": state_home_instance_id(attacker), 
		"attacker_position": attacker_position, 
		"impact_position": attacker_position + Vector2(float(attacker.get("facing", 1.0)) * 52.0, 0.0), 
		"weapon": weapon, 
		"duration": 0.24, 
		"damage": 0.0, 
		"hit": false, 
		"downed": false, 
		"blood_amount": 0, 
		"blood_seed": combat_event_sequence * 7919 + attacker_id * 131, 
	}
	if target_id > 0:
		var target: Dictionary = peer_states[target_id]
		var damage: = 34.0
		var new_health: = maxf(0.0, float(target.get("health", 100.0)) - damage)
		attacker["mark"] = 55.0
		attacker["attack_weapon"] = weapon
		peer_states[attacker_id] = attacker
		target["health"] = new_health
		target["downed"] = new_health <= 0.0
		peer_states[target_id] = target
		payload["impact_position"] = state_position(target)
		payload["damage"] = damage
		payload["hit"] = true
		payload["downed"] = new_health <= 0.0
		payload["blood_amount"] = 10 if new_health <= 0.0 else 5
		payload["home_instance_id"] = state_home_instance_id(target)
		payload["blood_evidence"] = add_blood_evidence_record(payload)
		if new_health <= 0.0:
			_broadcast_chat("SYSTEM", "%s downed %s. A disposition window is open." % [String(attacker.get("name", "Resident")), String(target.get("name", "Resident"))])
		if profiles_enabled:
			store_connected_resident(attacker_id)
			store_connected_resident(target_id)
	else:
		attack_requested.emit(attacker_id)
	_broadcast_snapshot()
	broadcast_combat_event(payload)
	return payload

func combat_observer_ids(source: Dictionary) -> Array[int]:
	var observer_ids: Array[int] = []
	for observer_value in peer_states.keys():
		var observer_id: = int(observer_value)
		if states_share_room_instance(source, peer_states[observer_id]):
			observer_ids.append(observer_id)
	return observer_ids

func broadcast_combat_event(payload: Dictionary) -> void :
	if not hosting:
		return
	var clean: = payload.duplicate(true)
	var source: = {
		"area": String(clean.get("area", "")), 
		"room_id": String(clean.get("room_id", "")), 
		"home_instance_id": String(clean.get("home_instance_id", "")), 
	}
	for observer_id in combat_observer_ids(source):
		if observer_id == 1:
			combat_event_received.emit(clean.duplicate(true))
		elif peer_connection_is_live(observer_id):
			receive_combat_event.rpc_id(observer_id, clean)

@rpc("authority", "call_remote", "reliable")
func receive_combat_event(payload: Dictionary) -> void :
	combat_event_received.emit(payload.duplicate(true))

func request_xp_popup(skill_name: String, amount: int) -> void :
	if not active or skill_name not in Rules.SKILLS or amount <= 0:
		return
	if hosting:
		resolve_xp_popup(local_peer_id(), skill_name, amount)
	else:
		request_xp_popup_server.rpc_id(1, skill_name, amount)

@rpc("any_peer", "call_remote", "reliable")
func request_xp_popup_server(skill_name: String, amount: int) -> void :
	if hosting:
		resolve_xp_popup(multiplayer.get_remote_sender_id(), skill_name, amount)

func xp_observer_ids(source: Dictionary, max_distance: float = 900.0) -> Array[int]:
	var observer_ids: Array[int] = []
	var source_position: = state_position(source)
	for observer_value in peer_states.keys():
		var observer_id: = int(observer_value)
		var observer: Dictionary = peer_states[observer_id]
		if states_share_room_instance(source, observer) and state_position(observer).distance_to(source_position) <= max_distance:
			observer_ids.append(observer_id)
	return observer_ids

func resolve_xp_popup(peer_id: int, skill_name: String, amount: int) -> Dictionary:
	if not hosting or peer_id not in peer_states or skill_name not in Rules.SKILLS or amount <= 0:
		return {}
	var state: Dictionary = peer_states[peer_id]
	xp_event_sequence += 1
	var payload: = {
		"event_id": xp_event_sequence, 
		"peer_id": peer_id, 
		"name": String(state.get("name", "Resident")).left(20), 
		"skill": skill_name, 
		"amount": clampi(amount, 1, 5000), 
		"area": String(state.get("area", "")), 
		"room_id": String(state.get("room_id", "")), 
		"home_instance_id": state_home_instance_id(state), 
		"position": state_position(state), 
	}
	for observer_id in xp_observer_ids(state):
		if observer_id == 1:
			xp_event_received.emit(payload.duplicate(true))
		else:
			receive_xp_event.rpc_id(observer_id, payload)
	return payload

@rpc("authority", "call_remote", "reliable")
func receive_xp_event(payload: Dictionary) -> void :
	xp_event_received.emit(payload.duplicate(true))

func request_disposition(target_peer_id: int, action: String) -> void :
	if not active:
		return
	if hosting:
		resolve_disposition_request(local_peer_id(), target_peer_id, action)
	else:
		request_disposition_server.rpc_id(1, target_peer_id, action)

func request_office_npc_disposition(target_actor_id: String, action: String, latest_state: Dictionary = {}) -> void :
	if not active or target_actor_id.is_empty():
		return
	if hosting:
		resolve_office_npc_disposition(local_peer_id(), target_actor_id, action)
		return
	if not latest_state.is_empty():
		var state_with_target: = latest_state.duplicate(true)
		state_with_target["office_disposition_actor_id"] = target_actor_id
		submit_state_to_server.rpc_id(1, state_with_target)
	request_disposition_server.rpc_id(1, 0, action)

@rpc("any_peer", "call_remote", "reliable")
func request_disposition_server(target_peer_id: int, action: String) -> void :
	if hosting:
		var sender: = multiplayer.get_remote_sender_id()
		if target_peer_id <= 0:
			var state: Dictionary = peer_states.get(sender, {})
			var target_actor_id: = String(state.get("office_disposition_actor_id", ""))
			state.erase("office_disposition_actor_id")
			peer_states[sender] = state
			resolve_office_npc_disposition(sender, target_actor_id, action)
		else:
			resolve_disposition_request(sender, target_peer_id, action)

func apply_disposition_result_to_peer(peer_id: int, resident: Dictionary) -> void :
	if peer_id <= 0 or peer_id not in peer_states or resident.is_empty():
		return
	var state: Dictionary = peer_states[peer_id]
	state["health"] = clampf(float(resident.get("health", state.get("health", 100.0))), 0.0, 100.0)
	state["downed"] = bool(resident.get("downed", state.get("downed", false)))
	state["deceased"] = bool(resident.get("deceased", state.get("deceased", false)))
	state["arrested"] = bool(resident.get("arrested", state.get("arrested", false)))
	state["warrant"] = bool(resident.get("warrant", state.get("warrant", false)))
	state["heat"] = authoritative_heat(resident)
	state["case_strength"] = state["heat"]
	state["detained"] = bool(resident.get("detained", false))
	state["detained_by_account_id"] = String(resident.get("detained_by_account_id", ""))
	state["detained_by_resident_slot"] = int(resident.get("detained_by_resident_slot", -1))
	state["detained_at_ms"] = maxi(0, int(resident.get("detained_at_ms", 0)))
	state["sentence_credits"] = maxi(0, int(resident.get("sentence_credits", state.get("sentence_credits", 0))))
	state["crimes"] = Array(resident.get("crimes", state.get("crimes", []))).duplicate(true)
	state["wanted"] = bool(resident.get("wanted", state.get("wanted", false)))
	state["mark"] = maxf(0.0, float(resident.get("mark_timer", state.get("mark", 0.0))))
	if bool(resident.get("arrested", false)):
		state["area"] = "jail"
		state["room_id"] = String(resident.get("room_id", "tier"))
		state["position"] = resident_saved_position(resident)
		state["home_instance_id"] = ""
		state["walking"] = false
	peer_states[peer_id] = state

func state_skill_level(state: Dictionary, skill_name: String) -> int:
	var skill_state: Variant = state.get("skills", {})
	if skill_state is not Dictionary:
		return 1
	return Rules.level_from_xp(maxi(0, int((skill_state as Dictionary).get(skill_name, 0))))

func permanent_harm_authorized(attacker: Dictionary, fatal: bool) -> bool:
	var carried: Variant = attacker.get("inventory", [])
	if carried is not Array or "Prepared Tool" not in (carried as Array):
		return false
	if state_skill_level(attacker, "Fighting") < (FATAL_FIGHTING_LEVEL if fatal else MAIM_FIGHTING_LEVEL):
		return false
	if fatal and state_skill_level(attacker, "Stealth") < FATAL_STEALTH_LEVEL:
		return false
	return true

func resolve_office_npc_disposition(attacker_id: int, target_actor_id: String, action: String) -> Dictionary:
	if not hosting or attacker_id not in peer_states or not laundry_office_actor_id_is_known(target_actor_id):
		return {}
	if action not in ["help", "restrain", "rob", "maim", "fatal"]:
		return {}
	var attacker: Dictionary = peer_states[attacker_id]
	var target: Dictionary = laundry_office_npcs[target_actor_id]
	if not peer_is_in_laundry_office(attacker) or bool(attacker.get("downed", false)) or bool(attacker.get("arrested", false)):
		return {}
	if not bool(target.get("downed", false)) or bool(target.get("removed", false)):
		return {}
	if state_position(attacker).distance_to(state_position(target)) > 125.0:
		return {}
	var result: = {"accepted": true, "action": action, "attacker_id": attacker_id, "target_actor_id": target_actor_id}
	match action:
		"help":
			target["health"] = 30.0
			target["downed"] = false
			target["downed_elapsed"] = 0.0
			target["ai_state"] = "idle" if target_actor_id == "laundry_capone" else "laundry_union_idle"
		"restrain":
			var credentials: Variant = attacker.get("credentials", [])
			var authorized: = String(attacker.get("active_job", "")) == "Security Guard" or credentials is Array and "Temporary Security Badge" in (credentials as Array)
			if not authorized:
				return {}
			target["health"] = 25.0
			target["downed"] = false
			target["restrained"] = true
			target["downed_elapsed"] = 0.0
			target["ai_state"] = "restrained"
		"rob":
			var taken: = maxi(0, int(target.get("cash", 0)))
			target["cash"] = 0
			attacker["dirty_cash"] = maxi(0, int(attacker.get("dirty_cash", 0))) + taken
			attacker["mark"] = 55.0
			peer_states[attacker_id] = attacker
			result["taken"] = taken
		"maim", "fatal":
			var fatal: = action == "fatal"
			if not permanent_harm_authorized(attacker, fatal):
				return {}
			var carried: Array = attacker.get("inventory", [])
			carried.erase("Prepared Tool")
			attacker["inventory"] = carried
			attacker["mark"] = 55.0
			peer_states[attacker_id] = attacker
			var marked: = float(target.get("mark", 0.0)) > 0.0
			var roll: = combat_rng.randi_range(1, 16)
			var success: = Rules.fatality_succeeds(roll, marked)
			var duration: = combat_rng.randf_range(5.0, 8.0)
			permanent_outcome_sequence += 1
			var outcome_id: = "%s-NPC-DISPOSITION-%d" % [server_world_id if not server_world_id.is_empty() else "SESSION", permanent_outcome_sequence]
			pending_permanent_outcomes.append({"target": 0, "target_actor_id": target_actor_id, "requesting_peer_id": attacker_id, "fatal": fatal, "success": success, "remaining": duration, "outcome_id": outcome_id, "outcome_sequence": permanent_outcome_sequence})
			send_permanent_outcome(attacker_id, {"lan": true, "fatal": fatal, "success": success, "roll": roll, "duration": duration, "attacker": String(attacker.get("name", "Resident")), "interrupted": false, "outcome_id": outcome_id})
			result["roll"] = roll
			result["success"] = success
			result["duration"] = duration
			result["outcome_id"] = outcome_id
	laundry_office_npcs[target_actor_id] = target
	if profiles_enabled:
		store_connected_resident(attacker_id)
	_schedule_snapshot(true)
	return result

func target_has_pending_outcome(target_id: int) -> bool:
	for pending in pending_permanent_outcomes:
		if int(pending.get("target", 0)) == target_id:
			return true
	return false

func resolve_disposition_request(attacker_id: int, target_id: int, action: String) -> Dictionary:
	if not hosting or attacker_id not in peer_states or target_id not in peer_states or attacker_id == target_id:
		return {}
	if action not in ["help", "restrain", "rob", "maim", "fatal", "detain", "arrest", "release_detention"]:
		return {}
	var attacker: Dictionary = peer_states[attacker_id]
	var target: Dictionary = peer_states[target_id]
	if bool(attacker.get("arrested", false)) or (bool(target.get("arrested", false)) and action != "release_detention"):
		return {}
	var custody_action: = action in ["detain", "arrest", "release_detention"]
	if ( not custody_action and not bool(target.get("downed", false))) or bool(attacker.get("downed", false)):
		return {}
	if not states_share_room_instance(attacker, target):
		return {}
	if state_position(attacker).distance_to(state_position(target)) > 125.0:
		return {}
	var result: = {"action": action, "attacker_id": attacker_id, "target_id": target_id, "accepted": true}
	if custody_action:
		var attacker_account: = safe_tester_id(String(peer_accounts.get(attacker_id, attacker.get("tester_id", ""))))
		var target_account: = safe_tester_id(String(peer_accounts.get(target_id, target.get("tester_id", ""))))
		var attacker_slot: = int(attacker.get("resident_slot", -1))
		var target_slot: = int(target.get("resident_slot", -1))
		if attacker_account.is_empty() or target_account.is_empty() or attacker_slot < 0 or target_slot < 0:
			return {}
		if profiles_enabled:
			store_connected_resident(attacker_id)
			store_connected_resident(target_id)
		var custody_request: = {
			"action": action.to_upper(), 
			"transaction_id": "TXN-%s-%s-%d-%d-DISP" % [server_world_id, attacker_account, attacker_slot, Time.get_ticks_msec()], 
			"world_id": server_world_id, 
			"target_account_id": target_account, 
			"target_resident_slot": target_slot, 
		}
		var custody_result: = process_economy_request_atomically(attacker_account, attacker_slot, custody_request)
		if attacker_id == 1:
			economy_result_received.emit(custody_result)
		else:
			economy_result.rpc_id(attacker_id, custody_result)
		if not bool(custody_result.get("ok", false)):
			return custody_result
		var updated_target: Dictionary = Dictionary(custody_result.get("target_resident", {})).duplicate(true)
		apply_disposition_result_to_peer(target_id, updated_target)
		result["economy"] = custody_result
		_broadcast_chat("SYSTEM", "%s %s %s." % [
			String(attacker.get("name", "Resident")), 
			"temporarily detained" if action == "detain" else "arrested" if action == "arrest" else "released", 
			String(target.get("name", "Resident")), 
		])
		_broadcast_snapshot()
		return result
	match action:
		"help":
			target["health"] = 30.0
			target["downed"] = false
			peer_states[target_id] = target
			_broadcast_chat("SYSTEM", "%s stabilized %s." % [attacker.get("name", "Resident"), target.get("name", "Resident")])
		"restrain":
			var credentials: Variant = attacker.get("credentials", [])
			var authorized: = String(attacker.get("active_job", "")) == "Security Guard" or credentials is Array and "Temporary Security Badge" in (credentials as Array)
			if not authorized:
				return {}
			target["health"] = 70.0
			target["downed"] = false
			target["area"] = "jail"
			target["room_id"] = "tier"
			peer_states[target_id] = target
			_broadcast_chat("SYSTEM", "%s transported %s alive." % [attacker.get("name", "Resident"), target.get("name", "Resident")])
		"rob":
			if not profiles_enabled:
				return {}
			store_connected_resident(attacker_id)
			store_connected_resident(target_id)
			var attacker_account: = safe_tester_id(String(peer_accounts.get(attacker_id, attacker.get("tester_id", ""))))
			var target_account: = safe_tester_id(String(peer_accounts.get(target_id, target.get("tester_id", ""))))
			var attacker_slot: = int(attacker.get("resident_slot", -1))
			var target_slot: = int(target.get("resident_slot", -1))
			if attacker_account.is_empty() or target_account.is_empty() or attacker_slot < 0 or target_slot < 0:
				return {}
			var robbery_request: = {
				"action": "SEARCH_ROBBERY_ALL", 
				"transaction_id": "TXN-%s-%s-%d-%d-ROB" % [server_world_id, attacker_account, attacker_slot, Time.get_ticks_msec()], 
				"world_id": server_world_id, 
				"target_account_id": target_account, 
				"target_resident_slot": target_slot, 
			}
			var robbery_result: = process_economy_request_atomically(attacker_account, attacker_slot, robbery_request)
			if attacker_id == 1:
				economy_result_received.emit(robbery_result)
			else:
				economy_result.rpc_id(attacker_id, robbery_result)
			if not bool(robbery_result.get("ok", false)):
				return robbery_result
			target = peer_states.get(target_id, target)
			attacker = peer_states.get(attacker_id, attacker)
			target["health"] = 22.0
			target["downed"] = false
			target["mark"] = 30.0
			attacker["mark"] = 55.0
			peer_states[target_id] = target
			peer_states[attacker_id] = attacker
			store_connected_resident(attacker_id)
			store_connected_resident(target_id)
			_broadcast_chat("SYSTEM", "A downed Resident was searched and robbed. The ledger kept the custody trail.")
			result["economy"] = robbery_result
		"maim", "fatal":
			var fatal: = action == "fatal"
			if not permanent_harm_authorized(attacker, fatal) or target_has_pending_outcome(target_id):
				return {}
			var carried: Array = attacker.get("inventory", [])
			carried.erase("Prepared Tool")
			attacker["inventory"] = carried
			attacker["mark"] = 55.0
			peer_states[attacker_id] = attacker
			var marked: = float(target.get("mark", 0.0)) > 0.0
			var roll: = combat_rng.randi_range(1, 16)
			var success: = Rules.fatality_succeeds(roll, marked)
			var interrupted: = fatal and success and bool(target.get("contingency", false))
			if interrupted:
				success = false
			var duration: = combat_rng.randf_range(5.0, 8.0)
			var payload: = {"lan": true, "fatal": fatal, "success": success, "roll": roll, "duration": duration, "attacker": String(attacker.get("name", "Resident")), "interrupted": interrupted}
			permanent_outcome_sequence += 1
			var outcome_id: = "%s-DISPOSITION-%d" % [server_world_id if not server_world_id.is_empty() else "SESSION", permanent_outcome_sequence]
			pending_permanent_outcomes.append({"target": target_id, "fatal": fatal, "success": success, "remaining": duration, "outcome_id": outcome_id, "outcome_sequence": permanent_outcome_sequence})
			send_permanent_outcome(target_id, payload)
			_broadcast_chat("SYSTEM", "%s committed to a permanent-harm attempt. The result is sealed." % attacker.get("name", "Resident"))
			result["roll"] = roll
			result["duration"] = duration
			result["success"] = success
			result["outcome_id"] = outcome_id
	_broadcast_snapshot()
	return result

func update_authoritative_combat(delta: float) -> void :
	for index in range(pending_permanent_outcomes.size() - 1, -1, -1):
		pending_permanent_outcomes[index]["remaining"] = float(pending_permanent_outcomes[index].get("remaining", 0.0)) - delta
		if float(pending_permanent_outcomes[index]["remaining"]) > 0.0:
			continue
		var pending: Dictionary = pending_permanent_outcomes[index]
		var target_actor_id: = String(pending.get("target_actor_id", ""))
		if not target_actor_id.is_empty() and target_actor_id in laundry_office_npcs:
			var target_actor: Dictionary = laundry_office_npcs[target_actor_id]
			target_actor["downed"] = false
			target_actor["downed_elapsed"] = 0.0
			if bool(pending.get("success", false)):
				if bool(pending.get("fatal", false)):
					target_actor["health"] = 0.0
					target_actor["removed"] = true
					target_actor["respawn_timer"] = combat_rng.randf_range(55.0, 105.0)
				else:
					target_actor["health"] = 28.0
					target_actor["maimed"] = true
			else:
				target_actor["health"] = 22.0
			target_actor["ai_state"] = "idle" if target_actor_id == "laundry_capone" else "laundry_union_idle"
			laundry_office_npcs[target_actor_id] = target_actor
			_schedule_snapshot()
			pending_permanent_outcomes.remove_at(index)
			continue
		var target_id: = int(pending.get("target", 0))
		if target_id in peer_states:
			var patch: = authoritative_hospital_recovery_patch()
			if bool(pending.get("success", false)):
				if bool(pending.get("fatal", false)):
					patch = {"health": 0.0, "downed": true, "dead": true, "deceased": true}
				else:
					patch["maimed"] = true
			host_patch_peer(target_id, patch)
			if bool(pending.get("success", false)) and bool(pending.get("fatal", false)):
				var body_record: = add_body_evidence_record(
					peer_states[target_id], 
					String(pending.get("outcome_id", "")), 
					int(pending.get("outcome_sequence", 0))
				)
				if not body_record.is_empty():
					broadcast_body_evidence_snapshots()
		pending_permanent_outcomes.remove_at(index)
	for peer_value in peer_states.keys():
		var peer_id: = int(peer_value)
		var state: Dictionary = peer_states[peer_id]
		if bool(state.get("downed", false)) and not target_has_pending_outcome(peer_id) and not bool(laundry_defeat_pending.get(peer_id, false)):
			authoritative_downed_timers[peer_id] = float(authoritative_downed_timers.get(peer_id, 0.0)) + delta
			if float(authoritative_downed_timers[peer_id]) >= DOWNED_RECOVERY_SECONDS:
				authoritative_downed_timers.erase(peer_id)
				host_patch_peer(peer_id, authoritative_hospital_recovery_patch())
		else:
			authoritative_downed_timers.erase(peer_id)

func authoritative_hospital_recovery_patch() -> Dictionary:
	return {
		"health": 35.0, 
		"stamina": 20.0, 
		"downed": false, 
		"area": "hospital", 
		"room_id": "ward", 
		"position": Vector2(400, 270), 
		"home_instance_id": "", 
	}

func submit_chat(sender_name: String, message: String) -> void :
	if not active:
		return
	var clean_name: = sender_name.strip_edges().left(20)
	var clean_message: = message.strip_edges().left(120)
	if clean_message.is_empty():
		return
	if hosting:
		_broadcast_chat(clean_name, clean_message)
	else:
		submit_chat_server.rpc_id(1, clean_name, clean_message)

@rpc("any_peer", "call_remote", "reliable")
func submit_chat_server(sender_name: String, message: String) -> void :
	if not hosting:
		return
	var sender: = multiplayer.get_remote_sender_id()
	var authoritative_name: = String(peer_states.get(sender, {}).get("name", sender_name)).left(20)
	_broadcast_chat(authoritative_name, message.strip_edges().left(120))

func host_patch_peer(peer_id: int, patch: Dictionary) -> void :
	if not hosting or peer_id not in peer_states:
		return
	var state: Dictionary = peer_states[peer_id]
	for key in patch:
		state[key] = patch[key]
	peer_states[peer_id] = state
	clear_school_study_if_state_invalid(String(peer_accounts.get(peer_id, state.get("tester_id", ""))), int(state.get("resident_slot", -1)), state)
	_schedule_snapshot(true)

func send_permanent_outcome(peer_id: int, payload: Dictionary) -> void :
	if not hosting or peer_id not in peer_states:
		return
	if peer_id == 1:
		permanent_outcome_received.emit(payload.duplicate(true))
	else:
		receive_permanent_outcome.rpc_id(peer_id, payload)

@rpc("authority", "call_remote", "reliable")
func receive_permanent_outcome(payload: Dictionary) -> void :
	permanent_outcome_received.emit(payload.duplicate(true))

@rpc("any_peer", "call_remote", "reliable")
func ping_server(sent_at_ms: int) -> void :
	if hosting:
		var sender: = multiplayer.get_remote_sender_id()
		if sender in authorized_peers and peer_connection_is_live(sender):
			pong_client.rpc_id(sender, sent_at_ms)

@rpc("authority", "call_remote", "reliable")
func pong_client(sent_at_ms: int) -> void :
	var current: = float(Time.get_ticks_msec() - sent_at_ms)
	jitter_ms = absf(current - ping_ms) * 0.35 + jitter_ms * 0.65 if ping_received > 0 else 0.0
	ping_ms = current
	ping_received += 1
	last_response_ms = Time.get_ticks_msec()
	_update_loss()

func _update_loss() -> void :
	packet_loss_percent = 0.0 if ping_sent <= 0 else clampf(100.0 * float(ping_sent - ping_received) / float(ping_sent), 0.0, 100.0)

func _schedule_snapshot(immediate: bool = false) -> void :
	if not hosting:
		return
	snapshot_dirty = true
	if immediate:
		snapshot_dirty = false
		snapshot_timer = snapshot_interval
		_broadcast_snapshot()

func state_home_instance_id(state: Dictionary) -> String:
	var explicit_id: = String(state.get("home_instance_id", ""))
	if not explicit_id.is_empty():
		return explicit_id
	if String(state.get("area", "")) != "apartment" or String(state.get("room_id", "")) != "unit":
		return ""
	return String(PlayerHomeContent.first_player_home(state.get("property", []), PlayerHomeContent.MERCY_COURT_ID).get("home_instance_id", ""))

func states_share_room_instance(first: Dictionary, second: Dictionary) -> bool:
	if String(first.get("area", "")) != String(second.get("area", "")) or String(first.get("room_id", "")) != String(second.get("room_id", "")):
		return false
	if String(first.get("area", "")) == "apartment" and String(first.get("room_id", "")) == "unit":
		var first_home: = state_home_instance_id(first)
		var second_home: = state_home_instance_id(second)
		return not first_home.is_empty() and first_home == second_home
	return true

func states_share_interest_scope(viewer: Dictionary, candidate: Dictionary) -> bool:
	if not public_hosting:
		return true
	if String(viewer.get("phase", "")) == "roster" or String(candidate.get("phase", "")) == "roster":
		return false
	return states_share_room_instance(viewer, candidate)

func laundry_office_snapshot_for_peer(peer_id: int, now_ms: int = -1) -> Dictionary:
	if peer_id not in peer_states or not peer_is_in_laundry_office(peer_states[peer_id]):
		return {}
	var checked_at: = Time.get_ticks_msec() if now_ms < 0 else now_ms
	var actor_snapshots: = {}
	for actor_id_value in laundry_office_npcs.keys():
		var actor_id: = String(actor_id_value)
		var actor: Dictionary = laundry_office_npcs[actor_id]
		actor_snapshots[actor_id] = {
			"actor_id": actor_id, 
			"position": state_position(actor), 
			"health": clampf(float(actor.get("health", 100.0)), 0.0, 100.0), 
			"downed": bool(actor.get("downed", false)), 
			"removed": bool(actor.get("removed", false)), 
			"restrained": bool(actor.get("restrained", false)), 
			"maimed": bool(actor.get("maimed", false)), 
			"ai_state": String(actor.get("ai_state", "idle")), 
			"hostile": laundry_capone_direct_for_peer(peer_id, checked_at) if actor_id == "laundry_capone" else laundry_hostility_active_for_peer(peer_id, checked_at), 
			"directly_attacked_by_player": actor_id == "laundry_capone" and laundry_capone_direct_for_peer(peer_id, checked_at), 
		}
	return {
		"actors": actor_snapshots, 
		"hostility_remaining_ms": maxi(0, int(laundry_hostile_until_ms.get(peer_id, 0)) - checked_at), 
		"capone_direct_remaining_ms": maxi(0, int(laundry_capone_direct_until_ms.get(peer_id, 0)) - checked_at), 
		"defeat_pending": bool(laundry_defeat_pending.get(peer_id, false)), 
		"capone_disposition_started": bool(laundry_capone_disposition_started.get(peer_id, false)), 
	}

func attach_laundry_office_snapshot(peer_id: int, snapshot: Dictionary) -> Dictionary:
	var result: = snapshot.duplicate(true)
	if peer_id not in result:
		return result
	var office_snapshot: = laundry_office_snapshot_for_peer(peer_id)
	if office_snapshot.is_empty():
		return result
	var self_state: Dictionary = result[peer_id]
	self_state["office_npcs"] = office_snapshot
	result[peer_id] = self_state
	return result

func encode_laundry_office_snapshot(snapshot: Dictionary) -> Array:
	var encoded_actors: Array = []
	var actors_value: Variant = snapshot.get("actors", {})
	if actors_value is Dictionary:
		var actor_ids: Array = (actors_value as Dictionary).keys()
		actor_ids.sort()
		for actor_id_value in actor_ids:
			var actor_id: = String(actor_id_value)
			var actor: Dictionary = (actors_value as Dictionary).get(actor_id_value, {})
			encoded_actors.append([
				actor_id, 
				state_position(actor), 
				float(actor.get("health", 100.0)), 
				bool(actor.get("downed", false)), 
				bool(actor.get("removed", false)), 
				bool(actor.get("restrained", false)), 
				bool(actor.get("maimed", false)), 
				String(actor.get("ai_state", "idle")), 
				bool(actor.get("hostile", false)), 
				bool(actor.get("directly_attacked_by_player", false)), 
			])
	return [
		maxi(0, int(snapshot.get("hostility_remaining_ms", 0))), 
		maxi(0, int(snapshot.get("capone_direct_remaining_ms", 0))), 
		bool(snapshot.get("defeat_pending", false)), 
		bool(snapshot.get("capone_disposition_started", false)), 
		encoded_actors, 
	]

func decode_laundry_office_snapshot(values: Array) -> Dictionary:
	if values.size() < 5 or values[4] is not Array:
		return {}
	var actors: = {}
	for actor_value in values[4]:
		if actor_value is not Array or (actor_value as Array).size() < 10:
			continue
		var actor: Array = actor_value
		var actor_id: = String(actor[0])
		if not actor_id.is_empty():
			actors[actor_id] = {
				"actor_id": actor_id, "position": actor[1], "health": actor[2], 
				"downed": actor[3], "removed": actor[4], "restrained": actor[5], 
				"maimed": actor[6], "ai_state": actor[7], "hostile": actor[8], 
				"directly_attacked_by_player": actor[9], 
			}
	return {
		"hostility_remaining_ms": maxi(0, int(values[0])), 
		"capone_direct_remaining_ms": maxi(0, int(values[1])), 
		"defeat_pending": bool(values[2]), 
		"capone_disposition_started": bool(values[3]), 
		"actors": actors, 
	}

func snapshot_for_peer(peer_id: int, snapshot: Dictionary) -> Dictionary:
	if not public_hosting:
		return attach_laundry_office_snapshot(peer_id, snapshot)
	var viewer: Dictionary = snapshot.get(peer_id, {})
	var scoped: = {}
	if peer_id in snapshot:
		scoped[peer_id] = snapshot[peer_id]
	for candidate_value in snapshot.keys():
		var candidate_id: = int(candidate_value)
		if candidate_id == peer_id:
			continue
		var candidate: Dictionary = snapshot[candidate_value]
		if states_share_interest_scope(viewer, candidate):
			scoped[candidate_id] = remote_replication_state(candidate)
	return scoped

func remote_replication_state(candidate: Dictionary) -> Dictionary:
	var replicated: = {}
	for field in REMOTE_REPLICATION_FIELDS:
		if candidate.has(field):
			replicated[field] = candidate[field]
	return replicated

func remote_replication_values(candidate: Dictionary) -> Array:
	var values: Array = []
	for field in REMOTE_MOTION_FIELDS:
		values.append(candidate.get(field, null))
	return values

func decode_remote_replication_values(values: Array) -> Dictionary:
	var replicated: = {}
	for index in range(mini(values.size(), REMOTE_MOTION_FIELDS.size())):
		if values[index] != null:
			replicated[REMOTE_MOTION_FIELDS[index]] = values[index]
	return replicated

func remote_identity_state(candidate: Dictionary) -> Dictionary:
	var identity: = {}
	for field in REMOTE_IDENTITY_FIELDS:
		if candidate.has(field):
			identity[field] = candidate[field]
	return identity

func remote_identity_map_for_peer(peer_id: int, snapshot: Dictionary) -> Dictionary:
	var viewer: Dictionary = snapshot.get(peer_id, {})
	var identities: = {}
	for candidate_value in snapshot.keys():
		var candidate_id: = int(candidate_value)
		var candidate: Dictionary = snapshot[candidate_value]
		if candidate_id == peer_id or states_share_interest_scope(viewer, candidate):
			identities[candidate_id] = remote_identity_state(candidate)
	return identities

func compact_replication_records_for_peer(peer_id: int, snapshot: Dictionary) -> Array:
	var viewer: Dictionary = snapshot.get(peer_id, {})
	var records: Array = []
	for candidate_value in snapshot.keys():
		var candidate_id: = int(candidate_value)
		var candidate: Dictionary = snapshot[candidate_value]
		if candidate_id == peer_id or states_share_interest_scope(viewer, candidate):
			records.append([candidate_id, remote_replication_values(candidate)])
	var office_snapshot: = laundry_office_snapshot_for_peer(peer_id)
	if not office_snapshot.is_empty():
		records.append(["office_npcs", encode_laundry_office_snapshot(office_snapshot)])
	return records

func snapshot_record_chunks(records: Array) -> Array:
	var chunks: Array = []
	var current: Array = []
	for record in records:
		var candidate: = current.duplicate()
		candidate.append(record)
		if not current.is_empty() and var_to_bytes(candidate).size() > SNAPSHOT_CHUNK_TARGET_BYTES:
			chunks.append(current)
			current = [record]
		else:
			current = candidate
	if not current.is_empty():
		chunks.append(current)
	return chunks

func self_authority_fingerprint(state: Dictionary) -> PackedByteArray:
	var authority_fields: = {}
	for field_variant in state.keys():
		var field: = String(field_variant)
		if field not in REMOTE_REPLICATION_FIELDS:
			authority_fields[field] = state[field_variant]
	return var_to_bytes(authority_fields)

func send_authoritative_self_if_changed(peer_id: int, state: Dictionary) -> void :
	var fingerprint: = self_authority_fingerprint(state)
	if last_self_authority_fingerprints.get(peer_id, PackedByteArray()) == fingerprint:
		return
	last_self_authority_fingerprints[peer_id] = fingerprint
	var wire_state: = _wire_snapshot({peer_id: state})
	var payload: = var_to_bytes(wire_state)
	self_authority_send_count += 1
	snapshot_bytes_sent_estimate += payload.size()
	if public_hosting and payload.size() > SNAPSHOT_CHUNK_TARGET_BYTES:
		roster_transfer_sequence += 1
		var chunks: = packed_byte_chunks(payload, ROSTER_CHUNK_TARGET_BYTES)
		print("[AGERVIS SERVER] AUTHORITATIVE SELF TO PEER %d - %d BYTES IN %d CHUNKS" % [peer_id, payload.size(), chunks.size()])
		for chunk_index in range(chunks.size()):
			receive_server_roster_chunk.rpc_id(peer_id, roster_transfer_sequence, chunk_index, chunks.size(), chunks[chunk_index], AUTHORITATIVE_SELF_TRANSFER_WORLD)
	else:
		receive_authoritative_self.rpc_id(peer_id, snapshot_sequence, wire_state)

func send_remote_identities_if_changed(peer_id: int, snapshot: Dictionary) -> void :
	var identities: = remote_identity_map_for_peer(peer_id, snapshot)
	var wire_identities: = _wire_snapshot(identities)
	var fingerprint: = var_to_bytes(wire_identities)
	if last_remote_identity_fingerprints.get(peer_id, PackedByteArray()) == fingerprint:
		return
	last_remote_identity_fingerprints[peer_id] = fingerprint
	remote_identity_send_count += 1
	snapshot_bytes_sent_estimate += fingerprint.size()
	receive_remote_identities.rpc_id(peer_id, snapshot_sequence, wire_identities)

func _schedule_population(immediate: bool = false) -> void :
	if not hosting:
		return
	population_dirty = true
	population_timer = 0.0 if immediate else 0.1

func _wire_snapshot(snapshot: Dictionary) -> Dictionary:
	var wire: = {}
	for peer_value in snapshot.keys():
		wire[str(int(peer_value))] = snapshot[peer_value]
	return wire

func peer_connection_is_live(peer_id: int) -> bool:
	if peer_id <= 1 or not is_inside_tree():
		return false
	return peer_id in multiplayer.get_peers()

func _broadcast_population() -> void :
	if not hosting:
		return
	population_dirty = false
	var population: = connected_player_count()
	if population == last_population_broadcast and max_players == last_capacity_broadcast:
		return
	last_population_broadcast = population
	last_capacity_broadcast = max_players
	main_server_population = population
	server_population_received.emit(population, max_players)
	for peer_value in authorized_peers.keys():
		var peer_id: = int(peer_value)
		if peer_id > 1 and peer_id in peer_states and peer_connection_is_live(peer_id):
			receive_server_population.rpc_id(peer_id, population, max_players)

@rpc("authority", "call_remote", "reliable")
func receive_server_population(population: int, capacity: int) -> void :
	main_server_population = maxi(0, population)
	max_players = maxi(1, capacity)
	server_population_received.emit(main_server_population, max_players)

func _broadcast_snapshot() -> void :
	if not hosting:
		return
	var snapshot: = peer_states.duplicate(true)
	peer_snapshot_received.emit(attach_laundry_office_snapshot(1 if hosting else local_peer_id(), snapshot))
	snapshot_broadcast_count += 1
	snapshot_sequence += 1
	for peer_value in authorized_peers.keys():
		var peer_id: = int(peer_value)
		var peer_is_live: = peer_connection_is_live(peer_id)
		var pending_initial: = peer_id in pending_initial_snapshot_peers
		if peer_id > 1 and peer_id in peer_states and (peer_is_live or (pending_initial and _initial_snapshot_retry_due(peer_id))):
			if pending_initial:
				var initial_scoped: = attach_laundry_office_snapshot(peer_id, snapshot_for_peer(peer_id, snapshot))
				var wire_initial: = _wire_snapshot(initial_scoped)
				var initial_payload: = var_to_bytes(wire_initial)
				if initial_payload.size() > SNAPSHOT_CHUNK_TARGET_BYTES:
					roster_transfer_sequence += 1
					var initial_chunks: = packed_byte_chunks(initial_payload, ROSTER_CHUNK_TARGET_BYTES)
					for chunk_index in range(initial_chunks.size()):
						receive_server_roster_chunk.rpc_id(peer_id, roster_transfer_sequence, chunk_index, initial_chunks.size(), initial_chunks[chunk_index], INITIAL_SNAPSHOT_TRANSFER_WORLD)
				else:
					receive_snapshot.rpc_id(peer_id, wire_initial)
				if peer_is_live:
					pending_initial_snapshot_peers.erase(peer_id)
				else:
					var retry_state: Dictionary = pending_initial_snapshot_peers.get(peer_id, {})
					retry_state["next_retry_ms"] = Time.get_ticks_msec() + INITIAL_SNAPSHOT_RETRY_INTERVAL_MS
					pending_initial_snapshot_peers[peer_id] = retry_state
				continue
			snapshot_recipient_count += 1
			if public_hosting:
				send_authoritative_self_if_changed(peer_id, snapshot[peer_id])
				send_remote_identities_if_changed(peer_id, snapshot)
				var chunks: = snapshot_record_chunks(compact_replication_records_for_peer(peer_id, snapshot))
				for chunk_index in range(chunks.size()):
					var chunk: Array = chunks[chunk_index]
					snapshot_chunk_count += 1
					var chunk_bytes: = var_to_bytes(chunk).size()
					snapshot_bytes_sent_estimate += chunk_bytes
					snapshot_periodic_bytes_sent_estimate += chunk_bytes
					receive_snapshot_chunk.rpc_id(peer_id, snapshot_sequence, chunk_index, chunks.size(), chunk)
			else:
				var wire_snapshot: = _wire_snapshot(snapshot_for_peer(peer_id, snapshot))
				var snapshot_bytes: = var_to_bytes(wire_snapshot).size()
				snapshot_bytes_sent_estimate += snapshot_bytes
				snapshot_periodic_bytes_sent_estimate += snapshot_bytes
				receive_snapshot.rpc_id(peer_id, wire_snapshot)

func _flush_pending_initial_snapshots() -> void :
	if not hosting or pending_initial_snapshot_peers.is_empty():
		return
	var ready: = false
	var now_ms: = Time.get_ticks_msec()
	for peer_variant in pending_initial_snapshot_peers.keys().duplicate():
		var peer_id: = int(peer_variant)
		if peer_id not in authorized_peers or peer_id not in peer_states:
			pending_initial_snapshot_peers.erase(peer_id)
		else:
			var retry_state: Dictionary = pending_initial_snapshot_peers.get(peer_id, {})
			if now_ms >= int(retry_state.get("deadline_ms", now_ms)):
				pending_initial_snapshot_peers.erase(peer_id)
			elif peer_connection_is_live(peer_id) or now_ms >= int(retry_state.get("next_retry_ms", now_ms)):
				ready = true
	if ready:
		_broadcast_snapshot()

func _initial_snapshot_retry_due(peer_id: int) -> bool:
	var retry_state: Dictionary = pending_initial_snapshot_peers.get(peer_id, {})
	var now_ms: = Time.get_ticks_msec()
	if now_ms >= int(retry_state.get("deadline_ms", now_ms)):
		pending_initial_snapshot_peers.erase(peer_id)
		return false
	return peer_connection_is_live(peer_id) or now_ms >= int(retry_state.get("next_retry_ms", now_ms))

@rpc("authority", "call_remote", "reliable")
func receive_authoritative_self(_sequence: int, wire_state: Dictionary) -> void :
	var local_id: = local_peer_id()
	var state_value: Variant = wire_state.get(str(local_id), null)
	if state_value is not Dictionary:
		return
	authoritative_self_state = (state_value as Dictionary).duplicate(true)
	var combined: = peer_states.duplicate(true)
	combined[local_id] = authoritative_self_state.duplicate(true)
	peer_states = combined
	peer_snapshot_received.emit(peer_states.duplicate(true))

@rpc("authority", "call_remote", "reliable")
func receive_remote_identities(_sequence: int, wire_identities: Dictionary) -> void :
	var identities: = {}
	for peer_key in wire_identities.keys():
		if wire_identities[peer_key] is Dictionary:
			identities[int(String(peer_key))] = (wire_identities[peer_key] as Dictionary).duplicate(true)
	remote_identity_states = identities

@rpc("authority", "call_remote", "unreliable_ordered", 2)
func receive_snapshot_chunk(sequence: int, chunk_index: int, chunk_count: int, records: Array) -> void :
	if sequence < pending_snapshot_sequence or chunk_index < 0 or chunk_index >= chunk_count or chunk_count <= 0:
		return
	if sequence > pending_snapshot_sequence:
		pending_snapshot_sequence = sequence
		pending_snapshot_chunk_count = chunk_count
		pending_snapshot_chunks.clear()
	if chunk_count != pending_snapshot_chunk_count:
		return
	pending_snapshot_chunks[chunk_index] = records.duplicate(true)
	if pending_snapshot_chunks.size() != pending_snapshot_chunk_count:
		return
	var normalized: = {}
	var office_snapshot: = {}
	for ordered_index in range(pending_snapshot_chunk_count):
		var chunk: Array = pending_snapshot_chunks.get(ordered_index, [])
		for record_variant in chunk:
			if record_variant is not Array or (record_variant as Array).size() < 2:
				continue
			var record: Array = record_variant
			if record[0] is String and record[0] == "office_npcs" and record[1] is Array:
				office_snapshot = decode_laundry_office_snapshot(record[1] as Array)
			elif record[1] is Array:
				normalized[int(record[0])] = decode_remote_replication_values(record[1])
	for peer_variant in normalized.keys():
		var peer_id: = int(peer_variant)
		if peer_id in remote_identity_states:
			var combined: Dictionary = (remote_identity_states[peer_id] as Dictionary).duplicate(true)
			for field_variant in (normalized[peer_id] as Dictionary).keys():
				combined[field_variant] = normalized[peer_id][field_variant]
			normalized[peer_id] = combined
	var local_id: = local_peer_id()
	if local_id in normalized and not authoritative_self_state.is_empty():
		var complete_self: = authoritative_self_state.duplicate(true)
		for field_variant in (normalized[local_id] as Dictionary).keys():
			complete_self[field_variant] = normalized[local_id][field_variant]
		normalized[local_id] = complete_self
	if local_id in normalized and not office_snapshot.is_empty():
		normalized[local_id]["office_npcs"] = office_snapshot
	elif local_id in normalized and local_id in peer_states and peer_states[local_id].has("office_npcs"):
		normalized[local_id]["office_npcs"] = peer_states[local_id]["office_npcs"]
	peer_states = normalized
	peer_snapshot_received.emit(peer_states.duplicate(true))

@rpc("authority", "call_remote", "reliable")
func receive_snapshot(snapshot: Dictionary) -> void :
	var normalized: = {}
	for peer_key in snapshot.keys():
		normalized[int(String(peer_key))] = snapshot[peer_key]


	var local_id: = local_peer_id()
	var prior_local: Dictionary = peer_states.get(local_id, {})
	if local_id in normalized and not normalized[local_id].has("office_npcs") and prior_local.has("office_npcs"):
		normalized[local_id]["office_npcs"] = prior_local["office_npcs"]
	peer_states = normalized.duplicate(true)
	peer_snapshot_received.emit(peer_states.duplicate(true))

func _broadcast_chat(sender_name: String, message: String) -> void :
	chat_received.emit(sender_name, message)
	if hosting and enet_peer != null:
		for peer_value in authorized_peers.keys():
			var peer_id: = int(peer_value)
			if peer_id > 1 and peer_connection_is_live(peer_id):
				receive_chat.rpc_id(peer_id, sender_name, message)

@rpc("authority", "call_remote", "reliable")
func receive_chat(sender_name: String, message: String) -> void :
	chat_received.emit(sender_name, message)

func _sanitize_initial_state(candidate: Dictionary, peer_id: int) -> Dictionary:
	var state: = candidate.duplicate(true)
	state.erase("invite_token")
	state["peer_id"] = peer_id
	state["tester_id"] = safe_tester_id(String(state.get("tester_id", "")))
	state["name"] = String(state.get("name", "Resident %d" % peer_id)).strip_edges().left(20)
	state["health"] = clampf(float(state.get("health", 100.0)), 0.0, 100.0)
	state["downed"] = bool(state.get("downed", false))
	state["mark"] = maxf(0.0, float(state.get("mark", 0.0)))
	state["heat"] = Rules.normalized_heat(int(state.get("heat", state.get("case_strength", 0))))
	state["case_strength"] = state["heat"]
	state["detained"] = bool(state.get("detained", false))
	state["arrested"] = bool(state.get("arrested", false))
	state["warrant"] = bool(state.get("warrant", false))
	state["attack_weapon"] = sanitize_attack_weapon(state.get("attack_weapon", "Fists"))
	state["home_instance_id"] = ""
	state["active_home_visit"] = {}
	for money_key in ["cash", "dirty_cash", "bank_balance"]:
		state[money_key] = clampi(int(state.get(money_key, 0)), 0, 999999999)
	return state

func authoritative_home_for(account_id: String, resident_slot: int) -> Dictionary:
	if not profiles_enabled or account_id.is_empty() or resident_slot < 0:
		return {}
	var roster: = account_roster(account_id)
	var slots: Array = roster.get("slots", [])
	if resident_slot >= slots.size() or slots[resident_slot] is not Dictionary:
		return {}
	var resident: = SaveMigration.migrate_resident(slots[resident_slot] as Dictionary)
	return PlayerHomeContent.first_player_home(resident.get("property", []), PlayerHomeContent.MERCY_COURT_ID)

func clear_persisted_active_home_visit(account_id: String, resident_slot: int, state: Dictionary) -> void :
	if not profiles_enabled or account_id.is_empty() or resident_slot < 0:
		return
	var roster: = account_roster(account_id)
	var slots: Array = roster.get("slots", [])
	if resident_slot >= slots.size() or slots[resident_slot] is not Dictionary:
		return
	var resident: = SaveMigration.migrate_resident(slots[resident_slot] as Dictionary)
	if PlayerHomeContent.normalize_active_visit(resident.get("active_home_visit", {})).is_empty():
		return
	resident["active_home_visit"] = {}
	resident["home_instance_id"] = ""
	resident["area"] = String(state.get("area", resident.get("area", "apartment")))
	resident["room_id"] = String(state.get("room_id", resident.get("room_id", "floor_1")))
	var position: = state_position(state)
	resident["position"] = [position.x, position.y]
	slots[resident_slot] = resident
	roster["slots"] = slots
	persistent_profiles[account_id] = ReleaseSave.normalize_roster(roster)
	profiles_dirty = true

func canonicalize_home_state(state: Dictionary, account_id: String, resident_slot: int) -> void :
	state["home_instance_id"] = ""
	if String(state.get("area", "")) != "apartment" or String(state.get("room_id", "")) != "unit":
		clear_persisted_active_home_visit(account_id, resident_slot, state)
		state["active_home_visit"] = {}
		return
	var active_visit: = PlayerHomeContent.normalize_active_visit(state.get("active_home_visit", {}))
	if not active_visit.is_empty():
		var visited_entry: = authoritative_home_by_instance(String(active_visit.get("home_instance_id", "")))
		if not visited_entry.is_empty() and String(visited_entry.get("account_id", "")) == safe_tester_id(String(active_visit.get("owner_account_id", ""))) and int(visited_entry.get("resident_slot", -1)) == int(active_visit.get("owner_resident_slot", -1)):
			var visited_owner: = SaveMigration.migrate_resident(visited_entry.get("resident", {}))
			var visited_home: Dictionary = Dictionary(visited_entry.get("home", {})).duplicate(true)
			active_visit["home_snapshot"] = PlayerHomeContent.visit_snapshot(visited_home, String(visited_owner.get("name", "Resident")))
			state["active_home_visit"] = active_visit
			state["home_instance_id"] = String(active_visit.get("home_instance_id", ""))
			return
		clear_persisted_active_home_visit(account_id, resident_slot, {"area": "apartment", "room_id": "floor_1", "position": Vector2(500, 270)})
		state["active_home_visit"] = {}
		state["room_id"] = "floor_1"
		state["position"] = Vector2(500, 270)
		return
	var home: = authoritative_home_for(account_id, resident_slot)
	if home.is_empty():
		state["room_id"] = "floor_1"
		state["position"] = Vector2(500, 270)
		return
	state["home_instance_id"] = String(home.get("home_instance_id", ""))

func handoff_location_allowed(state: Dictionary, rule: Dictionary, source: bool) -> bool:
	var room_key: = "%s:%s" % [String(state.get("area", "")), String(state.get("room_id", ""))]
	var allowed_key: = "sources" if source else "destinations"
	var allowed_rooms: Array = rule.get(allowed_key, [])
	if room_key not in allowed_rooms:
		return false
	var point_key: = "source_point" if source else "destination_point"
	if rule.get(point_key, null) is Vector2:
		return state_position(state).distance_to(rule[point_key] as Vector2) <= float(rule.get("radius", 180.0))
	return true

func persisted_authoritative_handoff(account_key: String, resident_slot: int, item_id: String) -> Dictionary:
	if not profiles_enabled or account_key.is_empty() or resident_slot < 0:
		return {}
	var stored_roster: = account_roster(account_key)
	var slots: Array = stored_roster.get("slots", [])
	if resident_slot >= slots.size() or slots[resident_slot] is not Dictionary:
		return {}
	var resident: Dictionary = slots[resident_slot]
	var stored_handoffs: Dictionary = resident.get("handoff_items", {})
	if stored_handoffs.get(item_id, null) is Dictionary:
		return Dictionary(stored_handoffs[item_id]).duplicate(true)
	return {}

func new_authoritative_handoff(peer_id: int, account_key: String, resident_slot: int, item_id: String, proposed: Dictionary, state: Dictionary) -> Dictionary:
	var rule: Dictionary = HANDOFF_RULES[item_id]
	handoff_event_sequence += 1
	var record: = proposed.duplicate(true)
	record["id"] = item_id
	record["display_name"] = String(rule.get("display", item_id))
	record["employer"] = String(rule.get("employer", "UNFILED"))
	record["state"] = "carried"
	record["outcome"] = "PENDING"
	record["owner_peer_id"] = peer_id
	record["owner_tester_id"] = account_key
	record["owner_resident_slot"] = resident_slot
	record["owner_world_id"] = server_world_id
	record["source_area"] = String(state.get("area", ""))
	record["source_room_id"] = String(state.get("room_id", ""))
	record["authority_nonce"] = "%d-%d-%d" % [peer_id, Time.get_ticks_msec(), handoff_event_sequence]
	record["authority_issued_msec"] = Time.get_ticks_msec()
	record["witnessed"] = false
	record["tampered"] = false
	record["delay_reported"] = false
	return record

func sanitize_peer_handoffs(candidate: Dictionary, previous: Dictionary, state: Dictionary, peer_id: int) -> Dictionary:
	var proposed_handoffs: Dictionary = candidate.get("handoff_items", {})
	var previous_handoffs: Dictionary = previous.get("handoff_items", {})
	var result: = previous_handoffs.duplicate(true)
	var account_key: = safe_tester_id(String(candidate.get("tester_id", state.get("tester_id", ""))))
	var resident_slot: = clampi(int(candidate.get("resident_slot", state.get("resident_slot", -1))), -1, ReleaseSave.FREE_SLOTS - 1)
	for item_value in HANDOFF_RULES.keys():
		var item_id: = String(item_value)
		var rule: Dictionary = HANDOFF_RULES[item_id]
		var proposed: Dictionary = Dictionary(proposed_handoffs.get(item_id, {})).duplicate(true)
		var current: Dictionary = Dictionary(result.get(item_id, {})).duplicate(true)
		var current_active: = String(current.get("state", "")) == "carried"
		if current_active:
			if String(current.get("owner_tester_id", "")) != account_key or int(current.get("owner_resident_slot", -2)) != resident_slot:
				continue
			if proposed.is_empty() or String(proposed.get("authority_nonce", "")) != String(current.get("authority_nonce", "")):
				continue
			current["witnessed"] = bool(current.get("witnessed", false)) or bool(proposed.get("witnessed", false))
			current["tampered"] = bool(current.get("tampered", false)) or bool(proposed.get("tampered", false))
			current["delay_reported"] = bool(current.get("delay_reported", false)) or bool(proposed.get("delay_reported", false))
			var proposed_state: = String(proposed.get("state", "carried"))
			var proposed_outcome: = String(proposed.get("outcome", "PENDING")).to_upper()
			if proposed_state == "closed":
				var may_close: = proposed_outcome in ["LOST", "STOLEN"]
				if proposed_outcome == "COMPLETED":
					may_close = handoff_location_allowed(state, rule, false)
				if may_close:
					current["state"] = "closed"
					current["outcome"] = proposed_outcome
					current["authority_closed_msec"] = Time.get_ticks_msec()
			elif proposed_outcome in ["WITNESSED", "TAMPERED WITH", "DELAYED"]:
				current["outcome"] = proposed_outcome
			result[item_id] = current
			continue
		if proposed.is_empty() or String(proposed.get("state", "")) != "carried":
			continue
		var restored: = persisted_authoritative_handoff(account_key, resident_slot, item_id)
		if String(restored.get("state", "")) == "carried" and not String(restored.get("authority_nonce", "")).is_empty() and String(proposed.get("authority_nonce", "")) == String(restored.get("authority_nonce", "")):
			result[item_id] = restored
		elif handoff_location_allowed(state, rule, true):
			result[item_id] = new_authoritative_handoff(peer_id, account_key, resident_slot, item_id, proposed, state)
	return result
func _sanitize_client_motion(candidate: Dictionary, previous: Dictionary, peer_id: int, accept_progress: bool = true) -> Dictionary:
	if previous.is_empty(): return _sanitize_initial_state(candidate, peer_id)
	var result: = previous.duplicate(true)
	var accepted_keys: = [
		"name", "area", "room_id", "phase", "position", "facing", "walking", "color", "pants_color", "skin", 
		"hair_style", "body_style", "hair_color", "facial_hair_style", "facial_hair_color", 
		"face_style", "eye_style", "stature", "outfit_style", "surreal_trait", "accessory", "attack_weapon", 
		"office_attack_actor_id", "office_disposition_actor_id", 
	]
	for key in accepted_keys:
		if candidate.has(key):
			result[key] = candidate[key]
	result["peer_id"] = peer_id
	result["name"] = String(result.get("name", "Resident %d" % peer_id)).strip_edges().left(20)
	result["attack_weapon"] = sanitize_attack_weapon(result.get("attack_weapon", "Fists"))
	if bool(previous.get("arrested", false)):


		result["arrested"] = true
		result["area"] = "jail"
		result["room_id"] = String(previous.get("room_id", "tier")) if String(previous.get("area", "jail")) == "jail" else "tier"
		result["home_instance_id"] = ""
		result["downed"] = false
		result["health"] = maxf(1.0, float(previous.get("health", 70.0)))
	if accept_progress:
		hydrate_peer_economy_from_profile(result, peer_id)
	return result

func hydrate_peer_economy_from_profile(state: Dictionary, peer_id: int) -> void :
	if not profiles_enabled:
		return
	var account_id: = safe_tester_id(String(peer_accounts.get(peer_id, state.get("tester_id", ""))))
	var resident_slot: = int(state.get("resident_slot", -1))
	if account_id.is_empty() or resident_slot < 0:
		return
	var roster: = account_roster(account_id)
	var slots: Array = roster.get("slots", [])
	if resident_slot >= slots.size() or slots[resident_slot] is not Dictionary:
		return
	var resident: = SaveMigration.migrate_resident(slots[resident_slot] as Dictionary)
	state["cash"] = floori(float(resident.get("carried_cash_clean", 0)) / 100.0)
	state["dirty_cash"] = floori(float(resident.get("carried_cash_dirty", 0)) / 100.0)
	state["bank_balance"] = floori(float(resident.get("bank_balance_clean", 0)) / 100.0)
	state["inventory"] = SaveMigration.inventory_names(resident.get("inventory", []))
	state["equipment"] = SaveMigration.equipment_names(resident.get("equipment", {}))
	state["health"] = clampf(float(resident.get("health", state.get("health", 100.0))), 0.0, 100.0)
	state["stamina"] = clampf(float(resident.get("stamina", state.get("stamina", 100.0))), 0.0, max_stamina_for_equipment(resident.get("equipment", {})))
	state["credentials"] = resident.get("credentials", []).duplicate()
	state["official_function"] = String(resident.get("official_function", ""))
	state["on_duty"] = bool(resident.get("on_duty", false))
	state["skills"] = Dictionary(resident.get("xp", {})).duplicate(true)
	state["heat"] = authoritative_heat(resident)
	state["case_strength"] = state["heat"]
	state["detained"] = bool(resident.get("detained", false))
	state["detained_by_account_id"] = String(resident.get("detained_by_account_id", ""))
	state["detained_by_resident_slot"] = int(resident.get("detained_by_resident_slot", -1))
	state["detained_at_ms"] = maxi(0, int(resident.get("detained_at_ms", 0)))
	state["arrested"] = bool(resident.get("arrested", false))
	state["warrant"] = bool(resident.get("warrant", false))
	state["sentence_credits"] = maxi(0, int(resident.get("sentence_credits", 0)))
	state["education_points"] = maxi(0, int(resident.get("education_points", 0)))
	state["jail_street_cred"] = maxi(0, int(resident.get("jail_street_cred", 0)))
	state["jail_favors"] = maxi(0, int(resident.get("jail_favors", 0)))
	state["jail_snitch_heat"] = maxi(0, int(resident.get("jail_snitch_heat", 0)))
	state["crimes"] = Array(resident.get("crimes", [])).duplicate(true)
	state["phone_messages"] = Array(resident.get("phone_messages", [])).duplicate(true)
	state["wanted"] = bool(resident.get("wanted", false))
	state["mark"] = maxf(0.0, float(resident.get("mark_timer", state.get("mark", 0.0))))
	if bool(resident.get("arrested", false)):
		if String(state.get("area", "")) != "jail":
			state["area"] = "jail"
			state["room_id"] = String(resident.get("room_id", "tier"))
			state["position"] = resident_saved_position(resident)
		state["home_instance_id"] = ""
		state["downed"] = false
		state["health"] = maxf(1.0, float(resident.get("health", 70.0)))
	state["apartment_leased"] = bool(resident.get("apartment_leased", false)) or not PlayerHomeContent.first_player_home(resident.get("property", []), PlayerHomeContent.MERCY_COURT_ID).is_empty()
	state["property"] = PlayerHomeContent.property_records(resident.get("property", []))
	state["active_home_visit"] = PlayerHomeContent.normalize_active_visit(resident.get("active_home_visit", {}))
	state["home_instance_id"] = ""
	var cashier_employment: = cashier_employment_record(resident)
	var restaurant_employment: = service_employment_record(resident, "alibis")
	var laundry_employment: = service_employment_record(resident, "spin_cycle")
	var capone_employment: = capone_employment_record(resident)
	if cashier_employment_active(capone_employment):
		state["active_job"] = "Capone Courier"
	elif cashier_employment_active(cashier_employment):
		state["active_job"] = "Cashier"
	elif cashier_employment_active(restaurant_employment):
		state["active_job"] = "Carryout Worker"
	elif cashier_employment_active(laundry_employment):
		state["active_job"] = "Laundry Attendant"
	else:
		state["active_job"] = String(resident.get("active_job", "None"))
	state["handoff_items"] = SaveMigration.legacy_handoff_dictionary(resident.get("active_handoffs", []))
	state["dealer_relationships"] = SaveMigration.dealer_relationship_records(resident.get("dealer_relationships", {}))
	canonicalize_home_state(state, account_id, resident_slot)
func _on_peer_connected(peer_id: int) -> void :
	if hosting:
		peer_states[peer_id] = {
			"peer_id": peer_id, 
			"name": "Awaiting invite token", 
			"area": "home", 
			"phase": "adult", 
			"position": Vector2(850, 260), 
			"health": 100.0, 
			"downed": false, 
			"mark": 0.0, 
		}
		max_connected_peer_count = maxi(max_connected_peer_count, connected_player_count())
		_set_status("CONNECTION REQUEST RECEIVED  -  VERIFYING INVITE")



func _on_peer_disconnected(peer_id: int) -> void :
	pending_initial_snapshot_peers.erase(peer_id)
	var disconnected_account: = safe_tester_id(String(peer_accounts.get(peer_id, peer_states.get(peer_id, {}).get("tester_id", ""))))
	var disconnected_slot: = int(peer_states.get(peer_id, {}).get("resident_slot", -1))
	interrupt_active_blood_cleaning_for_peer(peer_id, "DISCONNECTED")
	interrupt_school_training_for_peer(peer_id, "DISCONNECTED")
	school_study_sessions.erase(school_training_key(disconnected_account, disconnected_slot))
	if profiles_enabled:
		store_connected_resident(peer_id)
		profiles_dirty = true
		profile_save_timer = 0.75
	peer_states.erase(peer_id)
	authorized_peers.erase(peer_id)
	peer_accounts.erase(peer_id)
	laundry_hostile_until_ms.erase(peer_id)
	laundry_capone_direct_until_ms.erase(peer_id)
	laundry_office_presence.erase(peer_id)
	laundry_defeat_pending.erase(peer_id)
	laundry_capone_disposition_started.erase(peer_id)
	last_self_authority_fingerprints.erase(peer_id)
	last_remote_identity_fingerprints.erase(peer_id)
	if connected_peer_for_resident(disconnected_account, disconnected_slot) == 0:
		release_assignments_for_resident(disconnected_account, disconnected_slot)
	disconnect_count += 1
	if hosting:
		if public_hosting:
			_set_status("MAIN SERVER RUNNING - UDP %d - %d/%d" % [port, peer_states.size(), max_players])
		else:
			_set_status("PRIVATE GAME RUNNING - UDP %d - %d/%d" % [port, peer_states.size(), max_players])
		_schedule_population()
		if connected_player_count() > 0:
			snapshot_dirty = true
			snapshot_timer = maxf(snapshot_timer, 0.15)
func _on_connected_to_server() -> void :
	var pending: Dictionary = peer_states.get(0, {})
	peer_states.clear()
	reconnect_attempts = 0
	_set_status("CONNECTED  -  TEST PACKET EXCHANGED  -  PEER %d" % local_peer_id())
	submit_state_to_server.rpc_id(1, pending)

func _on_connection_failed() -> void :
	active = false
	if not reconnect_address.is_empty() and reconnect_attempts < 3:
		reconnect_attempts = 1 if reconnect_attempts == 0 else reconnect_attempts + 1
		reconnect_timer = 1.25
		_set_status("UNABLE TO CONNECT TO SERVER  -  RETRY %d/3" % reconnect_attempts)
	else:
		reconnect_attempts = 4
		_set_status("UNABLE TO CONNECT TO SERVER")

func _on_server_disconnected() -> void :
	active = false
	if reconnect_address.is_empty():
		_set_status("HOST ENDED THE SESSION")
		return
	reconnect_attempts = 1
	reconnect_timer = 0.75
	_set_status("CONNECTION LOST  -  RECONNECTING 1/3")

func _attempt_reconnect() -> void :
	if reconnect_attempts > 3:
		_set_status("UNABLE TO CONNECT TO SERVER")
		return
	_set_status("RECONNECTING  -  ATTEMPT %d/3" % reconnect_attempts)
	var result: = _open_client(reconnect_address, reconnect_state, reconnect_port, reconnect_token)
	if result != OK:
		reconnect_attempts += 1
		if reconnect_attempts > 3:
			_set_status("UNABLE TO CONNECT TO SERVER")
		else:
			reconnect_timer = 1.25

func _set_status(message: String) -> void :
	status = message
	status_changed.emit(message)

func connection_confirmed() -> bool:
	if hosting: return active
	return active and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and local_peer_id() > 1
