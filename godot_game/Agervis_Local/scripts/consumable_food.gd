extends Node

# Consumable food and drink items with HoT/DoT mechanics
# Non-pharmaceutical alternatives to substance effects
# Lower power, no addiction, heal/damage over time instead of instant

const CONSUMABLE_ITEMS: = {
	"Calming Tea": {
		"item_id": "calming_tea",
		"category": "beverage",
		"stack_size": 10,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Centered",
			"total_duration": 120.0,
			"tick_interval": 10.0,
			"effects": {
				"cc_resistance": 0.15,
				"composure_regen": 0.08,
			}
		},
		"debuff": {
			"name": "Drowsiness",
			"trigger": "upon_expiration",
			"duration_seconds": 60.0,
			"effects": {
				"movement_speed": -0.10,
			}
		}
	},
	"Bone Broth": {
		"item_id": "bone_broth",
		"category": "food",
		"stack_size": 5,
		"hot_dot_type": "heal_over_time",
		"hot": {
			"name": "Nourished",
			"total_duration": 180.0,
			"tick_interval": 12.0,
			"vitality_per_tick": 0.05,
		},
		"debuff": {
			"name": "Full Stomach",
			"duration_seconds": 120.0,
			"effects": {
				"food_block": 1.0,
			}
		}
	},
	"Ginger Stew": {
		"item_id": "ginger_stew",
		"category": "food",
		"stack_size": 5,
		"hot_dot_type": "heal_over_time",
		"hot": {
			"name": "Warming",
			"total_duration": 150.0,
			"tick_interval": 10.0,
			"vitality_per_tick": 0.04,
		},
		"debuff": {
			"name": "Full Stomach",
			"duration_seconds": 100.0,
			"effects": {
				"food_block": 1.0,
			}
		}
	},
	"Energy Drink": {
		"item_id": "energy_drink",
		"category": "beverage",
		"stack_size": 10,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Wired",
			"total_duration": 240.0,
			"tick_interval": 10.0,
			"effects": {
				"hands_accuracy": 0.10,
				"attack_speed": 0.05,
			}
		},
		"debuff": {
			"name": "Jitters",
			"trigger": "upon_expiration",
			"duration_seconds": 90.0,
			"effects": {
				"guard_scaling": -0.15,
			}
		}
	},
	"Strong Coffee": {
		"item_id": "strong_coffee",
		"category": "beverage",
		"stack_size": 10,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Caffeinated",
			"total_duration": 180.0,
			"tick_interval": 10.0,
			"effects": {
				"hands_rating": 0.08,
				"run_energy_regen": 0.12,
			}
		},
		"debuff": {
			"name": "Caffeine Crash",
			"trigger": "upon_expiration",
			"duration_seconds": 60.0,
			"effects": {
				"run_energy_regen": -0.20,
			}
		}
	},
	"Protein Shake": {
		"item_id": "protein_shake",
		"category": "beverage",
		"stack_size": 10,
		"hot_dot_type": "buff_ramp",
		"buff": {
			"name": "Recovery",
			"total_duration": 60.0,
			"tick_interval": 10.0,
			"ramp_type": "linear",
			"effects_max": {
				"guard_scaling": 0.20,
			}
		},
		"debuff": {
			"name": "Digesting",
			"duration_seconds": 60.0,
			"effects": {
				"movement_speed": -0.05,
			}
		}
	},
	"Recovery Meal": {
		"item_id": "recovery_meal",
		"category": "food",
		"stack_size": 5,
		"hot_dot_type": "buff_ramp",
		"buff": {
			"name": "Rebuilding",
			"total_duration": 90.0,
			"tick_interval": 15.0,
			"ramp_type": "linear",
			"effects_max": {
				"guard_scaling": 0.25,
				"muscle_boost": 0.10,
			}
		},
		"debuff": {
			"name": "Digesting",
			"duration_seconds": 90.0,
			"effects": {
				"movement_speed": -0.08,
			}
		}
	},
	"Mushroom Soup": {
		"item_id": "mushroom_soup",
		"category": "food",
		"stack_size": 5,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Alert",
			"total_duration": 180.0,
			"tick_interval": 10.0,
			"effects": {
				"evasion_ballistic": 0.15,
				"composure_regen": 0.05,
			}
		},
		"debuff": {
			"name": "Sensitive",
			"duration_seconds": 180.0,
			"effects": {
				"melee_vulnerability": 0.10,
			}
		}
	},
	"Spicy Noodles": {
		"item_id": "spicy_noodles",
		"category": "food",
		"stack_size": 5,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Endorphin Rush",
			"total_duration": 300.0,
			"tick_interval": 15.0,
			"effects": {
				"cc_reduction": 0.20,
				"pain_tolerance": 0.15,
			}
		},
		"dot": {
			"name": "Burning",
			"duration_seconds": 120.0,
			"tick_interval": 10.0,
			"vitality_drain_per_tick": 0.01,
		}
	},
	"Capsaicin Dish": {
		"item_id": "capsaicin_dish",
		"category": "food",
		"stack_size": 5,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Fire Inside",
			"total_duration": 240.0,
			"tick_interval": 12.0,
			"effects": {
				"cc_reduction": 0.18,
				"composure_floor": 0.10,
			}
		},
		"dot": {
			"name": "Burning",
			"duration_seconds": 100.0,
			"tick_interval": 10.0,
			"vitality_drain_per_tick": 0.008,
		}
	},
	"Fermented Drink": {
		"item_id": "fermented_drink",
		"category": "beverage",
		"stack_size": 10,
		"hot_dot_type": "vitality_floor",
		"buff": {
			"name": "Safety Net",
			"total_duration": 300.0,
			"vitality_floor": 0.20,
		},
		"debuff": {
			"name": "Bloated",
			"duration_seconds": 300.0,
			"effects": {
				"run_energy_regen": -0.15,
			}
		}
	},
	"Probiotic Blend": {
		"item_id": "probiotic_blend",
		"category": "beverage",
		"stack_size": 10,
		"hot_dot_type": "vitality_floor",
		"buff": {
			"name": "Gut Guard",
			"total_duration": 240.0,
			"vitality_floor": 0.15,
		},
		"debuff": {
			"name": "Bloated",
			"duration_seconds": 240.0,
			"effects": {
				"run_energy_regen": -0.12,
			}
		}
	},
	"Trail Mix": {
		"item_id": "trail_mix",
		"category": "food",
		"stack_size": 20,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Sustained Energy",
			"total_duration": 240.0,
			"tick_interval": 10.0,
			"effects": {
				"run_energy_regen": 0.15,
				"vitality_regen": 0.05,
			}
		},
		"debuff": {
			"name": "Sugar Crash",
			"trigger": "upon_expiration",
			"duration_seconds": 60.0,
			"effects": {
				"run_energy_regen": -0.20,
			}
		}
	},
	"High-Calorie Bar": {
		"item_id": "high_calorie_bar",
		"category": "food",
		"stack_size": 20,
		"hot_dot_type": "buff_over_time",
		"buff": {
			"name": "Quick Fuel",
			"total_duration": 180.0,
			"tick_interval": 10.0,
			"effects": {
				"run_energy_regen": 0.18,
				"movement_speed": 0.05,
			}
		},
		"debuff": {
			"name": "Sugar Crash",
			"trigger": "upon_expiration",
			"duration_seconds": 45.0,
			"effects": {
				"run_energy_regen": -0.25,
			}
		}
	},
}

