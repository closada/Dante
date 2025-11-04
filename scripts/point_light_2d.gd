extends Light2D

@export var min_energy: float = 0.5
@export var max_energy: float = 1.0
@export var speed: float = 2.0

var time_passed: float = 0.0

func _process(delta: float) -> void:
	# Si la luz está apagada, no pulsear ni cambiar 'energy'
	if not visible:
		return

	time_passed += delta * speed
	energy = min_energy + (max_energy - min_energy) * (0.5 + 0.5 * sin(time_passed))
