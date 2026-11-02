# Substance System: Current Status

Last updated: 2026-10-26 (after context compaction recovery)

## Completed Fixes (This Session)

### Code Fixes
1. **pharmaceutical_content.gd:349** - Fixed `addictrall_xr` → `addictrall` ID mismatch
2. **main.gd:31081** - Renamed `substance_id_lower` → `street_key` (variable held display name, not ID)
3. **main.gd:30904, 30923** - Fixed withdrawal debuff `substance` fields to use `substance_internal_id`
4. **main.gd:31031** - Fixed combo addiction bonus to use scaled `addiction_gained`
5. **street_substances.gd:422** - Renamed `combo_name` → `combo_id` parameter
6. **main.gd:12444, 14140, 32186** - Fixed operator precedence (added parentheses)
7. **private_session.gd:2685, 4579** - Fixed operator precedence (added parentheses)
8. **opioid_overdose_system.gd:16-19, 37** - Fixed CNS overdose threshold (reduced risk by ~50%, fixed argument order)
9. **addiction_system.gd:48** - Deleted unused `add_addiction_points()` helper function
10. **pharmaceutical_content.gd:374** - Deleted unused `can_prescribe()` helper function
11. **addiction_system.gd:17-24** - Fixed stale severity table comments to match actual substance data
12. **street_substances.gd:135-137, 342** - Renamed "Special" → "Jet" (substance_id "special" → "jet")

### Documentation Updates (This Session)
8. **BUFF_EFFECT_RULES.md** - Updated all line references to current code locations
9. **OVERDOSE_KEY_RULES.md** - Updated line references for `instant_death` check and `trigger_overdose()`
10. **SUBSTANCE_SYSTEM_README.md** - Updated main.gd line numbers throughout
11. **ADDICTION_SYSTEM_RULES.md** - Marked issues 2-5 as RESOLVED
12. **SUBSTANCE_ID_RULES.md** - Updated "Special" → "Jet" in substance table

### Naming Cleanup (Previous Session)
- Renamed internal IDs: `ketalar` → `dissociaderm`, `sernyl` → `serenex`
- Renamed visual variable: `crack` → `fracture`
- **Blocklist scan result: ZERO HITS**

### Character Creation (Previous Session)
- Populated all `creation_*` arrays with full option sets (were single-element placeholders)
- Aligned `draw_character_figure()` parameters at line 15900 (added `expression` and `breast_style`)

## Questions for User

### 1. Non-Vector Graphics (OPEN DISCUSSION)
**Context:** "I am still on the fence about incorporating non-vector graphics so that it wouldn't be so hard to add things to the game."
**Status:** Not yet addressed

### 2. Server Fields (DESIGN DECISION)
**Context:** `boobs` and `expression` parameters added to character creation
**Question:** Should these be:
- Client-only display values (current)?
- Server-validated and stored fields?

## Remaining Technical Issues

### Low Priority / Latent Bugs
1. **main.gd:31043** - `.capitalize()` + case-sensitive `.contains()` - only breaks with multi-word substance IDs (none exist yet)
2. **Various files** - Brand-style display names in code/comments (naming rule violation, cosmetic)

## Documentation Status

### Up to Date
- `SUBSTANCE_SYSTEM_README.md` (verified 2026-10-26, main.gd line numbers updated)
- `SUBSTANCE_ID_RULES.md` (Known Open Issues section marked all 4 as FIXED)
- `OPERATOR_PRECEDENCE_RULES.md` (line 31043 marked as FIXED)
- `OPIOID_SYSTEM_RULES.md` (Open Question 2 removed, references updated)
- `SUBSTANCE_NAMING_SECURITY.md` (blocklist status updated to EXISTS)
- `BUFF_EFFECT_RULES.md` (all line references updated 2026-10-26)
- `OVERDOSE_KEY_RULES.md` (all line references updated 2026-10-26)
- `ADDICTION_SYSTEM_RULES.md` (issues 2-4 marked RESOLVED)
- `COMBO_SYSTEM_RULES.md` (no line-specific references, still current)
- `CONSUMABLE_FOOD_SYSTEM.md` (created this session, approved)
- `CONSUMABLE_VS_PHARMA_REFERENCE.md` (created this session, approved)

## System Health

### ✅ Clean
- Blocklist scan: zero whole-word hits
- ID consistency: all substance IDs use proper internal lowercase format
- Operator precedence: all known issues fixed
- Parameter alignment: character creation function calls aligned
- CNS overdose threshold: fixed and balanced
- Unused functions: removed
- Documentation: all 11 docs current with verified line numbers
- Substance naming: "Special" renamed to "Jet" (completed 2026-10-26)

### ⚠️ Needs Attention
- Brand-style display names in code/comments (cosmetic, low priority)

### 📋 Documentation Complete
- All 10 bug fixes documented in SUBSTANCE_SYSTEM_README.md Section 2
- All line numbers verified and updated (2026-10-26)
- All open questions resolved or documented as legacy

## Next Steps

**Immediate (completed):**
1. ✅ "Special" → "Jet" rename completed (substance_id, display key, street_names, combo references)

**Short term (can proceed without input):**
2. Decide on dead functions → delete or document as future-use
3. Update stale doc line numbers → refresh references

**Long term (design decisions):**
4. Non-vector graphics decision
5. Server field validation for character appearance
