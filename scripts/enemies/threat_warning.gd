class_name ThreatWarning
extends Control

const AMBER := Color("#ffd166")
const DANGER := Color("#d95d5d")

var _threat: SkeletonThreat

func present(threat: SkeletonThreat) -> void:
	_threat = threat
	queue_redraw()

func _draw() -> void:
	if _threat == null or not _threat.is_active():
		return
	
	var left_side := _threat.flank == SkeletonThreat.Flank.LEFT
	var edge_x := 22.0 if left_side else size.x - 22.0
	var inward := 1.0 if left_side else -1.0
	
	var tint := DANGER \
	 if _threat.phase == SkeletonThreat.Phase.REACH \
	 else AMBER
	
	draw_circle(Vector2(edge_x, size.y * 0.5), 14.0, tint)
	draw_colored_polygon(PackedVector2Array([
		Vector2(edge_x + inward * 24.0, size.y * 0.5),
		Vector2(edge_x + inward * 7.0, size.y * 0.5 - 12.0),
		Vector2(edge_x + inward * 7.0, size.y * 0.5 + 12.0),
	]), tint)
