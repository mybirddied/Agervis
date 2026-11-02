class_name ItemUseRules
extends RefCounted

const STANDARD_CONSUMABLES: = {
	"Hot Plate": {
		"effect_id": "health", "health_restore": 24.0, 
		"description": "Restores 24 health. Contents retain counsel.", 
	}, 
	"Sealed Water": {
		"effect_id": "stamina", "restore_stamina_full": true, 
		"description": "Restores stamina without introducing a new plot.", 
	}, 
	"Basic Bandage": {
		"effect_id": "health", "health_restore": 12.0, 
		"description": "Restores 12 health. Does not restore the story.", 
	}, 
}

static func definition(item_id: String) -> Dictionary:
	var value: Variant = STANDARD_CONSUMABLES.get(item_id, {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

static func is_standard_consumable(item_id: String) -> bool:
	if STANDARD_CONSUMABLES.has(item_id):
		return true
	# Check if it's a single-dose substance
	if item_id.contains("(single)") or item_id.contains("(0.1g dose)") or item_id.contains("(oz)"):
		return true
	return false

static func apply_standard_effect(item_id: String, current_health: float, current_stamina: float, max_stamina: float, healing_effectiveness: float = 1.0, instant_heal_effectiveness: float = 1.0) -> Dictionary:
	var item_definition: = definition(item_id)
	if item_definition.is_empty():
		return {"ok": false, "error_code": "ITEM_NOT_USABLE"}
	var health_before: = clampf(current_health, 0.0, 100.0)
	var stamina_limit: = maxf(0.0, max_stamina)
	var stamina_before: = clampf(current_stamina, 0.0, stamina_limit)

	# Apply healing effectiveness multipliers to health restoration
	var base_health_restore: = float(item_definition.get("health_restore", 0.0))
	var modified_health_restore: = base_health_restore * healing_effectiveness * instant_heal_effectiveness

	var health_after: = minf(100.0, health_before + modified_health_restore)
	var stamina_after: = stamina_limit if bool(item_definition.get("restore_stamina_full", false)) else stamina_before
	var health_restored: = health_after - health_before
	var stamina_restored: = stamina_after - stamina_before
	if health_restored <= 0.001 and stamina_restored <= 0.001:
		return {"ok": false, "error_code": "NO_EFFECT"}
	return {
		"ok": true,
		"effect_id": String(item_definition.get("effect_id", "standard")),
		"health": health_after,
		"stamina": stamina_after,
		"health_restored": health_restored,
		"stamina_restored": stamina_restored,
	}
