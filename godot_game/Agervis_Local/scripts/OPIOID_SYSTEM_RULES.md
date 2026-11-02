# OPIOID SYSTEM RULES

Read before editing: any opioid, overdose, CNS, dose-tracking, or `opioid_dose_*` code.

---

## PART 1: THE 5 RULES (TL;DR)

1. **One shared meter.** China, Tar, Syrup, and NeverDone all count toward the same overdose meter.
2. **The meter resets after 10 minutes with no opioid dose.** Someone must READ `opioid_dose_timer` every frame, or the meter never resets.
3. **CNS depressants are Blackout and Vassalium.** When one is active, the overdose threshold drops.
4. **IDs are lowercase internal `substance_id` values.** Never compare display names like `"Blackout™"`. Comparisons fail silently.
5. **Every timer you write must be read and reset somewhere.** A timer that is set but never read is a silent bug.

---

## PART 2: WHERE THINGS LIVE

| What | File | Search for |
|---|---|---|
| Opioid list, CNS list, threshold, check | `opioid_overdose_system.gd` | `OPIOID_SUBSTANCES`, `CNS_DEPRESSANTS`, `check_overdose` |
| Meter variables | `main.gd` | `var opioid_dose_timer` |
| Meter decay (10 min reset) | `main.gd`, in `_process` | `Decay opioid overdose meter` |
| Dose counting and overdose trigger | `main.gd`, in `consume_substance` | `Track opioid doses for shared overdose meter` |
| Active ID list for CNS check | `main.gd`, in `consume_substance` | `var active_substance_ids` |
| Buff stores the internal ID | `main.gd`, in `consume_substance` | `active_buffs.append({` |

---

## PART 3: THE SHARED METER

All four opioids add to ONE counter (`opioid_dose_count`).

| Internal ID | Defined in |
|---|---|
| `china` | `street_substances.gd` |
| `tar` | `street_substances.gd` |
| `syrup` | `pharmaceutical_content.gd` (`SYRUP`) |
| `neverdone` | `pharmaceutical_content.gd` (`PHARMA_SUBSTANCES`) |

Mixing counts. China then Tar = 2 doses = overdose (with no CNS active, inside the window).

---

## PART 4: OVERDOSE THRESHOLD

`OVERDOSE_THRESHOLD = 2`. Overdose fires when `opioid_dose_count >= threshold`.

| Situation | Threshold | What happens |
|---|---|---|
| No CNS depressant active | 2.0 | Dose #2 inside the window = overdose |
| Blackout or Vassalium active | 2 x random(0.20 to 0.43) = 0.40 to 0.86 | Dose #1 = overdose (see Open Question 1) |

After an overdose, `opioid_dose_count` resets to 0.

---

## PART 5: TIMER LIFECYCLE

```
Opioid consumed  (consume_substance)
    opioid_dose_count += 1
    opioid_dose_timer  = elapsed         <- timer STARTS (and refreshes on every dose)
        |
        v
Every frame  (_process)
    if count > 0 and timer > 0.0:
        if elapsed - timer >= 600:       <- 10 min since LAST opioid dose
            count = 0
            timer = 0.0                  <- meter RESETS
        |
        v
Next opioid consumed  -> back to top
```

**Key point:** the 10-minute window counts from the LAST opioid dose, not the first. Doses 9 minutes apart never reset the meter.

### Timeline examples (no CNS active)

| Time | Event | Count | Result |
|---|---|---|---|
| 0:00 | China | 1 | OK. Timer = 0:00 |
| 5:00 | Tar | 2 | OVERDOSE. Count resets to 0 |
| 6:00 | China | 1 | OK. Timer = 6:00 |
| 16:00 | (nothing taken) | 0 | Decay fires (10 min since 6:00). Meter cleared |
| 16:30 | Tar | 1 | OK. Timer = 16:30 |
| 25:00 | China | 2 | OVERDOSE (8.5 min since last dose, window still open) |

---

## PART 6: WHERE THE TIMER MUST BE READ

| Step | Must happen | Where |
|---|---|---|
| Write | `opioid_dose_timer = elapsed` on every opioid dose | `consume_substance` |
| Read | Compare `elapsed - opioid_dose_timer` every frame | `_process`, Decay block |
| Reset | Set count and timer back to 0 | Decay block, and after overdose (count) |

**The bug this prevents:** the timer was written but never read. The meter never decayed. The second opioid dose ALWAYS overdosed, even days later.

