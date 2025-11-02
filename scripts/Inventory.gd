extends Node

# Estructura general del archivo de guardado
var save_data: Dictionary = {
	"nivel_actual": 1,
	"reliquias": [],
	"recuerdos": {
		"limbo": []
	},
	"configuracion": {
		"musica": 0.8,
		"efectos": 0.7,
		"idioma": "es"
	}
}

# Archivo donde se guarda todo
const SAVE_PATH := "user://save_game.json"

# --------------------------------------------------------------
# Guardado de reliquias o recuerdos
# --------------------------------------------------------------
func add_relic(data: Dictionary) -> void:
	# data debe tener { "id": "pua_guitarra", "name": "Púa de guitarra", "description": "..." }
	var relic_id = data.get("id", "")
	if relic_id == "":
		push_warning("No se puede guardar reliquia: id vacío")
		return

	# Guardar en la lista general de reliquias si no está ya
	if relic_id not in save_data["reliquias"]:
		save_data["reliquias"].append(relic_id)

	# Guardar también dentro de los recuerdos del nivel actual (ej: "limbo")
	var current_level = _get_level_name()
	if relic_id not in save_data["recuerdos"][current_level]:
		save_data["recuerdos"][current_level].append(relic_id)

	print("Reliquia/recuerdo guardado:", relic_id)
	save_to_json()

# --------------------------------------------------------------
# Guardar archivo JSON
# --------------------------------------------------------------
func save_to_json():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("💾 Datos guardados correctamente en save_game.json")

# --------------------------------------------------------------
# Cargar archivo JSON
# --------------------------------------------------------------
func load_from_json():
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠️ No existe archivo de guardado, creando uno nuevo...")
		save_to_json()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		save_data = data
		print("✅ Datos cargados:", save_data)
	else:
		push_warning("Error al parsear save_game.json, creando nuevo...")
		save_to_json()

# --------------------------------------------------------------
# Función auxiliar para saber el nombre del nivel actual
# --------------------------------------------------------------
func _get_level_name() -> String:
	match save_data["nivel_actual"]:
		1:
			return "limbo"
		2:
			return "lujuria"
		3:
			return "gula"
		_:
			return "desconocido"
