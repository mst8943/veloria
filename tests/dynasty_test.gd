extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

func _init() -> void:
	Loc.set_lang("tr")
	var sim = SimScript.new()
	sim.record_chronicle = false
	sim.autosave = false
	sim.dynasty_path = "user://dynasty_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.dynasty_path))
	sim.new_game(101)
	sim.flags["halef_karari_1"] = 100
	sim.record = {"title": "Medya Rejimi", "survived": true, "king": sim.king_name, "weeks": 104, "regime": "Medya Rejimi"}
	sim._record_dynasty(sim.record)
	var first: Dictionary = sim.dynasty_record()
	_check("ilk nesil yalnız halef kararıyla sürer", first.eligible and first.generations == 1 and first.entries.size() == 1 and first.legacy.next_king == "Julian Valerius")
	sim.new_game(102, -1, "", sim.dynasty_legacy())
	sim.flags["halef_karari_1"] = 100
	sim.record = {"title": "Medya Rejimi", "survived": true, "king": sim.king_name, "weeks": 104, "regime": "Medya Rejimi"}
	sim._record_dynasty(sim.record)
	var second: Dictionary = sim.dynasty_record()
	_check("ikinci nesil sayılır ve miras azalır", second.generations == 2 and second.entries.size() == 2 and second.entries[1].generation == 2 and sim.king_name == "Julian Valerius")
	sim.record = {"title": "Devrilen Kral", "survived": false, "king": sim.king_name, "weeks": 42, "regime": ""}
	sim.flags.erase("halef_karari_1")
	sim._record_dynasty(sim.record)
	var lost: Dictionary = sim.dynasty_record()
	_check("kayıp hanedan devamını ve sayacı sıfırlar", not lost.eligible and lost.generations == 0 and lost.legacy.is_empty() and lost.entries.size() == 2)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.dynasty_path))
	sim.free()
	print("DYNASTY: OK" if _ok else "DYNASTY: FAIL")
	quit(0 if _ok else 1)

var _ok := true
func _check(label: String, condition: bool) -> void:
	print(("ok  " if condition else "FAIL ") + label)
	_ok = _ok and condition
