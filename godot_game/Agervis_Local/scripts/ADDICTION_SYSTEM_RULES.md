# Addiction System Rules

> **TL;DR**
> 1. Substances store a **severity string**: `"addiction_level": "Extreme"`.
> 2. Convert it to **points** with `AddictionSystem.ADDICTION_POINTS_PER_USE`. Never treat the string as a number.
> 3. Store points under the **internal id** (`substance_internal_id`, lowercase). Never use the display name.
> 4. Combo bonus = `base * (multiplier - 1)`, added on top of the base points.

**Source of truth:** the substance data files (`street_substances.gd`, `pharmaceutical_content.gd`).
Comments elsewhere can be stale. See Known Issues.

---

## 1. Two-Step Conversion (String to Points)

```
substance_data["addiction_level"]   -->   ADDICTION_POINTS_PER_USE[...]   -->   int points
      "Extreme" (String)                         25 (int)
```

**Step 1:** read the string.
**Step 2:** look the string up in the table.

```gdscript
var addiction_level_str: String = substance_data.get("addiction_level", "None")
var base_addiction: = AddictionSystem.ADDICTION_POINTS_PER_USE.get(addiction_level_str, 0)
```

### Why this needs care

- `.get(key, default)` fails **silently**.
- A typo like `"Very high"` returns `0` points. No error, no warning.
- A missing `addiction_level` field also returns `0` points, because the default is `"None"`.

### Recommended guard

```gdscript
assert(AddictionSystem.ADDICTION_POINTS_PER_USE.has(addiction_level_str),
	"Unknown addiction_level: %s" % addiction_level_str)
```

---

## 2. Valid `addiction_level` Strings

Exact match, case-sensitive. Copy these exactly.

| String        | Points | Verified examples (from data files)                     |
|---------------|--------|---------------------------------------------------------|
| `"Extreme"`   | 25     | China, Tar                                              |
| `"Very High"` | 20     | Crystal, Rock, Dust                                     |
| `"High"`      | 15     | Blackout™, A2                                           |
| `"Moderate"`  | 10     | Jet, Powder, NeverDone™, Subscriptxone™, Addictrall XR™, Vassalium™, Serenex™, Syrup |
| `"Low"`       | 5      | Caps, Rebillin™, Paper, Dissociaderm™                        |
| `"Minimal"`   | 2      | Herb                                                    |
| `"None"`      | 0      | Revivar™. Also the fallback when the field is missing.    |

Table source: `addiction_system.gd` lines 17-25 (`ADDICTION_POINTS_PER_USE`).

---

## 3. Internal ID vs Display Name

**Rule:** any per-substance dictionary uses `substance_internal_id` as the key.

| Value                                  | Example              | Valid as key? |
|----------------------------------------|----------------------|---------------|
| Internal id (`substance_data["substance_id"]`) | `"china"`   | **YES**       |
| Dictionary key in `STREET_SUBSTANCES` | `"China"`            | NO            |
| Display / item name                    | `"China (single)"`   | NO            |

```gdscript
var substance_internal_id: String = substance_data.get("substance_id", "")

addiction_points[substance_internal_id] = ...   # CORRECT
addiction_points[substance_id] = ...            # WRONG: "China" != "china"
```

**Watch out:** `consume_substance()` has two similar variables:
- `substance_id` holds the dictionary key (`"China"`).
- `substance_internal_id` holds the lowercase id (`"china"`).

Always use `substance_internal_id` for saved per-substance state.

---

## 4. Combo Addiction Multiplier

### Pattern

```gdscript
var combo_check: Dictionary = StreetSubstances.check_dangerous_combination(active_substance_ids)
if not combo_check.is_empty():
	var combo_id: String = combo_check.get("id", "")
	var combo_mult: float = StreetSubstances.get_combination_addiction_multiplier(combo_id)
	addiction_points[substance_internal_id] = int(addiction_points.get(substance_internal_id, 0)) \
		+ int(base_addiction * (combo_mult - 1.0))
```

### The math

- The base points were already added once (Step 1).
- The combo adds only the **extra**: `base * (mult - 1)`.
- Total for that dose: `base * mult`.

