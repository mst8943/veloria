extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

var sim: Node
var failures: Array[String] = []


func _initialize() -> void:
	Loc.set_lang("tr")
	sim = SimScript.new()
	sim.record_chronicle = false
	sim.autosave = false
	sim.save_path = "user://election_test.sav"
	_check_election_rng_and_factors()
	_check_government_paths()
	_check_migration_and_save()
	_check_achievements()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	if failures.is_empty():
		print("ELECTION: OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_election_rng_and_factors() -> void:
	sim.new_game(41, 1)
	var main_state: int = sim.rng.state
	var parliament_state: int = sim.parliament_rng.state
	sim.consent = 92.0
	sim.economy = 88.0
	sim.unrest = 12.0
	sim.parliament_proposals = [{"bill": "judicial", "status": "passed"}]
	var event: Dictionary = sim._prepare_election_result({"id": "secim_sonucu", "title": "Seçim sonucu", "text": "Meclis", "advisors": [], "choices": []})
	_check(int(sim.stats["elections"]) == 1 and sim.parliament_blocs["royal"]["loyalty"] > 96.0, "public mood, economy, and law history shift election blocs")
	_check(sim.rng.state == main_state and sim.parliament_rng.state == parliament_state, "election outcome uses its independent generator")
	_check(not str(event["text"]).contains("sandalye") and not str(event["text"]).contains("oy sayısı"), "election result hides exact votes and seats")
	sim.new_game(41, 1)
	sim.consent = 10.0
	sim.economy = 10.0
	sim.unrest = 90.0
	sim.parliament_proposals = [{"bill": "press", "status": "passed_under_pressure"}]
	sim.facts["public_scandal"] = {"subject": "king", "public": true}
	sim._prepare_election_result({"id": "secim_sonucu", "choices": []})
	_check(sim.parliament_blocs["opposition"]["loyalty"] > 56.0, "hardship, coercive law history, and scandals favor opposition")
	var election: Dictionary = {}
	for entry: Dictionary in sim._events:
		if str(entry.get("id", "")) == "erken_secim":
			election = entry
	sim._set_parliament_base_opposition(29.7)
	sim.week = 50
	_check(not election.is_empty() and not sim._eligible(election), "early election waits for its support threshold")
	sim.parliament_laws["election"] = sim.week
	_check(sim._eligible(election), "election law remains connected to early-election threshold")


func _check_government_paths() -> void:
	sim.new_game(42, 1)
	var result: Dictionary = sim._prepare_election_result({"id": "secim_sonucu", "title": "Seçim sonucu", "text": "Meclis", "advisors": [], "choices": []})
	sim.pending = [{"event": result, "age": 0}]
	sim.mesai = 4
	sim.resolve_decision(0, 0)
	_check(sim.pending[0]["event"]["kind"] == "government_formation", "election result leads to a separate government formation decision")
	sim.mesai = 4
	sim.resolve_decision(0, 1)
	_check(sim.government_pm == "kessler" and sim.government_coalition == ["royal", "independents"], "election result choice forms a bloc coalition")
	sim.parliament_blocs["royal"]["loyalty"] = 0.0
	sim.parliament_blocs["royal"]["pressure"] = 100.0
	sim.parliament_blocs["independents"]["loyalty"] = 0.0
	sim.parliament_blocs["independents"]["pressure"] = 100.0
	sim.government_coalition.assign(["royal", "independents"])
	sim.government_pm = "kessler"
	sim.week = 20
	sim.pending.clear()
	sim._tick_parliament()
	_check(not sim.pending.is_empty() and sim.pending[0]["event"]["kind"] == "confidence_vote", "lost Veyra coalition support queues a confidence vote")
	sim.mesai = 4
	var force_cost: float = sim.king_strength
	sim.resolve_decision(0, 2)
	_check(sim.government_pm == "kessler" and sim.king_strength < force_cost and sim.flags.has("CONFIDENCE_FORCE_TRACE_20") and sim.facts.has("confidence_force_20"), "force rescue survives at a visible political and treasury cost with a trace")
	sim.government_coalition.assign(["royal", "nobles"])
	sim.parliament_blocs["royal"]["loyalty"] = 0.0
	sim.parliament_blocs["royal"]["pressure"] = 100.0
	sim.parliament_blocs["nobles"]["loyalty"] = 0.0
	sim.parliament_blocs["nobles"]["pressure"] = 100.0
	sim.last_confidence_week = 0
	sim.pending.clear()
	sim._tick_parliament()
	sim.mesai = 4
	sim.resolve_decision(0, 1)
	_check(sim.government_pm == "" and sim.finance_report_source == "dorn" and sim.pending[0]["event"]["kind"] == "government_appointment", "government fall transfers finance reporting and asks for a new PM")
	_check(sim.government_status_line().contains("geçici yönetim") and sim.government_status_line().contains("Kraliçe Helena"), "caretaker cabinet and finance reporter are clear while the office is vacant")
	sim.mesai = 4
	sim.resolve_decision(0, 1)
	_check(sim.government_pm == "dorn" and sim.finance_report_source == "dorn", "new PM appointment retains budget and finance reporting")
	sim.reports.clear()
	sim._generate_reports()
	_check(not sim.economy_journal_line().contains("raporu bu hafta masaya ulaşmadı"), "finance report remains available after Veyra leaves office")
	sim.pending.clear()
	sim.week = 26
	sim._fire_budget()
	_check(not sim.pending.is_empty() and sim.pending[0]["event"]["advisors"].has("dorn"), "R1 budget choices use the acting finance reporter")


func _check_migration_and_save() -> void:
	sim.new_game(43, 1)
	sim.government_pm = "brandt"
	sim.government_coalition.assign(["opposition", "independents"])
	sim.finance_report_source = "dorn"
	sim.last_confidence_week = 17
	sim.save_game()
	var saved: Dictionary = str_to_var(FileAccess.get_file_as_string(sim.save_path))
	_check(int(saved["version"]) == sim.SAVE_VERSION and saved["government_pm"] == "brandt", "R3c government state is saved")
	var old := saved.duplicate(true)
	old["version"] = 17
	for key in ["government_rng", "government_pm", "government_coalition", "finance_report_source", "last_confidence_week"]:
		old.erase(key)
	var migrated: Dictionary = sim._migrate_save(old, 17)
	_check(migrated["government_pm"] == "kessler" and migrated["finance_report_source"] == "kessler" and migrated["government_coalition"] == ["royal", "nobles"], "v17 saves migrate to Veyra's existing cabinet")
	_check(int(migrated["government_rng"]) != int(saved["rng"]), "migrated election RNG is seeded separately from the main RNG")
	_check(sim.load_game() and sim.government_pm == "brandt" and sim.finance_report_source == "dorn", "current save round-trips government and finance state")


func _check_achievements() -> void:
	sim.stats["elections"] = 1
	sim.stats["government_formations"] = 1
	sim.stats["confidence_votes"] = 1
	for achievement in ["sandik_mandati", "koalisyon_mimari", "guven_oyunu"]:
		_check(sim.ACHIEVEMENTS.has(achievement), "achievement exists: " + achievement)


func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
