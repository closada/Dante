extends Node2D

@export var max_volume := -4.0
@export var min_volume := -15.0
@export var max_distance := 4000.0
@export var relic_number := 5
@export var baja_musica := false

@onready var area = $Area2D

var player = null
var sfx_a: AudioStreamPlayer
var sfx_b: AudioStreamPlayer
var active_player := 0   # 0 = A, 1 = B
var loop_len := 0.0      # duración exacta para loop real
var looping := false


func _ready():
	# === Crear dos reproductores ===
	sfx_a = _create_player()
	sfx_b = _create_player()

	add_child(sfx_a)
	add_child(sfx_b)

	# Duración real del clip
	loop_len = sfx_a.stream.get_length()

	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)


func _create_player() -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = load("res://assets/audio/clues/partituras_music.wav")
	p.autoplay = false

	# Asegurar loop OFF para usar loop doble
	var stream : AudioStream= p.stream
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = false

	return p



# ======================================================
#           ENTRADA A LA ZONA
# ======================================================
func _on_enter(body):
	if body.name != "Player":
		return

	if Inventory.get_active_relic_id_num() != relic_number:
		return

	player = body
	looping = true

	# iniciar loop perfecto
	sfx_a.volume_db = min_volume
	sfx_a.play()
	_schedule_next_overlap()

	set_process(true)



# ======================================================
#           SALIDA DE LA ZONA
# ======================================================
func _on_exit(body):
	if body == player:
		looping = false
		sfx_a.stop()
		sfx_b.stop()
		player = null
		set_process(false)



# ======================================================
#     PROGRAMAR SUPERPOSICIÓN ENTRE A Y B
# ======================================================
func _schedule_next_overlap():
	if not looping:
		return

	# En 0.05s antes del final del clip, arrancamos el otro
	var t : float = max(loop_len - 0.05, 0.01)

	var timer = get_tree().create_timer(t)
	timer.timeout.connect(_start_other_player)


func _start_other_player():
	if not looping:
		return

	if active_player == 0:
		sfx_b.play()
		active_player = 1
	else:
		sfx_a.play()
		active_player = 0

	_schedule_next_overlap()



# ======================================================
#            VOLUMEN SEGÚN DISTANCIA
# ======================================================
func _process(delta):
	
	# fade out música solo una vez
	if not baja_musica:
		MusicManager.fade_out_music(1.0)
		baja_musica = true
		
	if not player or not looping:
		return

	var target := find_relic_by_id("partitura")
	if not target:
		return

	var dist = player.global_position.distance_to(target.global_position)

	# normalizar
	var t = clamp(1.0 - dist / max_distance, 0.0, 1.0)

	# curva mejorada (sube antes)
	t = pow(t, 0.6)

	var new_vol = lerp(min_volume, max_volume, t)

	sfx_a.volume_db = new_vol
	sfx_b.volume_db = new_vol



func find_relic_by_id(id: String) -> Node:
	for r in get_tree().get_nodes_in_group("relics"):
		if r.relic_id == id:
			return r
	return null
