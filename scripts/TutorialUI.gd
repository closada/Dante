extends CanvasLayer

@export var textos: Array[String] = [
	"Dante... estás en un hospital.",
	"Debes encontrar los objetos para activar el ascensor.",
	"Usa W, A, S, D o las flechas para moverte.",
	"Haz click izquierdo para recolectar objetos.",
	"Empecemos..."
]

var indice := 0
var custom_text: String = ""

@onready var panel = $Panel
@onready var portrait = $Panel/HBoxContainer/Portrait
@onready var label = $Panel/HBoxContainer/Label

func _ready():
	var virgilio = get_node_or_null("/root/Virgilio")
	if virgilio:
		if not virgilio.is_connected("new_message", Callable(self, "_on_new_message")):
			virgilio.connect("new_message", Callable(self, "_on_new_message"))
	else:
		print("⚠️ Virgilio no encontrado en /root/.")

	panel.visible = true
	portrait.visible = false  # ocultar al inicio
	label.text = custom_text if custom_text != "" else textos[indice]

	get_tree().paused = true
	set_process_input(true)

func _on_new_message(texto: String) -> void:
	panel.visible = true
	portrait.visible = true  # mostrar retrato de Virgilio cuando habla
	label.text = texto
	get_tree().paused = true
	custom_text = texto

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if custom_text != "":
			cerrar_tutorial()
		else:
			avanzar_texto()

func avanzar_texto():
	indice += 1
	if indice < textos.size():
		label.text = textos[indice]
	else:
		cerrar_tutorial()

func cerrar_tutorial():
	panel.visible = false
	portrait.visible = false
	get_tree().paused = false
	custom_text = ""
	hide()
