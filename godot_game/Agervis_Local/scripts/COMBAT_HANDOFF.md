# Combat System Handoff Document

**Date**: 2026-10-27  
**From**: Session working on substance effect system  
**To**: Agent responsible for combat system

---

## What Was Done (This Session)

### 1. Per-Tick Substance Effects (main.gd lines 5451-5542)

Added buff/debuff timer countdown and per-tick effect application to `update_active_substance_effects()`:

```gdscript
# Update pharmaceutical/substance buffs and debuffs
for i in range(active_buffs.size() - 1, -1, -1):
    active_buffs[i]["remaining"] -= delta
    if active_buffs[i]["remaining"] <= 0.0:
        active_buffs.remove_at(i)

for i in range(active_debuffs.size() - 1, -1, -1):
    active_debuffs[i]["remaining"] -= delta
    if active_debuffs[i]["remaining"] <= 0.0:
        active_debuffs.remove_at(i)

# Apply per-tick buff/debuff effects
if not player_downed and health > 0.0:
    var vitality_restore: = get_effect_additive("vitality_restore", 0.0)
    var vitality_drain: = get_effect_additive("vitality_drain", 0.0)
    var vitality_drain_per_tick: = get_effect_additive("vitality_drain_per_tick", 0.0)
    var vitality_regen: = get_effect_additive("vitality_regen", 0.0)

    var net_vitality_change: = (vitality_restore + vitality_drain + vitality_drain_per_tick + vitality_regen) * delta
    health = clampf(health + net_vitality_change, 1.0, 100.0)

var run_energy_regen: = get_effect_additive("run_energy_regen", 0.0)
var run_energy_drain: = get_effect_additive("run_energy_drain", 0.0)

var net_stamina_change: = (run_energy_regen + run_energy_drain) * delta
stamina = clampf(stamina + net_stamina_change, 0.0, 100.0)
```

**Effect keys wired**: vitality_restore, vitality_drain, vitality_drain_per_tick, vitality_regen, run_energy_regen, run_energy_drain

**Design decisions**:
- Health effects only apply when not downed and health > 0
- Health clamped to 1.0-100.0 (minimum 1hp prevents death from effects)
- Stamina clamped to 0.0-100.0

---

### 2. Guard Mitigation and Vitality Floor (main.gd lines 9576-9595)

Modified `damage_player()` to respect guard mitigation and vitality floor effects:

```gdscript
func damage_player(amount: float, attacker: AgervisActor) -> void :
    if god_mode:
        return
    if player_downed:
        return
    sleeping = false
    spawn_blood(player_position, "attack", maxi(4, int(amount / 4.0)))

    # Apply guard mitigation from buffs/debuffs
    var guard_mitigation: = get_effect_additive("guard_mitigation", 0.0)
    var guard_mitigation_kinetic: = get_effect_additive("guard_mitigation_kinetic", 0.0)
    var total_mitigation: = clampf(guard_mitigation + guard_mitigation_kinetic, 0.0, 0.95)
    var mitigated_damage: = amount * (1.0 - total_mitigation)

    # Apply vitality floor from buffs/debuffs
    var vitality_floor: = get_effect_additive("vitality_floor", 0.0)
    var min_health: = maxf(0.0, vitality_floor)

    health = maxf(min_health, health - mitigated_damage)
```

**Effect keys wired**: guard_mitigation, guard_mitigation_kinetic, vitality_floor

**Design decisions**:
- Total mitigation capped at 95% to prevent full immunity
- Vitality floor ensures health never drops below specified value

---

### 3. Healing Effectiveness Multipliers

**item_use_rules.gd lines 31-51** - Modified `apply_standard_effect()`:

Added parameters `healing_effectiveness` and `instant_heal_effectiveness` (both default 1.0):

```gdscript
# Apply healing effectiveness multipliers to health restoration
var base_health_restore: = float(item_definition.get("health_restore", 0.0))
var modified_health_restore: = base_health_restore * healing_effectiveness * instant_heal_effectiveness
```

**main.gd line ~31078** - Updated `consume_item()` call site:

```gdscript
var healing_effectiveness: = get_effect_multiplicative("healing_effectiveness", 1.0)
var instant_heal_effectiveness: = get_effect_multiplicative("instant_heal_effectiveness", 1.0)

var effect: = ItemUseRules.apply_standard_effect(item_id, health, stamina, max_stamina_value(), healing_effectiveness, instant_heal_effectiveness)
```

**Effect keys wired**: healing_effectiveness, instant_heal_effectiveness

**Design decisions**:
- Both multipliers stack multiplicatively with base healing
- Defaults to 1.0 for backward compatibility
- Buffs with healing_effectiveness > 1.0 increase healing
- Debuffs with healing_effectiveness < 1.0 reduce healing

---

## Total Effect Keys Wired (Current + Prior Session)

**This session added 11 keys**:
1. vitality_restore
2. vitality_drain
3. vitality_drain_per_tick
4. vitality_regen
5. run_energy_regen
6. run_energy_drain
7. guard_mitigation
8. guard_mitigation_kinetic
9. vitality_floor
10. healing_effectiveness
11. instant_heal_effectiveness

