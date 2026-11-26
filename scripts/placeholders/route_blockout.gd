@tool
class_name RouteBlockout
extends Node2D

const GROUND := Color("#2f4a33")
const ROAD_EDGE := Color("#5a4634")
const ROAD := Color("#7a6248")
const STONE := Color("#a39a88")
const TREE := Color("#1d3322")
const CIDERY := Color("#c0763a")

@export var road_path: Path2D:
	set(value):
		road_path = value
		_watch_curve()
		queue_redraw()

@export var road_width := 90.0
@export var ground_margin := 700.0
@export var tree_count := 160
@export var tree_seed := 7

func _ready() -> void:
	_watch_curve()

func _watch_curve() -> void:
	if road_path == null or road_path.curve == null:
		return
	
	var callback := Callable(self, "queue_redraw")
	if not road_path.curve.changed.is_connected(callback):
		road_path.curve.changed.connect(callback)

func _draw() -> void:
	if road_path == null or road_path.curve == null or road_path.curve.point_count < 2:
		return
	
	var curve := road_path.curve
	var points := curve.get_baked_points()
	var bounds := Rect2(points[0], Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	bounds = bounds.grow(ground_margin)
	
	draw_rect(bounds, GROUND)
	draw_polyline(points, ROAD_EDGE, road_width + 14.0)
	draw_polyline(points, ROAD, road_width)
	
	var length := curve.get_baked_length()
	var offset := 0.0
	while offset < length:
		var frame := curve.sample_baked_with_rotation(offset)
		for side: float in [-1.0, 1.0]:
			draw_circle(frame * Vector2(0.0, side * (road_width * 0.5 + 16.0)), 6.0, STONE)
		offset += 140.0
	
	var rng := RandomNumberGenerator.new()
	rng.seed = tree_seed
	for i in tree_count:
		var spot := Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))
		var radius := rng.randf_range(18.0, 42.0)
		if curve.get_closest_point(spot).distance_to(spot) > road_width * 0.5 + radius + 10.0:
			draw_circle(spot, radius, TREE)
	var finish := points[points.size() - 1]
	draw_rect(Rect2(finish - Vector2(60, 60), Vector2(120, 120)), CIDERY)
	draw_string(ThemeDB.fallback_font, finish + Vector2(-100, -72), "CIDERY", HORIZONTAL_ALIGNMENT_CENTER, 200, 28)
