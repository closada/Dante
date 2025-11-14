extends Control


func _ready():
# Ruta de tu música de menú
	var music_path = 	"res://assets/audio/theme_Dante.mp3"
	# Reproducir solo si no está ya sonando (por ejemplo, al volver del juego)
	if not MusicManager.is_playing():
		MusicManager.play_music(music_path)

func _on_jugar_pressed() -> void:
	SFXManager.play("click")
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_opciones_pressed() -> void:
	SFXManager.play("click")
	get_tree().change_scene_to_file("res://scenes/menu_opciones.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
