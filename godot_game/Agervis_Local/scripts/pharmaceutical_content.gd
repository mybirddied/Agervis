class_name PharmaceuticalContent
extends RefCounted

# Pharmaceutical substances with blister/pouch packaging
const PHARMA_SUBSTANCES: = {
	"Blackout™": {
		"brand": "Blackout™",
		"street_names": ["bars", "benzos", "xans"],
		"form": "bars",
		"pack_sizes": [7, 30, 90],
		"substance_id": "blackout",
		"addiction_level": "High",
		"buff": {
			"name": "Delusions of Sobriety",
			"duration_seconds": 15.0,
			"effects": {
				"panic_immunity": 1.0,
				"fear_immunity": 1.0,
				"cc_resistance": 0.85,
			}
		},
		"debuff": {
			"name": "Amnesiac Autopilot",
			"duration_seconds": 15.0,
			"effects": {
				"ui_visibility": 0.0,
			}
		},
		"overdose": {
			"name": "Fugue State",
			"trigger": "second_dose_before_expiry",
			"effects": "Inverts movement inputs. Character autonomously drops 1-3 random unequipped items over 15s."
		}
	},
	"NeverDone™": {
		"brand": "NeverDone™",
		"street_names": ["done", "liquid handcuffs"],
		"form": "gel-caps",
		"pack_sizes": [7, 30, 90],
		"substance_id": "neverdone",
		"addiction_level": "Moderate",
		"buff": {
			"name": "Liquid Handcuffs",
			"duration_seconds": 720.0,  # 12 minutes
			"effects": {
				"vitality_floor": 0.15,
				"guard_floor": 0.15,
			}
		},
		"debuff": {
			"name": "Receptor Blockade",
			"duration_seconds": 720.0,
			"effects": {
				"instant_heal_effectiveness": 0.1,  # blocks 90%
			}
		},
		"overdose": {
			"name": "Heavy Toxicity",
			"trigger": "second_dose_before_expiry",
			"effects": "Vomiting animation every 5s for 30s. Interrupts actions, movement, weapon swings."
		}
	},
	"Subscriptxone™": {
		"brand": "Subscriptxone™",
		"street_names": ["subs", "script"],
		"form": "foil pouches",
		"pack_sizes": [7, 30, 90],
		"substance_id": "subscriptxone",
		"addiction_level": "Moderate",
		"buff": {
			"name": "Maintenance",
			"duration_seconds": 600.0,  # 10 minutes
			"effects": {
				"vitality_regen_boost": 0.10,
			}
		},
		"debuff": {
			"name": "Precipitated Withdrawal",
			"trigger": "consumed_while_tar_china_active",
			"effects": {
				"vitality_drain": 0.30,
				"run_energy_drain": 0.50,
			}
		},
		"overdose": {
			"name": "Ceiling Overload",
			"trigger": "second_dose_before_expiry",
			"effects": "Drains -100% Composure. Disables passive Vitality regen for 5 minutes."
		}
	},
	"Addictrall XR™": {
		"brand": "Addictrall XR™",
		"street_names": ["addys", "speed", "study pills"],
		"form": "capsules",
		"pack_sizes": [7, 30, 90],
		"substance_id": "addictrall",
		"addiction_level": "Moderate",
		"buff": {
			"name": "Hyper-Focus",
			"duration_seconds": 360.0,  # 6 minutes
			"effects": {
				"hands_accuracy": 0.20,
				"crit_chance": 0.15,
			}
		},
		"debuff": {
			"name": "Burnout",
			"trigger": "upon_expiration",
			"effects": {
				"guard_scaling": -0.25,
				"run_energy_drain": 0.20,
			}
		},
		"overdose": {
			"name": "Shadow People",
			"trigger": "second_dose_before_expiry",
			"effects": "Spawns fake hostile 'Shadow' mobs on minimap. Drains -100% Composure."
		}
	},
	"Vassalium™": {
		"brand": "Vassalium™",
		"street_names": ["vals", "muscle relaxers"],
		"form": "caplets",
		"pack_sizes": [7, 30, 90],
		"substance_id": "vassalium",
		"addiction_level": "Moderate",
		"buff": {
			"name": "Muscle Relaxer",
			"duration_seconds": 300.0,
			"effects": {
				"guard_scaling": 0.25,
				"stun_resistance": 0.60,
			}
		},
		"debuff": {
			"name": "Motor Delay",
			"duration_seconds": 300.0,
			"effects": {
				"attack_speed": -0.20,
			}
		},
		"overdose": {
			"name": "Jelly Legs",
			"trigger": "second_dose_before_expiry",
			"effects": "Run toggled off for 60s. Evasion locked to 0%."
		}
	},
	"Rebillin™": {
		"brand": "Rebillin™",
		"street_names": ["diet pills", "reb"],
		"form": "tabs",
		"pack_sizes": [7, 30, 90],
		"substance_id": "rebillin",
		"addiction_level": "Low",
		"buff": {
			"name": "Stimulation",
			"duration_seconds": 300.0,
			"effects": {
				"hands_rating": 0.10,
			}
		},
		"debuff": {
			"name": "Appetite Suppression",
			"duration_seconds": 300.0,
			"effects": {
				"vitality_regen": -0.50,
			}
		},
		"overdose": {
			"name": "Tachycardia",
			"trigger": "second_dose_before_expiry",
			"effects": "-25% Max Vitality. Disables food/healing items for 30s."
		}
	},
	"Paper": {
		"brand": "Paper",
		"street_names": ["tabs", "acid", "blotter"],
		"form": "strips",
		"pack_sizes": [10],  # 10-pack only
		"substance_id": "paper",
		"addiction_level": "Low",
		"buff": {
			"name": "Tracers",
			"duration_seconds": 300.0,
			"effects": {
				"evasion_ballistic": 0.25,
			}
		},
		"debuff": {
			"name": "Visual Distortion",
			"duration_seconds": 300.0,
			"effects": {
				"hands_accuracy": -0.15,
			}
		},
		"overdose": {
			"name": "Bad Trip",
			"trigger": "second_dose_before_expiry",
			"effects": "UI scrambles. Inventory slots/hotkeys visually swap for 45s."
		}
	},
	"A2": {
		"brand": "A2",
		"street_names": ["synth", "fake herb", "spice"],
		"form": "capsules",
		"pack_sizes": [7, 30, 90],
		"substance_id": "a2",
		"addiction_level": "High",
		"buff": {
			"name": "Artificial Munchies",
			"duration_seconds": 90.0,
			"effects": {
				"food_heal_multiplier": 1.20,
			}
		},
		"debuff": {
			"name": "Synthetic Crash",
			"duration_seconds": 90.0,
			"effects": {
				"movement_speed": -0.35,
				"crit_chance": -0.20,
				"composure_drain": 0.25,
			}
		},
		"overdose": {
			"name": "Bad Synth",
			"trigger": "second_dose_before_expiry",
			"effects": "-100% Run Energy. Vomiting animation every 8s for 30s. Cannot consume food during vomiting."
		}
	},
	"Dissociaderm™": {
		"brand": "Dissociaderm™",
		"street_names": ["medical k", "med k"],
		"form": "vials",
		"pack_sizes": [7, 30],
		"substance_id": "dissociaderm",
		"addiction_level": "Low",
		"buff": {
			"name": "Controlled Dissociation",
			"duration_seconds": 90.0,
			"effects": {
				"damage_reflection": 0.30,
			}
		},
		"debuff": {
			"name": "Motor Impairment",
			"duration_seconds": 8.0,
			"effects": {
				"movement_speed": -0.60,
				"hands_penalty": -0.50,
				"muscle_penalty": -0.50,
			}
		},
		"overdose": {
			"name": "Deep Sedation",
			"trigger": "second_dose_before_expiry",
			"effects": "Screen darkens 6s. Movement -80% for 15s."
		}
	},
	"Serenex™": {
		"brand": "Serenex™",
		"street_names": ["controlled dust", "medical dust"],
		"form": "tablets",
		"pack_sizes": [7, 30],
		"substance_id": "serenex",
		"addiction_level": "Moderate",
		"buff": {
			"name": "Controlled Analgesia",
			"duration_seconds": 420.0,
			"effects": {
				"cc_reduction": 0.50,
				"muscle_boost": 0.20,
			}
		},
		"debuff": {
			"name": "Delayed Recovery",
			"trigger": "upon_expiration",
			"effects": {
				"healing_effectiveness": -0.40,
				"unblockable_recoil": 0.15,
			}
		},
		"overdose": {
			"name": "Agitation",
			"trigger": "second_dose_before_expiry",
			"effects": "Forces auto-retaliate on nearest hostile for 20s. -40% Movement Speed."
		}
	},
}

