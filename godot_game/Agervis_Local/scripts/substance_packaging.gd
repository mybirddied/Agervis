class_name SubstancePackaging
extends RefCounted

# Handles breaking down packages into individual doses
# and pressing pills for quality verification

# Pill pressing - verifies pharmaceutical authenticity
# Requires Chemistry skill (like powder purity analysis)
const PILL_PRESS_CHEMISTRY_LEVEL: = 3  # Same as powder analysis

# Pill authenticity tiers (similar to powder purity)
const PILL_AUTHENTICITY_LEVELS: = [
	{"tier": 1, "label": "Pressed Counterfeit", "effectiveness": 0.20, "risk_multiplier": 3.0},
	{"tier": 2, "label": "Diluted Generic", "effectiveness": 0.50, "risk_multiplier": 2.0},
	{"tier": 3, "label": "Standard Generic", "effectiveness": 0.85, "risk_multiplier": 1.2},
	{"tier": 4, "label": "Legitimate Brand", "effectiveness": 1.0, "risk_multiplier": 1.0},
	{"tier": 5, "label": "Verified Pharmaceutical", "effectiveness": 1.0, "risk_multiplier": 0.8},
]

# Determines pill authenticity based on source
static func pill_authenticity_for_prescription(account_id: String, prescription_sequence: int, substance_brand: String, source: String) -> int:
	# Clinic prescriptions are always legitimate (tier 4-5)
	if source == "clinic":
		var roll: = int(hash("%s:%d:%s:clinic" % [account_id, prescription_sequence, substance_brand])) & 2147483647
		return 4 + (roll % 2)  # Either tier 4 or 5

	# Pill mill has variable quality (tier 1-4, weighted toward lower)
	if source == "pillmill":
		var roll: = int(hash("%s:%d:%s:pillmill" % [account_id, prescription_sequence, substance_brand])) & 2147483647
		var weighted: = roll % 100

		if weighted < 30:  # 30% chance tier 1
			return 1
		elif weighted < 55:  # 25% chance tier 2
			return 2
		elif weighted < 80:  # 25% chance tier 3
			return 3
		else:  # 20% chance tier 4
			return 4

	# Street/unknown source (tier 1-3, heavily weighted toward counterfeit)
	var roll: = int(hash("%s:%d:%s:street" % [account_id, prescription_sequence, substance_brand])) & 2147483647
	var weighted: = roll % 100

	if weighted < 60:  # 60% chance tier 1
		return 1
	elif weighted < 85:  # 25% chance tier 2
		return 2
	else:  # 15% chance tier 3
		return 3

static func pill_authenticity_data(tier: int) -> Dictionary:
	var index: = clampi(tier, 1, PILL_AUTHENTICITY_LEVELS.size()) - 1
	return Dictionary(PILL_AUTHENTICITY_LEVELS[index]).duplicate(true)

# Break down pharmaceutical pack into individual pills
static func break_pharma_pack(pack_item_id: String, pack_size: int) -> Array:
	var doses: Array = []

	# Extract brand from pack item ID
	# Format: "Addictrall XR™ (30-pack)" -> "Addictrall XR™"
	var brand: = pack_item_id.replace(" (%d-pack)" % pack_size, "")

	for i in range(pack_size):
		doses.append({
			"item_id": PharmaceuticalContent.dose_item_id(brand),
			"brand": brand,
			"form": "blister_single",
		})

	return doses

# Break down street substance package into loose doses
static func break_street_package(package_item_id: String, weight_grams: float, substance_id: String) -> Array:
	var substance: = StreetSubstances.substance_data(substance_id)
	if substance.is_empty():
		return []

	var doses_per_gram: = int(substance.get("doses_per_gram", 10))
	var total_doses: = int(weight_grams * doses_per_gram)
	var doses: Array = []

	for i in range(total_doses):
		doses.append({
			"item_id": StreetSubstances.dose_item_id(substance_id),
			"substance_id": substance_id,
			"dose_weight": substance.get("dose_weight", 0.1),
		})

	return doses

