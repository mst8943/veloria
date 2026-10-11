extends SceneTree

const Loc := preload("res://game/core/loc.gd")
const Press := preload("res://game/core/press.gd")
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, label: String) -> void:
	if not value:
		failures.append(label)
		push_error("PARLIAMENT LAWS: " + label)


func _run() -> void:
	await process_frame
	Loc.set_lang("tr")
	var sim: Node = root.get_node("Sim")
	var old_path := str(sim.save_path)
	sim.save_path = "user://parliament_laws_test.txt"
	sim.autosave = false
	sim.record_chronicle = false
	sim.new_game(17032, 1)
	var old_v16: Dictionary = sim._migrate_save({"seed": 17032, "opp": 24.0}, 16)
	_check(old_v16["parliament_laws"].is_empty() and old_v16["last_parliament_review_week"] == 0, "v16 saves migrate with no laws active")
	_check(sim.parliament_laws_line() == "Yürürlükteki yasalar: Yok.", "daily law list reports an empty chamber")
	var numeric_text := RegEx.new()
	numeric_text.compile("[0-9]")
	_check(numeric_text.search(sim.parliament_laws_line()) == null, "law list keeps hidden values qualitative")
	sim.week = 10
	sim.pending.clear()
	sim.treasury = 50.0
	sim.private_wealth = 50.0
	sim.king_strength = 54.0
	_check(not sim._can_force_parliament(), "forcing a bill requires enough royal authority")
	sim.king_strength = 55.0
	_check(sim._can_force_parliament(), "the authority threshold enables pressure when funds are available")
	sim.king_strength = 90.0
	sim._tick_parliament()
	sim.pending[0]["event"]["proposal"]["bill"] = "press"
	sim.parliament_proposals.back()["bill"] = "press"
	var consent_before_pass: float = sim.consent
	sim.resolve_decision(0, 3)
	_check(sim.parliament_laws.has("press") and sim.consent == consent_before_pass - 8.0 and sim.parliament_proposals.back().has("law_week"), "an accepted bill activates and records its permanent law")

	sim.new_game(17032, 1)
	var baseline_flattery: float = Press._flattery(sim, "free")
	var before_consent: float = sim.consent
	sim._enact_parliament_law("press")
	_check(sim.consent == before_consent - 8.0 and Press._flattery(sim, "free") > baseline_flattery, "press law blunts Leyla's influence at a consent cost")
	sim._repeal_parliament_law("press")
	_check(not sim.parliament_laws.has("press") and is_equal_approx(Press._flattery(sim, "free"), baseline_flattery), "repeal restores the free press effect")

	sim.new_game(17033, 1)
	var arden_power: float = sim.actors["arden"].power
	sim._set_budget_allocation({"army": 10.0, "social": 70.0, "industry": 10.0, "palace": 10.0})
	sim._enact_parliament_law("army")
	_check(sim.actors["arden"].power == arden_power + 1.0 and sim.budget_allocation["army"] >= 26.0, "army law strengthens Arden and raises the R1 allocation floor")
	sim._set_budget_allocation({"army": 10.0, "social": 70.0, "industry": 10.0, "palace": 10.0})
	_check(sim.budget_allocation["army"] >= 26.0 and is_equal_approx(sim.budget_allocation.values().reduce(func(a: float, b: float) -> float: return a + b, 0.0), 100.0), "later budget choices preserve the law's army floor and total")
	sim._repeal_parliament_law("army")
	_check(sim.actors["arden"].power == arden_power, "repealing the army law removes its lasting authority bonus")

	sim.new_game(17034, 1)
	sim._enact_parliament_law("tax")
	_check(sim.treasury == 58.0, "tax reform creates its initial treasury revenue")
	var tax_control: Node = load("res://game/core/sim.gd").new()
	tax_control.new_game(17034, 1)
	tax_control.week = sim.week
	tax_control.economy = sim.economy
	tax_control.treasury = sim.treasury
	tax_control.capacity = sim.capacity.duplicate()
	sim._tick_state()
	tax_control._tick_state()
	_check(is_equal_approx(sim.treasury - tax_control.treasury, 0.02) and is_equal_approx(sim.unrest - tax_control.unrest, 2.25), "tax reform adds R1 revenue while its recurring burden feeds unrest")
	sim._repeal_parliament_law("tax")
	_check(not sim.parliament_laws.has("tax"), "tax law can be withdrawn")
	tax_control.free()

	sim.new_game(17035, 1)
	sim.facts.clear()
	sim._add_fact("law_test", "Test", "king", 45.0, [], 1)
	var pressure_before_amnesty: float = sim.legal_pressure()
	var consent_before_amnesty: float = sim.consent
	sim._enact_parliament_law("amnesty")
	_check(sim.legal_pressure() < pressure_before_amnesty and sim.consent > consent_before_amnesty, "amnesty grants relief from judicial pressure and restores consent")
	sim._repeal_parliament_law("amnesty")
	_check(sim.legal_pressure() > pressure_before_amnesty - 0.1, "amnesty repeal ends its ongoing judicial relief")

	sim.new_game(17036, 1)
	sim.week = 50
	sim.opposition = 29.75
	var early_election: Dictionary = {}
	for event: Dictionary in sim._events:
		if event["id"] == "erken_secim":
			early_election = event
	_check(not early_election.is_empty() and not sim._eligible(early_election), "early election retains its original threshold without the law")
	sim._enact_parliament_law("election")
	_check(sim._eligible(early_election), "election law lowers the early election threshold for R3c")

	sim.new_game(17037, 1)
	sim.facts.clear()
	sim._add_fact("law_judicial_test", "Test", "king", 45.0, [], 1)
	var pressure_before_judicial: float = sim.legal_pressure()
	var capacity_before_judicial: float = sim.capacity["hukuk"]
	sim._enact_parliament_law("judicial")
	var pressure_with_judicial: float = sim.legal_pressure()
	_check(sim.capacity["hukuk"] == capacity_before_judicial + 1.0 and pressure_with_judicial < pressure_before_judicial, "judicial reform raises court capacity and eases case pressure")
	sim._repeal_parliament_law("judicial")
	_check(sim.legal_pressure() > pressure_with_judicial, "judicial repeal restores prior case pressure")

	sim.new_game(17038, 1)
	sim.parliament_laws["press"] = sim.week
	sim.last_parliament_review_week = 1
	sim.week = 27
	sim.treasury = 30.0
	sim.mesai = 4
	sim.pending.clear()
	sim._tick_parliament()
	var repeal_event: Dictionary = sim.pending[0]["event"] if not sim.pending.is_empty() else {}
	_check(repeal_event.get("kind", "") == "parliament_repeal" and repeal_event["choices"][0]["available"], "law review offers an affordable repeal decision")
	var treasury_before_repeal: float = sim.treasury
	var ap_before_repeal: int = sim.mesai
	var repeal_result: String = sim.resolve_decision(0, 0)
	_check(repeal_result != "" and not sim.parliament_laws.has("press") and sim.treasury == treasury_before_repeal - 10.0 and sim.mesai == ap_before_repeal - 1, "repeal charges treasury and one action point")

	sim.parliament_laws["tax"] = sim.week
	sim.last_parliament_review_week = sim.week
	_check(sim.save_game(), "law state saves")
	sim.parliament_laws.clear()
	_check(sim.load_game() and sim.parliament_laws.has("tax"), "law state loads")
	var saved: Dictionary = {}
	var file := FileAccess.open(sim.save_path, FileAccess.READ)
	if file != null:
		saved = str_to_var(file.get_as_text())
		file.close()
	var saved_v16: Dictionary = saved.duplicate(true)
	saved_v16["version"] = 16
	saved_v16.erase("parliament_laws")
	saved_v16.erase("last_parliament_review_week")
	var migrated_v16: Dictionary = sim._migrate_save(saved_v16, 16)
	_check(migrated_v16["parliament_laws"].is_empty() and migrated_v16["last_parliament_review_week"] == 0, "legacy v16 campaign gets a stable no-law default")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	sim.save_path = old_path
	print("PARLIAMENT LAWS: OK" if failures.is_empty() else "PARLIAMENT LAWS: FAILED (%d)" % failures.size())
	quit(0 if failures.is_empty() else 1)
