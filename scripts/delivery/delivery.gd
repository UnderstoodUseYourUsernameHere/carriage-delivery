extends Control

enum Seat { CABIN, DRIVER }
var _seat: Seat = Seat.CABIN
var _journey: RoamJourney

@onready var _cabin_view: CabinCombat = $Overlay/CabinView
@onready var _driver_view: Control = $Overlay/DriverView
@onready var _status: Label = $Overlay/Status

@onready var _windows: CabinWindows = $Overlay/CabinView/WindowBackdrop
@onready var _wagon_skin: LanternWagon = $Overlay/CabinView/CabinArt
@onready var _fruit_pips: FruitPips = $Overlay/CabinView/FruitPips
@onready var _compass: CabinCompass = $Overlay/CabinView/Compass
@onready var _map: RoamMap = $Exterior
@onready var _threat_warning: ThreatWarning = $Overlay/DriverView/ThreatWarning

func _ready() -> void:
	var take_reins: Button = $Overlay/CabinView/TakeReins
	var return_to_cabin: Button = $Overlay/DriverView/ReturnToCabin
	
	take_reins.pressed.connect(_set_seat.bind(Seat.DRIVER))
	return_to_cabin.pressed.connect(_set_seat.bind(Seat.CABIN))
	
	_restart()

func _process(delta: float) -> void:
	var steering := 0.0
	
	if _seat == Seat.DRIVER:
		steering = Input.get_axis(&"steer_left", &"steer_right")
	_journey.step(delta, steering)
	_present()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart_delivery"):
		_restart()
		get_viewport().set_input_as_handled()
		return
	
	if _seat != Seat.CABIN:
		return
	
	var accepted := false
	
	if event.is_action_pressed(&"swing_left"):
		accepted = _journey.try_swing(SkeletonThreat.Flank.LEFT)
	elif event.is_action_pressed(&"swing_right"):
		accepted = _journey.try_swing(SkeletonThreat.Flank.RIGHT)
	
	if not accepted:
		return
	
	_present()
	get_viewport().set_input_as_handled() 

func _restart():
	_journey = RoamJourney.new()
	_map.begin_run(_journey)
	_set_seat(Seat.CABIN)

func _set_seat(next_seat: Seat) -> void:
	_seat = next_seat
	
	_cabin_view.visible = _seat == Seat.CABIN
	_driver_view.visible = _seat == Seat.DRIVER
	_map.visible = _seat == Seat.DRIVER
	
	_present()

func _present() -> void:
	_map.present(_journey)
	_windows.set_road_distance(_journey.odometer)
	_windows.set_heading(_journey.heading)
	_wagon_skin.set_road_distance(_journey.odometer)
	_fruit_pips.count = _journey.fruit
	_compass.set_bearing(_journey.bearing_to_target())
	_cabin_view.present(_journey)
	_threat_warning.present(_journey.active_threat)
	_refresh_hud()

func _refresh_hud() -> void:
	var seat_text := "MAP - A/D to steer" if _seat == Seat.DRIVER else "CABIN"
	var stage_text := _journey.stage_text()
	
	_status.text = seat_text \
	+ "  |  " + stage_text \
	+ "  |  Fruit " + str(_journey.fruit) + "/5" \
	+ "  |  Target " + str(int(_journey.distance_to_target())) + " away" \
	+ "  |  R: restart!"
	
	if _seat == Seat.CABIN:
		var sword_text := "ready"
		
		if _journey.swing_recovery > 0.0:
			sword_text = "recovering"
		
		if _journey.swing_age() < 0.4:
			sword_text += " - HIT" if _journey.last_swing_hit else " - miss"
		
		_status.text += "\nQ/E swing left/right  |  Sword: " + sword_text
	
	if _journey.active_threat != null:
		_status.text += (
			"\nSkeleton "
			+ _journey.active_threat.flank_text()
			+ ": "
			+ _journey.active_threat.phase_text()
		)
	
	if _journey.has_arrived():
		_status.text += (
			"\nDelivered "
			+ str(_journey.fruit)
			+ " dragon fruit to Ratticus!"
		)
