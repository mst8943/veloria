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
	sim._add_fact("muhalefet_finansmani", "Muhalefeti bölmek için verilen gizli para", "king", 30.0, ["voss"], 1)
	_check(sim.fact_text_for_display(sim.facts["muhalefet_finansmani"]) == "Secret funds used to split the opposition", "old scandal fact displays in English")
	sim._open_other("border")
	_check(str(sim.pending[0]["event"]["title"]) == "Drakon begins a border exercise", "border note is localized in English")
	sim.other_crisis["phase"] = "crisis"
	sim.pending.clear()
	sim._check_crises()
	_check(str(sim.pending[0]["event"]["title"]) == "Drakon issues a border ultimatum", "ultimatum is localized in English")
	Loc.set_lang("tr")
	sim.new_game(303)
	sim.pending.clear()
	sim.treasury = 25.0
	sim.ext_pressure["asteria"] = 70.0
	sim._open_other("siege")
	_check(str(sim.pending[0]["event"]["id"]) == "b1b_ambargo_notasi", "financial pressure opens the embargo note")
	var siege_rng: int = sim.rng.state
	sim.resolve_decision(0, 0)
	_check(sim.other_crisis.get("phase", "") == "crisis" and sim.rng.state == siege_rng, "the credit-cut stage waits a week on its separate RNG")
	sim.week += 1
	sim.pending.clear()
	sim._check_crises()
	var credit_card: Dictionary = sim.pending[0]["event"]
	_check(str(credit_card["id"]) == "b1b_kredi_kesildi" and credit_card["choices"].size() == 3, "credit-cut card has all three response paths")
	sim.new_game(605)
	sim.week = 20
	var assassination_main_rng: int = sim.rng.state
	sim.pending.clear()
	sim.other_crisis.clear()
	sim.flags.erase("SUIKAST_OMEN_DUE")
	sim._check_crises()
	_check(sim.other_crisis.is_empty() and sim.rng.state == assassination_main_rng, "assassination cannot open without a warning and leaves main RNG untouched")
	sim.other_crisis.clear()
	sim.crisis_cooldown = 0
	sim.week = 20
	sim.flags["SUIKAST_OMEN_DUE"] = sim.week + 1
	sim.week += 1
	sim.pending.clear()
	sim._check_crises()
	var assassination_card: Dictionary = sim.pending[0]["event"]
	_check(str(assassination_card["id"]) == "b1c_kortej_plani" and sim.other_crisis.get("phase", "") == "prep" and assassination_card["choices"].size() == 3, "assassination warning opens its preparation card one week later with three choices")
	var attack_rng: int = sim.rng.state
	sim.king_strength = 100.0
	sim.resolve_decision(0, 1)
	_check(sim.rng.state == attack_rng, "assassination resolution consumes only its separate RNG")
	_check(sim.flags.has("SUIKAST_ATLATILDI") and sim.pending.is_empty(), "successful route change leaves the ruler wounded and survives the night")
	var aftermath := {}
	for event: Dictionary in sim._events:
		if str(event.get("id", "")) == "suikast_sonrasi":
			aftermath = event
	_check(str(aftermath.get("needs_flag", "")) == "SUIKAST_ATLATILDI" and aftermath.get("choices", []).size() == 2, "survival unlocks the two-choice Palace aftermath event")
	sim._end(true)
	var earned: Array = sim._award_achievements(true, str(sim.record["title"]), str(sim.record["cause"]))
	_check(str(sim.record["title"]) == "Yaralı Egemen" and "yarali_egemen" in earned, "surviving the assassination grants its wounded sovereign ending and achievement")
	Loc.set_lang("en")
	sim.new_game(606)
	sim._open_other("assassination")
	var english_assassination: Dictionary = sim.pending[0]["event"]
	_check(str(english_assassination["title"]) == "The procession route changed" and english_assassination["choices"].size() == 3, "assassination preparation card is fully localized in English")
	Loc.set_lang("tr")
	sim.new_game(607)
	sim.flags["external_defeat"] = "assassination"
	sim._check_end()
	_check(str(sim.record["title"]) == "Suikast" and str(sim.record["cause"]).contains("Suikast"), "assassination defeat records its own ending")
	Loc.set_lang("en")
	sim.new_game(404)
	sim.pending.clear()
	sim.other_crisis = {"kind": "siege", "phase": "crisis", "week": sim.week}
	sim.pending.append({"event": sim._external_event("siege"), "age": 0})
	_check(str(sim.pending[0]["event"]["title"]) == "Credit is cut; payday is near", "credit-cut card is localized in English")
	sim.weekly_news.clear()
	sim.weekly_news_localized.clear()
	sim._open_other("siege")
	_check(str(sim.weekly_news_localized.values()[0]).begins_with("CRISIS: Asteria and Seravia cut credit"), "financial crisis news is localized in English")
	Loc.set_lang("tr")
	sim.new_game(505)
	sim.flags["external_defeat"] = "siege"
	sim._check_end()
	_check(str(sim.record["title"]) == "Mali Çöküş" and str(sim.record["cause"]).contains("Mali çöküş"), "financial defeat records its own cause and title")
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
