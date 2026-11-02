class_name AddictionSystem
extends RefCounted

# Addiction accumulation and autonomous consumption system
# Based on substance severity and usage patterns

# Addiction levels
const ADDICTION_LEVELS: = {
	0: {"label": "None", "description": "No dependency", "autonomous_check_interval_seconds": 0.0},
	1: {"label": "Mild", "description": "Occasional cravings", "autonomous_check_interval_seconds": 1800.0, "check_fail_chance": 0.05},  # 30 min, 5%
	2: {"label": "Moderate", "description": "Point of no return - permanent baseline Level 1", "autonomous_check_interval_seconds": 900.0, "check_fail_chance": 0.15},  # 15 min, 15%
	3: {"label": "Severe", "description": "Frequent autonomous consumption", "autonomous_check_interval_seconds": 600.0, "check_fail_chance": 0.30},  # 10 min, 30%
	4: {"label": "Critical", "description": "Constant craving interference", "autonomous_check_interval_seconds": 300.0, "check_fail_chance": 0.50},  # 5 min, 50%
}

# Addiction points per substance severity
const ADDICTION_POINTS_PER_USE: = {
	"Extreme": 25,    # China, Tar
	"Very High": 20,  # Crystal, Dust, Rock
	"High": 15,       # Blackout™, A2
	"Moderate": 10,   # Jet, Powder, NeverDone™, Subscriptxone™, Addictrall XR™, Vassalium™, Serenex™, Syrup
	"Low": 5,         # Rebillin™, Paper, Caps, Dissociaderm™
	"Minimal": 2,     # Herb
	"None": 0,        # Revivar
}

# Points required to reach each addiction level
const ADDICTION_LEVEL_THRESHOLDS: = [0, 100, 300, 600, 1000]  # Level 0-4

# The Level 2 Permanent Lock
# Once a character reaches Level 2, their baseline locks at Level 1 forever
# They can never return to Level 0 (no dependency)

static func calculate_addiction_level(addiction_points: int, has_reached_level_2: bool) -> int:
	var level: = 0

	for threshold_level in range(ADDICTION_LEVEL_THRESHOLDS.size() - 1, -1, -1):
		if addiction_points >= ADDICTION_LEVEL_THRESHOLDS[threshold_level]:
			level = threshold_level
			break

	# Permanent Level 1 minimum if ever reached Level 2
	if has_reached_level_2 and level < 1:
		level = 1

	return level

static func addiction_level_data(level: int) -> Dictionary:
	return ADDICTION_LEVELS.get(level, ADDICTION_LEVELS[0]).duplicate(true)

# Autonomous consumption check (RNG tick)
# Returns true if the character loses agency and must consume
static func autonomous_consumption_check(addiction_level: int) -> bool:
	if addiction_level <= 0:
		return false

	var level_data: = addiction_level_data(addiction_level)
	var fail_chance: = float(level_data.get("check_fail_chance", 0.0))

	if fail_chance <= 0.0:
		return false

	var roll: = randf()
	return roll < fail_chance

# Autonomous consumption sequence
# 1. Stash Run - path to bank or withdraw from stash
# 2. Breakdown - packs/baggies to generate loose doses
# 3. Consumption - use 1 loose dose if available

const AUTONOMOUS_SEQUENCE_STEPS: = ["stash_run", "breakdown", "consumption"]

static func get_preferred_substance_for_craving(consumption_history: Array) -> String:
	# Determine which substance the character craves most
	# Based on recent usage patterns (last 10 uses)

	var substance_counts: = {}
	var recent_history: = consumption_history.slice(-10) if consumption_history.size() > 10 else consumption_history

	for entry in recent_history:
		var substance: = String(entry.get("substance_id", ""))
		if substance.is_empty():
			continue

		substance_counts[substance] = substance_counts.get(substance, 0) + 1

	# Find most used substance
	var max_count: = 0
	var preferred: = ""

	for substance in substance_counts.keys():
		if substance_counts[substance] > max_count:
			max_count = substance_counts[substance]
			preferred = substance

	return preferred

