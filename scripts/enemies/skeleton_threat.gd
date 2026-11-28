class_name SkeletonThreat
extends RefCounted

enum Flank { LEFT = -1, RIGHT = 1 }
enum Phase { APPROACH, GRAB, REACH, REPELLED, STOLEN }

const APPROACH_SECONDS := 2.2
const GRAB_SECONDS := 1.4
const REACH_SECONDS := 1.3
const EXIT_SECONDS := 0.5

var flank: Flank
var started_at: float 
var phase: Phase = Phase.APPROACH
var resolved_at := -1.0

func _init(p_flank: Flank, p_started_at: float) -> void:
	flank = p_flank
	started_at = p_started_at

func grab_at() -> float:
	return started_at + APPROACH_SECONDS

func reach_at() -> float:
	return grab_at() + GRAB_SECONDS

func steal_at() -> float:
	return reach_at() + REACH_SECONDS

func update(now: float) -> bool:
	if is_resolved():
		return false
	
	if now >= steal_at():
		phase = Phase.STOLEN
		resolved_at = now
		return true
	
	if now >= reach_at():
		phase = Phase.REACH
	elif now >= grab_at():
		phase = Phase.GRAB
	else:
		phase = Phase.APPROACH
	
	return false

func is_resolved() -> bool:
	return phase in [Phase.REPELLED, Phase.STOLEN]

func is_active() -> bool:
	return not is_resolved()

func is_visible_at(now: float) -> bool:
	if not is_resolved():
		return true
	
	return now - resolved_at < EXIT_SECONDS

func phase_progress(now: float) -> float:
	match phase:
		Phase.APPROACH:
			return inverse_lerp(started_at, grab_at(), now)
		Phase.GRAB:
			return inverse_lerp(grab_at(), reach_at(), now)
		Phase.REACH:
			return inverse_lerp(reach_at(), steal_at(), now)
		Phase.REPELLED, Phase.STOLEN:
			return exit_progress(now)
	
	return 0.0

func exit_progress(now: float) -> float:
	if resolved_at < 0.0:
		return 0.0
	
	return clampf(
		(now - resolved_at) / EXIT_SECONDS,
		0.0,
		1.0
	)

func repel(now: float) -> bool:
	if phase != Phase.REACH:
		return false
	
	phase = Phase.REPELLED
	resolved_at = now
	return true

func flank_text() -> String:
	return "LEFT" if flank == Flank.LEFT else "RIGHT"

func phase_text() -> String:
	return str(Phase.find_key(phase))