**Example:** China (Extreme = 25) inside Speedball (multiplier 3.0)
`25 + 25 * (3.0 - 1.0)` = **75 points**

### Rules

- **Pass the combo id** (`"speedball"`), not the display name (`"Speedball"`).
  - `get_combination_addiction_multiplier()` compares against id keys.
  - Passing a name returns `1.0` silently, so the bonus is lost.
- Multiplier `1.0` means no bonus.
- Combo multipliers are defined on `DANGEROUS_COMBINATIONS` in `street_substances.gd` (lines 305, 332, 354).

---

## 5. Naming Collision: `addiction_level`

The same name means two different things:

| Context                | Name                           | Type     | Values        |
|------------------------|--------------------------------|----------|---------------|
| Substance data         | `addiction_level` (dict field) | `String` | `"Extreme"`...|
| Player state           | `addiction_level` (variable)   | `int`    | `0` to `4`    |

**Rule:** name variables by what they hold.

```gdscript
var addiction_level_str: String = substance_data.get("addiction_level", "None")  # severity
var addiction_level: int = AddictionSystem.get_addiction_level(points)           # player level 0-4
```

---

## 6. Grep Commands to Find Violations

Run from `Agervis_Local\`. Each check says what to expect.

### Git Bash / WSL

```bash
# A. Old broken read. Expect NO results.
grep -rn --include="*.gd" 'get("addiction_points"' scripts/

# B. Raw severity reads. Each hit must feed ADDICTION_POINTS_PER_USE.
grep -rn --include="*.gd" 'get("addiction_level"' scripts/

# C. Every lookup into the table. Expect 3 hits:
#    addiction_system.gd:17 (definition), :49 (helper), main.gd:31019 (fixed call site)
grep -rn --include="*.gd" 'ADDICTION_POINTS_PER_USE' scripts/

# D. Hardcoded point additions that bypass the table. Expect NO results.
grep -rnE --include="*.gd" 'addiction_points.*\+ *[0-9]' scripts/

# E. Every write to addiction_points. Key must be substance_internal_id.
grep -rn --include="*.gd" 'addiction_points\[' scripts/

# F. Combo multiplier calls. Argument must be the combo id, not a name.
grep -rn --include="*.gd" 'get_combination_addiction_multiplier(' scripts/

# G. Severity values outside the valid set (typos). Expect NO results.
grep -rnE --include="*.gd" '"addiction_level":' scripts/ | grep -vE '"(Extreme|Very High|High|Moderate|Low|Minimal|None)"'
```

### PowerShell (Windows)

```powershell
# G. Severity typos. Expect NO results.
Select-String -Path scripts\*.gd -Pattern '"addiction_level":' |
  Where-Object { $_.Line -notmatch '"(Extreme|Very High|High|Moderate|Low|Minimal|None)"' }

# E. Writes to addiction_points. Check every key.
Select-String -Path scripts\*.gd -Pattern 'addiction_points\['
```

---

## 7. Known Issues (Found While Writing This)

Fix these when you touch the related code.

1. **RESOLVED.** Stale table comments in `addiction_system.gd` lines 17-25 have been corrected to match actual substance data.

2. **RESOLVED.** `main.gd:30869` declares `substance_internal_id` before line 30937 uses it in `check_receptor_blockade()`. Declaration order is now correct.

3. **RESOLVED.** Tolerance scaling is now consistent: both base and combo bonus use `addiction_gained` (tolerance-scaled value) at `main.gd:31078` and `31094`.

4. **RESOLVED.** Parameter renamed from `combo_name` to `combo_id` in `street_substances.gd:422`.

5. **RESOLVED.** `add_addiction_points()` unused helper function deleted from `addiction_system.gd:48`.

---

## 8. Checklist Before Committing Addiction Code

- [ ] Severity is read as a `String` and converted through `ADDICTION_POINTS_PER_USE`.
- [ ] The lookup has an `assert` or an intentional fallback.
- [ ] Per-substance dictionary keys are `substance_internal_id` (lowercase).
- [ ] Combo calls pass the combo **id**, and the bonus is `base * (mult - 1)`.
- [ ] `addiction_level_str` (String) and `addiction_level` (int) are not mixed up.
- [ ] Grep check **G** returns no results.
