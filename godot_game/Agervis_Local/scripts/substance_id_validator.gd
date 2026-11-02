class_name SubstanceIdValidator
extends RefCounted

# SUBSTANCE ID VALIDATOR
# Static, read-only checks for the display-name vs internal-ID bug class.
# Rules: SUBSTANCE_ID_RULES.md (same folder).
#
# Usage from a test:
#   var errors: Array[String] = SubstanceIdValidator.validate_all()
#   assert(errors.is_empty(), "\n".join(PackedStringArray(errors)))
#
# Every check reads the live tables, so a renamed or broken table is caught here.
# validate_all() checks the static data only. Use find_non_internal_ids() on
# runtime lists such as active_substance_ids.


# Every valid internal ID, built from the real tables.
static func known_internal_ids() -> Array[String]:
	var ids: Array[String] = []
	for data in StreetSubstances.STREET_SUBSTANCES.values():
		ids.append(String(data.get("substance_id", "")))
	for data in PharmaceuticalContent.PHARMA_SUBSTANCES.values():
		ids.append(String(data.get("substance_id", "")))
	ids.append(String(PharmaceuticalContent.SYRUP.get("substance_id", "")))
	ids.append(String(PharmaceuticalContent.REVIVAR.get("substance_id", "")))
	return ids


# True only if value is exactly a known internal ID. Case-sensitive on purpose.
static func is_internal_id(value: String) -> bool:
	return value in known_internal_ids()


# Returns a problem message for each value that is not an internal ID.
# Tells apart a display name ("Tar") from an unknown string ("xyz").
static func find_non_internal_ids(values: Array) -> Array[String]:
	var known: Array[String] = known_internal_ids()
	var problems: Array[String] = []
	for raw in values:
		var value: String = String(raw)
		if value in known:
			continue
		if value.to_lower() in known:
			problems.append("'%s' is a display name. Use '%s'." % [value, value.to_lower()])
		else:
			problems.append("'%s' is not a known internal ID." % [value])
	return problems


# Each substance data row must carry a lowercase substance_id with no spaces.
static func check_substance_tables() -> Array[String]:
	var errors: Array[String] = []
	_check_table(errors, "STREET_SUBSTANCES", StreetSubstances.STREET_SUBSTANCES)
	_check_table(errors, "PHARMA_SUBSTANCES", PharmaceuticalContent.PHARMA_SUBSTANCES)
	for problem in [
		_id_field_problem("SYRUP", PharmaceuticalContent.SYRUP),
		_id_field_problem("REVIVAR", PharmaceuticalContent.REVIVAR),
	]:
		if not problem.is_empty():
			errors.append(problem)
	return errors


# No two substances may share an internal ID.
static func check_unique_ids() -> Array[String]:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	for sid in known_internal_ids():
		if seen.has(sid):
			errors.append("Duplicate internal ID '%s'. Two substances share it." % [sid])
		seen[sid] = true
	return errors


# Every ingredient in every combo must be an internal ID. Each combo needs exactly 2 ingredient sets.
static func check_combo_table() -> Array[String]:
	var errors: Array[String] = []
	for combo_id in StreetSubstances.DANGEROUS_COMBINATIONS.keys():
		var combo: Dictionary = StreetSubstances.DANGEROUS_COMBINATIONS[combo_id]
		var sets: Array = combo.get("ingredients", [])
		if sets.size() != 2:
			errors.append("Combo '%s' needs exactly 2 ingredient arrays, has %d." % [combo_id, sets.size()])
		for ingredient_set in sets:
			for ingredient in ingredient_set:
				if not is_internal_id(String(ingredient)):
					errors.append("Combo '%s' ingredient '%s' is not an internal ID." % [combo_id, String(ingredient)])
	return errors


# Overdose and CNS lists must hold internal IDs only.
static func check_opioid_and_cns_lists() -> Array[String]:
	var errors: Array[String] = []
	for sid in OpioidOverdoseSystem.OPIOID_SUBSTANCES:
		if not is_internal_id(String(sid)):
			errors.append("OPIOID_SUBSTANCES has non-internal ID '%s'." % [String(sid)])
	for sid in OpioidOverdoseSystem.CNS_DEPRESSANTS:
		if not is_internal_id(String(sid)):
			errors.append("CNS_DEPRESSANTS has non-internal ID '%s'." % [String(sid)])
	return errors


# Runs every static check. An empty array means all checks passed.
static func validate_all() -> Array[String]:
	var errors: Array[String] = []
	errors.append_array(check_substance_tables())
	errors.append_array(check_unique_ids())
	errors.append_array(check_combo_table())
	errors.append_array(check_opioid_and_cns_lists())
	return errors


static func _check_table(errors: Array[String], table_label: String, table: Dictionary) -> void:
	for key in table.keys():
		var problem: String = _id_field_problem("%s['%s']" % [table_label, key], table[key])
		if not problem.is_empty():
			errors.append(problem)


# Returns "" when the row is fine, otherwise a message.
static func _id_field_problem(label: String, data: Dictionary) -> String:
	var sid: String = String(data.get("substance_id", ""))
	if sid.is_empty():
		return "%s has no substance_id." % [label]
	if sid != sid.to_lower() or sid.contains(" "):
		return "%s substance_id '%s' must be lowercase with no spaces." % [label, sid]
	return ""