# Withdrawal effects (when addiction level drops or substance unavailable)
const WITHDRAWAL_EFFECTS: = {
	"Extreme": {
		"vitality_drain_per_minute": 0.10,
		"composure_drain_per_minute": 0.25,
		"movement_speed_penalty": -0.40,
		"hands_penalty": -0.30,
		"muscle_penalty": -0.30,
		"cannot_sleep": true,
	},
	"Very High": {
		"vitality_drain_per_minute": 0.05,
		"composure_drain_per_minute": 0.15,
		"movement_speed_penalty": -0.25,
		"hands_penalty": -0.20,
	},
	"High": {
		"composure_drain_per_minute": 0.10,
		"movement_speed_penalty": -0.15,
		"hands_penalty": -0.10,
	},
	"Moderate": {
		"composure_drain_per_minute": 0.05,
		"hands_penalty": -0.05,
	}
}

static func calculate_withdrawal_severity(addiction_level: int, hours_since_last_use: float) -> String:
	if addiction_level <= 1:
		return "None"

	# Withdrawal kicks in after certain hours without use
	var withdrawal_threshold_hours: = {
		2: 6.0,   # Moderate addiction - withdrawal after 6 hours
		3: 4.0,   # Severe - after 4 hours
		4: 2.0,   # Critical - after 2 hours
	}

	var threshold: = withdrawal_threshold_hours.get(addiction_level, 999.0)

	if hours_since_last_use < threshold:
		return "None"

	# Map addiction level to withdrawal severity
	match addiction_level:
		2: return "Moderate"
		3: return "High"
		4: return "Extreme"
		_: return "None"

static func get_withdrawal_effects(severity: String) -> Dictionary:
	return WITHDRAWAL_EFFECTS.get(severity, {}).duplicate(true)

# Track substance combinations for dangerous synergies
static func track_active_buffs(active_buffs: Array) -> Array:
	var active_substance_ids: Array = []

	for buff in active_buffs:
		var substance_id: = String(buff.get("substance", ""))
		if not substance_id.is_empty() and substance_id not in active_substance_ids:
			active_substance_ids.append(substance_id)

	return active_substance_ids

# Check for precipitated withdrawal
# Occurs when Subscriptxone™/Revivar used while Tar/China active
static func check_precipitated_withdrawal(new_substance_id: String, active_substances: Array) -> bool:
	var blockers: = ["subscriptxone", "revivar"]
	var opioids: = ["tar", "china"]

	if new_substance_id not in blockers:
		return false

	for substance in active_substances:
		if substance in opioids:
			return true

	return false

# Check for receptor blockade
# Active NeverDone™/Subscriptxone™ blocks Tar/China effectiveness
static func check_receptor_blockade(new_substance_id: String, active_substances: Array) -> bool:
	var maintenance: = ["neverdone", "subscriptxone"]
	var opioids: = ["tar", "china"]

	if new_substance_id not in opioids:
		return false

	for substance in active_substances:
		if substance in maintenance:
			return true

	return false

static func get_addiction_level(points: int) -> int:
	for threshold_level in range(ADDICTION_LEVEL_THRESHOLDS.size() - 1, -1, -1):
		if points >= ADDICTION_LEVEL_THRESHOLDS[threshold_level]:
			return threshold_level
	return 0

static func check_autonomous_consumption(addiction_level: int, delta: float, rng: RandomNumberGenerator) -> bool:
	if addiction_level < 2:
		return false

	var level_data: Dictionary = ADDICTION_LEVELS.get(addiction_level, {})
	var interval: = float(level_data.get("autonomous_check_interval_seconds", 999999.0))
	var fail_chance: = float(level_data.get("check_fail_chance", 0.0))

	# Simple probabilistic check each frame
	var check_chance_per_second: = fail_chance / interval
	var frame_chance: = check_chance_per_second * delta

	return rng.randf() < frame_chance

static func calculate_withdrawal(substance_id: String, addiction_level: int, time_since_use: float) -> Dictionary:
	if addiction_level < 2:
		return {}

	var hours_since: = time_since_use / 3600.0
	var severity: = calculate_withdrawal_severity(addiction_level, hours_since)

	if severity.is_empty():
		return {}

	var effects: Array[String] = []

	match severity:
		"Extreme":
			effects = ["health_drain", "stamina_drain", "movement_penalty", "attack_penalty"]
		"Very High":
			effects = ["health_drain", "stamina_drain", "movement_penalty"]
		"High":
			effects = ["stamina_drain", "movement_penalty"]
		"Moderate":
			effects = ["stamina_drain"]

	return {
		"severity": severity,
		"effects": effects,
		"hours_since_use": hours_since
	}

