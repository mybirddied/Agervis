# Buff and Debuff Effect Rules

> **STATUS: NOT IMPLEMENTED. Effects are decorative.**
>
> **KNOWN LIMITATION - FUTURE WORK**
>
> Effects are decorative. Don't promise they work without implementing the consumer.

---

## TL;DR

- Drugs create buff and debuff records. Each record has an `effects` dictionary (for example `{"movement_speed": -0.20}`).
- Nothing reads that `effects` dictionary. Only the record's `remaining` timer and `substance` id are read.
- So a drug does not actually change damage, movement, accuracy, or any other stat in game. The timer runs and the record expires, and that is all.
- Making effects work needs a consumer system, and some of the stats the effects refer to do not exist yet.
- This file is a reference and a scope document. It does not change any code.

---

## 1. Current State

### What reads what

| Field on a record | Written by | Read by | Actually works? |
|---|---|---|---|
| `substance` | `main.gd:31048` | `AddictionSystem.track_active_buffs` (`addiction_system.gd:157`), `AddictionSystem.check_receptor_blockade` (`addiction_system.gd:184`) | Yes (identity and blockade checks) |
| `remaining` | `main.gd:31051`, `:31071` | Per-tick timer loop, `main.gd:5388-5397` | Yes (expires on time) |
| `name` | `main.gd:31049`, `:31069` | Not checked | Unknown |
| `effects` | `main.gd:31050`, `:31070` | **Nothing** | **NO. Decorative.** |

### Write path

- Buff and debuff records are created in `main.gd:31047-31072`.
- `effects` is copied from the content table with `.duplicate(true)`.
- When purity tier is above 0, every numeric value in `effects` is multiplied by `purity_multiplier`.
- The duration tolerance multiplier is hardcoded to `1.0` (`main.gd:31031-31032`, comment says "simplified - no tolerance system implemented").

### Separate system that DOES work

`active_substance_effects` is a different, older system keyed by `"powder"` and `"food"`. It is consumed, and it is the working reference for how a consumer should look:

- `active_powder_effect()` and `active_food_effect()` (`main.gd:5348-5364`) check expiry using `ends_at_unix_ms`.
- `update_active_substance_effects()` applies `health_regen_per_second` each tick (`main.gd:5366-5386`).
- `active_stamina_regen_multiplier()` (`main.gd:5422-5424`) reads `stamina_regen_multiplier`.

Buffs and debuffs do not use this path.

---

## 2. What Needs To Be Built

A **consumer system**: code that reads active effects and applies them to game stats.

Minimum requirements:

1. A rule for each effect key: how it combines (additive, multiplicative, absolute, or flag).
2. A rule for stacking: what happens when two active records set the same key.
3. A place where each key is read (see Section 4).
4. Stats for the effects to act on (see Section 6, "Why this is hard").
5. Clean data: no prose strings where dictionaries are expected, and every record has a duration.

---

## 3. Effect Key Schema

Counted from the content tables: **45 unique keys.**

- **S** = `scripts/street_substances.gd` (`STREET_SUBSTANCES`)
- **C** = `scripts/street_substances.gd` (`DANGEROUS_COMBINATIONS` only)
- **P** = `scripts/pharmaceutical_content.gd` (`PHARMA_SUBSTANCES`, `SYRUP`)

"Kind" is **TBD** unless noted. Confirm the kind from values in the content file before writing any consumer.

### 3a. Vitality (health)

| Key | Source | Kind |
|---|---|---|
| `vitality_restore` | S | TBD |
| `vitality_drain` | S (C), P | TBD |
| `vitality_drain_per_tick` | C | TBD (per tick) |
| `vitality_floor` | P | TBD |
| `vitality_regen` | P | TBD |
| `vitality_regen_boost` | P | TBD |
| `healing_effectiveness` | P | TBD |
| `instant_heal_effectiveness` | P | TBD |
| `food_heal_multiplier` | S | Multiplier (name implies it) |
| `healing_items_disabled` | S | Flag |
| `max_vitality_overheal` | P (SYRUP buff: `0.20`) | TBD |

### 3b. Guard

| Key | Source | Kind |
|---|---|---|
| `guard_penalty` | S | TBD |
| `guard_mitigation` | C | TBD |
| `guard_mitigation_kinetic` | S | TBD |
| `guard_floor` | P | TBD |
| `guard_scaling` | P | TBD |

### 3c. Movement and run energy

| Key | Source | Kind |
|---|---|---|
| `movement_speed` | S, P (SYRUP debuff: `-0.20`) | Looks additive (negative fraction) |
| `run_energy_regen` | S | TBD |
| `run_energy_drain` | S (C), P | TBD |

### 3d. Combat (attack, accuracy, damage)

