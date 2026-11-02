class_name AgervisMothContent
extends RefCounted

const DEALER_ID: = "moth"
const DEALER_NAME: = "Moth"
const MOTH_POINT: = Vector2(6030.0, 115.0)
const INTERACTION_RADIUS: = 280.0
const HOSTILITY_SECONDS: = 10.0 * 60.0
const CHASE_SPEED: = 150.0
const RETURN_SPEED: = CHASE_SPEED * 0.5
const PIKE_REACTION_RADIUS: = 240.0

const RUN_TIERS: = {
	"dime": {
		"display": "Dime Bag", "item_id": "sealed_dime_bag", "item_display": "Sealed Dime Bag", 
		"trust_required": 0, "trust_gain": 3, "pay_min_cents": 2000, "pay_max_cents": 3500, 
		"stealth_xp": 120, "enterprise_xp": 90, "active_seconds": 300.0, 
	}, 
	"quarter": {
		"display": "Quarter Bag", "item_id": "sealed_quarter_bag", "item_display": "Sealed Quarter Bag", 
		"trust_required": 10, "trust_gain": 5, "pay_min_cents": 4500, "pay_max_cents": 7000, 
		"stealth_xp": 180, "enterprise_xp": 140, "active_seconds": 360.0, 
	}, 
}

const ROUTES: = [
	{"id": "tee_bus", "recipient_actor_id": "bus_client_tee", "recipient_name": "Tee", "destination_label": "the bus stop", "area": "street", "room_id": "", "point": Vector2(10060.0, 205.0)}, 
	{"id": "nell_fire_escape", "recipient_actor_id": "moth_customer_nell", "recipient_name": "Nell", "destination_label": "the Mercy fire-escape landing", "area": "rooftop", "room_id": "", "point": Vector2(1120.0, 205.0)}, 
	{"id": "mack_gated_lot", "recipient_actor_id": "moth_customer_mack", "recipient_name": "Mack", "destination_label": "the gated mechanic lot", "area": "rear", "room_id": "", "point": Vector2(6200.0, 215.0)}, 
	{"id": "nia_laundry_rear", "recipient_actor_id": "moth_customer_nia", "recipient_name": "Nia", "destination_label": "the laundromat rear entrance", "area": "rear", "room_id": "", "point": Vector2(4540.0, 215.0)}, 
	{"id": "cal_store_rear", "recipient_actor_id": "moth_customer_cal", "recipient_name": "Cal", "destination_label": "behind Boss's store", "area": "rear", "room_id": "", "point": Vector2(4930.0, 215.0)}, 
]

const WHOLESALE_OFFERS: = [
	{"item_id": "Herb Ounce (28 g)", "display": "herb ounce (28 g)", "trust_required": 20, "price_cents": 14000}, 
	{"item_id": "Herb Quarter Pound (4 oz)", "display": "herb quarter-pound (4 oz)", "trust_required": 40, "price_cents": 48000}, 
	{"item_id": "Powder (8-ball)", "display": "Powder (8-ball) - 3.5 g", "trust_required": 40, "price_cents": 26000, "substance_id": "powder", "weight_grams": 3.5}, 
	{"item_id": "Herb Half Pound (8 oz)", "display": "herb half-pound (8 oz)", "trust_required": 60, "price_cents": 88000}, 
	{"item_id": "Powder (½ zip)", "display": "Powder (½ zip) - 14 g", "trust_required": 50, "price_cents": 98000, "substance_id": "powder", "weight_grams": 14.0}, 
	{"item_id": "Powder (zip)", "display": "Powder (zip) - 28 g", "trust_required": 60, "price_cents": 160000, "substance_id": "powder", "weight_grams": 28.0}, 
	{"item_id": "Herb Pound (16 oz)", "display": "herb pound (16 oz)", "trust_required": 80, "price_cents": 160000},
	{"item_id": "Powder (QP)", "display": "Powder (QP) - 112 g", "trust_required": 70, "price_cents": 560000, "substance_id": "powder", "weight_grams": 112.0}, 
	{"item_id": "Powder (HP)", "display": "Powder (HP) - 224 g", "trust_required": 80, "price_cents": 980000, "substance_id": "powder", "weight_grams": 224.0}, 
	{"item_id": "Powder (P)", "display": "Powder (P) - 448 g", "trust_required": 90, "price_cents": 1680000, "substance_id": "powder", "weight_grams": 448.0}, 
]

