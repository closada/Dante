extends CanvasLayer

@export var textos: Array[String] = [
	"Dante... estás en un hospital.",
	"Debes encontrar los objetos para activar el ascensor.",
	"Usa W, A, S, D o las flechas para moverte.",
	"Haz click izquierdo para recolectar objetos.",
	"Empecemos..."
]

var indice := 0
var player: Node = null

@onready var panel = $Panel
@onready var label = $Panel/Label

func _ready():
	panel.visible = true
	label.text = textos[indice]
	get_tree().paused = true  # pausa el juego mientras se muestra el tutorial
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		avanzar_texto()

func avanzar_texto():
	indice += 1
	if indice < textos.size():
		label.text = textos[indice]
	else:
		cerrar_tutorial()

func cerrar_tutorial():
	panel.visible = false
	get_tree().paused = false  # vuelve a habilitar todo
	queue_free()  # elimina el nodo si ya no se usa
