# SUBSTANCE ID RULES

Read this before editing any substance, pharma, addiction, overdose, combo, or packaging code.

**TL;DR:** Logic compares **internal IDs** (lowercase, like `"tar"`). **Display names** (`"Tar"`, `"Blackout™"`) are for UI text only. Mixing them fails silently. There is no error and no log. The check just never matches.

Companion docs:
- `COMBO_SYSTEM_RULES.md` covers `combo_id` vs `combo_name`.
- `substance_id_validator.gd` has static checks you can call from tests.

---

## CRITICAL: Always Use Internal IDs

- Comparisons, lookup lists, logic dictionary keys, buff `"substance"` fields, addiction tracking: **internal ID**.
- `"Tar"`, `"Blackout™"`, `"Addictrall XR™"`: **display names**. UI text only.
- `"Tar" == "tar"` is **false** in GDScript. Case and symbols matter.

---

## What Are Internal IDs?

Every substance data row has a `"substance_id"` field. It is lowercase, with no spaces and no symbols. Always read it from the data row. Never type it as a literal when you have the row.

| Display name (table key) | Table | Internal ID |
|---|---|---|
| `"China"` | STREET_SUBSTANCES | `china` |
| `"Tar"` | STREET_SUBSTANCES | `tar` |
| `"Crystal"` | STREET_SUBSTANCES | `crystal` |
| `"Rock"` | STREET_SUBSTANCES | `rock` |
| `"Jet"` | STREET_SUBSTANCES | `jet` |
| `"Dust"` | STREET_SUBSTANCES | `dust` |
| `"Caps"` | STREET_SUBSTANCES | `caps` |
| `"Herb"` | STREET_SUBSTANCES | `herb` |
| `"Powder"` | STREET_SUBSTANCES | `powder` |
| `"Blackout™"` | PHARMA_SUBSTANCES | `blackout` |
| `"NeverDone™"` | PHARMA_SUBSTANCES | `neverdone` |
| `"Subscriptxone™"` | PHARMA_SUBSTANCES | `subscriptxone` |
| `"Addictrall XR™"` | PHARMA_SUBSTANCES | `addictrall` |
| `"Vassalium™"` | PHARMA_SUBSTANCES | `vassalium` |
| `"Rebillin™"` | PHARMA_SUBSTANCES | `rebillin` |
| `"Paper"` | PHARMA_SUBSTANCES | `paper` |
| `"A2"` | PHARMA_SUBSTANCES | `a2` |
| `"Dissociaderm™"` | PHARMA_SUBSTANCES | `dissociaderm` |
| `"Serenex™"` | PHARMA_SUBSTANCES | `serenex` |
| `"Syrup"` | `PharmaceuticalContent.SYRUP` (standalone) | `syrup` |
| `"Revivar™"` | `PharmaceuticalContent.REVIVAR` (standalone) | `revivar` |

**Note:** `Blackout™` is **not** a STREET_SUBSTANCES key. It is a PHARMA_SUBSTANCES key (`pharmaceutical_content.gd`).

### TRAP: The two `substance_data()` functions take different inputs

| Function | Takes | Example |
|---|---|---|
| `StreetSubstances.substance_data(id)` | **internal ID** | `substance_data("tar")` |
| `PharmaceuticalContent.substance_data(brand)` | **display key** | `substance_data("Blackout™")` |

Passing the wrong kind returns `{}`. Nothing warns you. `PharmaceuticalContent.substance_data` also special-cases `"Syrup"` and `"Revivar"`.

---

## Where Internal IDs MUST Be Used

- `"ingredients"` arrays in `StreetSubstances.DANGEROUS_COMBINATIONS` (`street_substances.gd`).
- `OpioidOverdoseSystem.OPIOID_SUBSTANCES` and `CNS_DEPRESSANTS` (`opioid_overdose_system.gd`).
- Arguments to `AddictionSystem.check_receptor_blockade`, `check_precipitated_withdrawal`, and `track_active_buffs` (`addiction_system.gd`).
- Keys of `addiction_points` and `addiction_last_use` (`main.gd`).
- Buff and debuff dictionaries, field `"substance"` (`main.gd`, around line 30991 and 31011).
- Argument to `StreetSubstances.substance_data(...)` and `StreetSubstances.package_item_id(...)`.
- Argument to `SubstancePackaging.get_possession_schedule(...)`.
- `PRESCRIPTION_SOURCES["substances"]`. **Target state is internal IDs.** It currently holds display names. See Known Open Issues.

---

## Where Display Names Are OK

