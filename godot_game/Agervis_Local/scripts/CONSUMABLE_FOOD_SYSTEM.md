# Consumable Food System

Non-pharmaceutical food and drink items with HoT/DoT (Heal over Time / Damage over Time) mechanics.

## Design Philosophy

- **Lower power than pharmaceuticals** - weaker effects, longer durations
- **No addiction** - safe alternatives without dependency risk
- **HoT/DoT instead of instant** - effects apply gradually over time
- **Trade-offs built in** - most have debuffs or consequences
- **No Revivar alternative** - intentionally excluded per user requirement

## Effect Types

### 1. Buff Over Time (`buff_over_time`)
Applies stat bonuses consistently over the duration, ticking at intervals.
- Example: Energy Drink gives +10% hands accuracy over 240s
- Effects remain constant per tick

### 2. Heal Over Time (`heal_over_time`)
Restores vitality gradually in ticks.
- Example: Bone Broth heals 5% vitality per tick over 180s (15 ticks = 75% total)
- Prevents instant full heals, creates strategic timing

### 3. Buff Ramp (`buff_ramp`)
Effects start weak and grow stronger over time.
- Example: Protein Shake reaches +20% guard scaling at the end of 60s
- Linear or quadratic ramp types available
- Rewards planning ahead

### 4. Vitality Floor (`vitality_floor`)
Prevents vitality from dropping below a threshold.
- Example: Fermented Drink keeps vitality above 20% for 300s
- Safety net, not a heal
- Can still take damage, just won't fall below the floor

### 5. Damage Over Time (`dot`)
Small vitality drain per tick.
- Example: Spicy Noodles drain 1% vitality per tick over 120s
- Trade-off for powerful buffs
- Total drain is manageable (typically 10-15% total)

## Item Categories

### Anti-Anxiety (Blackout alternatives)
- **Calming Tea**: +15% CC resistance, composure regen over 120s
  - Debuff: -10% movement speed for 60s after
  - Use case: preparing for stressful situations

### Vitality Sustain (Opioid alternatives)
- **Bone Broth**: 5% vitality per tick over 180s (75% total)
  - Debuff: Can't eat for 120s (food block)
  - Use case: out-of-combat recovery
  
- **Ginger Stew**: 4% vitality per tick over 150s (60% total)
  - Debuff: Can't eat for 100s (food block)
  - Use case: moderate healing, shorter cooldown

- **Fermented Drink**: Vitality floor 20% for 300s
  - Debuff: -15% run energy regen
  - Use case: safety net during risky activity

- **Probiotic Blend**: Vitality floor 15% for 240s
  - Debuff: -12% run energy regen
  - Use case: lighter safety net, shorter duration

### Stimulants (Addictrall/Rebillin alternatives)
- **Energy Drink**: +10% hands accuracy, +5% attack speed over 240s
  - Debuff: -15% guard scaling for 90s after (jitters)
  - Use case: combat accuracy boost

- **Strong Coffee**: +8% hands rating, +12% run energy regen over 180s
  - Debuff: -20% run energy regen for 60s after (crash)
  - Use case: general performance, shorter duration

- **Trail Mix**: +15% run energy regen, +5% vitality regen over 240s
  - Debuff: -20% run energy regen for 60s after (sugar crash)
  - Use case: sustained energy, portable

- **High-Calorie Bar**: +18% run energy regen, +5% movement speed over 180s
  - Debuff: -25% run energy regen for 45s after (sugar crash)
  - Use case: quick energy, movement bonus

### Muscle Support (Vassalium alternatives)
- **Protein Shake**: Ramps to +20% guard scaling over 60s
  - Debuff: -5% movement speed for 60s (digesting)
  - Use case: pre-combat preparation

- **Recovery Meal**: Ramps to +25% guard, +10% muscle over 90s
  - Debuff: -8% movement speed for 90s (digesting)
  - Use case: maximum defensive boost, requires planning

### Perception (Paper alternatives)
- **Mushroom Soup**: +15% evasion vs ballistic, +5% composure regen over 180s
  - Debuff: +10% melee vulnerability for 180s (sensitive)
  - Use case: ranged combat situations

### Pain Management (Dissociative alternatives)
- **Spicy Noodles**: +20% CC reduction, +15% pain tolerance over 300s
  - DoT: 1% vitality drain per tick over 120s (12% total)
  - Use case: CC-heavy encounters, long duration

- **Capsaicin Dish**: +18% CC reduction, 10% composure floor over 240s
  - DoT: 0.8% vitality drain per tick over 100s (8% total)
  - Use case: lighter CC protection, less drain

## Comparison: Pharmaceuticals vs Consumables

| Aspect | Pharmaceuticals | Consumables |
|---|---|---|
| Power | High (15-30% bonuses) | Moderate (10-20% bonuses) |
| Duration | Short-Medium (90-720s) | Medium-Long (120-300s) |
| Effect timing | Instant full power | Gradual over time or ramping |
| Addiction | Yes (Low to High) | None |
| Overdose | Yes, dangerous | None |
| Availability | Prescription or street | Purchasable anywhere |
| Stacking | Dangerous combos | Safe to mix categories |
| Debuffs | Often severe | Mild to moderate |

