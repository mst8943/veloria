extends SceneTree
## R1 economy state, migration, isolated random stream, policies and budget regression gate.

const Loc := preload("res://game/core/loc.gd")

var failures: Array[String] = []


func _initialize() -> void:
	Loc.set_lang("tr")
	var sim: Node = load("res://game/core/sim.gd").new()
	sim.record_chronicle = false
	sim.autosave = false
	sim.new_game(101)
	_check(sim.economy_metrics.size() == 5, "five hidden economy metrics are initialized")
	_check(sim.economy_metrics.keys().all(func(k: String) -> bool: return float(sim.economy_metrics[k]) >= 0.0 and float(sim.economy_metrics[k]) <= 100.0), "economy metrics stay bounded")
	_check(sim.ACHIEVEMENTS.has("butce_dengesi") and sim.ACHIEVEMENTS.has("uretim_atilimi") and sim.ACHIEVEMENTS.has("fiyat_istikrari"), "three economy achievements are localized")
	sim.treasury = 70.0
	sim.economy_metrics = {"inflation": 20.0, "jobs": 75.0, "debt": 30.0, "trade": 80.0, "growth": 70.0}
	_check(sim._economy_achievement_ids().size() == 3, "healthy economy grants its three conditional achievements")
	sim.new_game(101)
	var main_rng: int = sim.rng.state
	sim.economy_report("kessler")
	_check(sim.rng.state == main_rng, "finance report uses the separate economy stream")
	sim.reports = [{"source": "kessler", "text": "test report"}]
	_check(sim.economy_journal_line().contains("test report"), "journal reuses the current finance report")
	sim.reports.clear()
	_check(sim.economy_journal_line().contains("Maliye raporu"), "journal finance fallback is Turkish")
	Loc.set_lang("en")
	_check(sim.economy_journal_line().contains("finance report"), "journal finance fallback is English")
	Loc.set_lang("tr")
	var old_save: Dictionary = sim._migrate_save({"seed": 101, "economy": 61.0, "treasury": 44.0}, 12)
	_check(old_save.has("economy_metrics") and old_save.has("economy_rng") and int(old_save["version"]) == sim.SAVE_VERSION, "v12 save receives economy migration")
	var v13: Dictionary = sim._migrate_save({"seed": 101, "economy": 61.0, "treasury": 44.0}, 13)
	_check(v13.has("budget_allocation") and v13.get("delayed_economy", null) is Array, "v13 save receives budget migration")
	sim.pending.clear()
	sim.week = 13
	sim._fire_budget()
	var budget_index := -1
	var budget: Dictionary = {}
	for i in sim.pending.size():
		var candidate: Dictionary = sim.pending[i].get("event", {})
		if str(candidate.get("id", "")) == "ceyrek_butce":
			budget_index = i
			budget = candidate
	var choices: Array = budget.get("choices", [])
	_check(choices.size() == 4 and choices[0].get("fx", {}).has("budget_allocation"), "quarterly budget offers three packages and custom allocation")
	_check(choices[3]["fx"].get("budget_custom", false) and float(choices[3]["fx"]["budget_allocation"]["social"]) == 70.0 and choices[3]["fx"]["budget_allocation"].values().reduce(func(a: float, b: float) -> float: return a + b, 0.0) == 100.0, "custom budget editor starts from a high-social split totaling one hundred")
	_check(sim._advice._advice_value(choices[3]["fx"]) < sim.choice_value(choices[1]["fx"]), "council values delayed social debt before recommending a budget")
	_check(int(choices[2]["fx"]["budget_stance"]) == 1, "generous budget keeps its baseline stance effect")
	sim.resolve_decision(budget_index, 3)
	_check(sim.budget_allocation.values().reduce(func(a: float, b: float) -> float: return a + b, 0.0) == 100.0, "custom budget shares sum to one hundred")
	_check(sim.delayed_economy.size() == 4, "custom high-social allocation schedules all sector changes")
	sim.delayed_economy.clear()
	sim._set_budget_allocation({"army": 35.0, "social": 35.0, "industry": 20.0, "palace": 10.0})
	var due: Array = sim.delayed_economy.map(func(item: Dictionary) -> int: return int(item["due"]) - sim.week)
	due.sort()
	_check(due == [4, 6, 8, 12], "budget effects are scheduled four to twelve weeks later")
	sim.new_game(202)
	sim.treasury = 40.0
	sim.economy_policy("tax_raise")
	var first_tax_gain: float = sim.treasury - 40.0
	sim.treasury = 40.0
	sim.economy_policy("tax_raise")
	_check(first_tax_gain > sim.treasury - 40.0 and sim.stats["economy_policy_tax_raise"] == 2, "repeated tax measures have diminishing returns")
	var queued_before: int = sim.delayed_economy.size()
	sim.economy_policy("incentive")
	_check(sim.delayed_economy.size() == queued_before + 1 and sim.delayed_economy[-1]["due"] == sim.week + 6, "incentives arrive later rather than immediately")
	var low_debt: Node = load("res://game/core/sim.gd").new()
	low_debt.new_game(303)
	low_debt.economy_metrics["debt"] = 0.0
	sim.new_game(303)
	sim.economy_metrics["debt"] = 90.0
	sim.ext_rng.seed = 555
	low_debt.ext_rng.seed = 555
	var ext_main_rng: int = sim.rng.state
	sim._tick_external_pressure()
	low_debt._tick_external_pressure()
	_check(sim.ext_pressure["asteria"] > low_debt.ext_pressure["asteria"] and sim.rng.state == ext_main_rng, "debt raises foreign pressure on the separate stream")
	var easy_debt: Node = load("res://game/core/sim.gd").new()
	easy_debt.new_game(404, 0)
	easy_debt.budget_allocation["social"] = 70.0
	easy_debt.economy_metrics["debt"] = 90.0
	easy_debt.ext_rng.seed = 777
	sim.new_game(404, 2)
	sim.budget_allocation["social"] = 70.0
	sim.economy_metrics["debt"] = 90.0
	sim.ext_rng.seed = 777
	easy_debt._tick_external_pressure()
	sim._tick_external_pressure()
	_check(easy_debt.ext_pressure["asteria"] < sim.ext_pressure["asteria"], "social debt feeds siege pressure less on Easy than Hard")
	sim.pending.clear()
	sim.other_crisis.clear()
	sim.week = 40
	sim.crisis_cooldown = 0
	sim.treasury = 40.0
	sim.ext_pressure["asteria"] = 65.0
	sim._check_crises()
	_check(sim.other_crisis.get("kind", "") == "siege", "debt pressure converges on the financial siege crisis")
	if failures.is_empty():
		print("ECONOMY: OK")
		quit(0)
	else:
		for failure in failures:
			printerr("FAIL ", failure)
		print("ECONOMY: FAIL (%d)" % failures.size())
		quit(1)


func _check(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)
