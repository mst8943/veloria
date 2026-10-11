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
