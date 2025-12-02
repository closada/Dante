extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_collision: CollisionShape2D = $CollisionShape2D
@onready var area_detector: Area2D = $Area2D_Detector
@onready var area_inside: Area2D = $Area2D_Inside
@onready var ui_fin_nivel: CanvasLayer = $UI_FinNivel
@onready var panel: Panel = $UI_FinNivel/Panel
@onready var label: Label = $UI_FinNivel/Panel/Label
@onready var btn_next: Button = $UI_FinNivel/Panel/BotonSiguiente
@onready var btn_menu: Button = $UI_FinNivel/Panel/BotonMenu
@onready var anim_player: AnimationPlayer = $UI_FinNivel/AnimationPlayer

var is_open := false
var player_inside := false

func _ready() -> void:
	anim.play("Idle")
	panel.visible = false
	ui_fin_nivel.visible = false

	# Señales del área interior (jugador dentro del ascensor)
	area_inside.connect("body_entered", Callable(self, "_on_inside_entered"))
	area_inside.connect("body_exited", Callable(self, "_on_inside_exited"))

	btn_menu.connect("pressed", Callable(self, "_on_menu_pressed"))
	btn_next.connect("pressed", Callable(self, "_on_next_pressed"))

	# Escuchar cambios en el inventario
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		inv.connect("inventory_changed", Callable(self, "_on_inventory_changed"))

func _on_inventory_changed() -> void:
	_check_open_condition()

func _check_open_condition() -> void:
	if Inventory.is_mission_complete() and not is_open:
		_open_elevator()

# --- Lógica de apertura del ascensor ---
func _open_elevator() -> void:
	SFXManager.play("elevator_open")
	is_open = true
	anim.play("Open")
	await anim.animation_finished
	door_collision.disabled = true
	print("Ascensor desbloqueado.")

# --- Área de detección de proximidad ---
func _on_detector_entered(body: Node) -> void:
	if body is CharacterBody2D and Inventory.is_mission_complete() and not is_open:
		_open_elevator()
		


func _on_inside_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_inside = false

# --- UI de fin de nivel ---
func _show_fin_nivel_ui() -> void:
	print("fin nivel")
	ui_fin_nivel.visible = true
	panel.visible = true
	# panel.modulate.a = 0.0

	if anim_player and anim_player.has_animation("fade_in"):
		anim_player.play("fade_in")
	else:
		panel.modulate.a = 1.0

	get_tree().paused = true

func _on_menu_pressed() -> void:
	SFXManager.play("click")
	print("🏠 Volviendo al menú principal...")
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		inv.reset_progress()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_next_pressed() -> void:
	SFXManager.play("click")
	get_tree().paused = false
	print("Próximo nivel (por ahora sin funcionalidad)")


func _on_area_2d_inside_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and is_open and Inventory.is_mission_complete():
		player_inside = true
		# print("por mostrar mensaje")
		_show_fin_nivel_ui()
