@tool
class_name CabinWindows
extends ColorRect

@export var vanishing_point := Vector2(0.50, 0.43):
	set(value):
		vanishing_point = value
		queue_redraw()

@export var tree_art: Texture2D:
	set(value):
		tree_art = value
		queue_redraw()

const TREE_SPACING_PX := 150.0
const GROUND := Color("#2f4a33")
const FAR_TREE := Color("29422e")
const NEAR_TREE := Color("#1d3322")

var _distance_px := 0.0

func set_road_distance(px: float) -> void:
	_distance_px = px
	queue_redraw()

func _draw() -> void:
	if size.x < 1.0 or size.y < 1.0:
		return
	
	var eye := size * vanishing_point
	draw_rect(Rect2(0.0, eye.y, size.x, size.y - eye.y), GROUND)
	_draw_roadside(eye, -1.0, 0.0)
	_draw_roadside(eye, 1.0, 0.43)

func _draw_roadside(eye: Vector2, side: float, stagger: float) -> void:
	var travel := _distance_px / TREE_SPACING_PX + stagger
	var phase := fposmod(travel, 1.0)
	
	for row in range(7, -1, -1):
		var k := 1.0 / (float(row) + 2.0 - phase)
		var foot := eye + Vector2(side * size.x * 0.85, size.y * 0.50) * k
		var tree_id := floorf(travel) + float(row) + stagger
		var h := size.y * k * (1.0 + 0.12 * sin(tree_id * 2.4))
		var alpha := phase if row == 7 else 1.0
		
		if tree_art != null:
			var w := h * float(tree_art.get_width()) / float(tree_art.get_height())
			var rect := Rect2(foot - Vector2(w * 0.5, h), Vector2(w, h))
			draw_texture_rect(tree_art, rect, false, Color(1, 1, 1, alpha))
			continue
		
		var tint := FAR_TREE.lerp(NEAR_TREE, k)
		tint.a = alpha
		var crown := foot - Vector2(0.0, h * 0.53)
		draw_line(foot, crown, tint, maxf(1.0, h * 0.055), true)
		draw_circle(crown, h * 0.24, tint)
		draw_circle(crown + Vector2(-side * h * 0.13, h * 0.05), h * 0.15, tint)
