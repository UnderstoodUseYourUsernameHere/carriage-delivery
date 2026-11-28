@tool
class_name MapLandmark
extends Node2D

enum Kind { POST, CHECKPOINT, CIDERY }

const DARK := Color("#49372f")
const WOOD := Color("#8a6f5e")
const TRIM := Color("#ae9279")
const IRON := Color("#4b5a5d")
const STONE := Color("#a39a88")
const FRUIT := Color("#d93f7d")
const LAMP := Color("#ffd166")
const CLEARING := Color("#3a5a3e")
const FLAG := Color("#8c3a52")

@export var kind: Kind = Kind.POST:
	set(value):
		kind = value
		queue_redraw()

var _current := false
var _reached := false

func set_state(current: bool, reached: bool) -> void:
	if current == _current and reached == _reached:
		return
	
	_current = current
	_reached = reached
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 68.0, CLEARING)
	
	if _current:
		draw_arc(Vector2.ZERO, 77.0, 0.0, TAU, 40, LAMP, 3.0, true)
	
	match kind:
		Kind.POST:
			_draw_post()
		Kind.CHECKPOINT:
			_draw_checkpoint()
		Kind.CIDERY:
			_draw_cidery()

func _draw_post() -> void:
	draw_rect(Rect2(-34, -18, 48, 46), DARK)
	draw_rect(Rect2(-30, -14, 40, 28), WOOD)
	
	if not _reached:
		for index in range(5):
			draw_circle(
				Vector2(-24 + index * 7, (index % 2) * 5),
				4.0,
				FRUIT
			)
	draw_line(Vector2(30, 15), Vector2(30, -36), DARK, 5.0, true)
	draw_rect(Rect2(16, -42, 42, 16), TRIM)
	draw_rect(Rect2(16, -42, 42, 16), DARK, false, 2.0)

func _draw_checkpoint() -> void:
	for index in range(3):
		draw_circle(
			Vector2(-12 + index * 12, 8 - (index % 2) * 6),
			10.0,
			STONE
		)
	
	draw_line(Vector2.ZERO, Vector2(0, -43), IRON, 3.0 ,true)
	
	var flag_y := -22.0 if _reached else -43.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, flag_y),
		Vector2(28, flag_y + 7),
		Vector2(0, flag_y + 15),
	]), FLAG)

func _draw_cidery() -> void:
	draw_rect(Rect2(-44, -32, 88, 64), DARK)
	draw_rect(Rect2(-40, -28, 80, 56), WOOD)
	
	draw_line(Vector2(-40, -25), Vector2(40, -25), TRIM, 4.0)
	draw_line(Vector2(-40, 0), Vector2(40, 0), DARK, 2.0)
	draw_line(Vector2(-40, 25), Vector2(40, 25), DARK, 2.0)
	
	for x in [-26.0, 26.0]:
		draw_circle(Vector2(x, 43), 8.0, DARK)
		draw_circle(Vector2(x, 43), 5.0, TRIM)
	
	var lamp_position := Vector2(0, 37)
	
	if not _reached:
		draw_circle(
			lamp_position,
			18.0,
			Color(1.0, 0.72, 0.28, 0.15)
		)
	
	draw_circle(
		lamp_position,
		4.5,
		Color("#5a5551") if _reached else LAMP
	)
