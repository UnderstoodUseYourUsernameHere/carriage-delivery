@tool
class_name PlaceholderSprite
extends Sprite2D

@export var placeholder_size := Vector2(64, 36):
	set(value):
		placeholder_size = value
		queue_redraw()

@export var placeholder_color := Color("#b07a45"):
	set(value):
		placeholder_color = value
		queue_redraw()

@export var placeholder_label := "":
	set(value):
		placeholder_label = value
		queue_redraw()

func _draw() -> void:
	if texture != null:
		return
	
	var rect := Rect2(-placeholder_size * 0.5, placeholder_size)
	if not centered:
		rect.position = Vector2.ZERO
	
	draw_rect(rect, placeholder_color)
	draw_rect(rect, placeholder_color.darkened(0.5), false, 2.0)
	
	var nose := Vector2(rect.end.x, rect.get_center().y)
	draw_colored_polygon(PackedVector2Array([
		nose + Vector2(10, 0), nose + Vector2(0, -6), nose + Vector2(0, 6),
	]), placeholder_color.darkened(0.5))
	
	if not placeholder_label.is_empty():
		var baseline := Vector2(rect.position.x, rect.get_center().y + 4.0)
		draw_string(ThemeDB.fallback_font, baseline, placeholder_label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color.BLACK)
