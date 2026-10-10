extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

var failures: Array[String] = []


func _initialize() -> void:
	var sim: Node = SimScript.new()
	sim.record_chronicle = false
	sim.autosave = false
	sim.save_path = "user://external_crisis_test.txt"
	Loc.set_lang("tr")
	sim.new_game(101)
	var main_rng_state: int = sim.rng.state
	for i in 20:
		sim._tick_external_pressure()
	_check(sim.rng.state == main_rng_state, "external pressure leaves the main RNG untouched")
	var hint_rng_state: int = sim.ext_rng.state
	sim.ext_pressure["drakon"] = 58.0
	var suspicion: int = sim.external_suspicion_level("malenkov")
	_check(suspicion >= 0 and suspicion <= 3 and sim.ext_rng.state == hint_rng_state, "envoy signal is bounded and does not consume the stream")
	sim.ext_pressure["drakon"] = 70.0
	sim._open_other("border")
	_check(str(sim.pending[0]["event"]["id"]) == "b1a_drakon_sinir_notasi", "border warning opens the note card")
	sim.resolve_decision(0, 0)
	_check(sim.other_crisis.get("phase", "") == "crisis", "note resolution schedules the ultimatum stage")
	sim.week += 1
	sim.pending.clear()
	sim._check_crises()
	_check(not sim.pending.is_empty() and str(sim.pending[0]["event"]["id"]) == "drakon_ultimatom", "ultimatum waits for the next week")
	var legacy: Dictionary = sim._migrate_save({"seed": 101}, 10)
	_check(legacy.get("ext_pressure", {}).get("drakon", -1.0) == 0.0 and legacy.get("external_history", null) is Array and int(legacy.get("version", 0)) == sim.SAVE_VERSION, "version 10 saves receive safe defaults")
	Loc.set_lang("en")
	sim.new_game(202)
	sim._open_other("border")
	_check(str(sim.pending[0]["event"]["title"]) == "Drakon begins a border exercise", "border note is localized in English")
	sim.other_crisis["phase"] = "crisis"
	sim.pending.clear()
	sim._check_crises()
	_check(str(sim.pending[0]["event"]["title"]) == "Drakon issues a border ultimatum", "ultimatum is localized in English")
	if failures.is_empty():
		print("EXTERNAL CRISIS: OK")
		quit(0)
	else:
		for failure in failures:
			printerr("FAIL ", failure)
		print("EXTERNAL CRISIS: FAIL (%d)" % failures.size())
		quit(1)


func _check(value: bool, description: String) -> void:
	print("ok    " if value else "FAIL  ", description)
	if not value:
		failures.append(description)
