class_name CarriageJourney
extends RefCounted

const RIDE_SECONDS := 18.0

var elapsed := 0.0

func step(delta: float) -> void:
	if has_arrived():
		return
	elapsed = minf(elapsed + delta, RIDE_SECONDS)

func progress_ratio() -> float:
	return elapsed / RIDE_SECONDS

func has_arrived() -> bool:
	return elapsed >= RIDE_SECONDS
