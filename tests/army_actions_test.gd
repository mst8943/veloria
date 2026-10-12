extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

var failures: Array[String] = []


func _initialize() -> void:
	Loc.set_lang("tr")
	var sim: Node = SimScript.new()
	sim.autosave = false
	sim.record_chronicle = false
	sim.save_path = "user://army_actions_test.sav"
	sim.new_game(101)
	sim.pending.clear()
	var main_rng: int = sim.rng.state
	var army_rng: int = sim.army_rng.state
	var mesai: int = sim.mesai
	sim.request_army_decision()
	_check(sim.pending[0]["event"]["kind"] == "army_action", "R5b actions open as a decision card")
	sim.resolve_decision(0, 0)
	_check(sim.pending.size() == 1 and sim.mesai == mesai, "choosing an action category spends no extra work")
	var previews := true
	for choice: Dictionary in sim.pending[0]["event"]["choices"]:
		previews = previews and str(choice.get("preview", "")) != ""
	_check(previews and sim.pending[0]["event"]["choices"].size() <= 4, "each grouped officer option has a qualitative preview")
	sim.resolve_decision(0, 0)
	_check(sim.pending[0]["event"]["choices"].size() == 2, "officer pair opens only two direction choices")
	_check(not str(sim.pending[0]["event"]["choices"][0]["label"]).contains("garnizonu'nin"), "officer order uses correct Turkish case")
	sim.resolve_decision(0, 0)
	_check(sim.mesai == mesai - 1 and sim.stats["army_officer_changes"] == 1, "officer assignment costs one work and changes command")
	_check(sim.army_units["capital"]["commander"] == "commander_border", "the selected new officer takes command")
	_check(sim.army_rng.state != army_rng and sim.rng.state == main_rng, "uncertain officer response uses army_rng only")
	_check(sim.army_report_line().contains("Ordu kararı:") and not _has_digit(sim.army_report_line()), "army action appears in qualitative daily and Divan report")
	var note_week: int = sim.week
	sim.week += 4
	_check(sim.army_action_line() == "", "old army action does not masquerade as this week's report")
	sim.week = note_week
	Loc.set_lang("en")
	_check(sim.army_action_line().begins_with("Army decision:"), "army action result is localized in English")
	Loc.set_lang("tr")

	sim._queue_army_action_options("redeploy")
	sim.resolve_decision(sim.pending.size() - 1, 0)
	_check(sim.army_units["capital"]["region"] == "border" and sim.regions["border"]["garrison"] > 0.0, "capital garrison can move to the border region")
	sim._queue_army_action_options("redeploy")
	sim.resolve_decision(sim.pending.size() - 1, 0)
	_check(sim.army_units["capital"]["region"] == "capital", "capital garrison can return to the capital")

	sim.treasury = 80.0
	sim.budget_allocation["army"] = 25.0
	for i in 3:
		sim.mesai = sim.mesai_max
		sim._queue_army_action_options("allowance")
		sim.resolve_decision(sim.pending.size() - 1, 0)
		if i == 0:
			var before: float = float(sim.army_units["capital"]["morale"])
			sim.week += 2
			sim._tick_army_effects()
			_check(float(sim.army_units["capital"]["morale"]) > before, "pay and supply effects arrive after a delay")
	_check(sim.stats["army_allowances"] == 3 and sim.stats["army_allowance_uses"] == 3, "repeated supplements are tracked for diminishing returns")

	sim.mesai = sim.mesai_max
	var arden_before := float(sim.actors["arden"].power)
	var army_capacity_before := float(sim.capacity["ordu"])
	sim._queue_army_action_options("split")
	sim.resolve_decision(sim.pending.size() - 1, 0)
	_check(sim.army_command_split and float(sim.actors["arden"].power) < arden_before, "splitting command reduces Arden's derived power")
	_check(float(sim.capacity["ordu"]) < army_capacity_before and sim.army_tension > 0.0, "command split costs efficiency and adds coup tension")
	_check(sim._army_achievement_ids().has("ordu_ikmalcisi") and sim._army_achievement_ids().has("garnizon_hatti"), "army action achievements register completed paths")

	_check(sim.save_game(), "v22 army action state saves")
	var file := FileAccess.open(sim.save_path, FileAccess.READ)
	var saved: Dictionary = str_to_var(file.get_as_text())
	_check(int(saved["version"]) == 22 and saved.has_all(["army_effects", "army_tension", "army_command_split", "army_action_note"]), "v22 save contains army action state")
	var v21: Dictionary = saved.duplicate(true)
	v21["version"] = 21
	for key in ["army_effects", "army_tension", "army_command_split", "army_action_note"]:
		v21.erase(key)
	for unit: Dictionary in v21["army_units"].values():
		unit.erase("region")
		unit.erase("appointed_week")
	var migrated: Dictionary = sim._migrate_save(v21, 21)
	_check(int(migrated["version"]) == 22 and migrated["army_units"]["capital"]["region"] == "capital", "v21 saves migrate safely to v22")
	_check(sim.load_game() and sim.army_command_split and sim.army_action_note == saved["army_action_note"], "army action state survives a save reload")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	if failures.is_empty():
		print("ARMY ACTIONS: OK")
		quit(0)
	else:
		for failure in failures:
			printerr("ARMY ACTIONS: ", failure)
		quit(1)


func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)


func _has_digit(text: String) -> bool:
	for character in text:
		if character in "0123456789":
			return true
	return false
