class_name OpioidOverdoseSystem
extends RefCounted

# Shared overdose meter for all opioids: China, Tar, Syrup, NeverDone™
# Any combination of these substances contributes to the same overdose threshold

# Opioid substance IDs that share the overdose meter
const OPIOID_SUBSTANCES: Array = ["china", "tar", "syrup", "neverdone"]

# CNS depressants that multiply overdose risk when combined with opioids
const CNS_DEPRESSANTS: Array = ["blackout", "vassalium"]

# Overdose threshold (total opioid doses before triggering overdose)
const OVERDOSE_THRESHOLD: int = 2

# CNS combination multiplier range: 50-100% increased overdose risk
# Translates to: threshold reduced by 35-50%
const CNS_COMBO_THRESHOLD_MULTIPLIER_MIN: float = 0.65  # 1 / 1.54 (154% total = 54% increase)
const CNS_COMBO_THRESHOLD_MULTIPLIER_MAX: float = 0.50  # 1 / 2.00 (200% total = 100% increase)

# Subscriptxone precipitated withdrawal decay
const SUBSCRIPTXONE_WITHDRAWAL_DURATION: float = 600.0  # 10 minutes
const SUBSCRIPTXONE_WITHDRAWAL_PEAK_MULTIPLIER: float = 3.0  # 300% severity at peak

static func is_opioid(substance_id: String) -> bool:
	return substance_id in OPIOID_SUBSTANCES

static func is_cns_depressant(substance_id: String) -> bool:
	return substance_id in CNS_DEPRESSANTS

# Calculate current overdose threshold based on active CNS depressants
static func calculate_overdose_threshold(has_active_cns_depressant: bool, rng: RandomNumberGenerator) -> float:
	if not has_active_cns_depressant:
		return float(OVERDOSE_THRESHOLD)

	# Random multiplier within 50-100% risk increase range
	var multiplier: = rng.randf_range(CNS_COMBO_THRESHOLD_MULTIPLIER_MAX, CNS_COMBO_THRESHOLD_MULTIPLIER_MIN)
	return float(OVERDOSE_THRESHOLD) * multiplier

# Check if opioid overdose triggered
static func check_overdose(opioid_dose_count: int, active_substances: Array, rng: RandomNumberGenerator) -> bool:
	# Check if any CNS depressant is active
	var has_cns: = false
	for sub_id in active_substances:
		if is_cns_depressant(sub_id):
			has_cns = true
			break

	var threshold: = calculate_overdose_threshold(has_cns, rng)
	return float(opioid_dose_count) >= threshold

# Calculate precipitated withdrawal severity from Subscriptxone
# Returns multiplier that decays from peak (3.0) to baseline (1.0) over duration
static func calculate_subscriptxone_withdrawal_multiplier(time_since_consumption: float) -> float:
	if time_since_consumption >= SUBSCRIPTXONE_WITHDRAWAL_DURATION:
		return 1.0  # Fully worn off

	# Exponential decay from peak to baseline
	var progress: = time_since_consumption / SUBSCRIPTXONE_WITHDRAWAL_DURATION
	var decay: = 1.0 - pow(progress, 2.0)  # Quadratic decay (starts harsh, eases off)

	return 1.0 + (SUBSCRIPTXONE_WITHDRAWAL_PEAK_MULTIPLIER - 1.0) * decay

# Check if Subscriptxone triggers precipitated withdrawal
# Returns withdrawal multiplier if triggered, 0.0 if not triggered
static func check_subscriptxone_interaction(
	subscriptxone_active: bool,
	time_since_subscriptxone: float,
	consuming_opioid: bool,
	opioid_active: bool,
	time_since_opioid: float
) -> float:
	# Subscriptxone consumed while opioid is active
	if subscriptxone_active and opioid_active:
		return calculate_subscriptxone_withdrawal_multiplier(time_since_subscriptxone)

	# Opioid consumed while Subscriptxone is active
	if consuming_opioid and subscriptxone_active:
		return calculate_subscriptxone_withdrawal_multiplier(time_since_subscriptxone)

	return 0.0  # No interaction

# Apply precipitated withdrawal effects
static func apply_precipitated_withdrawal(multiplier: float) -> Dictionary:
	if multiplier <= 0.0:
		return {}

	return {
		"name": "Precipitated Withdrawal",
		"severity_multiplier": multiplier,
		"effects": {
			"vitality_drain": 0.30 * multiplier,
			"run_energy_drain": 0.50 * multiplier,
			"composure_drain": 0.40 * multiplier,
		},
		"duration_remaining": SUBSCRIPTXONE_WITHDRAWAL_DURATION * (1.0 - ((multiplier - 1.0) / (SUBSCRIPTXONE_WITHDRAWAL_PEAK_MULTIPLIER - 1.0)))
	}
