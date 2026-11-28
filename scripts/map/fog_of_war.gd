class_name FogOfWar
extends Node2D

const FOG := Color("#101b15")

var _journey: RoamJourney
var _last_revealed_count := -1

func begin_run(journey: RoamJourney) -> void:
	_journey = journey
	_last_revealed_count = -1
	present(journey)

func present(journey: RoamJourney) -> void:
	_journey = journey
	
	var revealed_count := journey.revealed_cells.size()
	if revealed_count == _last_revealed_count:
		return
	
	_last_revealed_count = revealed_count
	queue_redraw()

func _draw() -> void:
	if _journey == null:
		return
	
	var world := RoamJourney.WORLD_BOUNDS
	var cell_size := RoamJourney.FOG_CELL
	
	var first_x := floori(world.position.x / cell_size)
	var first_y := floori(world.position.y / cell_size)
	var last_x := ceili(world.end.x / cell_size)
	var last_y := ceili(world.end.y / cell_size)
	
	for y in range(first_y, last_y):
		for x in range(first_x, last_x):
			var cell := Vector2i(x, y)
			if _journey.revealed_cells.has(cell):
				continue
			var rectangle := Rect2(
				Vector2(x, y) * cell_size,
				Vector2.ONE * cell_size
			)
			draw_rect(rectangle.grow(0.5), FOG)
