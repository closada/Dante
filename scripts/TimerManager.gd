extends Node

@export var tiempo_inicial: int = 30 # 5 minutos = 300 segundos
@export var bonus_por_reliquia: int = 30

@onready var timer: Timer = $Timer
@onready var ui_label: Label = $UI_Timer/LabelTiempo
@onready var panel_gameover: Panel = $UI_Timer/PanelGameOver
@onready var boton_reintentar: Button = $UI_Timer/PanelGameOver/BotonReintentar
@onready var boton_menu: Button = $UI_Timer/PanelGameOver/BotonMenu

var tiempo_restante: int

func _ready():
	tiempo_restante = tiempo_inicial
	panel_gameover.visible = false
	ui_label.text = _formatear_tiempo(tiempo_restante)
	
	timer.wait_time = 1.0
	timer.connect("timeout", Callable(self, "_on_timer_tick"))
	timer.start()
	
	boton_reintentar.connect("pressed", Callable(self, "_on_reintentar_pressed"))
	boton_menu.connect("pressed", Callable(self, "_on_menu_pressed"))

	# Escuchar si se recoge una reliquia
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.connect("relic_collected", Callable(self, "_on_relic_collected"))

func _on_timer_tick():
	tiempo_restante -= 1
	if tiempo_restante < 0:
		_tiempo_agotado()
	else:
		ui_label.text = _formatear_tiempo(tiempo_restante)

func _on_relic_collected(_id: String):
	tiempo_restante += bonus_por_reliquia
	print("Tiempo aumentado:", tiempo_restante)
	ui_label.text = _formatear_tiempo(tiempo_restante)

func _tiempo_agotado():
	timer.stop()
	get_tree().paused = true
	panel_gameover.visible = true
	panel_gameover.modulate.a = 1.0
	panel_gameover.get_node("LabelGameOver").text = "Nivel no completado"
	print("⏰ Tiempo agotado, fin del nivel")

func _on_reintentar_pressed():
	print("Reiniciando partida...")
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.reset_progress()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _formatear_tiempo(segundos: int) -> String:
	var m = segundos / 60
	var s = segundos % 60
	return "%02d:%02d" % [m, s]

func _on_menu_pressed():
	print("Reiniciando partida y volviendo al menu...")
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.reset_progress()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
