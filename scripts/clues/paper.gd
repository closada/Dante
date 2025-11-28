extends Node2D

func _ready():
	visible = false
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.inventory_changed.connect(_refresh_visibility)
		_refresh_visibility() # primera evaluación

func _refresh_visibility():
	var inv = get_node("/root/Inventory")
	var next_id_num = inv.get_active_relic_id_num()

	print("Pista: la siguiente reliquia es ID:", next_id_num)

	# mostrar pista SI número > 1
	visible = next_id_num > 0
