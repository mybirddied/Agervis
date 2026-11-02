class_name StreetSubstances
extends RefCounted

# Street substances sold by weight (gram-based packaging)
# Each 1g breaks down into 10x 0.1g loose doses

# KEYS ARE DISPLAY NAMES ("China"). Use them for UI text only.
# LOGIC USES row["substance_id"] (lowercase, "china"). Never compare or store the key.
# See SUBSTANCE_ID_RULES.md.
const STREET_SUBSTANCES: = {
	"China": {
		"substance_id": "china",
		"street_names": ["china"],
		"unit_weight": 1.0,  # grams
		"doses_per_gram": 10,  # 10x 0.1g doses
		"dose_weight": 0.1,
		"packaging": "vial",
		"addiction_level": "Extreme",
		"buff": {
			"name": "Triage Heal",
			"instant": true,
			"effects": {
				"vitality_restore": 0.75,
				"hands_boost": 0.30,
				"muscle_boost": 0.30,
			},
			"duration_seconds": 15.0,
		},
		"debuff": {
			"name": "Lethal Depression",
			"duration_seconds": 15.0,
			"overdose_timer": 15.0,
			"effects": {
				"guard_penalty": -0.50,
			},
			"lethal": true,  # -100% Max Vitality if no reversal
		},
		"overdose": {
			"name": "Respiratory Failure",
			"trigger": "no_revivar_before_timer",
			"instant_death": true,
		}
	},
	"Tar": {
		"substance_id": "tar",
		"street_names": ["tar", "black"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "foil bind",
		"addiction_level": "Extreme",
		"buff": {
			"name": "The Nod",
			"instant": true,
			"effects": {
				"vitality_restore": 0.35,
				"guard_mitigation_kinetic": 0.20,
			}
		},
		"debuff": {
			"name": "Lethargy",
			"duration_seconds": 30.0,
			"effects": {
				"run_energy_regen": -0.50,
				"attack_speed": -0.30,
			}
		},
		"overdose": {
			"name": "The Deep Nod",
			"trigger": "second_dose_before_expiry",
			"effects": "Hard stun 12s. -10% Max Vitality asphyxiation damage every 2s."
		}
	},
	"Crystal": {
		"substance_id": "crystal",
		"street_names": ["ice", "glass", "shards"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "baggie",
		"addiction_level": "Very High",
		"buff": {
			"name": "Tweaking",
			"duration_seconds": 180.0,
			"effects": {
				"muscle_boost": 0.25,
				"attack_speed": 0.25,
			}
		},
		"debuff": {
			"name": "Body Degradation",
			"duration_seconds": 180.0,
			"effects": {
				"guard_penalty": -0.40,
				"toxic_recoil": 0.15,  # -15% Max Vitality over 3m
			}
		},
		"overdose": {
			"name": "Overamped",
			"trigger": "second_dose_before_expiry",
			"effects": "Model jitters. Movement randomized 15s. -50% Max Vitality."
		}
	},
	"Rock": {
		"substance_id": "rock",
		"street_names": ["hard", "rock"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "vial",
		"addiction_level": "Very High",
		"buff": {
			"name": "Bell-Ringer",
			"duration_seconds": 15.0,
			"effects": {
				"hands_accuracy": 1.20,
				"movement_speed": 1.20,
			}
		},
		"debuff": {
			"name": "The Crash",
			"trigger": "upon_expiration",
			"effects": {
				"composure_drain": 0.80,
				"hands_accuracy": -0.50,
				"movement_speed": -0.30,
			}
		},
		"overdose": {
			"name": "Seizure",
			"trigger": "second_dose_before_expiry",
			"effects": "Hard stun 8s. Strips weapons/shields to inventory."
		}
	},
	"Jet": {
		"substance_id": "jet",
		"street_names": ["jet", "k-nom", "drift"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "baggie",
		"addiction_level": "Moderate",
		"buff": {
			"name": "K-Hole",
			"duration_seconds": 30.0,
			"effects": {
				"damage_reflection": 0.50,
			}
		},
		"debuff": {
			"name": "Sensory Disconnect",
			"duration_seconds": 4.0,
			"effects": {
				"movement_speed": -1.0,  # rooted
				"hands_penalty": -0.80,
				"muscle_penalty": -0.80,
			}
		},
		"overdose": {
			"name": "Complete Anesthesia",
			"trigger": "second_dose_before_expiry",
			"effects": "Screen black 10s. Audio muffled. Cannot move/eat/attack."
		}
	},
	"Dust": {
		"substance_id": "dust",
		"street_names": ["dust"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "baggie",
		"addiction_level": "Very High",
		"buff": {
			"name": "Juggernaut",
			"duration_seconds": 180.0,
			"effects": {
				"cc_reduction": 0.80,
				"muscle_boost": 0.35,
			}
		},
		"debuff": {
			"name": "Tissue Damage",
			"trigger": "upon_expiration",
			"effects": {
				"healing_items_disabled": true,
				"unblockable_recoil": 0.30,  # -30% Max Vitality
			}
		},
		"overdose": {
			"name": "Delirium",
			"trigger": "second_dose_before_expiry",
			"effects": "Spawns fake hostile entities. Inverts movement controls. Forces auto-retaliate on nearest entity (friend or foe) for 30s."
		}
	},
	"Caps": {
		"substance_id": "caps",
		"street_names": ["shrooms", "caps", "mushrooms"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "baggie",
		"addiction_level": "Low",
		"buff": {
			"name": "Ego Death",
			"duration_seconds": 45.0,
			"effects": {
				"npc_aggro_radius": -0.80,  # mobs ignore player
			}
		},
		"debuff": {
			"name": "Disorientation",
			"duration_seconds": 45.0,
			"effects": {
				"attack_speed": -0.20,
				"minimap_disabled": true,
			}
		},
		"overdose": {
			"name": "Ego Dissolution",
			"trigger": "second_dose_before_expiry",
			"effects": "Cannot discern friend/foe. Minimap disabled. Cannot initiate combat 30s."
		}
	},
	"Herb": {
		"substance_id": "herb",
		"street_names": ["herb", "green"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "baggie",
		"addiction_level": "Minimal",
		"buff": {
			"name": "Munchies",
			"duration_seconds": 300.0,
			"effects": {
				"food_heal_multiplier": 0.35,  # food heals 35% more
			}
		},
		"debuff": {
			"name": "Couch-lock",
			"duration_seconds": 300.0,
			"effects": {
				"movement_speed": -0.15,
				"crit_chance": -0.05,
			}
		},
		"overdose": {
			"name": "Greened Out",
			"trigger": "second_dose_before_expiry",
			"effects": "-100% Run Energy. Forces sit/stun 8s."
		}
	},
	"Powder": {
		"substance_id": "powder",
		"street_names": ["coke", "powder", "white"],
		"unit_weight": 1.0,
		"doses_per_gram": 10,
		"dose_weight": 0.1,
		"packaging": "baggie",
		"addiction_level": "Moderate",
		"purity_variable": true,  # Uses existing powder purity system
		"buff": {
			"name": "Ego Inflation",
			"duration_seconds": 60.0,
			"effects": {
				"hands_accuracy": 0.20,
				"movement_speed": 0.20,
			}
		},
		"debuff": {
			"name": "Comedown",
			"trigger": "upon_expiration",
			"effects": {
				"composure_drain": 0.25,
			}
		},
		"overdose": {
			"name": "Cardiac Event",
			"trigger": "second_dose_before_expiry",
			"effects": "Cannot attack/special 12s. -40% Max Vitality."
		}
	},
}

# Dangerous combinations (synergies)
# CRITICAL: every "ingredients" entry must be a LOWERCASE internal substance_id ("tar", not "Tar").
# Display names here fail silently. check_dangerous_combination() does exact matching.
# See SUBSTANCE_ID_RULES.md and COMBO_SYSTEM_RULES.md.
const DANGEROUS_COMBINATIONS: = {
	"speedball": {
		"name": "Speedball",
		"ingredients": [["tar", "china"], ["crystal", "powder", "rock"]],
		"requires_both_categories": true,
		"buff": {
			"name": "Speedball Rush",
			"duration_seconds": 60.0,
			"effects": {
				"muscle_boost": 0.40,
				"hands_boost": 0.40,
				"negates_lethargy": true,
			}
		},
		"lethal_risk": {
			"name": "Cardiac Stress",
			"trigger": "upon_expiration",
			"effects": {
				"vitality_drain": 0.60,
				"run_energy_drain": 1.0,
			}
		},
		"addiction_multiplier": 3.0,
	},
	"cns_shutdown": {
		"name": "CNS Shutdown",
		"ingredients": [["china", "tar", "syrup", "neverdone"], ["blackout", "vassalium"]],
		"requires_both_categories": true,
		"description": "Opioids + CNS depressants increase overdose risk by 133-400%",
		"overdose_risk_multiplier": {
			"min": 2.33,  # 133% increase = 233% of baseline
			"max": 5.0,   # 400% increase = 500% of baseline
		},
		"buff": {
			"name": "CNS Depression",
			"duration_seconds": 180.0,
			"effects": {
				"guard_mitigation": 0.50,
				"panic_immunity": 1.0,
			}
		},
		"lethal_risk": {
			"name": "Respiratory Depression",
			"effects": {
				"movement_speed": -0.60,
				"attack_speed": -0.40,
				"vitality_drain_per_tick": 0.03,
			}
		},
		"addiction_multiplier": 2.5,
	},
	"psychosis": {
		"name": "Psychosis",
		"ingredients": [["dust", "jet", "paper"], ["crystal", "rock"]],
		"requires_both_categories": true,
		"buff": {
			"name": "Psychotic Break",
			"duration_seconds": 120.0,
			"effects": {
				"evasion": 0.50,
				"special_attack_regen": 0.50,
			}
		},
		"lethal_risk": {
			"name": "Sensory Overload",
			"effects": {
				"composure_drain": 1.0,  # instant -100%
				"forced_auto_retaliate": true,
				"target_selection_disabled": true,
			}
		},
		"addiction_multiplier": 2.0,
	},
}

# CRITICAL: takes an INTERNAL ID ("tar"), NOT a display name ("Tar").
# Passing "Tar" returns {} silently. Blackout/Vassalium etc. are NOT in this table; use PharmaceuticalContent.
static func substance_data(substance_id: String) -> Dictionary:
	for data in STREET_SUBSTANCES.values():
		if data.get("substance_id") == substance_id:
			return data.duplicate(true)
	return {}

static func substance_by_street_name(street_name: String) -> Dictionary:
	var search: = street_name.to_lower()
	for data in STREET_SUBSTANCES.values():
		var names: Array = data.get("street_names", [])
		for name in names:
			if String(name).to_lower() == search:
				return data.duplicate(true)
	return {}

# Generate item IDs for packaged substances
static func package_item_id(substance_id: String, weight_grams: float) -> String:
	var substance: = substance_data(substance_id)
	if substance.is_empty():
		return ""

	# Format weight nicely
	if weight_grams < 1.0:
		return "%s (%.1fg)" % [substance_id.capitalize(), weight_grams]
	else:
		return "%s (%.0fg)" % [substance_id.capitalize(), weight_grams]

# Generate item ID for loose dose
static func dose_item_id(substance_id: String) -> String:
	return "%s (0.1g dose)" % substance_id.capitalize()

# Check if combination is dangerous
# CRITICAL: active_substances must be INTERNAL IDs ("tar", "china"), lowercase.
# Returned dict includes "id" (the combo key, e.g. "speedball"). Use that id for lookups, never "name".
static func check_dangerous_combination(active_substances: Array) -> Dictionary:
	for combo_id in DANGEROUS_COMBINATIONS.keys():
		var combo: Dictionary = DANGEROUS_COMBINATIONS[combo_id]
		var ingredient_sets: Array = combo.get("ingredients", [])

		if combo.get("requires_both_categories", false):
			# Must have at least one from each category
			var has_category: = [false, false]
			for i in range(ingredient_sets.size()):
				var category: Array = ingredient_sets[i]
				for substance in active_substances:
					if substance in category:
						has_category[i] = true
						break

			if has_category[0] and has_category[1]:
				var result = combo.duplicate(true)
				result["id"] = combo_id
				return result

	return {}

static func get_combination_addiction_multiplier(combo_id: String) -> float:
	if combo_id.is_empty():
		return 1.0

	for id in DANGEROUS_COMBINATIONS.keys():
		var combo: Dictionary = DANGEROUS_COMBINATIONS[id]
		if id == combo_id:
			return float(combo.get("addiction_multiplier", 1.0))

	return 1.0