**Prior session wired 6 keys**:
1. movement_speed (movement system)
2. muscle_boost (damage calculation)
3. muscle_penalty (damage calculation)
4. hands_boost (damage calculation)
5. hands_penalty (damage calculation)
6. crit_chance (critical hit chance)

**Total: 17 effect keys now functional**

---

## Still Not Wired (From BUFF_EFFECT_RULES.md)

### Combat Stats
- `attack_speed` - Would modify attack animation duration
- `hands_accuracy` - Hit chance modifier (no miss system exists)
- `hands_rating` - Purpose unclear
- `evasion`, `evasion_ballistic` - Dodge chance
- `unblockable_recoil`, `toxic_recoil` - Self-damage on attack
- `damage_reflection` - Damage attacker on being hit
- `special_attack_regen` - Special attack meter (doesn't exist)

### Vitality/Health
- `vitality_regen_boost` - Multiplier for health regen
- `food_heal_multiplier` - Food-specific healing modifier
- `max_vitality_overheal` - Temporary max health increase

### Guard/Defense
- `guard_penalty` - Guard reduction
- `guard_floor` - Minimum guard value
- `guard_scaling` - Guard scaling modifier

### Crowd Control
- `cc_reduction` - Status effect duration reduction
- `cc_resistance` - Status effect resist chance
- `stun_resistance` - Stun-specific resistance
- `panic_immunity`, `fear_immunity` - Status immunity flags
- `forced_auto_retaliate` - Auto-attack flag
- `target_selection_disabled` - Prevents targeting

### UI and Behavior
- `composure_drain` - Mental stat drain
- `npc_aggro_radius` - NPC detection range modifier
- `minimap_disabled` - UI disable flag
- `ui_visibility` - UI visibility modifier
- `negates_lethargy` - Counters specific debuff
- `healing_items_disabled` - Flag to disable healing items

---

## Known Issues Not Fixed

1. **SYRUP debuff**: No `duration_seconds`, expires immediately
2. **Overdose effects**: Prose strings instead of effect dictionaries
3. **REVIVAR clear list**: Doesn't match actual substance IDs
4. **Purity scaling**: Multiplies ALL numeric values (including those that shouldn't scale like absolute targets)

These are documented in `BUFF_EFFECT_RULES.md` but not yet addressed.

---

## Architecture Notes

### Effect Stacking Pattern
- **Additive effects**: Sum across all active buffs/debuffs (`get_effect_additive()`)
- **Multiplicative effects**: Multiply together (`get_effect_multiplicative()`)
- **Flags**: True if any active record sets flag to true (`get_effect_flag()`)

### Helper Functions (main.gd lines 10113-10147)
```gdscript
func get_effect_additive(key: String, default_value: float = 0.0) -> float
func get_effect_multiplicative(key: String, default_value: float = 1.0) -> float
func get_effect_flag(key: String) -> bool
```

### Weapon Stats vs Effects
- **Weapon stats**: Permanent bonuses while weapon equipped (see WEAPON_STATS const)
- **Buff/debuff effects**: Temporary bonuses from substances
- Both stack additively in damage calculation

---

## Next Steps for Combat System

1. **Attack Speed Effects**: Wire `attack_speed` to modify animation duration
2. **Hit/Miss System**: Implement if needed, then wire `hands_accuracy`, `evasion`
3. **Status Effects**: Implement stun/root/slow, then wire CC reduction/resistance
4. **Recoil Damage**: Wire `unblockable_recoil`, `toxic_recoil` to damage player on attack
5. **Damage Reflection**: Wire `damage_reflection` to damage attacker when hit
6. **Guard System Completion**: Wire `guard_penalty`, `guard_floor`, `guard_scaling`
7. **Advanced Healing**: Wire `food_heal_multiplier`, `max_vitality_overheal`, `healing_items_disabled`

---

## Testing Current Changes

### Test Per-Tick Effects
```gdscript
active_buffs.append({
    "substance": "test_regen",
    "name": "Health Regen Test",
    "remaining": 10.0,
    "effects": {"vitality_regen": 5.0}  # +5 hp/sec
})
```

### Test Guard Mitigation
```gdscript
active_buffs.append({
    "substance": "test_armor",
    "name": "Armor Test",
    "remaining": 30.0,
    "effects": {"guard_mitigation": 0.50}  # 50% damage reduction
})
```

### Test Healing Effectiveness
```gdscript
active_buffs.append({
    "substance": "test_heal_boost",
    "name": "Healing Boost",
    "remaining": 60.0,
    "effects": {"healing_effectiveness": 1.5}  # 50% more healing from items
})

# Then use Hot Plate (24 hp) -> should heal 36 hp
```

---

## Files Modified This Session

1. **main.gd** (2 locations):
   - Lines 5466-5493: Per-tick substance effects
   - Lines 9576-9595: Guard mitigation and vitality floor in damage_player()
   - Line ~31078: Healing effectiveness in consume_item()

2. **item_use_rules.gd**:
   - Lines 31-51: Added healing effectiveness parameters to apply_standard_effect()

---

## References

- **WEAPON_COMBAT_SYSTEM.md**: Full weapon and combat documentation from prior session
- **BUFF_EFFECT_RULES.md**: Complete list of all 45+ effect keys and their definitions
- **build7_content.gd**: Weapon item data and substance definitions
- **addiction_system.gd**: Addiction and substance consumption system
