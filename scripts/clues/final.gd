extends Node2D

@onready var particles := $CPUParticles2D

func _ready():
	visible = false
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.inventory_changed.connect(_refresh_visibility)
		_refresh_visibility()

func _refresh_visibility():
	var inv = get_node("/root/Inventory")
	var next_id_num = inv.get_active_relic_id_num()

	visible = (next_id_num == -1)

	if visible:
		particles.emitting = false
		particles.emitting = true  # reiniciar emisión
		print("se activa visibilidad particulas")
