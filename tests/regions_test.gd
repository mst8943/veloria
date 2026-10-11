extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

var failures: Array[String] = []


func _initialize() -> void:
	Loc.set_lang("tr")
	var sim: Node = SimScript.new()
	sim.autosave = false
	sim.record_chronicle = false
	sim.save_path = "user://regions_test.sav"
	sim.new_game(101)
	_check(sim.regions.size() == 4, "four regions initialize")
	_check(sim.actors.size() == 18, "four supporting governors join the existing cast")
	_check(absf(_weighted(sim, "unrest") - sim.unrest) < 0.001, "national unrest is the weighted regional summary")
	_check(absf(_weighted(sim, "economy") - sim.economy) < 0.001, "national economy is the weighted regional summary")
	_check(sim.regions.values().map(func(r: Dictionary) -> float: return float(r["unrest"])).max() > sim.regions.values().map(func(r: Dictionary) -> float: return float(r["unrest"])).min(),
		"local unrest differs across regions while its weighted summary stays fixed")
	var target_unrest := 99.25
	var target_economy := 0.4
	sim.unrest = target_unrest
	sim.economy = target_economy
	sim._sync_regions_to_national()
	_check(absf(sim.unrest - target_unrest) < 0.001 and absf(sim.economy - target_economy) < 0.001,
		"regional bounds preserve national values at extremes")
	sim.new_game(101)
	_check(sim.stats["regional_investments"].values().all(func(n: int) -> bool: return n == 0), "R4a has no regional investment actions; all per-region counters remain zero")
	var main_state: int = sim.rng.state
	sim.region_rng.randf()
	_check(sim.rng.state == main_state, "regional generator is independent from the main generator")
	for id in ["capital", "industry", "farmland", "border"]:
		var governor: String = sim.regions[id]["governor"]
		_check(sim.actors.has(governor) and sim.actors[governor].supporting and not sim.actors[governor].insider,
			"%s governor is a supporting environmental actor" % id)
	var report: String = sim.region_report_line()
	_check(report.contains("Başkent") and report.contains("Sınır İlleri") and not report.contains("30.0"), "regional report is qualitative and names all regions")
	var old_save := {"version": 18, "seed": 101, "unrest": 27.5, "economy": 61.25}
	var migrated: Dictionary = sim._migrate_save(old_save, 18)
	_check(int(migrated["version"]) == 19 and absf(_weighted_data(migrated["regions"], "unrest") - 27.5) < 0.001,
		"v18 migration preserves the national unrest level")
	_check(absf(_weighted_data(migrated["regions"], "economy") - 61.25) < 0.001, "v18 migration preserves the national economy level")
	Loc.set_lang("en")
	sim.new_game(102)
	_check(sim.actors["governor_capital"].display_name == "Mira Solen"
		and sim.actors["governor_capital"].red_line == "Use of force against civilians"
		and sim.region_report_line().contains("Capital"),
		"governor and regional report content are localized in English")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	if failures.is_empty():
		print("REGIONS: OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _weighted(sim: Node, field: String) -> float:
	var result := 0.0
	for id in sim.REGION_WEIGHTS:
		result += float(sim.regions[id][field]) * float(sim.REGION_WEIGHTS[id])
	return result


func _weighted_data(data: Dictionary, field: String) -> float:
	var result := 0.0
	for id in SimScript.REGION_WEIGHTS:
		result += float(data[id][field]) * float(SimScript.REGION_WEIGHTS[id])
	return result


func _check(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)