static func get_consumable_data(item_name: String) -> Dictionary:
	for key in CONSUMABLE_ITEMS.keys():
		if item_name.to_lower().contains(key.to_lower()):
			return CONSUMABLE_ITEMS[key]
	return {}

static func is_consumable_item(item_name: String) -> bool:
	return not get_consumable_data(item_name).is_empty()

static func get_hot_tick_count(consumable_data: Dictionary) -> int:
	if consumable_data.has("buff"):
		var buff: Dictionary = consumable_data.get("buff", {})
		var total: float = buff.get("total_duration", 0.0)
		var interval: float = buff.get("tick_interval", 1.0)
		return int(total / interval) if interval > 0.0 else 0
	elif consumable_data.has("hot"):
		var hot: Dictionary = consumable_data.get("hot", {})
		var total: float = hot.get("total_duration", 0.0)
		var interval: float = hot.get("tick_interval", 1.0)
		return int(total / interval) if interval > 0.0 else 0
	return 0

static func get_dot_tick_count(consumable_data: Dictionary) -> int:
	if consumable_data.has("dot"):
		var dot: Dictionary = consumable_data.get("dot", {})
		var total: float = dot.get("duration_seconds", 0.0)
		var interval: float = dot.get("tick_interval", 1.0)
		return int(total / interval) if interval > 0.0 else 0
	return 0

static func calculate_ramp_multiplier(elapsed: float, total_duration: float, ramp_type: String) -> float:
	if ramp_type == "linear":
		return minf(1.0, elapsed / total_duration)
	elif ramp_type == "quadratic":
		var progress: = minf(1.0, elapsed / total_duration)
		return progress * progress
	return 1.0