- `notify(...)`, dialog text, shop and inventory labels, log text, debug prints.
- Table keys themselves: `STREET_SUBSTANCES` and `PHARMA_SUBSTANCES` are keyed by display name. Use these keys only to fetch data rows, not to compare or store.
- `"street_names"` arrays (player slang). Matching goes through `substance_by_street_name()`, which lowercases both sides.
- `"name"` in combos (UI text only).

**Rule of thumb:** If the value is used in `==`, `in`, a logic dictionary key, or saved into a buff, addiction record, or list, it must be an internal ID.

---

## Common Bug Patterns

### Pattern 1: Display name in a lookup list (silent)
```gdscript
# WRONG. Overdose check never sees "China".
const OPIOID_SUBSTANCES: Array = ["China", "Tar"]

# RIGHT
const OPIOID_SUBSTANCES: Array = ["china", "tar"]
```

### Pattern 2: Display name passed to an ID function (silent)
```gdscript
# WRONG. Returns false, so the blockade never fires.
AddictionSystem.check_receptor_blockade("Tar", active_substance_ids)

# RIGHT
AddictionSystem.check_receptor_blockade("tar", active_substance_ids)
```

### Pattern 3: Looking up in the wrong table (silent)
```gdscript
# WRONG. Blackout is not in STREET_SUBSTANCES. Returns {}.
StreetSubstances.substance_data("Blackout™")

# RIGHT
PharmaceuticalContent.substance_data("Blackout™")

# WRONG. Pharma table is keyed by brand name. Returns {}.
PharmaceuticalContent.substance_data("tar")
```

### Pattern 4: Non-substance strings in a substance list
Buffs use the `"substance"` field for things that are not substances, such as `"subscriptxone_withdrawal"` and `"opioid_withdrawal"` (`main.gd`, around lines 30903 and 30922). Those strings end up in `active_substance_ids`. Right now they do not cause harm, because no list contains them and exact matches never hit. The risk is that a future list or a `contains` check will misfire on them. Keep withdrawal states out of substance lists.

### Pattern 5: Misleading variable names
`substance_id_lower` (`main.gd`, around line 31087) holds a **display name**. A name that lies invites Pattern 1. Name variables for what they hold:
- `substance_id`: internal ID
- `street_key` or `brand_name`: display name
- `combo_id` or `combo_name`: see `COMBO_SYSTEM_RULES.md`

### Pattern 6: Using a variable before it is declared
GDScript needs a declaration above first use. See Known Open Issues, item 1.

### Pattern 7: Combo lookups by name
See `COMBO_SYSTEM_RULES.md`, RULE 4 and RULE 5. Use `combo_id`.

---

## The Fix Pattern

1. Find where the value comes from. If you have a display key, fetch the data row and read `"substance_id"`.
```gdscript
var data: Dictionary = PharmaceuticalContent.substance_data(brand_name)  # or StreetSubstances.substance_data(id)
var substance_id: String = String(data.get("substance_id", ""))
```
2. Store, compare, and pass only `substance_id`.
3. Pass display text only to UI calls.
4. Name variables for what they hold.
5. Run the Quick Check below and the validator (`substance_id_validator.gd`).

---

## Quick Check

Run from the project `scripts` folder in PowerShell. **Expect ZERO hits.** Any hit is a display name where an internal ID belongs, or a raw variable stored in a buff.

```powershell
Select-String -Path "*.gd" -Pattern '"substance":\s*substance_id\b|OPIOID_SUBSTANCES.*"[A-Z]|CNS_DEPRESSANTS.*"[A-Z]|"ingredients":.*"[A-Z]'
```

Validator (for a test script):
```gdscript
var errors: Array[String] = SubstanceIdValidator.validate_all()
assert(errors.is_empty(), "\n".join(PackedStringArray(errors)))
```

---

## Known Open Issues

Remove each item when it is fixed. Last updated 2026-10-26.

1. **`pharmaceutical_content.gd` `PRESCRIPTION_SOURCES`, line 349.** FIXED - now uses internal ID `addictrall` instead of `addictrall_xr`. Line 355 is correct (uses `revivar` internal ID).
2. **`main.gd` buff `"substance"` field, lines 30904 and 30923.** FIXED - now stores `substance_internal_id` instead of withdrawal state strings.
3. **`main.gd` `breakdown_substance_package`, line 31081.** FIXED - variable renamed from `substance_id_lower` to `street_key`.
4. **`main.gd` `consume_substance`, variable declaration order.** FIXED - `substance_internal_id` (30869), `active_substance_ids` (30870), and `blockade_check` (30874) now declared in correct order before use.

**All previously identified issues have been resolved.**

---

## Related

- Combo rules: `COMBO_SYSTEM_RULES.md`
- Validator: `substance_id_validator.gd` (`class_name SubstanceIdValidator`)
