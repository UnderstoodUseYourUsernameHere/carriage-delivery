@tool
class_name CabinCompass
extends Control

const DARK := Color("#49372f")
const BRASS := Color("#d9a84e")
const FACE := Color("#d7c8a3")
const IRON := Color("#4b5a5d")
const NEEDLE := Color("#8c3a52")

var _bearing := 0.0

func _ready() -> void:
	resized.connect(queue_redraw)

func set_bearing(radians: float) -> void:
	if is_equal_approx(radians, _bearing):
		return
	
	_bearing = radians
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.42
	
	if radius <= 0.0:
		return
	
	draw_circle(center + Vector2(2, 3), radius + 3.0, DARK)
	draw_circle(center, radius + 2.0, BRASS)
	draw_circle(center, radius, FACE)
	
	for index in range(8):
		var direction := Vector2.UP.rotated(float(index) * TAU / 8.0)
		
		draw_line(
			center + direction * radius * 0.72,
			center + direction * radius * 0.91,
			IRON,
			1.5,
			true
		)
	
	var forward := Vector2.UP.rotated(_bearing)
	var sideways := forward.orthogonal()
	
	draw_colored_polygon(PackedVector2Array([
		center + forward * radius * 0.72,
		center + sideways * radius * 0.15,
		center - forward * radius * 0.25,
		center - sideways * radius * 0.15,
	]), NEEDLE)
	
	draw_circle(center, 2.5, IRON)
