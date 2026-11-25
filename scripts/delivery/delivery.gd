extends Control

enum Seat { CABIN, DRIVER }
var _seat: Seat = Seat.CABIN

@onready var _cabin_view: Control = $CabinView
@onready var _driver_view: Control = $DriverView
@onready var _status: Label = $Status

func _ready() -> void:
	var take_reins: Button = $CabinView/TakeReins
	var return_to_cabin: Button = $DriverView/ReturnToCabin
	take_reins.pressed.connect(_set_seat.bind(Seat.DRIVER))
	return_to_cabin.pressed.connect(_seat.bind(Seat.CABIN))
	_set_seat(Seat.CABIN)

func _set_seat(next_seat: Seat) -> void:
	_seat = next_seat
	_cabin_view.visible = _seat == Seat.CABIN
	_driver_view.visible = _seat == Seat.DRIVER
	_refresh_hud()

func _refresh_hud() -> void:
	_status.text = "CABIN" if _seat == Seat.CABIN else "DRIVER"
