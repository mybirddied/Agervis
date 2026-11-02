# Substance System: Start Here

Index for the substance system. Read this first, then open the one rule doc that matches your task.

Line numbers here were checked on 2026-10-26. They drift as code changes, so search for the function name if a line looks wrong.

---

## 1. What This System Is

A simulation of street substances and pharmaceuticals. Using a substance does five things:

1. Creates a **buff or debuff record** (timer plus `substance` ID).
2. Adds **addiction points** for that substance.
3. Counts **opioid doses** toward one shared overdose meter.
4. Can trigger an **overdose** (7-second emergency, cancellable with a reversal item).
5. Checks **dangerous combinations** with other active substances.

Entry point: `consume_substance()` in `main.gd` (lines 30831-31102).

Data lives in four tables:

| Table | File |
|---|---|
| Street substances | `street_substances.gd` |
| Pharmaceuticals | `pharmaceutical_content.gd` |
| Addiction levels and points | `addiction_system.gd` |
| Overdose threshold and withdrawal curve | `opioid_overdose_system.gd` |

---

## 2. Recently Fixed Bugs

### Changes confirmed in the code (session 2026-10-26)

- [x] **Operator precedence at `main.gd:31043`.** Now reads `A and (B or C)`, parentheses added.
- [x] **Dead `has_cns` variable removed from `main.gd`.** Only exists in `opioid_overdose_system.gd` where used.
- [x] **`addictrall_xr` → `addictrall` ID mismatch fixed.** `pharmaceutical_content.gd:349` now uses correct registered ID.
- [x] **`substance_id_lower` renamed to `street_key` at `main.gd:31081`.** Variable name now accurate (holds display name, not ID).
- [x] **`combo_name` parameter renamed to `combo_id` in `street_substances.gd:422`.** Parameter name matches what it receives.
- [x] **Withdrawal debuff `substance` fields fixed at `main.gd:30904, 30923`.** Now correctly use `substance_internal_id`.
- [x] **Combo addiction bonus scaling fixed at `main.gd:31094`.** Now uses scaled `addiction_gained` instead of unscaled `base_addiction`.
- [x] **Operator precedence fixes.** Five unparenthesized and/or mixes corrected: `main.gd:12444, 14140, 32186` and `private_session.gd:2685, 4579`.
- [x] **CNS overdose threshold fixed at `opioid_overdose_system.gd:16-19, 37`.** Reduced risk by ~50% (now 0.50-0.65 multiplier), fixed randf_range argument order.
- [x] **Unused helper functions deleted.** Removed `add_addiction_points()` from `addiction_system.gd:48` and `can_prescribe()` from `pharmaceutical_content.gd:374`.

### Current naming scan (see Section 6)

The official whole-word scan (Section 6, check 5) returns **zero files**. A looser substring scan finds **83 lines across 9 text files**: `main.gd` 45, `private_session.gd` 26, `save_migration.gd` 5, `project.godot` 2, and 1 line each in `build9_systems.gd`, `education_questions.gd`, `moth_content.gd`, `export_presets.cfg`, and `global_script_class_cache.cfg` (a generated file that Godot rewrites). This README is now clean: the one match it had was an ordinary English word near the word "Buff", reworded in this pass. Binary matches in `project.binary` and the PNGs under `assets\release-1` are excluded, because the scan skips binary files. Substring hits are informational only: most sit inside longer words or identifiers, so triage each one before renaming anything.

---

## 3. Prevention Docs

Read the doc that matches your task before editing.

