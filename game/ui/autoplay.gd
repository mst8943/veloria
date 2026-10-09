extends RefCounted
## Otomatik oynatma testi (main.gd'den ayrıldı): `-- --autoplay` (rastgele), `--mobile`, `--full` (Kolay'da
## dikkatli oynayarak 104 hafta; geç oyun olayları, miras kararı, zafer finali ve oyun sonu ekranı).
## Arayüz düğmelerine basarak oynar; ana ekranın alanlarına `m` üzerinden erişir.

var m: Control   # main.gd


func _init(main: Control) -> void:
	m = main


## Tam saltanat: Kolay seviyede dikkatli oynayarak 104 haftayı arayüz üzerinden tamamlamaya çalışır.
## Geç oyun olaylarını, miras kararını, zafer finalini ve oyun sonu ekranını sınar.
func _autoplay_full() -> void:
	var seeds_tried := 0
	while seeds_tried < 6:
		seeds_tried += 1
		Sim.new_game(100 + seeds_tried, 0)
		m._after_load("tam saltanat testi")
		while not Sim.ended:
			await m.get_tree().process_frame
			var guard := 0
			while not m._decision_buttons.is_empty() and Sim.mesai > 0 and guard < 4:
				guard += 1
				var e: Dictionary = Sim.pending[0]["event"]
				var best := 0
				for i in e["choices"].size():
					if not e["choices"][i].get("available", true) or Sim.private_wealth + float(e["choices"][i].get("fx", {}).get("wealth", 0)) < 0.0:
						continue
					if not e["choices"][best].get("available", true) or Sim.choice_value(e["choices"][i].get("fx", {})) > Sim.choice_value(e["choices"][best].get("fx", {})):
						best = i
				if e.get("crisis", false):
					best = 1   # kriz kartı: taviz / uzlaşma (etkisi boş seçenekleri choice_value ayırt edemez)
				# Kart düğmeleri seçenek sırasıyla dizili: ilk kartın düğmesine bas
				m._decision_buttons[best].pressed.emit()
				await m.get_tree().process_frame
			# Dikkatli oyuncu: haftada en fazla bir gizli ödeme (her ödeme iz bırakır, izler mahkemeye gider);
			# kalan mesai huzura çağırma ya da doğrulama.
			var bribed := false
			while Sim.mesai > 0 and not Sim.ended:
				var target = null
				for a in Sim.actors.values():
					if not a.moved and a.insider and (target == null or a.rebellion_drive() > target.rebellion_drive()):
						target = a
				if target == null:
					break
				m._sel.clear()
				m._sel.append(target.id)
				m._update_info()
				if target.rebellion_drive() > 0.0 and Sim.private_wealth >= 5.0 and not bribed:
					bribed = true
					(m._buttons["bribe"] as Button).pressed.emit()
				elif Sim.summon_wait(target.id) == 0:
					(m._buttons["summon"] as Button).pressed.emit()
				else:
					(m._buttons["cross"] as Button).pressed.emit()
			m._end_btn.pressed.emit()
		var halef: bool = Sim.fired_events.has("halef_karari")
		print("FULLRUN tohum=%d hafta=%d sonuç=%s ünvan=%s miras_kararı=%s olay=%d son_ekran=%s" % [100 + seeds_tried, Sim.record["weeks"],
			"TAHTTA" if Sim.record["survived"] else "DÜŞTÜ", Sim.record["title"], halef, Sim.fired_events.size(), m._end_overlay.visible])
		if Sim.record["survived"]:
			break
	if "--i18n-dump" not in OS.get_cmdline_user_args():
		m.get_tree().quit(0)


func run() -> void:
	if "--full" in OS.get_cmdline_user_args():
		await _autoplay_full()
		return
	var rng := RandomNumberGenerator.new()
	var seed := 11
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			seed = int(arg.substr(7))
	rng.seed = seed
	var pressed := 0
	while not Sim.ended:
		await m.get_tree().process_frame
		var guard := 0
		while not m._decision_buttons.is_empty() and Sim.mesai > 0 and guard < 3:
			guard += 1
			var b: Button = m._decision_buttons[rng.randi() % m._decision_buttons.size()]
			b.pressed.emit()
			pressed += 1
			await m.get_tree().process_frame
		if not m._cards.is_empty():
			var ids: Array = m._cards.keys()
			var pick: String = ids[rng.randi() % ids.size()]
			m._sel.clear()
			m._sel.append(pick)
			if rng.randf() < 0.3:
				m._sel.append(ids[rng.randi() % ids.size()])
			m._update_info()
		var keys := ["promote", "bribe", "cross", "o_soz", "o_ima", "o_sor", "op_dikkat", "op_bol", "appoint_loyal", "appoint_merit", "tender", "train_heir", "delegation"]
		while Sim.mesai > 0 and not Sim.ended:
			var k: String = keys[rng.randi() % keys.size()]
			if k == "tender" and (m._sel.is_empty() or m._sel[0] != "halden"):
				k = "cross"
			if k == "train_heir" and (m._sel.is_empty() or m._sel[0] != "julian"):
				k = "cross"
			if k == "delegation" and (m._sel.is_empty() or not Sim.FOREIGN_ENVOYS.has(m._sel[0])):
				k = "cross"
			(m._buttons[k] as Button).pressed.emit()
			pressed += 1
			if Sim.mesai > 0 and rng.randf() < 0.3:
				break
		if not m._fact_ids.is_empty():
			m._fact_act("destroy", m._fact_ids[0])
		if Sim.week % 3 == 0:
			# Medya üretimini farklı oyun durumlarında da sına
			m._open_media()
			m._media.show_tab("free")
			m._media.show_tab("tv")
			m._media.close_view()
		if Sim.week % 4 == 0:
			# Masa ve harita: her kapıyı ve her kurum panelini aç
			m._desk.open()
			for t in ["gundem", "kisiler", "gunluk", "dosyalar"]:
				m._desk.open()
				m._on_desk_request(t)
			m._city.open()
			for site in m._city._sites:
				if site != "saray":
					m._city.show_site(site)
			m._on_city_request("actor", "arden")
			m._modal.hide()
		m._end_btn.pressed.emit()
	print("AUTOPLAY DONE: tohum=%d hafta=%d basılan=%d sonuç=%s" % [seed, Sim.week, pressed, "TAHTTA" if Sim.record.get("survived", false) else "DÜŞTÜ"])
	if "--i18n-dump" not in OS.get_cmdline_user_args():
		m.get_tree().quit(0)
