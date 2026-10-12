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
	_check(sim.actors.size() == 21, "the four governors join the existing cast")
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
	_check(sim.stats["regional_investments"].values().all(func(n: int) -> bool: return n == 0), "regional investment counters start clear")
	sim.pending.clear()
	sim.week = 12
	var action_mesai: int = sim.mesai
	_check(sim.request_regional_decision().contains("gündeme") and sim.pending[0]["event"]["choices"].size() == 4,
		"regional management opens a four-region decision on request")
	sim.resolve_decision(0, 0)
	_check(sim.pending[0]["event"]["choices"].size() <= 4 and sim.mesai == action_mesai,
		"region selection opens a compact action card without spending an extra action point")
	sim.pending.clear()
	sim.new_game(101)
	var treasury_before: float = sim.treasury
	var main_before: int = sim.rng.state
	_check(sim._resolve_region_action({"action": "invest", "region": "industry"}) != "", "investment decision resolves")
	_check(sim.treasury == treasury_before - 8.0 and sim.stats["regional_investments"]["industry"] == 1,
		"investment spends treasury and records its region")
	_check(sim.rng.state == main_before and sim.regional_effects.size() == 1, "investment leaves main RNG untouched and schedules a delayed effect")
	sim.budget_allocation["army"] = 40.0
	sim._resolve_region_action({"action": "garrison", "region": "capital"})
	_check(float(sim.regions["capital"]["garrison"]) > 0.0 and sim.stats["regional_garrisons"]["capital"] == 1,
		"army allocation supports a regional garrison")
	sim._resolve_region_action({"action": "media", "region": "border"})
	_check(sim.stats["regional_media"]["border"] == 1 and sim.regions["border"]["media"] > 0.0,
		"local media support is recorded in its region")
	sim.budget_allocation["industry"] = 10.0
	var denied_cost: float = sim.treasury
	var denied_result: String = sim._resolve_region_action({"action": "invest", "region": "capital"})
	_check(denied_result != "" and is_equal_approx(sim.treasury, denied_cost), "low R1 industry allocation blocks investment without charging treasury")
	sim.budget_allocation["industry"] = 25.0
	var governor: String = sim.regions["capital"]["governor"]
	sim._resolve_region_action({"action": "dismiss", "region": "capital"})
	_check(sim.regions["capital"]["governor"] == "" and not sim._governor_assigned(governor), "governor dismissal opens the post")
	sim._resolve_region_action({"action": "appoint", "region": "capital", "actor": governor})
	_check(sim.regions["capital"]["governor"] == governor, "vacant governorship can be filled")
	var closed_event := {"id": "closed_region_options", "choices": [{"available": false, "fx": {}}]}
	var advice_rng := RandomNumberGenerator.new()
	advice_rng.seed = 1
	var closed_advice: Dictionary = sim._advice._advise(sim.actors["arden"], closed_event, advice_rng)
	_check(int(closed_advice.get("rec", -2)) == -1,
		"advisor handles a decision with no available options")
	var economy_before_local_effect: float = sim.economy
	sim.week = 5
	sim._tick_region_systems()
	sim._sync_regions_to_national()
	_check(sim.economy > economy_before_local_effect, "delayed regional investment flows into the national weighted economy")
	var main_state: int = sim.rng.state
	sim.region_rng.randf()
	_check(sim.rng.state == main_state, "regional generator is independent from the main generator")
	var crisis_found := false
	sim.regions["industry"]["economy"] = 20.0
	var main_rng_crisis: int = sim.rng.state
	for seed in range(1, 26):
		sim.pending.clear()
		sim.other_crisis.clear()
		sim.region_rng.seed = seed
		sim._check_regional_crisis()
		if not sim.pending.is_empty():
			crisis_found = sim.pending[0]["event"].get("crisis_kind", "") == "regional"
			break
	_check(crisis_found and sim.rng.state == main_rng_crisis, "regional crisis uses its separate RNG and creates a decision card")
	if crisis_found:
		var crisis: Dictionary = sim.pending[0]["event"]
		_check(str(crisis["title"]).contains("Sanayi Kuşağı") and crisis["choices"].size() == 2,
			"industrial crisis is localized and offers two responses")
	for crisis_case: Dictionary in [
		{"id": "famine", "region": "farmland", "field": "economy", "value": 10.0, "name": "Tarım Ovaları"},
		{"id": "border", "region": "border", "field": "unrest", "value": 90.0, "name": "Sınır İlleri"},
		{"id": "disorder", "region": "capital", "field": "unrest", "value": 90.0, "name": "Başkent"}]:
		sim.new_game(102)
		sim.regions[crisis_case["region"]][crisis_case["field"]] = crisis_case["value"]
		var crisis_title := _find_region_crisis(sim)
		_check(crisis_title.contains(crisis_case["name"]), "%s crisis has a region-specific card" % crisis_case["id"])
	sim.stats["regional_actions"] = 4
	sim.stats["regional_investments"] = {"capital": 1, "industry": 1, "farmland": 0, "border": 1}
	sim.stats["regional_media"] = {"capital": 1, "industry": 1, "farmland": 1, "border": 0}
	var regional_badges: Array = sim._region_achievement_ids()
	_check(regional_badges.size() == 3, "three regional achievements have reachable conditions")
	for id in ["capital", "industry", "farmland", "border"]:
		var governor_id: String = sim.regions[id]["governor"]
		_check(sim.actors.has(governor_id) and sim.actors[governor_id].supporting and not sim.actors[governor_id].insider,
			"%s governor is a supporting environmental actor" % id)
	var report: String = sim.region_report_line()
	_check(report.to_lower().contains("öne çıkıyor") and report.to_lower().contains("diğer bölgeler") and not report.contains("30.0"), "regional report highlights one region and summarizes the rest without numbers")
	var old_save := {"version": 18, "seed": 101, "unrest": 27.5, "economy": 61.25}
	var migrated: Dictionary = sim._migrate_save(old_save, 18)
	_check(int(migrated["version"]) == 22 and absf(_weighted_data(migrated["regions"], "unrest") - 27.5) < 0.001,
		"v18 migration preserves the national unrest level")
	_check(absf(_weighted_data(migrated["regions"], "economy") - 61.25) < 0.001, "v18 migration preserves the national economy level")
	var v19_regions: Dictionary = sim._new_regions(27.5, 61.25)
	var v19_capital_unrest: float = v19_regions["capital"]["unrest"]
	var migrated_v19: Dictionary = sim._migrate_save({"version": 19, "seed": 101, "unrest": 27.5, "economy": 61.25,
		"regions": v19_regions, "stats": {}}, 19)
	_check(is_equal_approx(float(migrated_v19["regions"]["capital"]["unrest"]), v19_capital_unrest)
		and float(migrated_v19["regions"]["capital"]["garrison"]) == 0.0,
		"v19 migration retains regional values and initializes R4b fields")
	Loc.set_lang("en")
	sim.new_game(102)
	_check(sim.actors["governor_capital"].display_name == "Mira Solen"
		and tr(sim.actors["governor_capital"].red_line) == "Use of force against civilians"
		and (sim.region_report_line().contains("Capital") or sim.region_report_line().contains("Industrial Belt") or sim.region_report_line().contains("Farming Plains") or sim.region_report_line().contains("Border Provinces")),
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


func _find_region_crisis(sim: Node) -> String:
	for seed in range(1, 60):
		sim.pending.clear()
		sim.region_rng.seed = seed
		sim._check_regional_crisis()
		if not sim.pending.is_empty():
			return str(sim.pending[0]["event"]["title"])
	return ""


func _check(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)
