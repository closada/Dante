extends Control

@onready var music_slider: HSlider = $VBoxContainer/Musica/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/efectos/SFXSlider

func _ready() -> void:
	# --- Cargar valores desde Inventory ---
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		var vol_musica = inv.get_config("musica", 0.8)
		var vol_sfx = inv.get_config("efectos", 0.7)
		music_slider.value = MusicManager.volumen_actual
		sfx_slider.value = vol_sfx
		# Aplicar a los buses al iniciar
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(vol_musica))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(vol_sfx))
		
		

func _on_music_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)

func _on_sfx_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	if has_node("/root/Inventory"):
		get_node("/root/Inventory").set_config("efectos", value)
		print("guardo el valor en json")

func _on_button_pressed() -> void:
	SFXManager.play("click")
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
