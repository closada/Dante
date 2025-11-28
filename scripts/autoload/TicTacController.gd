extends Node

var player := AudioStreamPlayer.new()
var cooldown := false
var last_intensity := 1

@export var cooldown_time := 0.25

# 🎵 Rutas a tus nuevos sonidos procesados en Audacity
const TICTAC_SOUNDS := {
	1: "res://assets/audio/clues/tic-tac-1.mp3",
	2: "res://assets/audio/clues/tic-tac-2.mp3",
	3: "res://assets/audio/clues/tic-tac-3.mp3",
	4: "res://assets/audio/clues/tic-tac-4.mp3"
}

func _ready():
	player.bus = "SFX"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	print("🔊 TicTacController listo.")


func request_tic(intensity: int):
	if cooldown:
		return

	# guardar intensidad por si querés debuggear
	last_intensity = intensity

	# cargar sonido según la intensidad
	if TICTAC_SOUNDS.has(intensity):
		var sound_path = TICTAC_SOUNDS[intensity]
		if ResourceLoader.exists(sound_path):
			player.stream = load(sound_path)
		else:
			push_warning("⚠️ El archivo no existe: " + sound_path)
	else:
		push_warning("⚠️ intensidad fuera de rango: " + str(intensity))
		return

	# reproducir evitando solapamiento
	player.play()

	# iniciar cooldown
	cooldown = true
	get_tree().create_timer(cooldown_time).timeout.connect(func():
		cooldown = false)
