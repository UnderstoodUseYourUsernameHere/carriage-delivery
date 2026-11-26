@tool
class_name FruitPips
extends Control

@export var fruit_texture: Texture2D:
	set(value):
		fruit_texture = value
		queue_redraw()
@export var slots := PackedVector2Array([
	Vector2(420, 478), Vector2(450, 470), Vector2(480, 478),
	Vector2(510, 470), Vector2(540, 478)
]):
	set(value):
		slots = value
		queue_redraw()
@export var fruit_size := Vector2(30, 30):
	set(value):
		fruit_size = value
		queue_redraw()
@export var count := 5:
	set(value):
		if value == count:
			return
		count = value
		queue_redraw()

func _draw() -> void:
	for i in mini(count, slots.size()):
		var center := slots[i]
		if fruit_texture != null:
			draw_texture_rect(fruit_texture, Rect2(center - fruit_size * 0.5, fruit_size), false)
		else:
			var radius := fruit_size.x * 0.5
			draw_circle(center, radius, Color("#d93f7d"))
			draw_circle(center + Vector2(0, -radius * 0.8), radius * 0.35, Color("#5fae4a"))
