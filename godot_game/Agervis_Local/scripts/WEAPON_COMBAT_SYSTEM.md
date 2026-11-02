# Weapon and Combat System

## Implementation Status: FUNCTIONAL

The weapon and combat system is now operational. Weapons provide stat bonuses, and buff/debuff effects from substances are consumed by the combat and movement systems.

---

## 1. Weapon Items

Weapons have been added to `build7_content.gd` ITEM_DATA with kind `"WEAPON"`:

| Weapon | Tag | Description |
|---|---|---|
| Worn Revolver | ILLEGAL | Six chambers. The grip remembers someone else's sweat. |
| Pipe Wrench | TOOL | Heavy adjustable wrench. Plumbing tool with negotiation capacity. |
| Bolt Cutters | TOOL | Long-handled cutters. Opens locks and closes arguments. |
| Box Cutter | TOOL | Retractable utility blade. Warehouse standard and street backup. |
| Kitchen Knife | TOOL | Chef's knife. Cuts vegetables and credibility. |
| Baseball Bat | SPORTING | Wooden bat. No ball required. |
| Crowbar | TOOL | Pry bar. Opens doors and closes distance. |
| Tire Iron | TOOL | Lug wrench. Automotive tool with persuasive weight. |

---

## 2. Weapon Stats System

### WEAPON_STATS Constant (`main.gd:391-461`)

Each weapon has stats that modify combat performance:

```gdscript
const WEAPON_STATS: = {
	"Fists": {
		"damage_bonus": 0.0,
		"attack_speed_multiplier": 1.0,
		"crit_chance_bonus": 0.0,
		"stamina_multiplier": 1.0,
		"range": 92.0,
		"requires_facing": true,
	},
	"Worn Revolver": {
		"damage_bonus": 35.0,
		"attack_speed_multiplier": 0.8,
		"crit_chance_bonus": 0.10,
		"stamina_multiplier": 1.2,
		"range": 250.0,
		"requires_facing": false,
	},
	# ... other weapons
}
```

### Stat Definitions

- **damage_bonus**: Flat damage added to attacks
- **attack_speed_multiplier**: Affects attack animation timing (not yet implemented)
- **crit_chance_bonus**: Added to base 15% critical hit chance
- **stamina_multiplier**: Multiplies stamina cost of attacks
- **range**: Attack range in pixels
- **requires_facing**: If true, requires facing target; if false, can attack in any direction

### Weapon Balance Design

**Fists**: Baseline stats, short range, requires facing
**Knives** (Box Cutter, Kitchen Knife): Low damage, high crit, low stamina, fast, short range
**Heavy Tools** (Pipe Wrench, Bolt Cutters, Tire Iron): Medium-high damage, medium stamina, medium range
**Blunt Weapons** (Baseball Bat, Crowbar): Medium damage, low crit, medium stamina, longer range
**Firearms** (Worn Revolver): High damage, high crit, high stamina, very long range, no facing requirement

---

## 3. Buff/Debuff Effect Consumer System

### Helper Functions (`main.gd:10113-10147`)

Three helper functions read active buff/debuff effects:

```gdscript
func get_effect_additive(key: String, default_value: float = 0.0) -> float
```
Sums all active buff/debuff values for an additive effect key. Returns default if no records have the key.

```gdscript
func get_effect_multiplicative(key: String, default_value: float = 1.0) -> float
```
Multiplies all active buff/debuff values for a multiplicative effect key. Returns default if no records have the key.

```gdscript
func get_effect_flag(key: String) -> bool
```
Returns true if any active buff/debuff has the flag set to true.

```gdscript
func get_weapon_stats() -> Dictionary
```
Returns weapon stats for the currently equipped weapon (or Fists if none).

---

## 4. Combat Integration Points

### Damage Calculation (`main.gd:10220-10238`)

**Weapon stats applied:**
- Base damage from COMBAT_FRAME_DATA
- Skill bonus from Fighting skill
- Weapon damage bonus
- Buff effects: `muscle_boost`, `muscle_penalty`, `hands_boost`, `hands_penalty`

```gdscript
var weapon_damage_bonus: = float(weapon_stats.get("damage_bonus", 0.0))
var muscle_boost: = get_effect_additive("muscle_boost", 0.0)
var muscle_penalty: = get_effect_additive("muscle_penalty", 0.0)
var hands_boost: = get_effect_additive("hands_boost", 0.0)
var hands_penalty: = get_effect_additive("hands_penalty", 0.0)

var total_damage_bonus: = weapon_damage_bonus + muscle_boost + muscle_penalty + hands_boost + hands_penalty
var final_damage: = (base_damage + skill_bonus + total_damage_bonus) * damage_multiplier
```

### Critical Hit Chance (`main.gd:10233-10240`)

**Weapon and effect bonuses combined:**
```gdscript
var base_crit_chance: = 0.15
var weapon_crit_bonus: = float(weapon_stats.get("crit_chance_bonus", 0.0))
var effect_crit_bonus: = get_effect_additive("crit_chance", 0.0)
var total_crit_chance: = base_crit_chance + weapon_crit_bonus + effect_crit_bonus
```

