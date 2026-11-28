class_name RoamMap
extends Node2D

@onready var _forest: ForestBlockout = $Forest
@onready var _fog: FogOfWar = $FogOfWar
@onready var _wagon_marker: Sprite2D = $WagonMarker
@onready var _camera: Camera2D = $MapCamera
@onready var _landmarks: Array[MapLandmark] = [
	$Landmarks/Post,
	$Landmarks/Checkpoint,
	$Landmarks/Cidery
]

func _ready() -> void:
	_camera.enabled = true
	_camera.make_current()

func begin_run(journey: RoamJourney) -> void:
	var clearings := PackedVector2Array()
	clearings.append(Vector2.ZERO)
	
	for waypoint in journey.waypoints:
		clearings.append(waypoint)
	
	_forest.begin_run(journey.run_seed, clearings)
	for index in range(_landmarks.size()):
		_landmarks[index].position = journey.waypoints[index]
	_fog.begin_run(journey)
	present(journey)

func present(journey: RoamJourney) -> void:
	_wagon_marker.position = journey.position
	_wagon_marker.rotation = journey.heading
	_camera.position = journey.position
	var stage_index := int(journey.stage)
	for index in range(_landmarks.size()):
		_landmarks[index].set_state(
			index == stage_index,
			index < stage_index
		)
	_fog.present(journey)
