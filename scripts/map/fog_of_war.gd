class_name FogOfWar
extends Node2D

const FOG := Color("#101b15")
const EDGE_ALPHA := 0.5

const NEIGHBORS: Array[Vector2i] = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]

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
	
	var soft := FOG
	soft.a = EDGE_ALPHA
	
	for y in range(first_y, last_y):
		var run_start := first_x
		var run_length := 0
		
		for x in range(first_x, last_x):
			var cell := Vector2i(x, y)
			var hidden := not _journey.revealed_cells.has(cell)
			var is_edge := hidden and _touches_revealed(cell)
			
			if hidden and not is_edge:
				if run_length == 0:
					run_start = x
				run_length += 1
				continue
			
			_flush_run(run_start, y, run_length, cell_size)
			run_length = 0
			
			if is_edge:
				draw_rect(_cell_rect(x, y, cell_size), soft)
		_flush_run(run_start, y, run_length, cell_size)

func _flush_run(start_x: int, y: int, length: int, cell_size: float) -> void:
	if length <= 0:
		return
	
	var rect := Rect2(
		Vector2(start_x, y) * cell_size,
		Vector2(length, 1.0) * cell_size
	)
	draw_rect(rect.grow(0.5), FOG)

func _cell_rect(x: int, y: int, cell_size: float) -> Rect2:
	var rect := Rect2(Vector2(x, y) * cell_size, Vector2.ONE * cell_size)
	return rect.grow(0.5)

func _touches_revealed(cell: Vector2i) -> bool:
	for offset in NEIGHBORS:
		if _journey.revealed_cells.has(cell + offset):
			return true
	return false