### Stamina Cost (`main.gd:9439-9443`)

**Weapon stamina multiplier applied:**
```gdscript
var base_stamina_cost: = float(attack_data.get("stamina_cost", 15.0))
var weapon_stamina_mult: = float(weapon_stats.get("stamina_multiplier", 1.0))
var stamina_cost: = base_stamina_cost * weapon_stamina_mult
```

### Attack Range and Facing (`main.gd:9389-9395`, `10209-10215`)

**Weapon determines range and facing requirement:**
- `player_attack()`: Uses weapon stats to determine target selection
- `execute_attack_hit()`: Uses weapon stats to verify target in range

```gdscript
var weapon_stats: = get_weapon_stats()
var weapon_range: = float(weapon_stats.get("range", 92.0))
var requires_facing: = bool(weapon_stats.get("requires_facing", true))

var target: = nearest_facing_actor(weapon_range, true) if requires_facing else nearest_actor(weapon_range, true)
```

### Movement Speed (`main.gd:7649-7653`)

**Movement speed modifier from buffs/debuffs:**
```gdscript
var base_speed: = 275.0 if sprinting else 175.0

var movement_speed_modifier: = get_effect_additive("movement_speed", 0.0)
var speed: = base_speed * (1.0 + movement_speed_modifier)
```

Effect values are additive: `-0.20` means 20% slower, `+0.30` means 30% faster.

---

## 5. Active Weapon Selection

### active_attack_weapon() (`main.gd:25307-25311`)

Returns the first weapon found in inventory, or "Fists" if none:
```gdscript
func active_attack_weapon() -> String:
	for item_name in ["Worn Revolver", "Pipe Wrench", "Bolt Cutters", "Box Cutter", "Kitchen Knife", "Baseball Bat", "Crowbar", "Tire Iron"]:
		if item_name in inventory:
			return item_name
	return "Fists"
```

Priority order matches the list. First weapon in inventory is used.

### Attack Type Selection (`main.gd:9420-9426`)

Weapon determines which attack animations are used:
- **Fists**: punch, heavy_punch, kick (combo-based)
- **Knives** (Box Cutter, Kitchen Knife): stab, slash
- **Heavy Tools** (Pipe Wrench, Bolt Cutters, etc.): overhead, slash
- **Firearms** (Worn Revolver): shoot_1h (placeholder)

---

## 6. Consumed Effect Keys

These effect keys from `BUFF_EFFECT_RULES.md` are now functional:

| Key | Type | Location | Purpose |
|---|---|---|---|
| `movement_speed` | Additive | `update_movement` (7651) | Modifies walk/sprint speed |
| `muscle_boost` | Additive | `execute_attack_hit` (10226) | Increases damage |
| `muscle_penalty` | Additive | `execute_attack_hit` (10227) | Decreases damage |
| `hands_boost` | Additive | `execute_attack_hit` (10228) | Increases damage (accuracy-themed) |
| `hands_penalty` | Additive | `execute_attack_hit` (10229) | Decreases damage |
| `crit_chance` | Additive | `execute_attack_hit` (10235) | Increases critical hit chance |

### Effect Stacking Rules

**Additive effects** sum across all active buffs and debuffs:
- Two buffs with `muscle_boost: 10.0` = +20.0 total
- One buff with `muscle_boost: 15.0` and one debuff with `muscle_penalty: -8.0` = +7.0 total

**Multiplicative effects** multiply together (not yet used in combat):
- Would stack as `1.0 * multiplier1 * multiplier2 * ...`

**Flags** return true if any active record sets them to true.

---

## 7. Not Yet Implemented

These effect keys are defined but not yet consumed:

### Combat Stats Not Wired
- `attack_speed` - Would modify attack animation duration
- `hands_accuracy` - Could affect hit chance (no miss system exists yet)
- `hands_rating` - Purpose unclear
- `evasion`, `evasion_ballistic` - No dodge chance system
- `unblockable_recoil`, `toxic_recoil` - Self-damage on attack
- `damage_reflection` - Damage attacker on being hit
- `special_attack_regen` - Special attack meter doesn't exist

### Vitality/Health
- `vitality_restore`, `vitality_drain`, `vitality_drain_per_tick` - Health modifications
- `vitality_floor`, `vitality_regen`, `vitality_regen_boost` - Health regen
- `healing_effectiveness`, `instant_heal_effectiveness` - Healing multipliers
- `food_heal_multiplier` - Food healing modifier
- `healing_items_disabled` - Flag to disable healing
- `max_vitality_overheal` - Temporary max health increase

### Guard/Defense
- `guard_penalty`, `guard_mitigation`, `guard_mitigation_kinetic` - Damage reduction
- `guard_floor`, `guard_scaling` - Defense stats

### Stamina
- `run_energy_regen`, `run_energy_drain` - Stamina regen modifiers

### Crowd Control
- `cc_reduction`, `cc_resistance`, `stun_resistance` - Status effect resistance
- `panic_immunity`, `fear_immunity` - Status immunity flags
- `forced_auto_retaliate` - Auto-attack flag
- `target_selection_disabled` - Prevents targeting

