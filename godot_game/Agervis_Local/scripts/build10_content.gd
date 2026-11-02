class_name AgervisBuild10Content
extends RefCounted

const BUILD_NUMBER: = 13
const BUILD_LABEL: = "Build 13 Private Alpha"
const PROTOCOL_VERSION: = 13
const MAIN_SERVER_HOST: = "governors-refute.tun.ply.gg"
const MAIN_SERVER_PORT: = 10813
const LOCAL_SERVER_PORT: = 24860

const EQUIPMENT_SLOTS: = [
	"head", "face", "torso", "outerwear", "hands", "legs", "feet", "back", 
	"contingency_1", "contingency_2", 
]

const EQUIPMENT_CATALOG: = {
	"Scholarship Jacket": {"slot": "outerwear", "capacity": 0, "stamina_cost": 0, "description": "A school-issued jacket with visibly earned trim."}, 
	"Honor Roll Jacket": {"slot": "outerwear", "capacity": 0, "stamina_cost": 0, "description": "A school-issued jacket with visibly earned trim."}, 
	"Reflective Scholarship Backpack": {"slot": "back", "capacity": 4, "stamina_cost": 2, "description": "Four extra carry slots. Reflective enough to become evidence."}, 
	"Canvas Backpack": {"slot": "back", "capacity": 8, "stamina_cost": 5, "description": "Eight extra carry slots and a noticeable silhouette."}, 
	"Large Courier Pack": {"slot": "back", "capacity": 12, "stamina_cost": 9, "description": "Twelve extra carry slots. Running with it has consequences."}, 
	"Kevlar Vest": {"slot": "contingency_1", "capacity": 0, "stamina_cost": 4, "description": "A one-use contingency against ballistic fatality."}, 
	"Used Kevlar": {"slot": "contingency_1", "capacity": 0, "stamina_cost": 4, "description": "A one-use contingency against a lethal ballistic hit."}, "Emergency Beacon": {"slot": "contingency_1", "capacity": 0, "stamina_cost": 0, "description": "A one-use interruption contingency."}, 
	"Revivar Kit": {"slot": "contingency_2", "capacity": 0, "stamina_cost": 0, "description": "A one-use overdose contingency."},
	"Clinic Revivar": {"slot": "contingency_2", "capacity": 0, "stamina_cost": 0, "description": "A one-use emergency overdose response contingency."}, }

