# Substance System Implementation Summary

## Files Created
1. **pharmaceutical_content.gd** - Pharmaceutical substances with blister/pouch packaging
2. **street_substances.gd** - Gram-based street substances
3. **substance_packaging.gd** - Pill pressing, package breakdown, tolerance mechanics
4. **addiction_system.gd** - Addiction tracking, withdrawal, autonomous consumption

## Files Modified
1. **build7_content.gd** - Updated ITEM_DATA with all substance items
2. **main.gd** - Integrated substance mechanics into game systems
3. **item_use_rules.gd** - Added substance recognition

## Core Systems Implemented

### 1. Prescription System (main.gd:11137-11147)
- **Pillmill**: Gives Addictrall XR™ (30-pack) + Blackout™ (30-pack)
- **Clinic**: Gives Subscriptxone™ (7-pack) + NeverDone™ (7-pack)
- Cooldowns: 150s (pillmill), 120s (clinic)

### 2. Substance Consumption (main.gd:30930-31021)
- `consume_substance()` - Handles all substance types
- Checks receptor blockade and precipitated withdrawal
- Applies buffs/debuffs with tolerance modifiers
- Tracks addiction points and last use time
- Detects dangerous combinations
- Triggers overdoses for lethal substances

### 3. Package Management (main.gd:31023-31067)
- `breakdown_substance_package()` - Breaks packs into single doses
- `press_pill()` - Chemistry skill check for authenticity verification
- Supports 7/30/90-packs for pharma, 1g for street substances

### 4. Inventory Actions (main.gd:31172-31195)
- Package items show breakdown/press options
- Single doses show consume option
- Dialog choices route to appropriate handlers

### 5. Addiction Tracking (main.gd:650-656)
- `addiction_points: Dictionary` - Tracks points per substance
- `addiction_last_use: Dictionary` - Tracks last use timestamp
- `active_buffs: Array[Dictionary]` - Active substance buffs
- `active_debuffs: Array[Dictionary]` - Active substance debuffs

### 6. Update Loop Integration (main.gd:5509-5541)
- Buffs/debuffs tick down over time
- Autonomous consumption checks for addiction level 2+
- Withdrawal effects applied based on time since last use
- Health/stamina drain for severe withdrawal

### 7. Overdose System (main.gd:30774)
- Updated to recognize Narcan (single) as reversal agent
- Existing trigger_overdose() function used for lethal substances

## Substance Categories

### Pharmaceuticals (7/30/90-pack + singles)
- Blackout™ (bars)
- NeverDone™ (gel-caps)
- Subscriptxone™ (pouches)
- Addictrall XR™ (capsules)
- Vassalium™ (caplets)
- Rebillin™ (tabs)
- Paper (10-pack, blotter strips)
- Syrup (pint/oz)
- Narcan (10-pack, spray pods)

### Street Substances (1g + 0.1g doses)
- China (fentanyl analog)
- Tar (heroin)
- Crystal (methamphetamine)
- Rock (crack cocaine)
- Special (ketamine)
- Dust (PCP)
- Caps (psilocybin)
- Herb (cannabis)

## Mechanics Implemented

### Pill Pressing
- Requires Chemistry skill level 3
- Returns authenticity tier (1-5)
- Clinic prescriptions: tier 4-5
- Pill mill: tier 1-4 (weighted low)
- Street: tier 1-3

### Tolerance
- Redosing within timeframe:
  - 50% buff effectiveness
  - 150% debuff duration
  - 2x addiction points

### Withdrawal Severity
- Extreme: 12+ hours since last use
- Very High: 8-12 hours
- High: 4-8 hours
- Moderate: 2-4 hours

### Dangerous Combinations
- Speedball (stimulant + opioid): 2x addiction
- CNS Shutdown (depressant + opioid): 3x addiction
- Psychosis (dissociative + stimulant): 2x addiction

### Receptor Blockade
- NeverDone™/Subscriptxone™ blocks Tar/China effects
- No effect when receptor is blocked

### Precipitated Withdrawal
- Subscriptxone™ or Narcan + recent Tar/China use
- Causes severe immediate withdrawal
- 40 health damage applied instantly

## NC Possession Limits (substance_packaging.gd)
- Schedule II: 4 doses
- Schedule III/IV: 100 doses
- Schedule I: 0 doses (any amount illegal)

## Takehome Restrictions
- Max 7-day supply stackable (TAKEHOME_MAX_STACK = 7)
- Prevents stockpiling clinic doses

## Integration Points

### Dialog Handler (main.gd:12813-12842)
- "breakdown_package" - Routes to breakdown_substance_package()
- "press_pill" - Routes to press_pill()
- "consume_substance" - Routes to consume_substance()
- "inspect_substance" - Shows item description

### Preloads (main.gd:7-13)
- PharmaceuticalContent
- StreetSubstances
- SubstancePackaging
- AddictionSystem

## Testing Checklist
- [ ] Prescription filling works (pillmill + clinic)
- [ ] Package breakdown creates single doses
- [ ] Pill pressing shows authenticity tiers
- [ ] Substance consumption applies buffs/debuffs
- [ ] Addiction points accumulate correctly
- [ ] Tolerance reduces redose effectiveness
- [ ] Autonomous consumption triggers at addiction level 2+
- [ ] Withdrawal effects apply over time
- [ ] Receptor blockade prevents effects
- [ ] Precipitated withdrawal damages health
- [ ] Dangerous combinations detected
- [ ] Overdose system triggers for lethal doses
- [ ] Narcan reverses overdoses

## Known Issues
None identified yet - requires in-game testing

## Next Steps
1. Test prescription system
2. Test substance consumption flow
3. Test addiction mechanics
4. Balance buff/debuff durations
5. Adjust addiction point values
6. Fine-tune withdrawal timing