## Integration with Main System

### Consumption Entry Point
Add to `main.gd` `consume_substance()` or create separate `consume_food()`:

```gdscript
func consume_food(item_name: String) -> void:
	var food_data: = ConsumableFood.get_consumable_data(item_name)
	if food_data.is_empty():
		notify("THAT CANNOT BE CONSUMED", DANGER, 2.0)
		return
	
	var hot_type: = food_data.get("hot_dot_type", "")
	
	# Check food block (Full Stomach debuff)
	if has_food_block():
		notify("TOO FULL TO EAT", ACCENT, 2.0)
		return
	
	# Apply buff/HoT
	if food_data.has("buff"):
		apply_food_buff(food_data["buff"], hot_type)
	elif food_data.has("hot"):
		apply_food_hot(food_data["hot"])
	
	# Apply debuff
	if food_data.has("debuff"):
		apply_food_debuff(food_data["debuff"])
	
	# Apply DoT if present
	if food_data.has("dot"):
		apply_food_dot(food_data["dot"])
	
	notify("CONSUMED %s" % item_name.to_upper(), ACCENT, 2.0)
```

### Tick System
Requires timer tracking similar to substance buffs:

```gdscript
# Per-character state
var active_food_buffs: Array = []  # {name, effects, remaining, tick_timer, tick_interval, ...}
var active_food_hots: Array = []   # {name, vitality_per_tick, remaining, tick_timer, ...}
var active_food_dots: Array = []   # {name, vitality_drain, remaining, tick_timer, ...}

# In _process(delta)
func process_food_effects(delta: float) -> void:
	# Process HoTs
	for hot in active_food_hots:
		hot.tick_timer -= delta
		if hot.tick_timer <= 0.0:
			# Apply heal tick
			health = minf(100.0, health + hot.vitality_per_tick * 100.0)
			hot.tick_timer = hot.tick_interval
		
		hot.remaining -= delta
		if hot.remaining <= 0.0:
			active_food_hots.erase(hot)
	
	# Process DoTs
	for dot in active_food_dots:
		dot.tick_timer -= delta
		if dot.tick_timer <= 0.0:
			# Apply damage tick
			health = maxf(0.0, health - dot.vitality_drain_per_tick * 100.0)
			dot.tick_timer = dot.tick_interval
		
		dot.remaining -= delta
		if dot.remaining <= 0.0:
			active_food_dots.erase(dot)
	
	# Process buff ramps
	for buff in active_food_buffs:
		if buff.get("ramp_type", "") != "":
			var elapsed: = buff.total_duration - buff.remaining
			var multiplier: = ConsumableFood.calculate_ramp_multiplier(
				elapsed, buff.total_duration, buff.ramp_type
			)
			# Update active effect strength based on multiplier
		
		buff.remaining -= delta
		if buff.remaining <= 0.0:
			# Trigger upon_expiration debuff if exists
			active_food_buffs.erase(buff)
```

### Vitality Floor Implementation
```gdscript
func apply_damage(amount: float) -> void:
	var floor_value: = get_active_vitality_floor()
	health = maxf(floor_value * 100.0, health - amount)

func get_active_vitality_floor() -> float:
	var highest_floor: = 0.0
	for buff in active_food_buffs:
		if buff.has("vitality_floor"):
			highest_floor = maxf(highest_floor, buff.vitality_floor)
	return highest_floor
```

## Stack Sizes

- **Beverages**: 10 (Energy Drink, Coffee, Tea, Fermented drinks)
- **Meals**: 5 (Broth, Stew, Soup, Noodles, Recovery Meal)
- **Snacks**: 20 (Trail Mix, Calorie Bar)

## Vendor Locations

Suggested placement:
- **Restaurant**: Meals (Broth, Stew, Noodles, Recovery Meal)
- **Convenience Store**: Beverages (Energy Drink, Coffee), Snacks (Trail Mix, Bars)
- **Health Food Shop**: Specialty items (Fermented Drink, Probiotic, Mushroom Soup, Protein Shake)
- **Street Vendors**: Basic items (Tea, Coffee, Trail Mix)

## Pricing (Suggested)

- Snacks: $5-$8
- Beverages: $8-$15
- Meals: $15-$25
- Specialty: $20-$35

All significantly cheaper than pharmaceuticals ($50-$200 per dose).

## Design Notes

1. **No Revivar alternative** - User specified not to create overdose reversal consumable
2. **Food block mechanic** - Prevents spam-eating, creates strategic timing
3. **Ramp effects** - Reward planning, punish panic consumption
4. **Mild DoTs** - Trade-off for power, not punishing (10-15% total over duration)
5. **Longer durations** - Compensate for lower power with longer uptime
6. **No stacking penalties** - Unlike pharmas, safe to mix (but food block still applies)

## Future Extensions

- **Cooking system**: Craft consumables from ingredients
- **Quality tiers**: Basic/Good/Excellent versions with scaling effects
- **Recipe discovery**: Unlock better versions through gameplay
- **Temperature effects**: Hot items provide warmth bonus, cold items provide focus
- **Freshness decay**: Items degrade over time if not consumed