const ROOM_LAYOUTS: = {
	"home": [
		{"id": "lobby", "label": "GROUP HOME LOBBY", "doors": ["communal", "caseworker", "street"]}, 
		{"id": "caseworker", "label": "CASEWORKER OFFICE", "doors": ["lobby"]}, 
		{"id": "communal", "label": "COMMUNAL ROOM", "doors": ["lobby", "resident_hall", "utility"]}, 
		{"id": "utility", "label": "KITCHEN / LAUNDRY", "doors": ["communal"]}, 
		{"id": "resident_hall", "label": "RESIDENT HALL", "doors": ["communal", "bed_6b"]}, 
		{"id": "bed_6b", "label": "BED 6B", "doors": ["resident_hall"]}, 
	], 
	"tutorial": [
		{"id": "guidance", "label": "TUTORIAL GUIDANCE OFFICE", "doors": ["orientation_hall"]}, 
		{"id": "orientation", "label": "TUTORIAL ORIENTATION CLASSROOM", "doors": ["orientation_hall"]}, 
		{"id": "orientation_hall", "label": "TUTORIAL - GUIDANCE / ORIENTATION HALL", "doors": ["guidance", "orientation", "hall_a"], "door_positions": {"guidance": 150.0, "orientation": 500.0, "hall_a": 850.0}}, 
		{"id": "hall_a", "label": "TUTORIAL - EAST CLASSROOM HALL", "doors": ["orientation_hall", "class_intelligence", "class_endurance", "gym_a", "vehicle_yard", "class_fighting"]},
		{"id": "hall_b", "label": "TUTORIAL - WEST CLASSROOM HALL", "doors": ["class_firearms", "class_stealth", "class_awareness", "class_safety", "class_medicine"]}, 
		{"id": "career_wing", "label": "TUTORIAL - CAREER WING", "doors": ["class_influence", "class_enterprise", "class_civics", "scholarship", "service_exit"]}, 
		{"id": "class_intelligence", "label": "INTELLIGENCE CLASSROOM", "doors": ["hall_a"], "skill_max_level": 5}, 
		{"id": "class_endurance", "label": "ENDURANCE CLASSROOM", "doors": ["hall_a"], "skill_max_level": 5}, 
		{"id": "gym_a", "label": "AGILITY GYM - LEFT COURT", "doors": ["hall_a"], "door_positions": {"hall_a": 600.0}, "skill_max_level": 5},
		{"id": "gym_b", "label": "AGILITY GYM - RIGHT COURT", "doors": [], "skill_max_level": 5},
		{"id": "vehicle_yard", "label": "VEHICLE TRAINING YARD", "doors": ["hall_a"], "skill_max_level": 5},
		{"id": "class_fighting", "label": "FIGHTING STRATEGY CLASSROOM", "doors": ["hall_a"], "skill_max_level": 5}, 
		{"id": "class_firearms", "label": "FIREARMS SAFETY CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_stealth", "label": "STEALTH / OBSERVATION CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_awareness", "label": "AWARENESS CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_safety", "label": "SAFETY CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_medicine", "label": "MEDICINE CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_influence", "label": "INFLUENCE CLASSROOM", "doors": ["career_wing"], "skill_max_level": 5}, 
		{"id": "class_enterprise", "label": "ENTERPRISE CLASSROOM", "doors": ["career_wing"], "skill_max_level": 5}, 
		{"id": "class_civics", "label": "CIVICS CLASSROOM", "doors": ["career_wing"], "skill_max_level": 5}, 
		{"id": "scholarship", "label": "TUTORIAL SCHOLARSHIP EXCHANGE", "doors": ["career_wing"]}, 
		{"id": "service_exit", "label": "TUTORIAL SERVICE EXIT / DITCH ROUTE", "doors": ["career_wing", "street"]}, 
	], 
	"school": [
		{"id": "orientation", "label": "ORIENTATION CLASSROOM", "doors": ["hall_a"]}, 
		{"id": "guidance", "label": "GUIDANCE OFFICE", "doors": ["hall_a"]}, 
		{"id": "hall_a", "label": "CONTINUATION SCHOOL - EAST HALL", "doors": ["orientation", "guidance", "class_intelligence", "class_endurance", "gym_a", "vehicle_yard", "class_fighting"]}, 
		{"id": "hall_b", "label": "CONTINUATION SCHOOL - WEST HALL", "doors": ["class_firearms", "class_stealth", "class_awareness", "class_safety", "class_medicine", "safety"]}, 
		{"id": "career_wing", "label": "CONTINUATION SCHOOL - CAREER WING", "doors": ["class_influence", "class_enterprise", "class_civics", "scholarship", "service_exit"]}, 
		{"id": "class_intelligence", "label": "INTELLIGENCE CLASSROOM", "doors": ["hall_a"], "skill_max_level": 5}, 
		{"id": "class_endurance", "label": "ENDURANCE CLASSROOM", "doors": ["hall_a"], "skill_max_level": 5}, 
		{"id": "gym_a", "label": "AGILITY GYM - LEFT COURT", "doors": ["hall_a"], "door_positions": {"hall_a": 600.0}, "skill_max_level": 5},
		{"id": "gym_b", "label": "AGILITY GYM - RIGHT COURT", "doors": [], "skill_max_level": 5},
		{"id": "vehicle_yard", "label": "VEHICLE TRAINING YARD", "doors": ["hall_a"], "skill_max_level": 5},
		{"id": "class_fighting", "label": "FIGHTING STRATEGY CLASSROOM", "doors": ["hall_a"], "skill_max_level": 5}, 
		{"id": "class_firearms", "label": "FIREARMS SAFETY CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_stealth", "label": "STEALTH / OBSERVATION CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_awareness", "label": "AWARENESS CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_safety", "label": "SAFETY CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_medicine", "label": "MEDICINE CLASSROOM", "doors": ["hall_b"], "skill_max_level": 5}, 
		{"id": "class_influence", "label": "INFLUENCE CLASSROOM", "doors": ["career_wing"], "skill_max_level": 5}, 
		{"id": "class_enterprise", "label": "ENTERPRISE CLASSROOM", "doors": ["career_wing"], "skill_max_level": 5}, 
		{"id": "class_civics", "label": "CIVICS CLASSROOM", "doors": ["career_wing"], "skill_max_level": 5}, 
		{"id": "scholarship", "label": "SCHOLARSHIP EXCHANGE", "doors": ["career_wing"]}, 
		{"id": "safety", "label": "ENCLOSED SAFETY OFFICE", "doors": ["hall_b"]}, 
		{"id": "service_exit", "label": "SERVICE EXIT / DITCH ROUTE", "doors": ["career_wing", "street"]}, 
	], 
	"store": [
		{"id": "sales", "label": "BOSS'S SALES FLOOR", "doors": ["stockroom", "street"], "door_positions": {"stockroom": 340.0, "street": 930.0}}, 
		{"id": "stockroom", "label": "STOCKROOM", "doors": ["sales", "safe", "dvr", "rear"]}, 
		{"id": "safe", "label": "DEPOSIT SAFE ROOM", "doors": ["stockroom"]}, 
		{"id": "dvr", "label": "DVR CLOSET", "doors": ["stockroom"]}, 
	], 
	"restaurant": [
		{"id": "dining", "label": "THE ALIBI DINING ROOM", "doors": ["kitchen", "street"]}, 
		{"id": "kitchen", "label": "ENCLOSED KITCHEN", "doors": ["dining", "office", "delivery", "rear"], "door_positions": {"office": 130.0, "delivery": 320.0, "rear": 500.0, "dining": 870.0}}, 
		{"id": "office", "label": "ALIBI OFFICE / STORAGE", "doors": ["kitchen"]}, 
		{"id": "delivery", "label": "DELIVERY RACK", "doors": ["kitchen"]}, 
	], 
	"apartment": [
		{"id": "lobby", "label": "MERCY COURT LOBBY", "doors": ["security", "stairs", "street"]}, 
		{"id": "security", "label": "LOCKED SECURITY OFFICE", "doors": ["lobby"]}, 
		{"id": "stairs", "label": "MERCY COURT ELEVATOR LOBBY", "doors": ["lobby"]}, 
		{"id": "floor_1", "label": "MERCY COURT - FLOOR 1", "doors": ["stairs", "unit"]}, 
		{"id": "unit", "label": "YOUR MERCY COURT APARTMENT", "doors": ["floor_1"]}, 
		{"id": "floor_2", "label": "MERCY COURT - FLOOR 2", "doors": ["stairs"]}, 
		{"id": "floor_3", "label": "MERCY COURT - FLOOR 3", "doors": ["stairs"]}, 
		{"id": "floor_4", "label": "MERCY COURT - FLOOR 4", "doors": ["stairs"]}, 
		{"id": "floor_5", "label": "MERCY COURT - FLOOR 5", "doors": ["stairs"]}, 
		{"id": "floor_6", "label": "MERCY COURT - FLOOR 6", "doors": ["stairs"]}, 
		{"id": "roof", "label": "MERCY COURT ROOF", "doors": ["stairs", "rooftop"]}, 
	], 
	"social": [
		{"id": "lobby", "label": "HUMAN OBSTACLES LOBBY", "doors": ["forms", "casework", "records", "street"]}, 
		{"id": "forms", "label": "FORMS HALL", "doors": ["lobby"]}, 
		{"id": "casework", "label": "CASEWORK FLOOR", "doors": ["lobby"]}, 
		{"id": "records", "label": "RESTRICTED RECORDS", "doors": ["lobby"]}, 
	], 
	"bank": [
		{"id": "lobby", "label": "FIRST BLOCK BANK LOBBY", "doors": ["street"], "door_positions": {"street": 930.0}}, 


	], 
	"hospital": [
		{"id": "intake", "label": "HOSPITAL INTAKE", "doors": ["ward", "pharmacy", "street"]}, 
		{"id": "ward", "label": "TREATMENT WARD", "doors": ["intake"]}, 
		{"id": "pharmacy", "label": "DISCHARGE PHARMACY", "doors": ["intake"]}, 
	], 
	"jail": [
		{"id": "booking", "label": "JAIL BOOKING", "doors": ["tier", "street"]}, 
		{"id": "tier", "label": "HOUSING TIER", "doors": ["booking", "labor", "education", "infirmary", "recovery"]}, 
		{"id": "west_tier", "label": "WEST TIER WALK", "doors": []}, 
		{"id": "labor", "label": "LABOR DETAIL", "doors": ["tier"]}, 
		{"id": "education", "label": "JAIL EDUCATION", "doors": ["tier"]}, 
		{"id": "infirmary", "label": "TIER INFIRMARY", "doors": ["tier"]}, 
		{"id": "recovery", "label": "RECOVERY GROUP", "doors": ["tier"]}, 
	], 
	"precinct": [
		{"id": "lobby", "label": "PRECINCT LOBBY", "doors": ["booking", "evidence", "holding", "street"]}, 
		{"id": "booking", "label": "BOOKING DESK", "doors": ["lobby"]}, 
		{"id": "evidence", "label": "EVIDENCE INTAKE", "doors": ["lobby"]}, 
		{"id": "holding", "label": "HOLDING CELL INTAKE", "doors": ["lobby"]}, 
	], 
	"barber": [{"id": "floor", "label": "BARBER FLOOR", "doors": ["supply", "street"]}, {"id": "supply", "label": "BARBER SUPPLY ROOM", "doors": ["floor", "rear"]}], 
	"laundromat": [{"id": "floor", "label": "LAUNDROMAT FLOOR", "doors": ["office", "utility", "street"]}, {"id": "office", "label": "LAUNDROMAT OFFICE", "doors": ["floor"]}, {"id": "utility", "label": "BOILER / SERVICE ROOM", "doors": ["floor", "rear"]}], 
	"pawn": [{"id": "sales", "label": "PAWN SALES FLOOR", "doors": ["records", "backroom", "street"]}, {"id": "records", "label": "OWNERSHIP RECORDS", "doors": ["sales"]}, {"id": "backroom", "label": "PAWN BACKROOM", "doors": ["sales", "rear"]}], 
	"pillmill": [{"id": "waiting", "label": "DOCTOR'S WAITING ROOM", "doors": ["exam", "street"]}, {"id": "exam", "label": "EXAM ROOM", "doors": ["waiting"]}], 
	"clinic": [{"id": "waiting", "label": "CLINIC WAITING ROOM", "doors": ["intake", "meeting", "street"]}, {"id": "intake", "label": "INTAKE OFFICE", "doors": ["waiting"]}, {"id": "meeting", "label": "RECOVERY MEETING ROOM", "doors": ["waiting"]}], 
	"debugshop": [{"id": "shop", "label": "DEBUG ITEM SHOP", "doors": ["street"]}], 
}

