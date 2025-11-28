extends Node2D

func _ready():
	# Conectar cada Area2D hijo automáticamente
	for child in get_children():
		if child is Area2D:
			# Podés poner la intensidad como grupo o export en el Area2D
			var intensity = _get_intensity_for_area(child)
			child.body_entered.connect(Callable(self, "_on_zone_entered").bind(intensity))
			# asegurate que el area monitoree
			child.monitoring = true

func _get_intensity_for_area(area: Area2D) -> int:
	# opción 1: usar grupos (recomendado si ya los pusiste)
	if area.is_in_group("tic_tac_zone_4"):
		return 4
	if area.is_in_group("tic_tac_zone_3"):
		return 3
	if area.is_in_group("tic_tac_zone_2"):
		return 2
	# fallback
	return 1

func _on_zone_entered(body, intensity):
	# usa grupo 'player' o nombre, según tengas
	if (body.is_in_group("player") or body.name == "Player") and Inventory.get_active_relic_id_num() == 3:
		print("se va a reproducir el tic tac con intensidad ", intensity)
		TicTacController.request_tic(intensity)
