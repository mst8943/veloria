extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

var failures: Array[String] = []


func _initialize() -> void:
	Loc.set_lang("tr")
	var sim: Node = SimScript.new()
	sim.autosave = false
	sim.record_chronicle = false
	sim.save_path = "user://army_test.sav"
	var test_save_path: String = sim.save_path
	sim.new_game(101)
	var ids := ["capital", "border", "security"]
	_check(sim.army_units.keys().size() == 3, "three army units initialize")
	for id in ids:
		var unit: Dictionary = sim.army_units[id]
		var commander := str(unit["commander"])
		_check(sim.actors.has(commander) and sim.actors[commander].supporting and not sim.actors[commander].insider,
			"%s has an environmental commander" % id)
		_check(unit.has_all(["loyalty", "morale", "supply"]), "%s stores hidden unit traits" % id)
	_check(sim.rng.state != 0 and sim.army_rng.state != sim.rng.state, "army generator is independent")
	var arden_power := float(sim.actors["arden"].power)
	sim.army_units["capital"]["loyalty"] = 20.0
	sim.army_units["border"]["loyalty"] = 50.0
	sim.army_units["security"]["loyalty"] = 80.0
	sim._sync_arden_power()
	_check(is_equal_approx(sim.actors["arden"].power, 50.0), "Arden's power is derived from unit loyalty")
	sim._set_arden_power(arden_power)
	var line: String = sim.army_report_line()
	_check(line.contains("Sınır kolordusu") or line.contains("Başkent garnizonu") or line.contains("Jandarma ve güvenlik"), "army report names one featured unit")
	_check(not _has_digit(line), "army report shows no hidden numeric values")
	Loc.set_lang("en")
	_check(sim.army_report_line().begins_with("Army:"), "army report is localized in English")
	Loc.set_lang("tr")
	var saved_power := float(sim.actors["arden"].power)
	var saved_units: Dictionary = sim.army_units.duplicate(true)
	var saved_rng: int = sim.army_rng.state
	_check(sim.save_game(), "v23 army save writes")
	var file := FileAccess.open(sim.save_path, FileAccess.READ)
	var data: Dictionary = str_to_var(file.get_as_text())
	_check(int(data["version"]) == 23 and data.has("army_units") and data.has("army_rng"), "v23 save contains army data")
	var old_save: Dictionary = data.duplicate(true)
	old_save["version"] = 20
	old_save.erase("army_units")
	old_save.erase("army_rng")
	var migrated: Dictionary = sim._migrate_save(old_save, 20)
	_check(int(migrated["version"]) == 23 and migrated["army_units"].size() == 3, "v21 save migrates to three units")
	_check(is_equal_approx(float(migrated["army_units"]["capital"]["loyalty"]), saved_power), "migration preserves old Arden power")
	_check(migrated["army_units"]["capital"]["region"] == "capital", "migration assigns existing garrison positions")
	_check(sim.load_game(), "v23 army save loads")
	_check(is_equal_approx(float(sim.actors["arden"].power), saved_power), "loaded army data preserves derived power")
	var traits_restored := true
	for id in ids:
		for key in ["loyalty", "morale", "supply"]:
			traits_restored = traits_restored and is_equal_approx(float(sim.army_units[id][key]), float(saved_units[id][key]))
	_check(traits_restored, "unit traits survive a save round trip")
	_check(sim.army_rng.state == saved_rng, "army RNG survives a save round trip")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_save_path))
	if failures.is_empty():
		print("ARMY TEST: OK")
		quit(0)
	else:
		for failure in failures:
			printerr("ARMY TEST: ", failure)
		quit(1)


func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)


func _has_digit(text: String) -> bool:
	for character in text:
		if character in "0123456789":
			return true
	return false
