# >>> SECURITY CONSTRAINT <<<

**READ THIS BEFORE NAMING ANYTHING.**

---

## THE RULE

**No real-world drug names. No drug brand names. No drug slang.**
**Not in code, comments, strings, IDs, keys, variable names, or file names. Anywhere in `Agervis_Local/`.**

Why: these files run through several AI models. If a model sees real drug names, it may think this project is about making drugs. That slows everything down.

Use only the in-game names in the ALLOWED list below.

---

## ALLOWED (in-game names)

- tar
- china
- dust
- rock
- syrup
- crystal
- powder
- herb
- paper
- caps

**Warning: an allowed word can still break the rule.** An allowed word is safe on its own. It is NOT safe when paired with another word that forms a real drug name. Example: one allowed word plus a color word. When in doubt, use a single allowed word or a new made-up name.

---

## PROHIBITED (never use)

Any of these, in any capitalization, anywhere in this folder:

1. **Real-world drug names** - generic names, chemical names, anything a pharmacy or police report would use.
2. **Brand names** - any drug or medication brand, including names marked with a trademark symbol.
3. **Street slang** - any slang for any drug. This includes ordinary English words when they are used as drug slang.
4. **Short codes** - single letters or abbreviations used as drug slang.
5. **Anything with an obvious real-world origin** - if a reader would think "that's a drug," it is prohibited.

**The full term list is NOT in this folder on purpose.** It lives outside the project (see the Scan section).

---

## RENAME PROCESS

When a name breaks the rule, rename it in ALL FOUR places in the same pass:

1. `substance_id` - the internal ID
2. Display key - the name the player sees
3. `street_names` array - the alias list
4. Combo references - any recipe, combo, addiction, or item rule that points at the old ID

After renaming:

- Search for the OLD name and the OLD ID. The result must be zero hits.
- Search for the NEW name. It should appear in all four places.
- Run the scan (below).

---

## SCAN FOR VIOLATIONS

The term list is kept OUTSIDE this folder, one term per line, at:

`C:\Users\MyBir\Documents\Agervis_substance_blocklist.txt`

**Status: EXISTS (30 terms).** Current scan result: zero whole-word hits (clean).

Scan file contents (whole words, case-insensitive):

```
rg -i -w -f "C:\Users\MyBir\Documents\Agervis_substance_blocklist.txt" "C:\Users\MyBir\Documents\Agervis 1\godot_game\Agervis_Local"
```

Scan file names:

```
Get-ChildItem -Recurse -Name "C:\Users\MyBir\Documents\Agervis 1\godot_game\Agervis_Local" | rg -i -w -f "C:\Users\MyBir\Documents\Agervis_substance_blocklist.txt"
```

**Zero output = clean.** Any output = a violation. Fix it using the Rename Process.

---

## SPECIAL - PENDING

The substance currently named with the word "Special" must be renamed.

- Status: the user knows. Waiting on the user's creative direction.
- Do NOT pick a new name on your own. Ask the user first.

---

## BEFORE YOU SAVE ANY NEW NAME (3-second check)

1. Is it on the ALLOWED list, or made only of allowed words that do not form a drug name?
2. Would a stranger think it is a drug? If yes, STOP and pick another name.
3. Does the scan come back clean?

---

**This file contains no prohibited names. Keep it that way.**
