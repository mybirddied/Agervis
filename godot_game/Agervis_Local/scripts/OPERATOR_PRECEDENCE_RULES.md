# Operator Precedence Rules (GDScript)

Last checked: 2026-10-26. Line numbers may shift as code changes.

## The One Rule

> **Always use parentheses when mixing `and` and `or` in the same condition.**

No exceptions. Parentheses cost nothing and make the code say what you mean.

## Why

- `and` binds tighter than `or`.
- So `A and B or C` means `(A and B) or C`.
- It does NOT mean `A and (B or C)`.
- `&&` and `||` work the same way as `and` and `or`.

## Side by Side

Same tokens, different meaning. Write the parens to match your intent.

```gdscript
# You mean: A and (B or C)
if A and (B or C):        # RIGHT
if A and B or C:          # WRONG - reads as (A and B) or C

# You mean: (A and B) or C
if (A and B) or C:        # RIGHT
if A and B or C:          # Works only by accident - always add the parens
```

## The Real Bug (main.gd:31043)

Intent: the carried item must match the substance, whether it is a `(single)` or a `(0.1g dose)`.

```gdscript
# WRONG: the dose branch skips the substance check
if item_name.contains(substance_id) and item_name.contains("(single)") or item_name.contains("(0.1g dose)"):

# RIGHT: the substance check covers both branches
if item_name.contains(substance_id) and (item_name.contains("(single)") or item_name.contains("(0.1g dose)")):
```

**Trap:** adding parens around only the first two terms does NOT fix it.

```gdscript
if (item_name.contains(substance_id) and item_name.contains("(single)")) or item_name.contains("(0.1g dose)"):
```

This is the same logic as the WRONG line. The parens change how it reads, not what it does.

**Status (2026-10-26):** main.gd:31043 is now FIXED with correct parentheses.

## Grep: Find Suspicious Lines

Run from the project root. Ripgrep does not support lookahead, so these patterns avoid it.

Lines (`if`, `elif`, `while`, `return`) that contain both `and` and `or`:

```
rg -n "^\s*(if|elif|while|return)\b.*(\band\b.*\bor\b|\bor\b.*\band\b)" --glob "*.gd"
```

Mixed `&&` and `||`:

```
rg -n "(&&.*\|\|)|(\|\|.*&&)" --glob "*.gd"
```

(The Grep tool accepts the same regex.)

Triage each hit:

1. Already parenthesized around the and/or mix? Fine. Skip it.
2. No parens? Decide what you meant, then add parens to match.
3. Not sure what you meant? Ask before changing it.

## Examples From This Codebase

### 1. main.gd:14140: correct, but add parens

```gdscript
if score > best_score or score == best_score and path_name == tutorial_headstart:
```

Reads as `score > best_score or (score == best_score and path_name == tutorial_headstart)`. That is the intent: higher score wins, and on a tie the headstart path wins. Add parens so the next reader doesn't have to work it out:

```gdscript
if score > best_score or (score == best_score and path_name == tutorial_headstart):
```

### 2. private_session.gd:4579: correct, but add parens

```gdscript
if home.is_empty() or String(home.get("world_id", "")) != server_world_id or owner_account == account_id and owner_slot == resident_slot:
```

Reads as `A or B or (owner_account == account_id and owner_slot == resident_slot)`. The grouping is right, but add parens around the owner check.

### 3. main.gd:12444: intent unclear, check it

```gdscript
if vendor_id.is_empty() or effect != "item" and effect not in ["contingency", "food", "water", "bandage"]:
```

Reads as `vendor_id.is_empty() or (effect != "item" and effect not in [...])`. If you meant `(vendor_id.is_empty() or effect != "item") and effect not in [...]`, this is a bug. Decide the intent, then add parens.

### Good model: main.gd:11849

```gdscript
if cooking_challenge_type == "temperature" or (cooking_challenge_type in ["timing", "flip"] and cooking_timer > cooking_step_duration * 1.5):
```

Mixed `and`/`or` with explicit parens. Copy this style.

## Checklist Before Committing a Condition

- [ ] Mixes `and` and `or`? Then add parens.
- [ ] Do the parens match what I meant?
- [ ] Did I test the wrong-substance case (a different substance's dose item)?
