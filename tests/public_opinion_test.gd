extends SceneTree

var ok := true

func _initialize() -> void:
	_run.call_deferred()

func _expect(value: bool, label: String) -> void:
	if not value:
		ok = false
		push_error("PUBLIC OPINION: " + label)

func _run() -> void:
	await process_frame
	var sim: Node = root.get_node("Sim")
	var old_path := str(sim.save_path)
	sim.save_path = "user://public_opinion_test.txt"
	sim.autosave = false
	sim.record_chronicle = false
	sim.new_game(991, 1)
	var main_rng: int = sim.rng.state
	var before_consent: float = sim.consent
	sim.mesai = 4
	sim.public_action("speech")
	_expect(sim.consent > before_consent and sim.rng.state == main_rng, "rıza artışı ve ana RNG yalıtımı")
	var before_fear: float = sim.public_fear
	sim.mesai = 4
	sim.public_action("hide")
	_expect(sim.public_fear > before_fear and sim.rng.state == main_rng, "gizlenme korkusu ve RNG yalıtımı")
	sim.week = 8
	sim.pending.clear()
	sim._tick_public_opinion()
	_expect(sim.pending.size() == 1 and sim.pending[0]["event"]["kind"] == "public_poll", "sekiz haftalık anket kartı")
	var consent_before_poll: float = sim.consent
	sim.resolve_decision(0, 0)
	_expect(sim.consent >= consent_before_poll + 2.9, "anket yayınının rıza etkisi")
	sim._add_fact("public_scandal_test", "Test skandalı", "king", 20, ["vale"], 1)
	sim.facts["public_scandal_test"]["public"] = true
	var before_apology: float = sim.consent
	sim.respond_to_scandal("public_scandal_test", "apologize")
	_expect(sim.consent > before_apology, "özür kamuoyu etkisi")
	_expect(sim.respond_to_scandal("public_scandal_test", "deny") == "", "skandal yanıtı tek kullanımlık")
	for response in ["deny", "scapegoat", "redirect"]:
		var id: String = "public_scandal_" + response
		sim._add_fact(id, "Test skandalı", "king", 20, ["vale"], 1)
		sim.facts[id]["public"] = true
		sim.mesai = 4
		_expect(sim.respond_to_scandal(id, response) != "", response + " yanıtı")
	_expect(sim.save_game(), "yeni alanları kaydet")
	var saved_consent: float = sim.consent
	sim.consent = 0.0
	_expect(sim.load_game() and is_equal_approx(sim.consent, saved_consent) and sim.public_opinion_active, "kamuoyu kaydını yükle")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sim.save_path))
	sim.save_path = old_path
	print("PUBLIC OPINION: OK" if ok else "PUBLIC OPINION: FAILED")
	quit(0 if ok else 1)
