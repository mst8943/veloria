extends SceneTree
## Scenario setup, save round-trip and 80-bot batches at every difficulty.

var ok := true


func _initialize() -> void:
	_run.call_deferred()


func _expect(value: bool, label: String) -> void:
	if not value:
		ok = false
		push_error("SCENARIO: " + label)


func _play_bot(sim: Node) -> void:
	var weeks := 0
	while not sim.ended and weeks < 112:
		weeks += 1
		var guard := 0
		while not sim.pending.is_empty() and sim.mesai > 0 and guard < 4:
			guard += 1
			var event: Dictionary = sim.pending[0]["event"]
			var best := 0
			if event.get("crisis", false):
				best = mini(1, event["choices"].size() - 1)
			else:
				var best_value := -INF
				for i in event["choices"].size():
					var choice: Dictionary = event["choices"][i]
					if not choice.get("available", true):
						continue
					var value: float = sim.choice_value(choice.get("fx", {}))
					if value > best_value:
						best_value = value
						best = i
			sim.resolve_decision(0, best)
		var bribed := false
		while sim.mesai > 0 and not sim.ended:
			var target = null
			for actor in sim.actors.values():
				if not actor.moved and actor.insider and (target == null or actor.rebellion_drive() > target.rebellion_drive()):
					target = actor
			if target == null:
				break
			if target.rebellion_drive() > 0.0 and sim.private_wealth >= 5.0 and not bribed:
				bribed = true
				sim.bribe(target.id)
			elif sim.summon_wait(target.id) == 0:
				sim.summon(target.id)
			else:
				sim.cross_check(target.id)
		if not sim.ended:
			sim.end_week()
	if not sim.ended:
		sim._end(false)


func _run() -> void:
	await process_frame
	var sim: Node = root.get_node("Sim")
	var sfx: Node = root.get_node("Sfx")
	var old_lang := str(sfx.language)
	var old_path := str(sim.save_path)
	sim.save_path = "user://scenario_test_save.txt"
	sim.autosave = false
	sim.record_chronicle = false
	var options: Array = sim.scenario_options()
	var ids: Array = []
	for option: Dictionary in options:
		ids.append(str(option.get("id", "")))
	_expect(ids == ["darbe", "naiplik", "bos_kasa"], "senaryo listesi ve sıra")
	sfx.set_language("en")
	_expect(str(sim.scenario_options()[0]["name"]) == "Coup-prone kingdom", "EN senaryo metni")
	sfx.set_language("tr")

	sim.new_game(431, 1, "darbe")
	_expect(is_equal_approx(sim.actors["arden"].power, 72.0) and is_equal_approx(sim.actors["arden"].ambition, 55.0), "darbe aktör değerleri")
	_expect(sim.flags.has("SENARYO_DARBE") and sim.pending.any(func(p: Dictionary) -> bool: return p["event"]["id"] == "general_atamalari"), "darbe başlangıç olayı")
	sim.save_game()
	sim.scenario_id = ""
	_expect(sim.load_game() and sim.scenario_id == "darbe" and is_equal_approx(sim.actors["arden"].power, 72.0), "senaryo kayıt turu")
	sim.new_game(432, 1, "naiplik")
	_expect(is_equal_approx(sim.heir_maturity, 12.0) and is_equal_approx(sim.actors["dorn"].power, 70.0), "naiplik başlangıç değerleri")
	sim.new_game(433, 1, "bos_kasa")
	_expect(is_equal_approx(sim.private_wealth, 2.0) and is_equal_approx(sim.capacity["maliye"], 28.0)
		and is_equal_approx(sim.treasury, 72.0) and is_equal_approx(sim.economy_metrics["debt"], 28.0), "boş kasa başlangıç değerleri")

	for scenario: Dictionary in options:
		var scenario_id := str(scenario["id"])
		for diff in sim.DIFFICULTY.size():
			var survived := 0
			for run in 80:
				sim.new_game(400000 + diff * 1000 + run, diff, scenario_id)
				_play_bot(sim)
				if sim.record.get("survived", false):
					survived += 1
			if diff == 1:
				_expect(survived >= 20 and survived <= 52, "%s Normal oranı %d/80" % [scenario_id, survived])
			print("SCENARIO BOT %s %s: %d/80" % [scenario_id, sim.DIFFICULTY[diff]["name"], survived])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	sim.save_path = old_path
	sfx.set_language(old_lang)
	print("SCENARIO: OK" if ok else "SCENARIO: FAILED")
	quit(0 if ok else 1)
