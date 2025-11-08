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
	"cinta_medica": "Tu cinta médica... estás hospitalizado. ¿Qué te pasó, Dante?",
	"ficha_medica": "Fragmentos de tu informe... coma inducido. Esto no es un sueño.",
	"llavero": "Un llavero con un casco roto... el accidente.",
	"reloj_roto": "La hora en que todo se detuvo.",
	"pua_guitarra": "Tu púa. Tu música.",
	"ascensor": "Has superado la primera prueba... pero el juicio continúa.",
	"tiempo_bajo": "¡Apurate, Dante! El tiempo se está agotando..."
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
	print("🔁 Llamado para repetir último mensaje")
	if ultimo_mensaje == "":
		print("⚠️ No hay mensaje anterior para repetir.")
		return

	# 🔸 Asegurar que el TutorialUI exista (igual que en mostrar_mensaje)
	var ui: Node = null
	if not get_tree().root.has_node("TutorialUI"):
		ui = ui_scene.instantiate()
		ui.name = "TutorialUI"
		get_tree().root.add_child(ui)
		print("🧩 TutorialUI creado dinámicamente por Virgilio (repetición).")
	else:
		ui = get_tree().root.get_node("TutorialUI")
		ui.show()

	# 🔸 Emitir el mensaje para que el UI lo reciba
	print("📢 Reenviando mensaje: ", ultimo_mensaje)
	emit_signal("new_message", ultimo_mensaje)
