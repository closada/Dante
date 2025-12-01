extends Node

var player: AudioStreamPlayer
var volumen_actual: float = 0.8
var volumen_sfx: float = 0.7
var current_track: String = ""
var loop_music: bool = true
var ready_to_play: bool = false

func _ready():
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		volumen_actual = inv.get_config("musica", 0.8)
		volumen_sfx = inv.get_config("efectos", 0.7)
	else:
		print("⚠️ Inventory no encontrado. Usando valores por defecto.")
	
	# 🔊 Aplicar volúmenes iniciales a los buses
	var db_music = linear_to_db(volumen_actual)
	var db_sfx = linear_to_db(volumen_sfx)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MasterMusic"), db_music)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db_sfx)
	
	# 🎧 Crear el AudioStreamPlayer para la música
	player = AudioStreamPlayer.new()
	player.bus = "MasterMusic"
	player.volume_db = db_music
	player.autoplay = false
	player.process_mode = Node.PROCESS_MODE_ALWAYS  # 🔹 mantiene el procesamiento aún en pausa
	player.stream_paused = false  # 🔹 asegura que el audio siga si se pausa el árbol
	player.finished.connect(_on_player_finished)


	call_deferred("_add_player_safe")
	if not player.is_connected("finished", Callable(self, "_on_player_finished")):
		player.connect("finished", Callable(self, "_on_player_finished"))


	print("🎵 MusicManager inicializado: música=", volumen_actual, " | efectos=", volumen_sfx)


func _add_player_safe():
	get_tree().get_root().add_child(player)
	ready_to_play = true
	print("🎧 MusicManager listo (player añadido al árbol).")


func play_music(path: String, loop := true):
	if not ready_to_play:
		print("⏳ MusicManager aún no está listo, diferimos la reproducción.")
		call_deferred("play_music", path, loop)
		return

	loop_music = loop

	if path == "" or path == null:
		push_error("MusicManager.play_music: path vacío")
		return

	if not ResourceLoader.exists(path):
		push_error("MusicManager.play_music: recurso no encontrado -> " + path)
		return

	var stream = load(path)
	if not stream:
		push_error("MusicManager.play_music: load devolvió null -> " + path)
		return
		
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	print("🎶 Reproduciendo:", path)
	player.stream = stream
	current_track = path
	player.play()


func stop_music():
	if player and player.playing:
		player.stop()


# 🔹 Cambia volumen de música y guarda en JSON
func set_volume(value: float):
	volumen_actual = clamp(value, 0.0, 1.0)
	var db = linear_to_db(volumen_actual)
	if player:
		player.volume_db = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MasterMusic"), db)

	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.set_config("musica", volumen_actual)
		print("💾 Volumen de música guardado:", volumen_actual)
	else:
		print("⚠️ No se pudo guardar volumen de música (Inventory no encontrado).")


# 🔹 Cambia volumen de efectos y guarda en JSON
func set_sfx_volume(value: float):
	volumen_sfx = clamp(value, 0.0, 1.0)
	var db = linear_to_db(volumen_sfx)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.set_config("efectos", volumen_sfx)
		print("💾 Volumen de efectos guardado:", volumen_sfx)
	else:
		print("⚠️ No se pudo guardar volumen de efectos (Inventory no encontrado).")


func is_playing() -> bool:
	return player and player.playing


func _on_player_finished():
	if loop_music and current_track != "":
		player.play()

func fade_out_music(duration := 1.0):
	var _start = volumen_actual
	var _t := 0.0
	var tween = get_tree().create_tween()

	tween.tween_method(self._set_music_volume_percent, 1.0, 0.0, duration)

func fade_in_music(duration := 1.0):
	var _target = volumen_actual
	var tween = get_tree().create_tween()
	tween.tween_method(self._set_music_volume_percent, 0.0, 1.0, duration)

func _set_music_volume_percent(percent: float):
	var db = linear_to_db(volumen_actual * percent)
	player.volume_db = db
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MasterMusic"), db)
