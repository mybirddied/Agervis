# COMBO SYSTEM RULES

Read before editing: `DANGEROUS_COMBINATIONS`, `check_dangerous_combination()`, `get_combination_addiction_multiplier()` in `street_substances.gd`, and the combo block in `main.gd` (search `var combo_check`).

---

## PART 1: EXAMPLES (WRONG vs RIGHT)

### Example 1: Ingredient lists

```gdscript
# WRONG - display names. Combo NEVER fires. No error, no log.
"speedball": {
	"name": "Speedball",
	"ingredients": [["Tar", "China"], ["Crystal", "Powder"]],
}

# RIGHT - lowercase internal substance_ids
"speedball": {
	"name": "Speedball",
	"ingredients": [["tar", "china"], ["crystal", "powder", "rock"]],
}
```

Why it fails silently: `check_dangerous_combination()` uses `substance in category`. That is an exact, case-sensitive match. `"Tar" != "tar"`.

### Example 2: Return value

```gdscript
# WRONG - no "id". Caller has nothing to look up the multiplier with.
var result = combo.duplicate(true)
return result

# RIGHT - "id" is the dictionary key
var result = combo.duplicate(true)
result["id"] = combo_id
return result
```

### Example 3: Multiplier lookup

```gdscript
# WRONG - display name. Multiplier silently returns 1.0.
var combo_name: String = combo_check.get("name", "UNKNOWN")   # "Speedball"
var mult: float = StreetSubstances.get_combination_addiction_multiplier(combo_name)

# RIGHT - id. Matches the dictionary key "speedball".
var combo_id: String = combo_check.get("id", "")              # "speedball"
var mult: float = StreetSubstances.get_combination_addiction_multiplier(combo_id)
```

`combo_name` is fine for UI text (`notify(...)`). Use it for display only.

---

## PART 2: VOCABULARY

| Term | Example | Lives in | Use for |
|---|---|---|---|
| `substance_id` | `"tar"`, `"china"` | `"substance_id"` field on substance data; `ingredients`; `active_substance_ids` | Logic, matching |
| street name | `"Tar"`, `"China"` | `street_names` arrays | UI text only |
| `combo_id` | `"speedball"` | `DANGEROUS_COMBINATIONS` key; `result["id"]` | Logic, multiplier lookup |
| `combo_name` | `"Speedball"` | `DANGEROUS_COMBINATIONS[...]["name"]` | UI text only |

---

## PART 3: RULES

**RULE 1. Ingredients are lowercase substance_ids.**
Every string in `ingredients` must exactly match a `substance_id` value. No capitals. No spaces.

**RULE 2. Dictionary keys are lowercase snake_case combo_ids.**
Examples: `"speedball"`, `"cns_shutdown"`, `"psychosis"`.

**RULE 3. `check_dangerous_combination()` returns the combo dict WITH `"id"`.**
It must set `result["id"] = combo_id`. It returns `{}` when nothing matches. Callers check `.is_empty()`.

**RULE 4. The multiplier lookup takes a combo_id, never a combo_name.**
`get_combination_addiction_multiplier(combo_id)`. Never pass `"name"` text, never pass a display string.

**RULE 5. Always do the two-step lookup.**
1. `check_dangerous_combination(active_substance_ids)` gives you the dict with `"id"`.
2. `get_combination_addiction_multiplier(check["id"])` gives you the float.
Never guess an id from a display name.

**RULE 6. Logic never compares display text.**
If the code compares `"name"` strings, that is a bug.

---

## PART 4: THE TWO-STEP FLOW

```
active_substance_ids = ["tar", "china", ...]       (lowercase substance_ids)
        |
        v
check_dangerous_combination(ids)
        |   exact match against ingredient sets
        |   returns combo dict + "id": "speedball"   (or {} if no match)
        v
combo_check.get("id")  ->  "speedball"
        |
        v
get_combination_addiction_multiplier("speedball")  ->  3.0
        |                                             (1.0 if id not found)
        v
addiction_points += base_addiction * (3.0 - 1.0)
```

---

## PART 5: KNOWN TRAP (parameter name)

`get_combination_addiction_multiplier(combo_name: String)` is misnamed. The parameter receives an **id**. The current caller is correct, but the name invites the exact bug this doc prevents.

Optional fix (not applied yet): rename the parameter to `combo_id` and use a direct lookup:

```gdscript
static func get_combination_addiction_multiplier(combo_id: String) -> float:
	if combo_id.is_empty() or not DANGEROUS_COMBINATIONS.has(combo_id):
		return 1.0
	return float(DANGEROUS_COMBINATIONS[combo_id].get("addiction_multiplier", 1.0))
```

---

## PART 6: ADDING A NEW COMBO CHECKLIST

- [ ] Key is lowercase snake_case (RULE 2)
- [ ] `"name"` is display text only
- [ ] `ingredients` is an Array of exactly 2 Arrays of lowercase substance_ids (RULE 1)
- [ ] Every ingredient exists as a `"substance_id"` value somewhere in `scripts/`
- [ ] `"requires_both_categories": true` is set. Without it, the combo NEVER triggers, because the check has no other code path.
- [ ] `"addiction_multiplier"` is set. Missing means silent 1.0.
- [ ] Ran the validation checks in Part 7

Note: `check_dangerous_combination()` allocates `has_category = [false, false]`. Exactly 2 ingredient arrays only. A third array indexes past `has_category[2]` and errors at runtime.

---

## PART 7: VALIDATION (run after every combo edit)

Folder: `C:\Users\MyBir\Documents\Agervis 1\godot_game\Agervis_Local\scripts`

**Check 1. Display names in ingredients. Expect ZERO hits.**
File: `street_substances.gd`
Grep pattern: `"ingredients":.*"[^"]*[A-Z][^"]*"`
PowerShell: `Select-String -Path "...\street_substances.gd" -Pattern '"ingredients":.*"[^"]*[A-Z][^"]*"'`

**Check 2. Multiplier called with a name. Expect ZERO bad hits.**
Grep pattern: `get_combination_addiction_multiplier\(` with glob `*.gd` (skips this doc)
Expected: 1 definition line, plus call sites that pass `combo_id` or `check["id"]`.
BAD: any call that passes `combo_name` or a `"name"` lookup.
(The definition line matches too. Ignore it.)

**Check 3. Return dict sets "id". Expect exactly 1 hit.**
File: `street_substances.gd`
Grep pattern: `result\["id"\] = combo_id`

**Check 4. Caller reads "id". Expect exactly 1 hit.**
File: `main.gd`
Grep pattern: `combo_check\.get\("id"`

**Check 5. Each ingredient exists as a substance_id. Run once per unique ingredient.**
Grep pattern: `"substance_id": "tar"` (replace `tar` with the ingredient name)
Expect at least 1 hit across `scripts/`.

---

## PART 8: WHY THESE RULES EXIST

| Bug | Result |
|---|---|
| Display names in ingredient lists | Combo never fired (exact match failed) |
| Multiplier got `"Speedball"`, keys are `"speedball"` | Multiplier always 1.0, addiction never scaled |
| Return dict had no `"id"` | Caller had no key to look up with |

All three failed silently. No error was raised. Check the validation steps after every edit.
