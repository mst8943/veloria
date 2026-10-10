extends SceneTree
## Extension continuation saves separately, reuses timed event pools, and remains playable past 200 weeks.

var ok := true


func _initialize() -> void:
	_run.call_deferred()


func _expect(value: bool, label: String) -> void:
	if not value:
		ok = false
		push_error("ENDLESS: " + label)


func _result_choice(event: Dictionary, sim: Node) -> int:
	if event.get("crisis", false):
		return mini(1, event.get("choices", []).size() - 1)
	var best := 0
	var best_value := -INF
	for i in event.get("choices", []).size():
		var choice: Dictionary = event["choices"][i]
		if not choice.get("available", true):
			continue
		var value: float = sim.choice_value(choice.get("fx", {}))
		if value > best_value:
			best_value = value
			best = i
	return best


func _restore(path: String, existed: bool, bytes: PackedByteArray) -> void:
	if existed:
		var f := FileAccess.open(path, FileAccess.WRITE)
		f.store_buffer(bytes)
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _run() -> void:
	await process_frame
	var sim: Node = root.get_node("Sim")
	var max_weeks: int = sim.MAX_WEEKS
	var old_path := str(sim.save_path)
	var old_autosave := bool(sim.autosave)
	var old_chronicle := bool(sim.record_chronicle)
	var ext_paths := [sim.EXTENSION_SAVE_PATH, sim.EXTENSION_ACHIEVEMENTS_PATH]
	var backups: Array = []
	for path in ext_paths:
		var exists := FileAccess.file_exists(path)
		var bytes := PackedByteArray()
		if exists:
			var f := FileAccess.open(path, FileAccess.READ)
			bytes = f.get_buffer(f.get_length())
		backups.append([exists, bytes])
	sim.save_path = "user://endless_test_save.txt"
	sim.autosave = false
	sim.record_chronicle = false
	sim.new_game(664, 0)
	sim.week = max_weeks + 1
	sim._end(true)
	_expect(sim.continue_endless(), "tahtta kaydından uzatmaya geçiş")
	_expect(sim.endless and not sim.ended and sim.week == max_weeks + 1, "uzatma durumu")
	_expect(sim.save_path == sim.EXTENSION_SAVE_PATH and FileAccess.file_exists(sim.EXTENSION_SAVE_PATH), "ayrı uzatma kaydı")
	_expect(not sim.continue_endless(), "ikinci kez uzatma başlatmama")
	_expect(sim.load_game() and sim.endless and sim.week == max_weeks + 1, "uzatma kaydı yükleme")

	for actor in sim.actors.values():
		actor.power = 5.0
		actor.ambition = 0.0
		actor.ready = false
		actor.moved = false
		for kind in actor.loyalty:
			actor.loyalty[kind] = 100.0
	sim.king_strength = 100.0
	sim.unrest = 0.0
	sim.economy = 90.0
	sim.opposition = 0.0
	sim.street_anger = 0.0
	sim.legal_relief = 100.0
	sim.pending.clear()
	sim.other_crisis.clear()
	sim.coup_crisis.clear()
	while not sim.ended and sim.week <= 200:
		while not sim.pending.is_empty():
			var event: Dictionary = sim.pending[0]["event"]
			sim.resolve_decision(0, _result_choice(event, sim))
			if sim.ended:
				break
		if not sim.ended:
			sim.end_week()
	_expect(not sim.ended and sim.week >= 201, "200 haftayı aşan bot koşusu")
	_expect(int(sim.fired_events.get("tac_giyme", 0)) >= max_weeks + 1, "bekleme süresinden sonra tek-seferlik olayın yeniden kullanımı")

	var old_week: int = sim.week
	sim.unrest = 52.0
	sim.other_crisis.clear()
	sim.coup_crisis.clear()
	sim.pending.clear()
	sim.week = 130
	sim._check_crises()
	_expect(sim.other_crisis.is_empty(), "ilk 26 uzatma haftasında kriz eşiği")
	sim.week = 131
	sim._check_crises()
	_expect(not sim.other_crisis.is_empty(), "26. haftada eşik 2 puan düşer")
	sim.week = old_week

	_restore(ext_paths[0], backups[0][0], backups[0][1])
	_restore(ext_paths[1], backups[1][0], backups[1][1])
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://endless_test_save.txt"))
	sim.save_path = old_path
	sim.autosave = old_autosave
	sim.record_chronicle = old_chronicle
	print("ENDLESS: OK" if ok else "ENDLESS: FAILED")
	quit(0 if ok else 1)
