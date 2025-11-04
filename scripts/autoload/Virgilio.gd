extends Node

# Señal para notificar a la UI cuando hay un nuevo mensaje
signal new_message(text)

# Diccionario de frases según evento
var mensajes := {
	"inicio": [
		"Dante... abre los ojos.",
		"Estás atrapado entre la vida y la muerte.",
		"Encuentra las reliquias. El ascensor te espera."
	],
	"cinta_medica": "Esa cinta... tu diagnóstico. El inicio de tu culpa.",
	"ficha_medica": "Recuerda quién eras, Dante. Cada registro guarda un pecado.",
	"llavero": "Las llaves... cerraban más que puertas.",
	"reloj_roto": "El tiempo no cura lo que no se enfrenta.",
	"pua_guitarra": "Tu música calló con tus errores, Dante.",
	"ascensor": "Has superado la primera prueba... pero el juicio continúa."
}

# Guarda el último mensaje mostrado
var ultimo_mensaje: String = ""

# Preload del TutorialUI (para crear uno nuevo si no hay)
@onready var ui_scene = preload("res://scenes/tutorial_ui.tscn")

func mostrar_mensaje(clave: String) -> void:
	# 🔸 Asegurar que el TutorialUI exista (crearlo si no está en escena)
	if not get_tree().root.has_node("TutorialUI"):
		var ui = ui_scene.instantiate()
		ui.name = "TutorialUI"
		get_tree().root.add_child(ui)
		print("🧩 TutorialUI creado dinámicamente por Virgilio.")
	else:
		var ui = get_tree().root.get_node("TutorialUI")
		ui.show()  # por si estaba oculto

	# 🔸 Mostrar mensaje normalmente
	if not mensajes.has(clave):
		print("⚠️ Mensaje de Virgilio no encontrado:", clave)
		return
	
	var msg = mensajes[clave]
	if msg is Array:
		for linea in msg:
			emit_signal("new_message", linea)
	else:
		emit_signal("new_message", msg)
	
	ultimo_mensaje = msg

# permite que el HUD o el botón lo vuelvan a mostrar
func repetir_ultimo_mensaje() -> void:
	if ultimo_mensaje != "":
		emit_signal("new_message", ultimo_mensaje)
