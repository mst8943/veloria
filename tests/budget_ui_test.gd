extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	ProjectSettings.set_setting("veloria/dev_autostart", true)
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var main := (load("res://game/ui/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	for frame in 20:
		await process_frame
	main._instant = true
	var sim: Node = root.get_node("Sim")
	sim.pending.clear()
	sim.week = 13
	sim._fire_budget()
	main._open_budget_editor(0, 3)
	await process_frame
	_check(main._budget_editor_spins.size() == 4, "custom editor has four budget shares")
	var body: VBoxContainer = main._budget_editor.get_child(1).get_child(0).get_child(0).get_child(0)
	var apply: Button = body.get_child(6).get_child(0)
	_check(not apply.disabled, "custom starting allocation totals one hundred")
	_check(apply.custom_minimum_size.y >= 44, "custom editor apply button is at least 44px")
	main._budget_editor_spins[0].value = 15
	_check(apply.disabled, "custom allocation rejects a total over one hundred")
	main._budget_editor_spins[1].value = 65
	_check(not apply.disabled, "custom allocation accepts a total of one hundred")
	apply.pressed.emit()
	for frame in 3:
		await process_frame
	_check(sim.budget_allocation == {"army": 15.0, "social": 65.0, "industry": 10.0, "palace": 10.0}, "custom allocation is applied to the selected budget")
	_check(sim.delayed_economy.size() == 4, "custom shares schedule all four delayed effects")
	if failures.is_empty():
		print("BUDGET UI: OK")
		quit(0)
	else:
		for failure in failures:
			printerr("FAIL ", failure)
		print("BUDGET UI: FAIL (%d)" % failures.size())
		quit(1)


func _check(ok: bool, label: String) -> void:
	if not ok:
		failures.append(label)
