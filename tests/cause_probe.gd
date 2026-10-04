extends SceneTree
## Kanıt yok etmeyen dikkatli oyuncu nasıl düşüyor? (Kolay ve Normal)

func _init() -> void:
	var sim: Node = load("res://game/core/sim.gd").new()
	sim.save_path = "user://test_save.txt"
	sim.record_chronicle = false
	sim.autosave = false
	for diff in [0, 1]:
		var causes := {}
		var wins := 0
		var lp_at_end: Array = []
		for s in range(1, 21):
			sim.new_game(s, diff)
			while not sim.ended:
				var guard := 0
				while not sim.pending.is_empty() and sim.mesai > 0 and guard < 6:
					guard += 1
					sim.resolve_decision(0, _best(sim.pending[0]["event"]))
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
				sim.end_week()
			wins += 1 if sim.record["survived"] else 0
			var c: String = sim.record["cause"]
			var key := "tahtta" if sim.record["survived"] else ("darbe" if c.contains("darbe") else ("ayaklanma" if c.contains("ayaklanma") else ("yetkisiz (skandal)" if c.contains("yetkisiz") else "diğer")))
			causes[key] = int(causes.get(key, 0)) + 1
		print("[%s, kanıt yok etmeden] kazanma %d/20  %s" % [sim.DIFFICULTY[diff]["name"], wins, causes])
	quit(0)


func _best(ev: Dictionary) -> int:
	var best := 0
	var best_score := -1e9
	for i in ev["choices"].size():
		var fx: Dictionary = ev["choices"][i].get("fx", {})
		var sc := float(fx.get("king", 0)) * 2.0 - float(fx.get("unrest", 0)) + float(fx.get("economy", 0)) * 0.7 - float(fx.get("opp", 0)) * 0.5
		for aid in fx.get("actors", {}):
			var d: Dictionary = fx["actors"][aid]
			sc -= float(d.get("power", 0)) * 0.3 + float(d.get("ambition", 0)) * 0.4 + float(d.get("obligation", 0)) * 0.3
		if sc > best_score:
			best_score = sc
			best = i
	return best