| Doc | Read before editing |
|---|---|
| [SUBSTANCE_ID_RULES.md](SUBSTANCE_ID_RULES.md) | Any substance, pharma, addiction, overdose, combo, or packaging code. Internal IDs vs display names. |
| [ADDICTION_SYSTEM_RULES.md](ADDICTION_SYSTEM_RULES.md) | Addiction points, levels, thresholds, combo addiction bonus. |
| [COMBO_SYSTEM_RULES.md](COMBO_SYSTEM_RULES.md) | `DANGEROUS_COMBINATIONS`, `combo_id` vs `combo_name`. |
| [OPIOID_SYSTEM_RULES.md](OPIOID_SYSTEM_RULES.md) | Shared opioid meter, CNS depressants, opioid decay timer. |
| [BUFF_EFFECT_RULES.md](BUFF_EFFECT_RULES.md) | Buff or debuff `effects`. Read this before promising any stat change. |
| [OVERDOSE_KEY_RULES.md](OVERDOSE_KEY_RULES.md) | Overdose dictionary keys. Only `instant_death` is read. |
| [OPERATOR_PRECEDENCE_RULES.md](OPERATOR_PRECEDENCE_RULES.md) | Any condition that mixes `and` and `or`. |
| [SUBSTANCE_NAMING_SECURITY.md](SUBSTANCE_NAMING_SECURITY.md) | Naming anything new. Real drug, brand, and slang names are banned. |

---

## 4. Quick Start for AI Assistants

1. **Read this file, then the matching doc in Section 3.**
2. **Use internal IDs.** Logic compares lowercase `substance_id` values. Display names are for UI text only. A mismatch fails silently.
3. **Read IDs from the data row.** Call `substance_data.get("substance_id", "")`. Do not retype the ID.
4. **Parenthesize any condition that mixes `and` and `or`.**
5. **Every timer must be written, read, and reset.** A timer that is set but never read is a silent bug.
6. **Overdose data is inert except `instant_death`.** No code reads `trigger`, `instant`, or the `clears` array. The only read is `instant_death` at `main.gd:31021`.
7. **Buff and debuff `effects` do not change stats.** The dictionary is copied with `duplicate(true)` at `main.gd:30978` and `:30998`, and purity scaling rewrites its numbers, but nothing in `scripts/` reads a key back out. The only reader is inside `calculate_tolerance_effects()` (`substance_packaging.gd:153`), and nothing calls that function. Withdrawal drains are a separate path and do work: they change health directly at `main.gd:30901` and `:30921`.
8. **Do not name new substances without asking the user.** Do not use real-world drug, brand, or slang names, even inside comments.
9. **Run the checks in Section 6** before finishing.
10. **Update a doc** when you fix one of the items in Section 7.

---

## 5. Main Files

### `main.gd` (1,670,691 bytes, which Windows shows as about 1.59 MB)

| What | Lines |
|---|---|
| Per-character state declarations (`overdose_timer`, `overdose_source`, `addiction_points`, `addiction_last_use`, `opioid_dose_count`, `opioid_dose_timer`, `subscriptxone_active_time`, `active_buffs`, `active_debuffs`) | 520-528 |
| Opioid meter decay (10-minute window) | 5392-5397 |
| `trigger_overdose()` | 30751 |
| `consume_substance()` | 30831-31102 |
| `substance_internal_id` declared | 30869 |
| `active_substance_ids` declared, then filled from `active_buffs` only | 30870, then 30871-30873 |
| Receptor blockade check | 30874-30877 |
| Opioid dose tracking and overdose check | 30994-31003 |
| Buff and debuff record creation | 31047-31072 |
| Addiction points added | 31078-31079 |
| Overdose trigger (`instant_death`) | 31082-31085 |
| Combo check and addiction bonus | 31088-31094 |
| `attempt_autonomous_substance_use()` | 31103 |
| `breakdown_substance_package()` | 31116 |
| `press_pill()` | 31169 |

### `street_substances.gd`

| What | Line |
|---|---|
| `STREET_SUBSTANCES` table | 10 |
| `DANGEROUS_COMBINATIONS` table | 289 |
| `substance_data()` (takes an internal ID) | 366 |
| `dose_item_id()` (builds `"%s (0.1g dose)"` via `.capitalize()`) | 394 |
| `check_dangerous_combination()` (returns a dict that includes `id`) | 400 |
| `get_combination_addiction_multiplier()` (parameter is misnamed `combo_name`, it receives an ID) | 422 |

