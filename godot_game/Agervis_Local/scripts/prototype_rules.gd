class_name PrototypeRules
extends RefCounted

const SKILLS: = [
	"Intelligence",
	"Endurance",
	"Agility",
	"Fighting",
	"Firearms",
	"Stealth",
	"Awareness",
	"Safety",
	"Medicine",
	"Chemistry",
	"Cooking",
	"Greenthumb",
	"Vehicle",
	"Influence",
	"Enterprise",
	"Civics",
]

const HEAT_MIN: = 0
const HEAT_MAX: = 140
const CASE_LEAD_MIN_HEAT: = 25
const LEO_DETENTION_MIN_HEAT: = 50
const CASE_PROBABLE_CAUSE_MIN_HEAT: = 55
const CASE_PROOF_MIN_HEAT: = 90
const LEO_ARREST_MIN_HEAT: = 100
const PIKE_CHASE_RADIUS: = 1200.0
const MOTH_CHASE_RADIUS: = PIKE_CHASE_RADIUS * 0.8

static func normalized_heat(heat: int) -> int:
	return clampi(heat, HEAT_MIN, HEAT_MAX)

static func arrest_is_eligible(heat: int, warrant: bool) -> bool:
	return normalized_heat(heat) >= LEO_ARREST_MIN_HEAT or warrant

static func xp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	var total: = 0
	for current_level in range(1, mini(level, 99)):
		total += xp_to_advance(current_level)
	return total

static func xp_to_advance(current_level: int) -> int:




	var rank: = clampi(current_level, 1, 98)
	var cost: = 70 + rank * 18 + rank * rank * 2
	if rank >= 21:
		var professional_pressure: = rank - 20
		cost += professional_pressure * professional_pressure * 6
	if rank >= 61:
		var elite_pressure: = rank - 60
		cost += elite_pressure * elite_pressure * elite_pressure * 5
	if rank >= 91:
		var prestige_pressure: = rank - 90
		cost += prestige_pressure * prestige_pressure * prestige_pressure * prestige_pressure * 90
	return cost

static func level_from_xp(xp: int) -> int:
	var level: = 1
	while level < 99 and xp >= xp_for_level(level + 1):
		level += 1
	return level

static func fatality_faces(mark_active: bool) -> int:

	return 4 if mark_active else 2

static func fatality_succeeds(roll: int, mark_active: bool) -> bool:
	var faces: = fatality_faces(mark_active)
	return roll > 16 - faces

static func case_level(strength: int) -> String:
	if strength >= CASE_PROOF_MIN_HEAT:
		return "PROOF"
	if strength >= CASE_PROBABLE_CAUSE_MIN_HEAT:
		return "PROBABLE CAUSE"
	if strength >= CASE_LEAD_MIN_HEAT:
		return "LEAD"
	return "RUMOR"

static func sentence_credits(crimes: Array[String]) -> int:
	var credits: = 0
	for crime in crimes:
		match crime:
			"SHOPLIFTING": credits += 1
			"ASSAULT": credits += 2
			"ROBBERY": credits += 2
			"OBSTRUCTION": credits += 1
			"ILLEGAL SEARCH": credits += 1
			"ATTEMPTED MAIMING": credits += 3
			"ATTEMPTED MURDER": credits += 4
			_: credits += 1
	return maxi(1, credits)
