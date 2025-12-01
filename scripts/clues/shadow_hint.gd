extends Node2D

@export var relic_number_celular := 8
@export var opacity_min := 0.15
@export var opacity_max := 0.85
@export var ahead_dist := 100.0
@export var max_distance := 900.0

var player: Node2D
var pluma: Node2D
var sprite: Sprite2D


func _ready():
	visible = false
	sprite = $Sprite2D
	sprite.modulate.a = 0.0
	set_process(false)
	if Inventory.get_active_relic_id_num() == relic_number_celular:
		activate()


func activate():
	player = get_tree().get_current_scene().get_node("Player")
	pluma = find_relic_by_id("pluma")
	print("pluma: ",pluma)
	if not player or not pluma:
		return

	visible = true
	set_process(true)


func _process(_delta):
	if not player or not pluma:
		return

	# vector hacia la pluma
	var dir = (pluma.global_position - player.global_position).normalized()

	# colocar la sombra "adelante" del jugador
	global_position = player.global_position + dir * ahead_dist

	# orientar la sombra como brújula
	look_at(pluma.global_position)

	# ajustar opacidad según la distancia
	var dist = player.global_position.distance_to(pluma.global_position)
	var t = clamp(1.0 - (dist / max_distance), 0.0, 1.0)
	sprite.modulate.a = lerp(opacity_min, opacity_max, t)


func find_relic_by_id(id: String) -> Node2D:
	var root = get_tree().get_current_scene()
	for r in root.get_tree().get_nodes_in_group("relics"):
		if r.relic_id == id:
			return r
	return null
