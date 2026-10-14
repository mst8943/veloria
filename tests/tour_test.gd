extends SceneTree

var main: Control

func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()

func _run() -> void:
	for i in 24: await process_frame
	var sfx: Node = root.get_node("Sfx")
	var old_done: bool = sfx.tour_done
	var old_enabled: bool = sfx.tour_enabled
	var old_intro: bool = sfx.intro
	var old_desk: bool = sfx.desk_start
	sfx.tour_done = false
	sfx.tour_enabled = true
	sfx.intro = false
	sfx.desk_start = false
	main._instant = false
	main._start_new()
	var sim: Node = root.get_node("Sim")
	if sim.pending.is_empty():
		for event in sim._events:
			if event["id"] == "gida_protestosu":
				sim.pending.append({"event": event, "age": 0})
				break
		main._refresh()
	await process_frame
	if not main._tour.active:
		printerr("TOUR: new game did not start the tour")
		quit(1); return
	main._tour.next_step()
	main._tour.next_step()
	main._tour.next_step()
	for i in 3: await process_frame
	if main._tour.index != 3:
		printerr("TOUR: forward navigation failed")
		quit(1); return
	main._tour.previous()
	await process_frame
	if main._tour.index != 2:
		printerr("TOUR: backward navigation failed")
		quit(1); return
	main._tour.next_step()
	main._tour.next_step()
	for i in 3: await process_frame
	if main._tour.index != 3 or not main._tour._next.disabled:
		printerr("TOUR: first decision gate is not waiting")
		quit(1); return
	main._choose(0, 0)
	await create_timer(0.9).timeout
	for i in 6: await process_frame
	if main._tour.index != 4:
		printerr("TOUR: actual choice did not continue the tour: index=", main._tour.index, " pending=", sim.pending.size(), " buttons=", main._decision_buttons.size(), " busy=", main._busy)
		quit(1); return
	main._tour.next_step()
	await create_timer(0.3).timeout
	if main._tour.index != 5 or not main._person_file.is_open() or main._tour._target() != main._person_file.sheet:
		printerr("TOUR: dossier step did not open and target the person file")
		quit(1); return
	main._tour.next_step()
	await create_timer(0.3).timeout
	if main._tour.index != 6 or main._person_file.is_open():
		printerr("TOUR: leaving dossier step did not close the person file")
		quit(1); return
	main._tour._skip.pressed.emit()
	if main._tour.active or not sfx.tour_done:
		printerr("TOUR: skip did not persist completion")
		quit(1); return
	main._start_new()
	await process_frame
	if main._tour.active:
		printerr("TOUR: completed tour started again on another new game")
		quit(1); return
	sfx.tour_done = false
	main._instant = true
	main._tour.begin()
	if main._tour.active:
		printerr("TOUR: _fast() did not suppress the tour")
		quit(1); return
	sfx.tour_done = old_done
	sfx.tour_enabled = old_enabled
	sfx.intro = old_intro
	sfx.desk_start = old_desk
	sfx.save_settings()
	print("TOUR: OK")
	quit(0)
