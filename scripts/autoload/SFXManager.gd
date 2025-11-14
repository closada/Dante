extends Node

# Diccionario con los efectos y sus rutas
const SFX_PATHS := {
	"relic_pickup": "res://assets/audio/relic.wav",
	"elevator_open": "res://assets/audio/elevator.mp3",
	"click": "res://assets/audio/click.ogg"
}

# Reproduce un sonido por nombre
func play(sfx_name: String) -> void:
	if not SFX_PATHS.has(sfx_name):
		push_warning("SFXManager: sonido no encontrado -> " + sfx_name)
		return

	var path = SFX_PATHS[sfx_name]
	if not ResourceLoader.exists(path):
		push_warning("SFXManager: archivo no existe -> " + path)
		return

	var sound = AudioStreamPlayer.new()
	sound.bus = "SFX"  # 🔹 Asegura que use el bus correcto
	sound.stream = load(path)
	sound.volume_db = 0
	sound.autoplay = false
	sound.process_mode = Node.PROCESS_MODE_ALWAYS  # para que suene incluso si el juego está pausado

	get_tree().root.add_child(sound)
	sound.play()

	# 🔹 Liberarlo automáticamente cuando termine
	sound.finished.connect(func():
		sound.queue_free())