### UI and Behavior
- `composure_drain` - Mental stat drain
- `npc_aggro_radius` - NPC detection range
- `minimap_disabled` - UI disable flag
- `ui_visibility` - UI visibility modifier
- `negates_lethargy` - Counters specific debuff

### Missing Stats

The player has only `health` and `stamina`. These stats referenced by effects don't exist:
- **Guard**: Damage reduction stat
- **Composure**: Mental stat (clarity, fear resistance)
- **Hands**: Accuracy/dexterity stat
- **Muscle**: Strength stat (currently effects just add to damage)

---

## 8. Testing the System

### Test Weapons
Add weapons to inventory to test:
```gdscript
inventory.append("Box Cutter")  # Fast, high crit, low damage
inventory.append("Baseball Bat")  # Medium damage, longer range
inventory.append("Worn Revolver")  # High damage, very long range, no facing
```

### Test Buffs
Create test buffs with combat effects:
```gdscript
active_buffs.append({
	"substance": "test_buff",
	"name": "Combat Boost",
	"remaining": 30.0,
	"effects": {
		"muscle_boost": 15.0,
		"crit_chance": 0.10,
		"movement_speed": 0.20,
	}
})
```

### Test Debuffs
Create test debuffs:
```gdscript
active_debuffs.append({
	"substance": "test_debuff",
	"name": "Combat Penalty",
	"remaining": 20.0,
	"effects": {
		"muscle_penalty": -10.0,
		"hands_penalty": -5.0,
		"movement_speed": -0.30,
	}
})
```

### Observable Effects
- **Damage numbers**: Watch hit markers show higher/lower damage
- **Critical hits**: More frequent with high crit weapons or buffs
- **Movement speed**: Visibly faster/slower with buff/debuff active
- **Attack range**: Longer-range weapons hit from farther away
- **Stamina drain**: Heavy weapons drain more stamina per attack

---

## 9. Future Expansion

### Weapon System
- **Equipment slot**: Currently first weapon in inventory is used; could add proper weapon slot
- **Weapon durability**: Track uses and breakage
- **Weapon requirements**: Skill/stat requirements to use effectively
- **Special attacks**: Weapon-specific special moves
- **Ammunition**: For firearms, track ammo and reloading

### Combat Stats
- **Attack speed effects**: Make `attack_speed` modify animation duration
- **Hit/miss system**: Implement accuracy and evasion mechanics
- **Defense system**: Add guard stat and damage mitigation
- **Status effects**: Stun, root, slow, bleed, poison

### Effect System
- **Per-tick effects**: Implement vitality drain/regen per game tick
- **Composite stats**: Create guard, composure, hands, muscle stats
- **Effect priorities**: Max/min values, effect caps, diminishing returns
- **Visual feedback**: Buff/debuff icons, effect timers on HUD

---

## 10. Architecture Notes

### Why Additive for Everything?
The current implementation uses additive stacking for all combat modifiers. This is simple and predictable:
- `muscle_boost: 10.0` means "+10 damage"
- Two `muscle_boost: 10.0` buffs = +20 damage total
- No confusion about multiplicative stacking order

Multiplicative effects are available via `get_effect_multiplicative()` but not used yet.

### Effect Key Namespace
All effect keys share one namespace in the `effects` dictionary. Keys use suffixes to indicate purpose:
- `_boost` / `_penalty`: Additive damage/stat modifiers
- `_drain` / `_regen`: Per-tick value changes
- `_multiplier`: Multiplicative modifiers
- `_disabled` / `_immunity`: Boolean flags

### Weapon Stats vs Effects
**Weapon stats** are permanent bonuses while the weapon is equipped.
**Buff/debuff effects** are temporary bonuses from substances.

Both stack additively with base stats in damage calculation.

---

## 11. Known Issues

### Data Problems (from BUFF_EFFECT_RULES.md)
- **SYRUP debuff** has no `duration_seconds`, expires immediately
- **Overdose effects** are prose strings, not dictionaries
- **REVIVAR** clear list doesn't match substance IDs

These need fixing before those substances can have working effects.

### Purity Scaling
Purity multiplier scales ALL numeric values in effects, including values that shouldn't scale (absolute targets, flags stored as ints). Need key-aware purity scaling.

### Attack Speed Not Implemented
`attack_speed_multiplier` on weapons and `attack_speed` effect key exist but don't modify animation duration yet.

---

## 12. Code Locations Quick Reference

| Feature | File | Lines |
|---|---|---|
| Weapon items | `build7_content.gd` | 146-153 |
| Weapon stats | `main.gd` | 391-461 |
| Effect helpers | `main.gd` | 10113-10147 |
| Damage calculation | `main.gd` | 10220-10238 |
| Crit chance | `main.gd` | 10233-10240 |
| Stamina cost | `main.gd` | 9439-9443 |
| Attack range/facing | `main.gd` | 9389-9395, 10209-10215 |
| Movement speed | `main.gd` | 7649-7653 |
| Active weapon | `main.gd` | 25307-25311 |
| Attack type selection | `main.gd` | 9403-9426 |

---

**Effects are now functional for combat and movement. Substance buffs/debuffs modify damage, crit chance, and movement speed in real time.**