# Syrup sold by pint (16oz) or individual oz
const SYRUP: = {
	"brand": "Syrup",
	"street_names": ["lean", "wock", "purple"],
	"form": "liquid",
	"pack_sizes": ["pint", "oz"],  # pint = 16oz
	"substance_id": "syrup",
	"addiction_level": "Moderate",
	"buff": {
		"name": "Leaning",
		"duration_seconds": 180.0,
		"effects": {
			"max_vitality_overheal": 0.20,
		}
	},
	"debuff": {
		"name": "Sluggish",
		"per_dose": true,
		"effects": {
			"attack_speed": -0.20,
			"movement_speed": -0.20,
		}
	},
	"overdose": {
		"name": "Brain Zap",
		"trigger": "second_dose_before_expiry",
		"effects": "Character randomly falls asleep (2-tick stun) every 6s for 60s. -80% Attack Speed."
	}
}

# Revivar (overdose reversal)
const REVIVAR: = {
	"brand": "Revivar™",
	"street_names": ["revivar"],
	"form": "spray pods",
	"pack_sizes": [10],
	"substance_id": "revivar",
	"addiction_level": "None",
	"effect": {
		"name": "Overdose Reversal",
		"can_self_admin": true,
		"can_target_ally": true,
		"clears": ["china_overdose", "tar_overdose", "china_buffs", "tar_buffs"],
	},
	"debuff": {
		"name": "Violent Reset",
		"instant": true,
		"effects": {
			"vitality_drain": 0.20,
			"run_energy_drain": 0.50,
		}
	}
}