const DEFAULT_ROOM: = {"tutorial": "guidance", "school": "hall_a", "home": "lobby", "store": "sales", "backroom": "stockroom", "bank": "lobby", "hospital": "intake", "jail": "booking", "apartment": "lobby", "social": "lobby", "restaurant": "dining", "barber": "floor", "laundromat": "floor", "pawn": "sales", "precinct": "lobby", "pillmill": "waiting", "clinic": "waiting", "debugshop": "shop"}

const BUILDING_STORIES: = {
	"home": 3, "tutorial": 3, "school": 3, "apartment": 6, "social": 4, "store": 2, 
	"restaurant": 2, "bank": 4, "hospital": 5, "barber": 2, "laundromat": 2, 
	"pawn": 3, "precinct": 4, "pillmill": 3, "clinic": 3, "debugshop": 1, 
}

const PARKOUR_ROUTES: = [


	{"id": "school_fence", "parkour_object_id": "school_fence", "area": "street", "name": "SCHOOL SERVICE FENCE", "center": 2700.0, "target_area": "rear", "target": Vector2(2700, 235), "stamina": 18.0, "agility": 1, "risk": 0.05, "kind": "fence"}, 
	{"id": "store_fence", "parkour_object_id": "store_fence", "area": "street", "name": "STORE DELIVERY FENCE", "center": 5440.0, "target_area": "rear", "target": Vector2(5440, 240), "stamina": 20.0, "agility": 2, "risk": 0.08, "kind": "fence"}, 

	{"id": "school_fence_return", "parkour_object_id": "school_fence", "area": "rear", "name": "SCHOOL SERVICE FENCE", "center": 2700.0, "target_area": "street", "target": Vector2(2700, 235), "stamina": 13.0, "agility": 1, "risk": 0.04, "kind": "fence"}, 
	{"id": "store_fence_return", "parkour_object_id": "store_fence", "area": "rear", "name": "STORE DELIVERY FENCE", "center": 5440.0, "target_area": "street", "target": Vector2(5440, 240), "stamina": 14.0, "agility": 1, "risk": 0.05, "kind": "fence"}, 
	{"id": "rear_fire_escape", "parkour_object_id": "mercy_fire_escape", "area": "rear", "name": "MERCY FIRE ESCAPE", "center": 980.0, "target_area": "rooftop", "target": Vector2(980, 235), "stamina": 38.0, "agility": 3, "risk": 0.16, "kind": "fire_escape"}, 
	{"id": "rear_ladder", "parkour_object_id": "store_ladder", "area": "rear", "name": "STORE SERVICE LADDER", "center": 5260.0, "target_area": "rooftop", "target": Vector2(5260, 240), "stamina": 30.0, "agility": 2, "risk": 0.1, "kind": "ladder"}, 
	{"id": "mercy_fire_escape_down", "parkour_object_id": "mercy_fire_escape", "area": "rooftop", "name": "MERCY FIRE ESCAPE DESCENT", "center": 980.0, "target_area": "rear", "target": Vector2(980, 235), "stamina": 20.0, "agility": 2, "risk": 0.08, "kind": "fire_escape"}, 
	{"id": "store_ladder_down", "parkour_object_id": "store_ladder", "area": "rooftop", "name": "STORE SERVICE LADDER DESCENT", "center": 5260.0, "target_area": "rear", "target": Vector2(5260, 240), "stamina": 16.0, "agility": 1, "risk": 0.04, "kind": "ladder"}, 
	{"id": "roof_gap", "parkour_object_id": "mercy_roof_gap", "area": "rooftop", "name": "MERCY ROOF GAP", "center": 1680.0, "target_area": "rooftop", "target": Vector2(1950, 235), "stamina": 42.0, "agility": 5, "risk": 0.23, "kind": "gap"}, 
	{"id": "roof_gap_return", "parkour_object_id": "mercy_roof_gap", "area": "rooftop", "name": "MERCY ROOF GAP RETURN", "center": 1950.0, "target_area": "rooftop", "target": Vector2(1680, 235), "stamina": 42.0, "agility": 5, "risk": 0.23, "kind": "gap"}, 
]