| Key | Source | Kind |
|---|---|---|
| `attack_speed` | S, P (SYRUP debuff: `-0.20`) | Looks additive (negative fraction) |
| `hands_boost` | S | TBD |
| `hands_penalty` | S, P | TBD |
| `hands_accuracy` | S, P | TBD |
| `hands_rating` | P | TBD |
| `crit_chance` | S, P | TBD |
| `muscle_boost` | S, P | TBD |
| `muscle_penalty` | S, P | TBD |
| `evasion` | C | TBD |
| `evasion_ballistic` | P | TBD |
| `unblockable_recoil` | S, P | TBD |
| `toxic_recoil` | S | TBD |
| `damage_reflection` | S, P | TBD |
| `special_attack_regen` | C | TBD |

### 3e. Crowd control

| Key | Source | Kind |
|---|---|---|
| `cc_reduction` | S, P | TBD |
| `cc_resistance` | P | TBD |
| `stun_resistance` | P | TBD |

### 3f. Mind, targeting, UI, and flags

| Key | Source | Kind |
|---|---|---|
| `composure_drain` | S, P | TBD |
| `panic_immunity` | S (C), P | Flag |
| `fear_immunity` | S (C), P | Flag (likely) |
| `npc_aggro_radius` | S | TBD |
| `minimap_disabled` | S | Flag |
| `ui_visibility` | P | TBD |
| `target_selection_disabled` | C | Flag |
| `forced_auto_retaliate` | C | Flag |
| `negates_lethargy` | C | Flag |

### 3g. Non-key formats (must be fixed before use)

- **Overdose entries are prose strings**, not dictionaries. Example: `PHARMA_SUBSTANCES` overdose `"effects": "Character randomly falls asleep (2-tick stun) every 6s for 60s. -80% Attack Speed."` A consumer cannot read this.
- **`REVIVAR`** uses a singular `effect` key (not `effects`) with a `clears` array: `["china_overdose", "tar_overdose", "china_buffs", "tar_buffs"]`. None of this is read. The `_buffs` entries do not match the `substance` values stored in records (for example `"china"`), so the clear rule is undefined.
- **`SYRUP` debuff** has `per_dose: true` and **no `duration_seconds`**. Its `remaining` becomes `0.0`, so it expires on the next tick. `per_dose` is also not read.

---

## 4. Where Effects SHOULD Be Read

These are the natural read points. Some are confirmed in code; others are not yet located and are marked that way.

| Area | Location | Keys it would read |
|---|---|---|
| Per-tick loop | `main.gd:5388-5397` (`update_active_substance_effects`) | `vitality_drain*`, `vitality_regen*`, `run_energy_regen`, `run_energy_drain`, `composure_drain`, withdrawal-like ticks |
| Movement | `main.gd:7480` (`update_movement(delta)`) | `movement_speed` |
| Damage intake | `main.gd:9436` (`damage_player(amount, attacker)`) | `guard_*`, `damage_reflection`, `evasion*` |
| Stamina cap and regen | `main.gd:30711` (`max_stamina_value`), `main.gd:5422` (`active_stamina_regen_multiplier`) | `run_energy_*` (pattern to copy for multipliers) |
| Attack resolution | **Not yet located** | `attack_speed`, `hands_*`, `crit_chance`, `muscle_*`, `special_attack_regen`, `unblockable_recoil`, `toxic_recoil` |
| Crowd control | **Not yet located** (where stun, root, and aggro are applied) | `cc_*`, `stun_resistance`, `forced_auto_retaliate`, `target_selection_disabled`, `npc_aggro_radius` |
| Healing | **Not yet located** (where food and healing items are applied) | `healing_effectiveness`, `instant_heal_effectiveness`, `food_heal_multiplier`, `healing_items_disabled`, `max_vitality_overheal` |
| UI | **Not yet located** | `minimap_disabled`, `ui_visibility` |

---

## 5. Other Notes for Whoever Builds the Consumer

- **Purity scaling hits everything numeric.** `main.gd:30985-30988` multiplies every float or int value. That includes absolute targets (for example a rooted value of `-1.0`) and any value that should not scale. Flags are not touched. Decide per key whether scaling applies.
- **Two dead or unused pieces:**
  - `calculate_tolerance_effects()` in `substance_packaging.gd:153-169` halves `effects` values. It appears to never be called from `main.gd`. Run a project-wide search before deleting it.
  - The tolerance multiplier in `main.gd:30975` is hardcoded to `1.0`.
