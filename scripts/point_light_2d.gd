extends Light2D  # Funciona para PointLight2D

@export var min_energy: float = 0.5  # Intensidad mínima
@export var max_energy: float = 1.0  # Intensidad máxima
@export var speed: float = 2.0       # Velocidad del parpadeo

var time_passed: float = 0.0

func _process(delta: float) -> void:
	time_passed += delta * speed
	# Oscilación sinusoidal entre min_energy y max_energy
	energy = min_energy + (max_energy - min_energy) * (0.5 + 0.5 * sin(time_passed))
