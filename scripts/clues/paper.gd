extends Node2D

@export var auto_hide := false  # por si después querés que desaparezcan
# El papel empieza invisible hasta que una reliquia lo active
func _ready():
	visible = false
	#si es distinto de la cinta, debo mostrar los papeles
	if Inventory.get_active_relic_id_num() > 0:
		visible = true
	print("id de reliquia a levantar: ", Inventory.get_active_relic_id())