### `pharmaceutical_content.gd`

| What | Line |
|---|---|
| `PHARMA_SUBSTANCES` table (keyed by display name, rows carry `substance_id`) | 5 (rows 6-291) |
| Standalone `SYRUP` const (oral opioid, registered on its own) | 292 |
| Standalone `REVIVAR` const (overdose reversal item, registered on its own) | 322 |
| `PRESCRIPTION_SOURCES` (holds internal IDs, one entry broken, see Section 7) | 346 |
| `substance_data()` (takes a display key, not an ID) | 364 |
| `can_prescribe()` (no callers in `scripts/`) | 374 |

### `addiction_system.gd`

| What | Line |
|---|---|
| `ADDICTION_POINTS_PER_USE` | 17 |
| `ADDICTION_LEVEL_THRESHOLDS` | 28 |
| `add_addiction_points()` (no callers in `scripts/`) | 48 |
| `check_precipitated_withdrawal()` | 169 |
| `check_receptor_blockade()` | 184 |

### `opioid_overdose_system.gd`

| What | Line |
|---|---|
| `OPIOID_SUBSTANCES` | 8 |
| `CNS_DEPRESSANTS` | 11 |
| `OVERDOSE_THRESHOLD` | 14 |
| CNS combo multiplier constants (names are inverted against their values, see Section 7) | 16-19 |
| `calculate_overdose_threshold()` | 32 |
| `check_overdose()` | 41 |
| Withdrawal curve (quadratic, peak 3.0, 600 seconds) | 54-62 |

---

## 6. Checks (PowerShell)

