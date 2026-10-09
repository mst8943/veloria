extends SceneTree

const Order := preload("res://game/ui/strip_order.gd")

func _initialize() -> void:
	var core := Order.strip_ids(4, false, [], [], [], "", "")
	assert(core == ["arden", "voss", "kessler", "halden", "prens"])
	var changed := Order.strip_ids(4, false, [], ["elena"], [], "", "")
	assert(changed[0] == "elena")
	var full := Order.strip_ids(4, false, ["arden", "voss", "kessler", "halden", "prens"], ["arden"], [], "julian", "")
	assert(full.size() == 5 and full.has("julian") and full.count("arden") == 1)
	assert(Order.strip_ids(2, true, ["elena"], [], [], "", "") == core)
	print("UI LOGIC: OK")
	quit()
