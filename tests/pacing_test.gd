extends SceneTree
## Tempo analizi: olayların haftalara dağılımı (dikkatli bot, Normal).
##   Godot_console.exe --headless --path . --script res://tests/pacing_test.gd

const BUCKET := 8
const Loc := preload("res://game/core/loc.gd")


func _init() -> void:
	Loc.set_lang("tr")
	var sim: Node = load("res://game/core/sim.gd").new()
	sim.save_path = "user://test_save.txt"
	sim.record_chronicle = false
	sim.autosave = false
	var buckets := {}
	var alive_weeks := {}
	var empty_streaks: Array = []
	var games := 40
	var difficulty := 1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--n="):
			games = maxi(1, int(arg.substr(4)))
		elif arg.begins_with("--diff="):
			difficulty = clampi(int(arg.substr(7)), 0, 2)
	for s in range(1, games + 1):
		sim.new_game(s, difficulty)
		var streak := 0
		var max_streak := 0
		while not sim.ended:
			var before: int = sim.fired_events.size()
			var demands_before: int = sim.halden_demands
			var repeat_before := 0
			for k in sim.fired_events:
				repeat_before += int(sim.fired_events[k])
			_careful_week(sim)
			sim.end_week()
			if sim.week > sim.MAX_WEEKS:
				continue
			var new_this_week := 0
			for k in sim.fired_events:
				# Aktör hamleleri (hamle_*) karar olayı değil; tempo yalnızca kararları sayar.
				if int(sim.fired_events[k]) == sim.week and not str(k).begins_with("hamle_"):
					new_this_week += 1
			new_this_week += sim.halden_demands - demands_before
			var b := int((sim.week - 1) / BUCKET)
			buckets[b] = int(buckets.get(b, 0)) + new_this_week
			alive_weeks[b] = int(alive_weeks.get(b, 0)) + 1
			streak = 0 if new_this_week > 0 else streak + 1
			max_streak = maxi(max_streak, streak)
		empty_streaks.append(max_streak)
	print("Dilim (hafta)   olay/hafta   (yaşayan oyun-haftası)")
	for b in range(0, 14):
		if not alive_weeks.has(b):
			continue
		print("H%3d-%3d        %.2f        (%d)" % [b * BUCKET + 1, (b + 1) * BUCKET, float(buckets.get(b, 0)) / alive_weeks[b], alive_weeks[b]])
	empty_streaks.sort()
	print("En uzun olaysız seri (medyan / en kötü): %d / %d hafta" % [empty_streaks[games / 2], empty_streaks[-1]])
	quit(0)


func _careful_week(sim: Node) -> void:
	var guard := 0
	while not sim.pending.is_empty() and sim.mesai > 0 and guard < 6:
		guard += 1
		sim.resolve_decision(0, 0)
	while sim.mesai > 0:
		var target: Object = null
		for a in sim.actors.values():
			if a.moved or not a.insider:
				continue
			if target == null or a.rebellion_drive() > target.rebellion_drive():
				target = a
		if target == null:
			break
		if target.rebellion_drive() > 0.0 and sim.private_wealth >= 5.0:
			sim.bribe(target.id)
		else:
			sim.cross_check(target.id)