const JOURNAL: = [
	{"title": "BED 6B", "objective": "Reach your private room and sleep.", "benefit": "Recover 1 health each second and access local storage.", "risk": "Sleeping makes you stationary and publicly predictable in shared housing."}, 
	{"title": "SECONDARY EDUCATION", "objective": "Earn a GED or equivalent diploma through the same secondary credential route.", "benefit": "Questions train Intelligence and award scholarship credits.", "risk": "Wrong answers spend filing credits; random guessing is not profitable."}, 
	{"title": "CASHIER SHIFT", "objective": "Complete Boss's currently posted exclusive task before another employee.", "benefit": "Pay and work experience grow with reliable attendance.", "risk": "The safe envelope must reach the bank sealed and on time."}, 
	{"title": "PARKOUR", "objective": "Use fences, ladders, ledges, and fire escapes to reach rear and roof routes.", "benefit": "Avoid busy sightlines and unlock high-value routes.", "risk": "Stamina and Agility govern falls; broken routes never become guaranteed."}, 
	{"title": "EVIDENCE", "objective": "Control cameras, witnesses, physical traces, and chain of custody.", "benefit": "Preparation can keep Heat from forming when nobody observes a crime.", "risk": "Deleting footage leaves a deletion trace; blood and bags can remain evidence."}, 
]