- **Withdrawal uses a third naming family.** `addiction_system.gd:103-126` uses `movement_speed_penalty`, `composure_drain_per_minute`, and `vitality_drain_per_minute`. `main.gd:5414-5419` only checks two string tokens (`"health_drain"`, `"stamina_drain"`) from the withdrawal list.
- **Three naming families exist:** buff keys (`_boost`, `_penalty`, `_drain`), withdrawal keys (`_per_minute`, `_penalty`), and overdose prose strings. Pick one for the consumer and convert the others.
- **Record shape must stay stable.** `addiction_system.gd` reads `substance` from records. Do not rename or remove `substance` or `remaining` without updating those callers.
- **Multiplayer path:** `private_session.gd` carries `active_substance_effects` (around lines 2159 and 4391-4397) but has no buff or debuff logic. It will need the same consumer when online play is built.

---

## 6. Why This Is Hard

This is a **stat refactor**, not a small patch.

1. **Missing stats.** The player has only `health` and `stamina` (`main.gd:483-484`). The effect keys refer to stats that do not exist anywhere in the code: hands, muscle, guard, composure, and the vitality naming. Each one needs a stat, a base value, a way to be changed, and a way to be displayed.
2. **Attack logic not centralized (yet).** Attack speed, accuracy, crit, and reflection need an attack-resolution path. That path has not been identified in this research.
3. **Mixed value semantics.** Additive deltas (`-0.20`), multipliers (`1.20`), absolute targets (`-1.0` for rooted), and boolean flags share one key namespace.
4. **Stacking is undefined.** If two active records set the same key, the rule (sum, multiply, take the strongest) is not written down anywhere.
5. **Data problems.** Prose overdose strings, the `SYRUP` duration bug, and the `REVIVAR` clear list all need fixing first.
6. **Purity scaling** affects absolute and flag values unless it is made key-aware.

Result: adding one consumer key is small. Making the whole schema work means defining the stats first.

---

## 7. Implementation Guidance (For When You Are Ready)

Work in this order. Each step is small and can be tested alone.

### Step 0: Decide the rules (no code)
- [ ] Confirm the kind (additive, multiplicative, absolute, flag, per-tick, per-dose) for each key in Section 3.
- [ ] Decide stacking rules.
- [ ] Decide which keys are exempt from purity scaling.

### Step 1: Fix the data
- [ ] Give `SYRUP` debuff a `duration_seconds` value (currently missing, so it expires on the next tick).
- [ ] Replace the overdose prose string with a dictionary.
- [ ] Decide the `REVIVAR` clear rule and make `clears` match `substance` ids.

### Step 2: Add a read helper (copy the existing pattern)

The working pattern is `active_stamina_regen_multiplier()` at `main.gd:5422`. A helper for additive keys could look like this:

```gdscript
# Sums one additive effect key across all active buffs and debuffs.
# Returns default_value if no active record sets the key.
func get_effect_additive(key: String, default_value: float = 0.0) -> float:
	var total: = 0.0
	var found: = false
	for record in active_buffs + active_debuffs:
		var effects: Dictionary = record.get("effects", {})
		if effects.has(key):
			total += float(effects[key])
			found = true
	return total if found else default_value
```

Notes:
- Use `record.get("effects", {})` so records without `effects` do not crash.
- Multiplicative keys need a product instead of a sum.
- Flags need an "any record has it set" check.

### Step 3: Wire one key end to end
- [ ] Pick `movement_speed` (simplest). Apply it in `update_movement` (`main.gd:7470`).
- [ ] Test with a movement-slowing debuff, after Step 1 is done.
- [ ] Check that movement speed returns to normal when the debuff expires.

### Step 4: Wire the per-tick keys
- [ ] Add `vitality_drain`, `vitality_drain_per_tick`, `vitality_regen`, and `run_energy_*` to `update_active_substance_effects` (`main.gd:5381`).

### Step 5: Build the stats, then wire combat
- [ ] Create the missing stats (hands, muscle, guard, composure).
- [ ] Find attack resolution and healing code.
- [ ] Wire combat, healing, and crowd-control keys.

### Test checklist (each step)
- [ ] Effect is applied while the record is active.
- [ ] Effect is removed when `remaining` reaches 0.
- [ ] Two records with the same key stack the way the rule says.
- [ ] Purity scaling is correct for that key.
- [ ] Nothing crashes when `effects` is missing or empty.

---

## 8. Quick Reference

| Question | Answer |
|---|---|
| Are drug effects working in game? | **No.** Stored only. |
| Which code reads `effects`? | **None.** |
| What does work? | Timers, substance identity, receptor blockade, and the powder/food legacy system. |
| What is the working example to copy? | `active_powder_effect()` and `active_stamina_regen_multiplier()` in `main.gd:5348-5424`. |
| What is the first safe thing to change? | Step 1 in Section 7 (fix the data). It changes nothing in game. |

---

> **Effects are decorative. Don't promise they work without implementing the consumer.**
