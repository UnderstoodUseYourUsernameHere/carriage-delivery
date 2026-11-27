@tool
class_name LanternWagon
extends TextureRect

enum Piece { CABIN, SWORD }

@export var piece: Piece = Piece.CABIN:
	set(value):
		piece = value
		queue_redraw()

const DESIGN := Vector2(960.0, 540.0)

const DARK := Color("#49372f")
const WOOD := Color("#8a6f5e")
const TRIM := Color("#ae9279")
const IRON := Color("#4b5a5d")
const LAMP := Color("#ffd166")

const CANVAS := Color("#36443e")
const FOOTWELL := Color("#393d35")
const PAPER := Color("#d7c8a3")

var _road_px := 0.0

func _ready() -> void:
	resized.connect(queue_redraw)

func set_road_distance(px: float) -> void:
	if is_equal_approx(px, _road_px):
		return
	
	_road_px = px
	queue_redraw()

func _draw() -> void:
	if texture != null or size.x <= 0.0 or size.y <= 0.0:
		return
	
	if piece == Piece.SWORD:
		_draw_sword()
		return
	
	draw_set_transform(Vector2.ZERO, 0.0, size / DESIGN)
	_draw_carriage()
	_draw_lantern(Vector2(270, 28))

func _draw_carriage() -> void:
	var hem := PackedVector2Array([
		Vector2(0, 72), Vector2(74, 54), Vector2(172, 38),
		Vector2(270, 28), Vector2(690, 28), Vector2(788, 38),
		Vector2(886, 54), Vector2(960, 72),
	])
	var hood := PackedVector2Array([Vector2(0, 0), Vector2(960, 0)])
	for i in range(hem.size() - 1, -1, -1):
		hood.append(hem[i])
	draw_colored_polygon(hood, CANVAS)
	_timber(hem, 5.0)
	
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 410), Vector2(286, 308), Vector2(674, 308),
		Vector2(960, 410), Vector2(960, 540), Vector2(0, 540),
	]), FOOTWELL)
	
	for side: float in [-1.0, 1.0]:
		var joint := Vector2(480.0 + side * 194.0, 308)
		var near_end := Vector2(480.0 + side * 480.0, 410)
		var upper := Vector2(480.0 + side * 210.0, 28)
		_timber(PackedVector2Array([upper, joint]), 4.0)
		_timber(PackedVector2Array([joint, near_end]), 8.0)
		draw_line(Vector2(480.0 + side * 461.0, 67), near_end, IRON, 3.0, true)
		_pin(joint)
	
	for x: float in [332.0, 628.0]:
		draw_line(Vector2(x, 280), Vector2(x, 334), IRON, 5.0, true)
	_timber(PackedVector2Array([
		Vector2(300, 312), Vector2(383, 306),
		Vector2(577, 306), Vector2(660, 312)
	]), 7.0)
	_pin(Vector2(332, 286))
	_pin(Vector2(628, 286))
	
	draw_line(Vector2(624, 309), Vector2(624, 327), DARK, 5.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(601, 324), Vector2(635, 316), Vector2(641, 330),
		Vector2(608, 337),
	]), PAPER)
	draw_colored_polygon(PackedVector2Array([
		Vector2(596, 328), Vector2(648, 323), Vector2(646, 350),
		Vector2(609, 357), Vector2(598, 347),
	]), DARK)
	var clasp := Vector2(625, 337)
	draw_circle(clasp, 6.5, IRON)
	draw_line(clasp + Vector2(-2, 3), clasp + Vector2(2, -3), PAPER, 1.5, true)
	
	draw_colored_polygon(PackedVector2Array([
		Vector2(383, 473), Vector2(577, 473), Vector2(556, 511),
		Vector2(404, 511),
	]), DARK)
	_timber(PackedVector2Array([
		Vector2(386, 483), Vector2(411, 494),
		Vector2(549, 494), Vector2(574, 483),
	]), 5.0)

func _timber(points: PackedVector2Array, width_px: float) -> void:
	var shadow := points.duplicate()
	var lip := points.duplicate()
	for i in range(points.size()):
		shadow[i] += Vector2(1.5, 2.0)
		lip[i] += Vector2(0.0, -width_px * 0.3)
	draw_polyline(shadow, DARK, width_px + 2.0, true)
	draw_polyline(points, WOOD, width_px, true)
	draw_polyline(lip, TRIM, 1.5, true)

func _pin(at: Vector2) -> void:
	draw_circle(at + Vector2(1, 2), 4.0, DARK)
	draw_circle(at, 3.5, IRON)
	draw_line(at + Vector2(-1, -1), at + Vector2(1, -1), TRIM, 1.0, true)

func _draw_lantern(hook: Vector2) -> void:
	var sway := sin(_road_px / 34.0) * 4.0
	var glass := hook + Vector2(sway, 49.0)
	
	draw_circle(glass, 26.0, Color(1.0, 0.72, 0.28, 0.08))
	draw_circle(glass, 16.0, Color(1.0, 0.72, 0.28, 0.16))
	
	draw_line(hook, glass + Vector2(0, -15), IRON, 2.0, true)
	draw_arc(glass + Vector2(0, -10), 5.0, PI, TAU, 12, IRON, 2.0, true)
	
	draw_colored_polygon(PackedVector2Array([
		glass + Vector2(-9, -10), glass + Vector2(9, -10),
		glass + Vector2(7, 9), glass + Vector2(0, 14),
		glass + Vector2(-7, 9),
	]), IRON)
	draw_colored_polygon(PackedVector2Array([
		glass + Vector2(-6, -7), glass + Vector2(6, -7),
		glass + Vector2(4, 7), glass + Vector2(-4, 7),
	]), LAMP)
	draw_line(glass + Vector2(-8, -10), glass + Vector2(8, -10), TRIM, 2.0, true)
	draw_circle(glass + Vector2(-1, 2), 2.5, Color("#fff2c7"))
	_pin(hook)

func _draw_sword() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(12, 1), Vector2(17, 15), Vector2(15, 81),
		Vector2(8, 81), Vector2(7, 15),
	]), IRON)
	draw_polyline(PackedVector2Array([
		Vector2(12, 4), Vector2(9, 16), Vector2(10, 78),
	]), Color("#bdc8bd"), 2.0, true)
	draw_line(Vector2(3, 84), Vector2(21, 82), TRIM, 3.5, true)
	draw_line(Vector2(12, 85), Vector2(12, 105), DARK, 5.0, true)
	_pin(Vector2(12, 107))