Run these from `scripts\`. They are checks, not fixes.

**1. Uppercase in the opioid and CNS lists, and in combo ingredients.** Expect zero hits. `Select-String` is case-insensitive by default, so `-CaseSensitive` is what makes this check mean anything. The `^[^#]*` prefix skips comment lines, which legitimately contain quoted display names.
```powershell
Select-String -Path "*.gd" -Pattern '^[^#]*(OPIOID_SUBSTANCES|CNS_DEPRESSANTS|"ingredients").*"[A-Z]' -CaseSensitive
```

**2. Every buff or debuff `substance` field.** Expect exactly four lines: 30904, 30923, 31048, 31068. Two hold withdrawal-state strings rather than IDs (30904, 30923); see Section 7. Note that the pattern in `SUBSTANCE_ID_RULES.md` (`"substance": substance_id`) misses the real code, which assigns a variable named `substance_internal_id`.
```powershell
Select-String -Path "main.gd" -Pattern '"substance":\s*\S+' -CaseSensitive
```

**3. Declaration order inside `consume_substance()`.** Expect three lines in ascending order: 30869 (`var substance_internal_id`), 30870 (`var active_substance_ids`), 30874 (`var blockade_check`). Ascending is what proves each local is declared before the line that uses it.
```powershell
Select-String -Path "main.gd" -Pattern 'var substance_internal_id|var active_substance_ids|var blockade_check' -CaseSensitive
```

**4. Mixed `and` / `or` on one line.** Two patterns, because either order is a trap. Current counts: 24 lines with `and` before `or`, 32 lines with `or` before `and`. Parenthesized mixes are fine and are the goal. Do not trust a paren-count filter to triage them, because a line can contain `foo.is_empty()` and still have no grouping at all. Verified unparenthesized mixes outside `consume_substance()`: `main.gd` 12444, 14140, 32186, and `private_session.gd` 2685, 4579. The other hits have not been read yet.
```powershell
Select-String -Path "*.gd" -Pattern '^\s*(if|elif|while|return)\b.*\band\b.*\bor\b'
Select-String -Path "*.gd" -Pattern '^\s*(if|elif|while|return)\b.*\bor\b.*\band\b'
```

**5. Naming scan.** The blocklist lives outside the project folder at `C:\Users\MyBir\Documents\Agervis_substance_blocklist.txt` (exists, 30 terms). The command is in `SUBSTANCE_NAMING_SECURITY.md`.

Current result: the whole-word scan returns **zero files**. A looser substring scan finds 83 lines across 9 text files, listed in Section 2. `rg` skips binary files, so matches inside `project.binary` and the PNGs under `assets\release-1` do not appear; do not treat that as proof those binaries are clean. Substring hits are informational, and most sit inside longer words or identifiers.
```powershell
rg -i -w -f "C:\Users\MyBir\Documents\Agervis_substance_blocklist.txt" "C:\Users\MyBir\Documents\Agervis 1\godot_game\Agervis_Local"
```

---

## 7. Known Open Issues

Checked against the code on 2026-10-26. Remove an item when it is fixed.

| # | Where | Problem | Doc |
|---|---|---|---|
| 1 | `street_substances.gd:135` | The substance currently named with the word "Special" must be renamed. **Do not pick a new name without asking the user.** | SUBSTANCE_NAMING_SECURITY.md |
| 2 | Across the folder | Brand-style display names appear in code and data (content tables, item lists, comments). They break the naming rule. Fix with the rename process. | SUBSTANCE_NAMING_SECURITY.md |
| 3 | `main.gd:31081` | `dose_item_id()` builds item names with `.capitalize()`, which lowercases everything after the first letter of each word, and `String.contains()` is case-sensitive. Any future `substance_id` with two or more words would never match. Single-word IDs today, so this is latent. Needs a runtime check, not a code read. | SUBSTANCE_ID_RULES.md |

### Stale docs (update when next touched)

- `OPERATOR_PRECEDENCE_RULES.md` calls the bug unfixed at `main.gd:31049` (lines 32 and 52). It is fixed, and it now sits at 31043. **FIXED 2026-10-26.**
- `SUBSTANCE_ID_RULES.md` Quick Check pattern at 154 misses `substance_internal_id` (see Section 6, check 2) and expects zero `"substance":` hits while four exist. Its item 1 (use-before-declaration at 30868-30880) no longer applies, since 30869-30874 now declare in order. Its items 2 and 3 have the wrong line numbers (see Section 7). Its "nothing has been fixed yet" line at 167 is out of date. Its item 3 at 171 says `PRESCRIPTION_SOURCES` holds display names; the lists hold lowercase IDs. **FIXED 2026-10-26.**
- `OPIOID_SYSTEM_RULES.md` Open Question 2 (dead `has_cns`) no longer applies to `main.gd`. Line 195 says `SUBSTANCE_ID_RULES.md` does not exist; it does. **FIXED 2026-10-26.**
- `SUBSTANCE_NAMING_SECURITY.md` says at line 72 that the blocklist file is "NOT CREATED YET". It exists, with 30 terms. **FIXED 2026-10-26.**
- `BUFF_EFFECT_RULES.md` line ranges predate the current code; treat them as approximate and search by function name. **FIXED 2026-10-26.**
- `OVERDOSE_KEY_RULES.md` line numbers updated. **FIXED 2026-10-26.**
- `SUBSTANCE_SYSTEM_README.md` main.gd line numbers updated. **FIXED 2026-10-26.**

---

## 8. Naming Rule (Short Version)

- Allowed words: tar, china, dust, rock, syrup, crystal, powder, herb, paper, caps.
- An allowed word can still break the rule when paired with another word to form a real drug name.
- Use the 3-second check in `SUBSTANCE_NAMING_SECURITY.md` before saving any new name.
- When a rename is needed, change all four places in the same pass: the `substance_id`, the display key, `street_names`, and combo references. Then search for the old name and the old ID, and expect zero hits.
- The allowed list above is a copy of the list in `SUBSTANCE_NAMING_SECURITY.md` (lines 20-29). If you change one, change both.
- One rename is already decided and waiting on a name: see Section 7, item 8.