# Prescription sources
const PRESCRIPTION_SOURCES: = {
	"pillmill": {
		"location": "DR. FEELBETTER PAIN + FOCUS",
		"substances": ["addictrall", "vassalium", "blackout"],
		"cooldown_hours": 24.0,
		"trust_required": 0,
	},
	"clinic": {
		"location": "CONTINUING CARE OUTCOME CENTER",
		"substances": ["subscriptxone", "neverdone", "revivar"],
		"cooldown_hours": 24.0,
		"enrollment_required": true,
	}
}

# Take-home dose rules
const TAKEHOME_MAX_STACK: = 7  # Can't carry more than 7-day supply

static func substance_data(brand_name: String) -> Dictionary:
	if brand_name == "Syrup":
		return SYRUP.duplicate(true)
	if brand_name == "Revivar":
		return REVIVAR.duplicate(true)
	return PHARMA_SUBSTANCES.get(brand_name, {}).duplicate(true)

static func prescription_source(location_id: String) -> Dictionary:
	return PRESCRIPTION_SOURCES.get(location_id, {}).duplicate(true)

# Generate pack item ID
static func pack_item_id(brand: String, pack_size: int) -> String:
	return "%s (%d-pack)" % [brand, pack_size]

# Generate individual dose item ID
static func dose_item_id(brand: String) -> String:
	return "%s (single)" % brand

# Syrup packaging
static func syrup_pint_item_id() -> String:
	return "Syrup (pint)"

static func syrup_oz_item_id() -> String:
	return "Syrup (oz)"
