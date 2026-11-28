class_name RoamJourney
extends RefCounted

enum Stage { TO_POST, TO_CHECKPOINT, TO_CIDERY, DONE }

const WORLD_BOUNDS := Rect2(-2048.0, -2048.0, 4096.0, 4096.0)
const PLAYABLE_BOUNDS := Rect2(-1808.0, -1808.0, 3616.0, 3616.0)

const CRUISE_SPEED := 150.0
const TURN_RATE := 1.55
const OBJECTIVE_MIN_GAP := 1000.0
const ARRIVAL_RADIUS := 80.0
const POST_FRUIT := 5
const FOG_CELL := 128.0
const REVEAL_RADIUS := 320.0
const FIRST_ATTACK_DELAY := 4.0
const ATTACK_INTERVAL_MIN := 7.0
const ATTACK_INTERVAL_MAX := 11.0
const SWING_RECOVERY := 1.5

var run_seed := 0
var elapsed := 0.0
var odometer := 0.0
var position := Vector2.ZERO
var heading := -PI / 2.0
var fruit := 0
var stage : Stage = Stage.TO_POST
var waypoints: Array[Vector2] = []
var revealed_cells: Dictionary = {}
var active_threat: SkeletonThreat
var next_attack_at := INF
var swing_recovery := 0.0
var last_swing_flank := SkeletonThreat.Flank.LEFT
var last_swing_hit := false
var _threat_rng := RandomNumberGenerator.new()

func _init(seed_value: int = -1) -> void:
	var rng := RandomNumberGenerator.new()
	if seed_value < 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	run_seed = rng.seed
	_threat_rng.seed = run_seed + 9001
	_generate_waypoints(rng)
	_reveal_around_position()

func step(delta: float, steer: float) -> void:
	if has_arrived() or delta <= 0.0:
		return
	
	elapsed += delta
	swing_recovery = move_toward(swing_recovery, 0.0, delta)
	steer = clampf(steer, -1.0, 1.0)
	heading = wrapf(heading + steer * TURN_RATE * delta, -PI, PI)
	
	var before := position
	var proposed := position + Vector2.RIGHT.rotated(heading) * CRUISE_SPEED * delta
	position = proposed.clamp(PLAYABLE_BOUNDS.position, PLAYABLE_BOUNDS.end)
	
	var distance_moved := before.distance_to(position)
	odometer += distance_moved
	
	if distance_moved > 0.0:
		_reveal_around_position()
		_check_current_objective()
	_update_threat()

func has_arrived() -> bool:
	return stage == Stage.DONE

func target_position() -> Vector2:
	if waypoints.is_empty():
		return position
	return waypoints[mini(int(stage), waypoints.size() - 1)]

func distance_to_target() -> float:
	if has_arrived():
		return 0.0
	return position.distance_to(target_position())

func bearing_to_target() -> float:
	if has_arrived():
		return 0.0
	return wrapf((target_position() - position).angle() - heading, -PI, PI)

func stage_text() -> String:
	match stage:
		Stage.TO_POST: return "Find the post!"
		Stage.TO_CHECKPOINT: return "Reach the rangers' hut!"
		Stage.TO_CIDERY: return "Deliver your fruits to Ratticus' Cidery!"
	return "Delivered"

func _generate_waypoints(rng: RandomNumberGenerator) -> void:
	waypoints.clear()
	var reserved: Array[Vector2] = [Vector2.ZERO]
	var area := WORLD_BOUNDS.grow(-248.0)
	
	for _index in range(3):
		var found := false
		for _attempt in range(512):
			var candidate := Vector2(
				rng.randf_range(area.position.x, area.end.x),
				rng.randf_range(area.position.y, area.end.y)
			)
			var far_enough := true
			for existing in reserved:
				if candidate.distance_to(existing) < OBJECTIVE_MIN_GAP:
					far_enough = false
					break
			if far_enough:
				waypoints.append(candidate)
				reserved.append(candidate)
				found = true
				break
		if not found:
			waypoints = [Vector2(1200.0, 0.0), Vector2(-600.0, 1040.0), Vector2(-600.0, -1040.0)]
			return

func _check_current_objective() -> void:
	if has_arrived():
		return
	if position.distance_to(target_position()) > ARRIVAL_RADIUS:
		return
	
	match stage:
		Stage.TO_POST:
			fruit = POST_FRUIT
			stage = Stage.TO_CHECKPOINT
			next_attack_at = elapsed + FIRST_ATTACK_DELAY
		Stage.TO_CHECKPOINT:
			stage = Stage.TO_CIDERY
		Stage.TO_CIDERY:
			stage = Stage.DONE
			active_threat = null
			next_attack_at = INF

func _reveal_around_position() -> void:
	var center := Vector2i(floori(position.x / FOG_CELL), floori(position.y / FOG_CELL))
	var radius_cells := ceili(REVEAL_RADIUS / FOG_CELL) + 1
	
	for y in range(center.y - radius_cells, center.y + radius_cells + 1):
		for x in range(center.x - radius_cells, center.x + radius_cells + 1):
			var cell := Vector2i(x, y)
			var cell_center := (Vector2(cell) + Vector2(0.5, 0.5)) * FOG_CELL
			if cell_center.distance_to(position) <= REVEAL_RADIUS + FOG_CELL * 0.7:
				revealed_cells[cell] = true

func _update_threat() -> void:
	if has_arrived():
		active_threat = null
		return
	
	if active_threat != null:
		if active_threat.update(elapsed):
			fruit = maxi(fruit - 1, 0)
		
		if not active_threat.is_visible_at(elapsed):
			active_threat = null
			_schedule_next_attack()
		
		return
	
	if fruit <= 0:
		return
	
	if stage not in [Stage.TO_CHECKPOINT, Stage.TO_CIDERY]:
		return
	
	if elapsed < next_attack_at:
		return
	
	var flank := SkeletonThreat.Flank.LEFT
	if _threat_rng.randi_range(0, 1) == 1:
		flank = SkeletonThreat.Flank.RIGHT
	
	active_threat = SkeletonThreat.new(flank, elapsed)
	next_attack_at = INF

func _schedule_next_attack() -> void:
	if fruit <= 0 or has_arrived():
		next_attack_at = INF
		return
	
	next_attack_at = elapsed + _threat_rng.randf_range(
		ATTACK_INTERVAL_MIN,
		ATTACK_INTERVAL_MAX
	)

func swing_age() -> float:
	return SWING_RECOVERY - swing_recovery

func try_swing(flank: int) -> bool:
	if has_arrived() or swing_recovery > 0.0:
		return false
	
	last_swing_flank = flank
	last_swing_hit = false
	swing_recovery = SWING_RECOVERY
	
	if active_threat == null:
		return true
	
	if active_threat.flank != flank:
		return true
	
	last_swing_hit = active_threat.repel(elapsed)
	return true
