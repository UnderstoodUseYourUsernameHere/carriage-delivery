class_name CabinCombat
extends Control

const APPROACH_DISTANCE := 230.0
const ARM_DISTANCE := 120.0
const KNOCKBACK_DISTANCE := 300.0
const STOLEN_DROP := 120.0

@onready var _body: Control = $OutsideSlot/SkeletonBody
@onready var _arm: Control = $InsideSlot/SkeletonArm

func present(journey: RoamJourney) -> void:
	var threat := journey.active_threat
	
	_body.visible = threat != null
	_arm.visible = (
		threat != null
		and threat.phase == SkeletonThreat.Phase.REACH
	)
	if threat == null:
		return
	
	var side := float(threat.flank)
	
	_body.scale = Vector2(-side, 1.0)
	_arm.scale = Vector2(-side, 1.0)
	
	var body_offset := Vector2.ZERO
	var alpha := 1.0
	
	if threat.is_resolved():
		var exit_t := threat.exit_progress(journey.elapsed)
		if threat.phase == SkeletonThreat.Phase.REPELLED:
			body_offset = Vector2(
				side * KNOCKBACK_DISTANCE * exit_t,
				-45.0 * exit_t
			)
		else:
			body_offset = Vector2(
				side * STOLEN_DROP * exit_t,
				110.0 * exit_t
			)
		alpha = 1.0 - exit_t
	elif threat.phase == SkeletonThreat.Phase.APPROACH:
		var progress := threat.phase_progress(journey.elapsed)
		var eased := 1.0 - pow(1.0 - progress, 2.0)
		
		body_offset = Vector2(
			side * APPROACH_DISTANCE * (1.0 - eased),
			sin(journey.elapsed * 17.0) * 6.0
		)
		alpha = eased
	
	_body.position = body_offset
	_body.modulate = Color(1.0, 1.0, 1.0, alpha)
	
	if _arm.visible:
		var reach_t := clampf(
			threat.phase_progress(journey.elapsed) / 0.35,
			0.0,
			1.0
		)
		_arm.position = Vector2(
			side * ARM_DISTANCE * (1.0 - reach_t),
			0.0
		)
