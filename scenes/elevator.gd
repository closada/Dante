extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var area = $Area2D
var is_open = false

func _ready():
	anim.play("Idle")
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	# conectar al cambio de inventario
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
		_check_open_condition()

func _on_body_entered(body):
	if body is CharacterBody2D and Inventory.is_mission_complete():
		_open_elevator()

func _on_inventory_changed():
	_check_open_condition()

func _check_open_condition():
	if Inventory.is_mission_complete() and not is_open:
		_open_elevator()

func _open_elevator():
	is_open = true
	anim.play("Open")
	await anim.animation_finished
	collision_layer = 0
	collision_mask = 0
	print("Ascensor desbloqueado.")
