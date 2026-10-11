extends SceneTree

const SimScript := preload("res://game/core/sim.gd")
const Loc := preload("res://game/core/loc.gd")

func _init() -> void:
	Loc.set_lang("tr")
	var plain = SimScript.new()
	plain.record_chronicle = false
	plain.autosave = false
	plain.new_game(101)
	var inherited = SimScript.new()
	inherited.record_chronicle = false
	inherited.autosave = false
	inherited.new_game(101, -1, "", {"generation": 3, "next_king": "Julian Valerius", "effects": ["treasury_full", "army_loyal", "reign_wear"]})
	_check("mirassız başlangıç değişmedi", plain.rng.state == inherited.rng.state and plain.week == inherited.week and plain.actors.size() == inherited.actors.size())
	_check("miras ayrı RNG tüketmiyor", plain.rng.state == inherited.rng.state)
	_check("miras etkileri ve nesil aşınması", inherited.king_name == "Julian Valerius" and inherited.treasury > plain.treasury
		and inherited.actors["arden"].loyalty["career"] > plain.actors["arden"].loyalty["career"] and inherited.king_strength == 54.0)
	plain.flags["halef_karari_1"] = 100
	var plan: Dictionary = plain.legacy_for_next_reign(1)
	var effects: Array = plan["effects"]
	var rows_file := FileAccess.open("res://game/data/legacy.json", FileAccess.READ)
	var rows: Array = JSON.parse_string(rows_file.get_as_text())
	var positive := 0
	var negative := 0
	for id in effects:
		for row: Dictionary in rows:
			if row["id"] == id:
				positive += 1 if row["positive"] else 0
				negative += 0 if row["positive"] else 1
	_check("miras üç etkiyi aşmıyor ve artı/eksi taşıyor", effects.size() <= 3 and positive >= 1 and negative >= 1)
	_check("halef sonucu Julian'ı seçiyor", plan["next_king"] == "Julian Valerius")
	plain.free()
	inherited.free()
	print("LEGACY: OK" if _ok else "LEGACY: FAIL")
	quit(0 if _ok else 1)

var _ok := true
func _check(label: String, condition: bool) -> void:
	print(("ok  " if condition else "FAIL ") + label)
	_ok = _ok and condition
