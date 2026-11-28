@tool
class_name ForestBlockout
extends Node2D

const GROUND := Color("#2f4a33")
const TREE_DARK := Color("#1d3322")
const TREE_LIGHT := Color("#29422e")
const STONE := Color("#a39a88")
const BORDER := Color("#1a2a1e")

var _clearings := PackedVector2Array()
var _tree_positions: Array[Vector2] = []
var _tree_radi: Array[float] = []
var _tree_colors: Array[Color] = []
var _stone_positions: Array[Vector2] = []

func begin_run(seed_value: int, clearings: PackedVector2Array) -> void:
	_clearings = clearings.duplicate()
	_tree_positions.clear()
	_tree_radi.clear()
	_tree_colors.clear()
	_stone_positions.clear()
	
	var world := RoamJourney.WORLD_BOUNDS
	
	var tree_rng := RandomNumberGenerator.new()
	tree_rng.seed = seed_value
	
	for _index in range(850):
		var point := Vector2(
			tree_rng.randf_range(world.position.x, world.end.x),
			tree_rng.randf_range(world.position.y, world.end.y)
		)
		var radius := tree_rng.randf_range(16.0, 34.0)
		var tint := TREE_DARK if tree_rng.randf() < 0.65 else TREE_LIGHT
		
		if _inside_clearing(point, radius):
			continue
		
		_tree_positions.append(point)
		_tree_radi.append(radius)
		_tree_colors.append(tint)
	
	var stone_rng := RandomNumberGenerator.new()
	stone_rng.seed = seed_value + 1
	
	for _index in range(260):
		_stone_positions.append(Vector2(
			stone_rng.randf_range(world.position.x, world.end.x),
			stone_rng.randf_range(world.position.y, world.end.y)
		))
	
	queue_redraw()

func _inside_clearing(point: Vector2, radius: float) -> bool:
	for clearing in _clearings:
		if point.distance_to(clearing) < 180.0 + radius:
			return true
	
	return false

func _draw() -> void:
	var world := RoamJourney.WORLD_BOUNDS
	draw_rect(world, GROUND)
	
	for index in range(_tree_positions.size()):
		var point := _tree_positions[index]
		var radius := _tree_radi[index]
		var tint := _tree_colors[index]
		
		draw_circle(point, radius, tint)
		draw_circle(
			point + Vector2(-radius * 0.3, radius * 0.2),
			radius * 0.6,
			tint
		)
	
	for point in _stone_positions:
		draw_circle(point, 3.5, STONE)
	
	draw_rect(world, BORDER, false, 38.0)
