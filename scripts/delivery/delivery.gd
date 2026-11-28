extends Control

enum Seat { CABIN, DRIVER }
var _seat: Seat = Seat.CABIN
var _journey: RoamJourney

@onready var _cabin_view: Control = $Overlay/CabinView
@onready var _driver_view: Control = $Overlay/DriverView
@onready var _status: Label = $Overlay/Status

@onready var _windows: CabinWindows = $Overlay/CabinView/WindowBackdrop
@onready var _wagon_skin: LanternWagon = $Overlay/CabinView/CabinArt
@onready var _map: RoamMap = $Exterior

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
	_refresh_hud()

func _refresh_hud() -> void:
	var seat_text := "MAP - A/D to steer" if _seat == Seat.DRIVER else "CABIN"
	
	_status.text = "%s  |  %s  |  Fruit %d/5  |  Traveled %.0f  |  Target %.0f away  |  Seed %d  |  R: restart" % [
		seat_text,
		_journey.stage_text(),
		_journey.fruit,
		_journey.odometer,
		_journey.distance_to_target(),
		_journey.run_seed
	] 
	
	if _journey.has_arrived():
		_status.text += "\nDelivered %d dragon fruit to Ratticus!" % _journey.fruit
 	
