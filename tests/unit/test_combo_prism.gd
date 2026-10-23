extends TestCase
## TEST-CMB-01…05 (FR-CMB-001/003), TEST-PRM-01…05 (FR-PRM-001…005).

var config := GameConfig.new()


func test_cmb_01_idle_to_active() -> void:
	var combo := ComboTracker.new(config)
	check_eq(combo.state, ComboTracker.State.IDLE, "estado inicial")
	combo.on_hit()
	check_eq(combo.state, ComboTracker.State.ACTIVE, "IDLE → ACTIVE")
	check_eq(combo.count, 1, "c = 1")


func test_cmb_02_active_to_broken_and_idle() -> void:
	var combo := ComboTracker.new(config)
	for i: int in 7:
		combo.on_hit()
	check_eq(combo.on_error(), 7, "combo previo")
	check_eq(combo.state, ComboTracker.State.BROKEN, "ACTIVE → BROKEN")
	check_eq(combo.count, 0, "c = 0")
	combo.advance(0.49)
	check_eq(combo.state, ComboTracker.State.BROKEN, "sigue BROKEN antes de 0.5 s")
	combo.advance(0.02)
	check_eq(combo.state, ComboTracker.State.IDLE, "BROKEN → IDLE tras 0.5 s")
	check_eq(combo.best, 7, "mejor combo")


func test_cmb_03_broken_to_active() -> void:
	var combo := ComboTracker.new(config)
	combo.on_hit()
	combo.on_error()
	combo.on_hit()
	check_eq(combo.state, ComboTracker.State.ACTIVE, "BROKEN → ACTIVE")
	check_eq(combo.count, 1, "c = 1")


func test_cmb_04_error_in_idle_stays_idle() -> void:
	var combo := ComboTracker.new(config)
	check_eq(combo.on_error(), 0, "sin combo previo")
	check_eq(combo.state, ComboTracker.State.IDLE, "IDLE + error = IDLE")


func test_cmb_05_tier_up_signal() -> void:
	var combo := ComboTracker.new(config)
	var ups: Array[int] = []
	for i: int in 12:
		if combo.on_hit():
			ups.append(combo.count)
	check_eq(ups, [5, 10] as Array[int], "sube de nivel en c=5 y c=10")


func test_prm_01_charge_and_halving() -> void:
	var prism := PrismController.new(config)
	for i: int in 24:
		prism.on_hit()
	check_eq(prism.charge, 96, "24 aciertos")
	check(not prism.try_activate(), "no activa con 96")
	prism.charge = 63
	prism.on_error()
	check_eq(prism.charge, 31, "floor(63/2)")
	prism.on_crystal_hit()
	check_eq(prism.charge, 51, "+20 por cristal")


func test_prm_02_activation_at_full_charge() -> void:
	var prism := PrismController.new(config)
	for i: int in 25:
		prism.on_hit()
	check(prism.try_activate(), "activa con 100")
	check_eq(prism.charge, 0, "Q ← 0")
	check(prism.active, "activo")
	check(not prism.try_activate(), "no reactivable estando activo")
	prism.on_hit()
	check_eq(prism.charge, 0, "no carga durante PRISM")


func test_prm_03_warning_and_end() -> void:
	var prism := PrismController.new(config)
	prism.charge = 100
	prism.try_activate()
	var events: Array[int] = []
	var steps: int = 0
	while prism.active and steps < 1000:
		var event: PrismController.Event = prism.advance(config.sim_step)
		steps += 1
		if event != PrismController.Event.NONE:
			events.append(event)
			if event == PrismController.Event.WARNING:
				check_near(prism.time_left, 1.5, config.sim_step, "aviso a 1.5 s del fin")
	check_eq(events, [PrismController.Event.WARNING, PrismController.Event.ENDED] as Array[int], "aviso y fin una vez")
	check_eq(steps, 360, "6 s = 360 pasos")
