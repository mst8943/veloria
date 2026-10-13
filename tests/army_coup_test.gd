extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

var failures: Array[String] = []


func _initialize() -> void:
	Loc.set_lang("tr")
	var sim: Node = SimScript.new()
	sim.autosave = false
	sim.record_chronicle = false
	sim.save_path = "user://army_coup_test.sav"
	sim.new_game(512)
	sim.pending.clear()
	for actor in sim.actors.values():
		actor.ready = false
	sim.actors["arden"].ready = true
	sim.week = 20
	var main_rng: int = sim.rng.state
	sim._open_crisis()
	var event: Dictionary = sim.pending[0]["event"]
	_check(sim.coup_crisis.has("unit") and sim.army_units.has(sim.coup_crisis["unit"]), "military coup identifies its turning unit")
	_check(event["choices"].size() == 3 and str(event["text"]).contains("Başkent garnizonu"), "coup card names the garrison and unit choices")
	_check(str(event["mobile_text"]).contains("komutan") and str(event["mobile_text"]).contains("ikmal") and str(event["mobile_text"]).contains("Muhafız"), "mobile crisis summary preserves the military warning signs")
	_check(not _has_digit(str(event["text"])), "coup narrative exposes no hidden values")
	_check(sim.rng.state == main_rng, "coup preparation leaves the main RNG untouched")
	var target: String = str(sim.coup_crisis["unit"])
	var defender: String = sim._army_defense_unit(target)
	sim.army_units[defender]["loyalty"] = 85.0
	var loyal_chance: float = sim.crisis_chance("army_suppress", defender)
	sim.army_units[defender]["loyalty"] = 20.0
	var weak_chance: float = sim.crisis_chance("army_suppress", defender)
	_check(loyal_chance > weak_chance, "unit loyalty changes local suppression odds")
	sim.army_units[defender]["loyalty"] = 85.0
	var covered_chance: float = sim.crisis_chance("army_suppress", defender)
	sim.other_crisis = {"kind": "border", "week": sim.week}
	sim.army_units["capital"]["region"] = "border"
	var border_chance: float = sim.crisis_chance("army_suppress", defender)
	_check(border_chance < covered_chance, "border crisis and withdrawn capital garrison weaken suppression")
	sim.army_units["border"]["region"] = "border"
	var border_force_chance: float = sim.other_chance("force")
	sim.army_units["border"]["region"] = "capital"
	_check(sim.other_chance("force") < border_force_chance, "border corps presence improves its own crisis response")
	sim.other_crisis.clear()
	Loc.set_lang("en")
	var english_event: Dictionary = sim._crisis_event(sim.actors["arden"])
	_check(str(english_event["choices"][0]["label"]).contains("Suppress"), "unit-specific coup choices are localized")
	Loc.set_lang("tr")

	# Pick a deterministic army_rng seed for the successful reserve-unit response.
	var reserve: String = str(event["choices"][2]["unit"])
	var switch_chance: float = sim.crisis_chance("army_switch", reserve)
	var chosen_seed := 1
	for seed in range(1, 1000):
		var probe_rng := RandomNumberGenerator.new()
		probe_rng.seed = seed
		if probe_rng.randf() < switch_chance:
			chosen_seed = seed
			break
	sim.army_rng.seed = chosen_seed
	main_rng = sim.rng.state
	sim.resolve_decision(0, 2)
	_check(sim.coup_crisis.is_empty() and str(sim.army_units[reserve]["region"]) == "capital", "switch-unit order calls a reserve to secure the palace")
	_check(sim.stats["army_coup_switches"] == 1 and sim.rng.state == main_rng, "successful unit change uses army_rng and is recorded")
	sim.stats["army_coup_suppressions"] = 1
	_check(sim._army_achievement_ids().has("komuta_zinciri") and sim._army_achievement_ids().has("muhafizlar_sadakati"), "coup decisions have distinct achievements")

	sim.new_game(513)
	sim.pending.clear()
	for actor in sim.actors.values(): actor.ready = false
	sim.actors["arden"].ready = true
	sim.week = 20
	sim._open_crisis()
	defender = str(sim.pending[0]["event"]["choices"][0]["unit"])
	var suppress_chance: float = sim.crisis_chance("army_suppress", defender)
	chosen_seed = 1
	for seed in range(1, 1000):
		var probe_rng := RandomNumberGenerator.new()
		probe_rng.seed = seed
		if probe_rng.randf() < suppress_chance:
			chosen_seed = seed
			break
	sim.army_rng.seed = chosen_seed
	main_rng = sim.rng.state
	sim.resolve_decision(0, 0)
	_check(sim.coup_crisis.is_empty() and sim.stats["army_coup_suppressions"] == 1 and sim.rng.state == main_rng,
		"unit-led suppression resolves and uses army_rng")

	_check(sim.save_game(), "coup state can be saved")
	var file := FileAccess.open(sim.save_path, FileAccess.READ)
	var old: Dictionary = str_to_var(file.get_as_text())
	old["version"] = 22
	old["coup_crisis"] = {"leader": "arden", "week": 20}
	var migrated: Dictionary = sim._migrate_save(old, 22)
	_check(int(migrated["version"]) == 23 and migrated["coup_crisis"]["unit"] == "capital", "v22 coup saves migrate with a safe unit")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	if failures.is_empty():
		print("ARMY COUP: OK")
		quit(0)
	else:
		for failure in failures:
			printerr("ARMY COUP: ", failure)
		quit(1)


func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)


func _has_digit(text: String) -> bool:
	for character in text:
		if character in "0123456789":
			return true
	return false
