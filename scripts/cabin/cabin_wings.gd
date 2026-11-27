@tool
class_name CabinWings
extends Control

@export var cabin_art: TextureRect:
	set(value):
		cabin_art = value
		queue_redraw()

@export var sample_inset_px := 4:
	set(value):
		sample_inset_px = value
		queue_redraw()

@export var sample_width_px := 2:
	set(value):
		sample_width_px = maxi(value, 1)
		queue_redraw()

@export var post_width := 16.0:
	set(value):
		post_width = value
		queue_redraw()

@export var post_color := Color("#24170f"):
	set(value):
		post_color = value
		queue_redraw()

@export_range(0.0, 1.0) var edge_shade := 0.35:
	set(value):
		edge_shade = value
		queue_redraw()

func _ready() -> void:
	resized.connect(queue_redraw)

func art_rect() -> Rect2:
	var tex_size := cabin_art.texture.get_size()
	var s := minf(size.x / tex_size.x, size.y / tex_size.y)
	var drawn := tex_size * s
	return Rect2((size - drawn) * 0.5, drawn)

func _draw() -> void:
	if cabin_art == null or cabin_art.texture == null:
		return
	
	var tex := cabin_art.texture
	var tex_size := tex.get_size()
	var art := art_rect()
	var gap := art.position.x
	if gap < 1.0:
		return
	
	const SEAM := 1.0 
	var left_arc := Rect2(sample_inset_px, 0, sample_width_px, tex_size.y)
	var right_arc := Rect2(tex_size.x - sample_inset_px - sample_width_px, 0, sample_width_px, tex_size.y)
	
	draw_texture_rect_region(tex, Rect2(0.0, art.position.y, gap + SEAM, art.size.y), left_arc)
	draw_texture_rect_region(tex, Rect2(art.end.x - SEAM, art.position.y, gap + SEAM, art.size.y), right_arc)
	
	_draw_shade(0.0, gap, true)
	_draw_shade(art.end.x, size.x, false)
	
	if post_width > 0.0:
		draw_rect(Rect2(0.0, 0.0, post_width, size.y), post_color)
		draw_rect(Rect2(size.x - post_width, 0.0, post_width, size.y), post_color)

func _draw_shade(from_x: float, to_x: float, dark_at_from: bool) -> void:
	if edge_shade <= 0.0:
		return
	
	var dark := Color(0, 0, 0, edge_shade)
	var clear := Color(0, 0, 0, 0)
	var a := dark if dark_at_from else clear
	var b := clear if dark_at_from else dark
	draw_polygon(
		PackedVector2Array([
			Vector2(from_x, 0), Vector2(to_x, 0),
			Vector2(to_x, size.y), Vector2(from_x, size.y),
		]),
		PackedColorArray([a, b, b, a])
	)
