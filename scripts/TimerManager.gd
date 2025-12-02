extends Node

@export var tiempo_inicial: int = 17 # 5 minutos = 300 segundos
@export var bonus_por_reliquia: int = 30
var aviso_tiempo_bajo := false 

# --- NODOS ---
@onready var timer: Timer = $Timer
@onready var ui_label: Label = $UI_Timer/HBoxContainer/LabelTiempo
@onready var panel_gameover: Panel = $UI_Timer/PanelGameOver
@onready var panel_gamepaused: Panel = $UI_Timer/PanelGamePaused
@onready var boton_reintentar: Button = $UI_Timer/PanelGameOver/BotonReintentar
@onready var boton_menu: Button = $UI_Timer/PanelGameOver/BotonMenu
@onready var boton_menu2: Button = $UI_Timer/PanelGamePaused/BotonMenu
@onready var boton_reanudar: Button = $UI_Timer/PanelGamePaused/BotonReanudar
@onready var boton_pausa: TextureButton = $UI_Timer/HBoxContainer/TextureButtonPause
@onready var boton_virgilio: TextureButton = $UI_Timer/HBoxContainer/VirgilioButton



# --- VARIABLES ---
var tiempo_restante: int
var pausado: bool = false

# --- FUNCIONES ---
func _ready():
	tiempo_restante = tiempo_inicial
	panel_gameover.visible = false
	panel_gamepaused.visible = false
	ui_label.text = _formatear_tiempo(tiempo_restante)
	
	timer.wait_time = 1.0
	timer.connect("timeout", Callable(self, "_on_timer_tick"))
	timer.start()
	
	
	# conexiones de botones
	boton_reintentar.connect("pressed", Callable(self, "_on_reintentar_pressed"))
	boton_menu.connect("pressed", Callable(self, "_on_menu_pressed"))
	boton_menu2.connect("pressed", Callable(self, "_on_menu_pressed"))
	boton_pausa.connect("pressed", Callable(self, "_on_pausa_pressed"))
	boton_virgilio.connect("pressed", Callable(self, "_on_virgilio_pressed"))
	boton_reanudar.connect("pressed", Callable(self, "_on_reanudar_pressed"))
	
	# Escuchar si se recoge una reliquia
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.connect("relic_collected", Callable(self, "_on_relic_collected"))

# --- LÓGICA DEL TIMER ---
func _on_timer_tick():
	if not pausado:
		tiempo_restante -= 1

		# 🔸 Si el tiempo llegó a cero, fin del nivel
		if tiempo_restante < 0:
			_tiempo_agotado()
			# poner sonido de poco tiempo
			SFXManager.start_low_time_warning()
			return

		# 🔸 Actualizar texto del temporizador
		ui_label.text = _formatear_tiempo(tiempo_restante)

		# 🔸 Cambiar color y mensaje si queda poco tiempo
		if tiempo_restante <= 15 and not aviso_tiempo_bajo:
			aviso_tiempo_bajo = true

			# Cambiar color del texto a rojo
			ui_label.add_theme_color_override("font_color", Color.RED)

			# Mostrar mensaje de Virgilio
			var virgilio = get_node_or_null("/root/Virgilio")
			if virgilio:
				virgilio.mostrar_mensaje("tiempo_bajo")
			else:
				print("⚠️ Virgilio no encontrado para advertencia de tiempo.")
		
		if tiempo_restante <= 15:
			SFXManager.play("poco_tiempo_tick")
			


func _on_relic_collected(_id: String):
	tiempo_restante += bonus_por_reliquia
	ui_label.text = _formatear_tiempo(tiempo_restante)

	if tiempo_restante > 30:
		ui_label.add_theme_color_override("font_color", Color.WHITE)
		aviso_tiempo_bajo = false
	
	if tiempo_restante > 15:
		SFXManager.stop_low_time_warning()


# --- GAME OVER ---
func _tiempo_agotado():
	timer.stop()
	get_tree().paused = true
	panel_gameover.visible = true
	panel_gameover.modulate.a = 1.0
	panel_gameover.get_node("LabelGameOver").text = "Nivel no completado"
	print("⏰ Tiempo agotado, fin del nivel")

func _on_reintentar_pressed():
	SFXManager.play("click")
	print("🔁 Reiniciando partida...")
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.reset_progress()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	SFXManager.play("click")
	print("🏠 Volviendo al menú principal...")
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.reset_progress()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

# --- BOTONES DE PAUSA Y VIRGILIO ---
func _on_pausa_pressed():
	SFXManager.play("click")
	if get_tree().paused:
		get_tree().paused = false
		pausado = false
		panel_gamepaused.visible = false
		print("▶️ Reanudando juego")
	else:
		get_tree().paused = true
		pausado = true
		panel_gamepaused.visible = true
		print("⏸️ Juego pausado")

func _on_virgilio_pressed():
	SFXManager.play("click")
	var virgilio = get_node_or_null("/root/Virgilio")
	if virgilio:
		virgilio.repetir_ultimo_mensaje()
	else:
		print("⚠️ Virgilio no encontrado en /root")

# --- FORMATO DE TIEMPO ---
func _formatear_tiempo(segundos: int) -> String:
	var m = segundos / 60
	var s = segundos % 60
	return "%02d:%02d" % [m, s]

func _on_reanudar_pressed() -> void:
	SFXManager.play("click")
	print("▶️ Reanudando partida...")
	
	# Asegurarse de que el panel de pausa o game over no quede visible
	if panel_gamepaused:
		panel_gamepaused.visible = false
	
	# Reanudar el juego
	get_tree().paused = false
	pausado = false
