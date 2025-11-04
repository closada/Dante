extends Control


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_opciones.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