**Rule for any new time-based state:** write it, read it, reset it. If you add a timestamp, add the read in `_process` in the same edit.

**Persistence:** no other `.gd` file references `opioid_dose_*`, so the meter is not saved by GDScript code. Restarting the game should clear it. The save format itself was not checked.

---

## PART 7: CNS MULTIPLIER (ID RULE)

The CNS check needs LOWERCASE INTERNAL IDs.

1. `active_substance_ids` is built from `active_buffs[i]["substance"]`.
2. That field holds `substance_internal_id`, which is lowercase.
3. `check_overdose()` does `sub_id in CNS_DEPRESSANTS`. This is exact and case-sensitive.
4. If a display name gets in, the check returns false. Nothing errors. No log is written.

### WRONG vs RIGHT

```gdscript
# WRONG - display name. CNS multiplier NEVER fires. No error.
const CNS_DEPRESSANTS: Array = ["Blackout™", "Vassalium"]
active_substance_ids.append("Blackout™")

# RIGHT - lowercase internal substance_id
const CNS_DEPRESSANTS: Array = ["blackout", "vassalium"]
active_substance_ids.append(substance_internal_id)   # "blackout"
```

**Timing:** the CNS check runs only when an OPIOID is consumed, and it looks at buffs active BEFORE that dose.
- Blackout, then China: multiplier applies.
- China, then Blackout: the Blackout does not trigger an overdose check (it is not an opioid). The multiplier applies to the next opioid dose only if Blackout's buff is still active.

---

## PART 8: INTERNAL ID RULE

The full rule belongs in `SUBSTANCE_ID_RULES.md`. **That file was NOT found in the repo when this doc was written.** The points below are what the code does today, observed while writing this doc. They are NOT copied from that file. Confirm them against the real file once it is found.

- Logic uses the `substance_id` field from the data tables (`"substance_id": "..."`), never display names.
- Every current ID is lowercase letters and digits (e.g. `a2`). No ™, no spaces.
- Comparisons are exact `==` / `in` checks, so case and symbols must match exactly.

| Internal ID | Used for |
|---|---|
| `china`, `tar` | Opioid meter, street substances |
| `syrup`, `neverdone` | Opioid meter |
| `blackout`, `vassalium` | CNS depressants |
| `subscriptxone` | Precipitated withdrawal (not in the meter) |

---

## PART 9: VALIDATION PATTERN

### Static check (add to `opioid_overdose_system.gd`, call from a debug build)

```gdscript
static func validate_ids() -> bool:
	var ok: = true
	for id in OPIOID_SUBSTANCES + CNS_DEPRESSANTS:
		if id != id.to_lower():
			push_error("OPIOID ID NOT LOWERCASE: '%s'" % id)
			ok = false
	return ok
```

### Runtime check (inside `consume_substance`, after `substance_internal_id` is set)

```gdscript
assert(substance_internal_id == substance_internal_id.to_lower(), "substance_id must be lowercase internal ID")
```

### Manual test checklist

- [ ] China, wait 10+ minutes of game time, then Tar. Expect: NO overdose.
- [ ] China, then Tar immediately. Expect: OVERDOSE.
- [ ] Blackout, then China. Expect: OVERDOSE (CNS multiplier).
- [ ] Add a temporary print of `active_substance_ids` during a Blackout dose. Expect: `["blackout"]`, not `["Blackout™"]`.

---

## PART 10: CHANGE CHECKLIST

Before finishing any opioid edit:

- [ ] New opioid? Add its lowercase ID to `OPIOID_SUBSTANCES`.
- [ ] New CNS depressant? Add its lowercase ID to `CNS_DEPRESSANTS`.
- [ ] New time-based field? Write it, read it in `_process`, reset it.
- [ ] Every ID in a comparison comes from `substance_id`, not a display name.
- [ ] Ran the manual test checklist above.

---

## OPEN QUESTIONS (do not fix silently)

1. **RESOLVED.** CNS threshold fixed at `opioid_overdose_system.gd:16-19, 37`. New values: 0.50-0.65 multiplier (threshold 1.0-1.3), allows first dose but makes second dose risky with CNS active.
2. **RESOLVED.** `SUBSTANCE_ID_RULES.md` now exists and is up to date.
3. **Zero-timer guard.** `opioid_dose_timer > 0.0` treats 0.0 as "no dose." Only matters if a dose happens at exactly `elapsed == 0.0`. Low risk.