# Break down syrup pint into oz bottles
static func break_syrup_pint() -> Array:
	var bottles: Array = []

	for i in range(16):  # 16 oz per pint
		bottles.append({
			"item_id": PharmaceuticalContent.syrup_oz_item_id(),
			"substance_id": "syrup",
			"volume_oz": 1,
		})

	return bottles

# Packaging rules for distribution
static func can_repackage_to_blister(dose_count: int) -> bool:
	# Individual pills must stay in blister form (can't go back to bottle)
	return false

static func exceeds_takehome_limit(dose_count: int) -> bool:
	return dose_count > PharmaceuticalContent.TAKEHOME_MAX_STACK

# NC possession limits (simplified - actual law is complex)
const NC_POSSESSION_LIMITS: = {
	"schedule_ii": {
		"personal_use_doses": 30,  # 30-day supply for personal use
		"intent_to_distribute_threshold": 100,  # 100+ doses = felony intent
	},
	"schedule_iii_iv": {
		"personal_use_doses": 90,
		"intent_to_distribute_threshold": 300,
	},
	"herb_bulk": {
		"personal_use_grams": 28.0,  # ~1 oz
		"intent_to_distribute_grams": 1500.0,  # ~3.3 lbs
	}
}

static func get_possession_schedule(substance_id: String) -> String:
	match substance_id:
		"china", "tar", "crystal", "powder", "addictrall":
			return "schedule_ii"
		"blackout", "vassalium", "subscriptxone", "neverdone":
			return "schedule_iii_iv"
		"herb":
			return "herb_bulk"
		_:
			return "unscheduled"

static func check_intent_to_distribute(substance_id: String, quantity: float, is_weight: bool) -> bool:
	var schedule: = get_possession_schedule(substance_id)

	if schedule == "herb_bulk" and is_weight:
		return quantity >= NC_POSSESSION_LIMITS["herb_bulk"]["intent_to_distribute_grams"]
	elif schedule == "schedule_ii" and not is_weight:
		return quantity >= NC_POSSESSION_LIMITS["schedule_ii"]["intent_to_distribute_threshold"]
	elif schedule == "schedule_iii_iv" and not is_weight:
		return quantity >= NC_POSSESSION_LIMITS["schedule_iii_iv"]["intent_to_distribute_threshold"]

	return false

# Tolerance mechanics (diminishing returns)
static func calculate_tolerance_effects(base_buff: Dictionary, is_redose_while_active: bool) -> Dictionary:
	if not is_redose_while_active:
		return base_buff.duplicate(true)

	# Redosing while active = 50% buff effectiveness, 150% debuff, 2x addiction
	var tolerant_buff: = base_buff.duplicate(true)

	if tolerant_buff.has("effects"):
		var effects: Dictionary = tolerant_buff["effects"]
		for key in effects.keys():
			effects[key] = effects[key] * 0.5  # 50% effectiveness

	tolerant_buff["tolerance_active"] = true
	tolerant_buff["debuff_multiplier"] = 1.5
	tolerant_buff["addiction_multiplier"] = 2.0

	return tolerant_buff

# Screenshot editing detection (visual metadata tracking)
# Pills/powder can be photographed, but screenshots can be edited
# This creates trust-based economy where quality verification matters
static func generate_visual_fingerprint(item_metadata: Dictionary) -> String:
	# Generate unique visual hash based on item properties
	# Used to detect if screenshot was edited
	var fingerprint_data: = "%s:%s:%s" % [
		item_metadata.get("item_id", ""),
		item_metadata.get("purity_tier", 0),
		item_metadata.get("authenticity_tier", 0),
	]
	return str(hash(fingerprint_data))

static func verify_screenshot_authenticity(claimed_metadata: Dictionary, actual_metadata: Dictionary) -> bool:
	var claimed_fingerprint: = generate_visual_fingerprint(claimed_metadata)
	var actual_fingerprint: = generate_visual_fingerprint(actual_metadata)
	return claimed_fingerprint == actual_fingerprint
