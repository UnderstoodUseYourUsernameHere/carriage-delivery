extends Control

enum Seat { CABIN, DRIVER }
var _seat: Seat = Seat.CABIN
var _journey

@onready var _cabin_view: Control = $Overlay/CabinView
@onready var _driver_view: Control = $Overlay/DriverView
@onready var _status: Label = $Overlay/Status
@onready var _travel: PathFollow2D = $Exterior/RoadPath/Travel
@onready var _carriage_art: Sprite2D = $Exterior/RoadPath/Travel/CarriageArt

func _ready() -> void:
	var take_reins: Button = $Overlay/CabinView/TakeReins
	var return_to_cabin: Button = $Overlay/DriverView/ReturnToCabin
	take_reins.pressed.connect(_set_seat.bind(Seat.DRIVER))
	return_to_cabin.pressed.connect(_set_seat.bind(Seat.CABIN))
	_restart()

func _process(delta: float) -> void:
	if _journey.has_arrived():
		return
	_journey.step(delta)
	_present()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart_delivery"):
		_restart()
		get_viewport().set_input_as_handled()

func _restart() -> void:
	_journey = CarriageJourney.new()
	_set_seat(Seat.CABIN)

func _set_seat(next_seat: Seat) -> void:
	_seat = next_seat
	_cabin_view.visible = _seat == Seat.CABIN
	_driver_view.visible = _seat == Seat.DRIVER
	_carriage_art.visible = _seat == Seat.DRIVER 
	_present()

func _present() -> void:
	_travel.progress_ratio = _journey.progress_ratio()
	_refresh_hud()

func _refresh_hud() -> void:
	var seat_text := "TOP-DOWN" if _seat == Seat.DRIVER else "CABIN"
	_status.text = "%s  |  %.1fs / %.0fs  |  R: restart" % [
		seat_text, _journey.elapsed, CarriageJourney.RIDE_SECONDS
	]
	if _journey.has_arrived():
		_status.text += "\n Arrived at Ratticus' cidery at long last!"
