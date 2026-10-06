extends SceneTree

var main: Control

func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	main = (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_run.call_deferred()

func _run() -> void:
	for i in 20:
		await process_frame
	main._on_flow("gundem")
	for i in 5:
		await process_frame
	var card: Control = main._cards.values()[0]
	var pos := card.get_global_rect().get_center()
	_click_at(pos)
	await process_frame
	if main._sel != ["arden"]:
		printerr("UI INPUT: kişi kartı seçilemedi: ", main._sel)
		quit(1)
		return
	main._sel.clear()
	var report: Control = main._report_box.get_child(1)
	var expected := str(root.get_node("Sim").reports[0]["source"])
	_click_at(report.get_global_rect().get_center())
	await process_frame
	if main._sel != [expected]:
		printerr("UI INPUT: rapordan kişi seçilemedi: ", main._sel)
		quit(1)
		return
	print("UI INPUT: OK")
	quit(0)

func _click_at(pos: Vector2) -> void:
	var move := InputEventMouseMotion.new()
	move.position = pos
	move.global_position = pos
	root.push_input(move, true)
	var click := InputEventMouseButton.new()
	click.position = pos
	click.global_position = pos
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	root.push_input(click, true)
