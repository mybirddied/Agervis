# Overdose Key Rules

Read this before adding or renaming any `"overdose"` key.

## Valid keys

| Key | Type | Does code read it? | Notes |
|---|---|---|---|
| `instant_death` | bool | **YES** (`main.gd:31084`) | The only key that changes behavior. |
| `trigger` | String | No | Documentation only. |
| `effects` | String (prose) | No | Documentation only. Every overdose `effects` seen so far is prose, not a dict. |
| `name` | String | No | Display label only. |

Any other key does nothing. It will not error, so it fails silently.

## Warning: `instant` is a buff key, not an overdose key

Buffs use `"instant": true` (`street_substances.gd:18` China, `:51` Tar).
Overdose uses `"instant_death": true`. This mix-up caused the China bug.

## What `instant_death` actually does

It does not kill instantly. `consume_substance()` calls `trigger_overdose()` (`main.gd:31085`), which:
1. Starts a 7 second timer (`main.gd:30755`).
2. Cancels if ready Revivar™ is used in that window (`main.gd:30762-30768`).
3. Otherwise deals 100 damage (`main.gd:30773`).

## Examples

China (`street_substances.gd:35`):
```gdscript
"overdose": {
	"name": "Respiratory Failure",
	"trigger": "no_revivar_before_timer",
	"instant_death": true,
}
```

Tar (`street_substances.gd:65`). No `instant_death`, so no overdose fires from `consume_substance()`:
```gdscript
"overdose": {
	"name": "The Deep Nod",
	"trigger": "second_dose_before_expiry",
	"effects": "Hard stun 12s. -10% Max Vitality asphyxiation damage every 2s."
}
```

Blackout (`pharmaceutical_content.gd:29`):
```gdscript
"overdose": {
	"name": "Fugue State",
	"trigger": "second_dose_before_expiry",
	"effects": "Inverts movement inputs. Character autonomously drops 1-3 random unequipped items over 15s."
}
```

## Find all overdose definitions

PowerShell:
```powershell
Select-String -Path "C:\Users\MyBir\Documents\Agervis 1\godot_game\Agervis_Local\scripts\*.gd" -Pattern '"overdose"|instant_death'
```

ripgrep:
```
rg -n "\"overdose\"|instant_death" "C:\Users\MyBir\Documents\Agervis 1\godot_game\Agervis_Local\scripts"
```

## Rule: adding a new key

A new key in the data does nothing until code reads it. To add one:
1. Add it to the substance data.
2. Add the read in `consume_substance()` (`main.gd:31082-31085`).
3. Add a row to the table above.
4. Re-run the grep and check every substance still matches.

Line numbers are current as of 2026-10-26. If they drift, search by the key names instead.
