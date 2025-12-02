
extends Node2D

@export var max_volume := -4.0
@export var min_volume := -15.0
@export var max_distance := 4000.0
@export var relic_number := 5
@export var baja_musica := false

@onready var area := $Area2D

var player: Node = null
var sfx_a: AudioStreamPlayer
var sfx_b: AudioStreamPlayer
var active_player := 0 # 0 = A, 1 = B
var loop_len := 0.0
var looping := false

func _ready():
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

	sfx_a = _create_player()
	sfx_b = _create_player()
	add_child(sfx_a)
	add_child(sfx_b)

	loop_len = sfx_a.stream.get_length()

	# Activamos el proceso para hacer el chequeo fácil
	set_process(true)

func _create_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = load("res://assets/audio/clues/partituras_music.wav")
	p.autoplay = false
	var stream: AudioStream = p.stream
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = false
	return p

# ======================================================
# INICIAR LOOP
# ======================================================
func _start_loop(body: Node):
	if looping:
		return
	if body == null or body.name != "Player":
		return
	if Inventory.get_active_relic_id_num() != relic_number:
		return

	player = body
	looping = true
	sfx_a.volume_db = min_volume
	sfx_a.play()
	active_player = 0
	_schedule_next_overlap()

	if not baja_musica:
		MusicManager.fade_out_music(1.0)
		baja_musica = true

# ======================================================
# ENTRADA A LA ZONA
# ======================================================
func _on_enter(body):
	_start_loop(body)

# ======================================================
# SALIDA DE LA ZONA
# ======================================================
func _on_exit(body):
	if body == player:
		looping = false
		sfx_a.stop()
		sfx_b.stop()
		player = null

# ======================================================
# SUPERPOSICIÓN ENTRE A Y B
# ======================================================
func _schedule_next_overlap():
	if not looping:
		return
	var t: float = max(loop_len - 0.05, 0.01)
	var timer := get_tree().create_timer(t)
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
# CHEQUEO FÁCIL EN _process
# ======================================================
func _process(_delta):
	# Si no hay loop y la reliquia activa coincide, verificar si el Player está dentro del área
	if not looping and Inventory.get_active_relic_id_num() == relic_number:
		for b in area.get_overlapping_bodies():
			if b.name == "Player":
				_start_loop(b)
				break

	if not player or not looping:
		return

	var target := find_relic_by_id("partitura")
	if not target:
		return
	if Inventory.get_active_relic_id_num() != relic_number:
		return

	var dist : float = player.global_position.distance_to(target.global_position)
	var t : float = clamp(1.0 - dist / max_distance, 0.0, 1.0)
	t = pow(t, 0.6)
	var new_vol : float = lerp(min_volume, max_volume, t)
	sfx_a.volume_db = new_vol
	sfx_b.volume_db = new_vol

func find_relic_by_id(id: String) -> Node:
	for r in get_tree().get_nodes_in_group("relics"):
		if r.relic_id == id:
			return r
	return null