const POWDER_PURITY_LEVELS: = [
	{"tier": 1, "label": "Heavily Cut", "duration_seconds": 50.0, "stamina_regen_multiplier": 1.15, "health_regen_per_second": 0.05},
	{"tier": 2, "label": "Low Purity", "duration_seconds": 55.0, "stamina_regen_multiplier": 1.25, "health_regen_per_second": 0.08},
	{"tier": 3, "label": "Street Standard", "duration_seconds": 60.0, "stamina_regen_multiplier": 1.4, "health_regen_per_second": 0.12},
	{"tier": 4, "label": "High Purity", "duration_seconds": 65.0, "stamina_regen_multiplier": 1.55, "health_regen_per_second": 0.17},
	{"tier": 5, "label": "Exceptional Purity", "duration_seconds": 70.0, "stamina_regen_multiplier": 1.75, "health_regen_per_second": 0.24},
]
const POWDER_ANALYSIS_CHEMISTRY_LEVEL: = 3

static func default_relationship() -> Dictionary:
	return {"trust": 0, "completed_runs": 0, "completed_by_tier": {}, "wholesale_purchases": 0, "hostile_until_unix_ms": 0}

static func normalize_relationship(value: Variant) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var completed_by_tier: = {}
	var tier_source: Variant = source.get("completed_by_tier", {})
	if tier_source is Dictionary:
		for tier_variant in (tier_source as Dictionary).keys():
			var tier: = String(tier_variant)
			if tier in RUN_TIERS:
				completed_by_tier[tier] = maxi(0, int((tier_source as Dictionary)[tier_variant]))
	return {
		"trust": clampi(int(source.get("trust", 0)), 0, 100), 
		"completed_runs": maxi(0, int(source.get("completed_runs", 0))), 
		"completed_by_tier": completed_by_tier, 
		"wholesale_purchases": maxi(0, int(source.get("wholesale_purchases", 0))), 
		"hostile_until_unix_ms": maxi(0, int(source.get("hostile_until_unix_ms", 0))), 
	}

static func run_tier(tier_id: String) -> Dictionary:
	return Dictionary(RUN_TIERS.get(tier_id.to_lower(), {})).duplicate(true)

static func route(route_id: String) -> Dictionary:
	for route_value in ROUTES:
		if String(route_value.get("id", "")) == route_id:
			return Dictionary(route_value).duplicate(true)
	return {}

static func route_for_run(account_id: String, completed_runs: int) -> Dictionary:
	var offset: = int(hash(account_id)) & 2147483647
	var index: = (offset + maxi(0, completed_runs)) % ROUTES.size()
	return Dictionary(ROUTES[index]).duplicate(true)

static func payout_cents(account_id: String, completed_runs: int, tier_id: String) -> int:
	var tier: = run_tier(tier_id)
	if tier.is_empty():
		return 0
	var minimum: = int(tier.get("pay_min_cents", 0)) / 100
	var maximum: = maxi(minimum, int(tier.get("pay_max_cents", minimum * 100)) / 100)
	var spread: = maximum - minimum + 1
	var roll: = int(hash("%s:%d:%s" % [account_id, completed_runs, tier_id])) & 2147483647
	return (minimum + (roll % spread)) * 100

static func wholesale_offer(item_id: String) -> Dictionary:
	for offer_value in WHOLESALE_OFFERS:
		if String(offer_value.get("item_id", "")) == item_id:
			return Dictionary(offer_value).duplicate(true)
	return {}

static func powder_purity(purity_tier: int) -> Dictionary:
	var index: = clampi(purity_tier, 1, POWDER_PURITY_LEVELS.size()) - 1
	return Dictionary(POWDER_PURITY_LEVELS[index]).duplicate(true)

static func powder_purity_for_purchase(account_id: String, purchase_sequence: int, item_id: String) -> int:
	var roll: = int(hash("%s:%d:%s:purity" % [account_id, purchase_sequence, item_id])) & 2147483647
	return 1 + (roll % POWDER_PURITY_LEVELS.size())
