extends SceneTree

const Loc := preload("res://game/core/loc.gd")
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, label: String) -> void:
	if not value:
		failures.append(label)
		push_error("PARLIAMENT: " + label)


func _run() -> void:
	await process_frame
	Loc.set_lang("tr")
	var sim: Node = root.get_node("Sim")
	var old_path := str(sim.save_path)
	sim.save_path = "user://parliament_test.txt"
	sim.autosave = false
	sim.record_chronicle = false
	sim.new_game(17031, 1)
	var main_rng: int = sim.rng.state
	var migrated: Dictionary = sim._migrate_save({"seed": 17031, "opp": 37.0}, 15)
	_check(sim.parliament_blocs.size() == 4 and is_equal_approx(sim.opposition, 20.0), "four blocs preserve the initial opposition baseline")
	_check(migrated["parliament_blocs"].size() == 4 and migrated["parliament_base_opposition"] == 37.0, "old saves migrate parliament state from opposition")
	_check(migrated["parliament_rng"] != 0, "migration seeds the independent parliament stream")
	sim.week = 10
	sim.pending.clear()
	sim._tick_parliament()
	_check(sim.pending.size() == 1 and sim.pending[0]["event"]["kind"] == "parliament_bill", "a bill is offered after ten weeks")
	_check(sim.rng.state == main_rng and sim.parliament_rng.state != 0, "proposal selection leaves the campaign RNG unchanged")
	var event: Dictionary = sim.pending[0]["event"]
	var card_text := str(event["title"]) + " " + str(event["text"])
	var number_regex := RegEx.new()
	number_regex.compile("[0-9]")
	_check(number_regex.search(card_text) == null, "bill card does not reveal a vote count")
	_check(event["choices"].map(func(choice: Dictionary) -> String: return str(choice["bill_action"])) == ["support", "amend", "withdraw", "force"], "bill offers the four required responses")
	_check(sim.advice_for(0).is_empty(), "bill voting uses qualitative rumours instead of council vote estimates")
	_check(number_regex.search(sim.parliament_report_line()) == null, "assembly report is qualitative")
	sim.mesai = 4
	var result: String = sim.resolve_decision(0, 0)
	_check(result != "" and sim.rng.state == main_rng and sim.mesai == 4, "vote uses its own RNG and no action point")
	_check(str(sim.parliament_proposals.back()["status"]) in ["passed", "failed"], "proposal records its uncertain vote outcome")
	sim.pending.clear()
	sim.week = 20
	sim.treasury = 45.0
	sim.private_wealth = 30.0
	sim.king_strength = 90.0
	sim._tick_parliament()
	sim.mesai = 4
	var before_treasury: float = sim.treasury
	var before_wealth: float = sim.private_wealth
	var before_unrest: float = sim.unrest
	var before_king: float = sim.king_strength
	var before_consent: float = sim.consent
	var force_index: int = sim.pending[0]["event"]["choices"].find_custom(func(choice: Dictionary) -> bool: return choice["bill_action"] == "force")
	sim.pending[0]["event"]["proposal"]["bill"] = "press"
	sim.parliament_proposals.back()["bill"] = "press"
	var force_result: String = sim.resolve_decision(0, force_index)
	_check(force_result != "" and sim.treasury == before_treasury - 10.0 and sim.private_wealth == before_wealth - 7.0 and sim.unrest == 100.0 and sim.king_strength == before_king - 60.0 and sim.consent == before_consent - 15.0, "forcing a bill through also costs public legitimacy")
	_check(sim.flags.has("PARLIAMENT_FORCE_TRACE_%d" % sim.week), "forced vote leaves a trace")
	_check(sim.save_game(), "parliament state saves")
	var saved_opposition: float = sim.opposition
	sim.parliament_blocs.clear()
	_check(sim.load_game() and sim.parliament_blocs.size() == 4 and is_equal_approx(sim.opposition, saved_opposition), "parliament state loads")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	sim.save_path = old_path
	print("PARLIAMENT: OK" if failures.is_empty() else "PARLIAMENT: FAILED (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
