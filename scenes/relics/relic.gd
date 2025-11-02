extends Node2D

@export var relic_id: String
@export var relic_name: String
@export var relic_description: String
@export var pickup_radius: float = 70.0

@onready var area := $Area2D

func _ready():
	if area:
		area.connect("input_event", Callable(self, "_on_area_input_event"))
	

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_pickup()

func _try_pickup():
	var player = get_tree().get_current_scene().get_node("Player")
	if player:
		_pickup()
	else:
		print("No se encontró al jugador")

func _pickup():
	print("Recolectada:", relic_name)
	if Inventory:
		Inventory.add_relic({
			"id": relic_id,
			"name": relic_name,
			"description": relic_description
		})
	queue_free()
