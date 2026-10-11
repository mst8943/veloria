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
	var main_rng: int = sim.rng.state
	sim.economy_report("kessler")
	_check(sim.rng.state == main_rng, "finance report uses the separate economy stream")
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
	sim.resolve_decision(budget_index, 3)
	_check(sim.budget_allocation.values().reduce(func(a: float, b: float) -> float: return a + b, 0.0) == 100.0, "custom budget shares sum to one hundred")
	sim._set_budget_allocation({"army": 35.0, "social": 35.0, "industry": 20.0, "palace": 10.0})
	var due: Array = sim.delayed_economy.map(func(item: Dictionary) -> int: return int(item["due"]) - sim.week)
	due.sort()
	_check(due == [4, 6, 8, 12], "budget effects are scheduled four to twelve weeks later")
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
