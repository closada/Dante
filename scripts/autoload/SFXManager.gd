extends Node

# Diccionario con los efectos y sus rutas
const SFX_PATHS := {
	"relic_pickup": "res://assets/audio/relic.wav",
	"elevator_open": "res://assets/audio/elevator.mp3",
	"click": "res://assets/audio/click.ogg",
	"tictac_hint": "res://assets/audio/clues/tic-tac-1.mp3",
	"partitura_hint": "res://assets/audio/clues/partituras_music.wav",
	"poco_tiempo": "res://assets/audio/poco_tiempo.mp3",
	"poco_tiempo_tick": "res://assets/audio/poco_tiempo_tick.wav",
	"poco_tiempo_fin": "res://assets/audio/poco_tiempo_fin.wav"
}

var low_time_player: AudioStreamPlayer = null

var currently_playing := {}

func play_single(sfx_name: String):
	if not SFX_PATHS.has(sfx_name):
		push_warning("SFXManager: sonido no encontrado -> " + sfx_name)
		return
	
	# Si ya está sonando, IGNORAR
	if currently_playing.get(sfx_name, false):
		return
	
	var path = SFX_PATHS[sfx_name]
	var sound = AudioStreamPlayer.new()
	sound.bus = "SFX"
	sound.stream = load(path)
	sound.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(sound)

	currently_playing[sfx_name] = true
	sound.play()

	# Liberar y marcar como "disponible"
	sound.finished.connect(func():
		currently_playing[sfx_name] = false
		sound.queue_free())

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

func start_low_time_warning():
	if low_time_player and low_time_player.playing:
		return

	low_time_player = AudioStreamPlayer.new()
	low_time_player.bus = "SFX"
	low_time_player.stream = load(SFX_PATHS["poco_tiempo_fin"])



	# Asegurar que respete el árbol de pausa
	low_time_player.process_mode = Node.PROCESS_MODE_PAUSABLE

	get_tree().current_scene.add_child(low_time_player)
	low_time_player.play()


func stop_low_time_warning():
	if low_time_player:
		low_time_player.stop()
		low_time_player.queue_free()
		low_time_player = null
