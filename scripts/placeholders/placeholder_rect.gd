@tool
class_name PlaceholderRect
extends TextureRect

@export var placeholder_rect := Rect2(0, 0, 64, 64):
	set(value):
		placeholder_rect = value
		queue_redraw()

@export var placeholder_color := Color("#c9c3b4"):
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
	
	draw_rect(placeholder_rect, placeholder_color)
	draw_rect(placeholder_rect, placeholder_color.darkened(0.5), false, 2.0)
	
	if not placeholder_label.is_empty():
		var baseline := Vector2(placeholder_rect.position.x, placeholder_rect.get_center().y + 5.0)
		draw_string(ThemeDB.fallback_font, baseline, placeholder_label, HORIZONTAL_ALIGNMENT_CENTER, placeholder_rect.size.x, 12, Color.BLACK)