static func room_ids(area_name: String) -> Array[String]:
	var result: Array[String] = []
	for room in ROOM_LAYOUTS.get(area_name, []):
		result.append(String(room["id"]))
	return result

static func room_label(area_name: String, room_id: String) -> String:
	for room in ROOM_LAYOUTS.get(area_name, []):
		if String(room["id"]) == room_id: return String(room["label"])
	return area_name.to_upper()

static func equipment_slot(item_name: String) -> String:
	return String(EQUIPMENT_CATALOG.get(item_name, {}).get("slot", ""))

static func backpack_capacity(item_name: String) -> int:
	return int(EQUIPMENT_CATALOG.get(item_name, {}).get("capacity", 0))

static func display_inventory(items: Array[String]) -> Array[String]:
	var counts: = {}
	var order: Array[String] = []
	for item in items:
		if item not in counts:
			counts[item] = 0
			order.append(item)
		counts[item] = int(counts[item]) + 1
	var result: Array[String] = []
	for item in order:
		var count: = int(counts[item])
		result.append(item if count == 1 else "%s x%d" % [item, count])
	return result

static func route_for(area_name: String, position_x: float, radius: float = 110.0) -> Dictionary:
	for route in PARKOUR_ROUTES:
		if String(route["area"]) == area_name and absf(float(route["center"]) - position_x) <= radius: return route
	return {}
