# Inventory.gd (autoload)
extends Node

# Lista ordenada de reliquias que deben recolectarse en orden.
@export var ordered_relics: Array = [
	"cinta_medica",
	"ficha_medica",
	"llavero",
	"reloj_roto",
	"pua_guitarra"
]

# Estado runtime: reliquias recolectadas en orden (IDs)
var collected: Array = []

# Save data general
var save_data: Dictionary = {
	"nivel_actual": 1,
	"reliquias": [],
	"recuerdos": {"limbo": []},
	"configuracion": {"musica": 0.8, "efectos": 0.7, "idioma": "es"},
	"mision_completa": false
}

const SAVE_PATH := "user://save_game.json"

signal inventory_changed         # emite cuando cambia collected
signal relic_collected(relic_id) # cuando se recoge una reliquia

func _ready():
	load_from_json()
	# sincroniza collected con save_data si existe
	if save_data.has("reliquias") and save_data["reliquias"] is Array:
		collected = save_data["reliquias"]
	# emitir para que las reliquias en escena se actualicen
	emit_signal("inventory_changed")

# Devuelve true si el id ya fue recolectado
func has_collected(relic_id: String) -> bool:
	return relic_id in collected

# Devuelve el id de la reliquia que está activa (siguiente en la secuencia), o "" si no hay
func get_active_relic_id() -> String:
	var next_index = collected.size()
	if next_index < ordered_relics.size():
		return ordered_relics[next_index]
	return ""

# Comprueba si el id es la reliquia activa
func is_relic_active(relic_id: String) -> bool:
	return (not has_collected(relic_id)) and (get_active_relic_id() == relic_id)

# Añade una reliquia SOLO si es la siguiente en la lista ordenada.
# data: Dictionary con al menos "id"
# Devuelve true si se agregó correctamente, false si no (por ejemplo, no es la siguiente).
func add_relic(data: Dictionary) -> bool:
	var relic_id = data.get("id", "")
	if relic_id == "":
		push_warning("Inventory.add_relic: id vacío")
		return false

	# Si ya está recolectada, no hacer nada
	if has_collected(relic_id):
		return false

	# Debe coincidir con la siguiente reliquia en orden
	var expected = get_active_relic_id()
	if relic_id != expected:
		# opcional: reproducir un "error" sonoro o feedback
		print("No es la reliquia esperada. Esperada:", expected, "recibida:", relic_id)
		return false

	# agregar a collected y guardar
	collected.append(relic_id)
	# tambien actualizar save_data.reliquias y recuerdos (nivel actual)
	save_data["reliquias"] = collected.duplicate()
	var level_name = _get_level_name(save_data["nivel_actual"])
	if not save_data["recuerdos"].has(level_name):
		save_data["recuerdos"][level_name] = []
	save_data["recuerdos"][level_name].append(relic_id)

	# si completó todas las ordered_relics -> mision_completa
	if collected.size() == ordered_relics.size():
		save_data["mision_completa"] = true

	# persistir y notificar
	save_to_json()
	emit_signal("inventory_changed")
	emit_signal("relic_collected", relic_id)
	print("Inventory: added relic:", relic_id)
	return true

func is_mission_complete() -> bool:
	return bool(save_data.get("mision_completa", false))

# ----------------- Save / Load -----------------
func save_to_json() -> void:
	var f = FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.WRITE)
	if not f:
		push_error("No se pudo abrir " + SAVE_PATH + " para guardar.")
		return
	# mantener save_data sincronizado
	save_data["reliquias"] = collected.duplicate()
	f.store_string(JSON.stringify(save_data, "\t"))
	f.close()
	print("Inventory: saved to", SAVE_PATH)

func load_from_json() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No existe save, creando uno nuevo.")
		save_to_json()
		return

	var f = FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.READ)
	if not f:
		push_error("No se pudo abrir " + SAVE_PATH + " para lectura.")
		return
	var txt = f.get_as_text()
	f.close()

	# Intentamos parsear. JSON.parse_string puede devolver directamente
	# el Dictionary parseado o un objeto de resultado según versión/contexto.
	var parsed = JSON.parse_string(txt)

	# Caso A: parsed es ya el Dictionary del JSON (tipo  TYPE_DICTIONARY)
	if typeof(parsed) == TYPE_DICTIONARY:
		save_data = parsed
		# sincronizar collected si existe el campo
		if save_data.has("reliquias") and save_data["reliquias"] is Array:
			collected = save_data["reliquias"]
		print("Inventory: loaded (direct dict) ", save_data)
		return

	# Caso B: parsed es un JSONParseResult-like (objeto con .error y .result)
	# Comprobamos de forma segura usando get() para evitar errores
	# (acá asumimos que parsed es un Object con métodos accesibles)
	# En GDScript comprobamos si tiene el método 'has' o propiedad 'result' mediante 'parsed is Dictionary' fue descartado arriba,
	# así que manejamos como fallback:
	if typeof(parsed) == TYPE_OBJECT:
		# intentar acceder a los campos esperados con safe calls
		# (algunas versiones devuelven un objeto con keys 'error' y 'result')
		var ok := false
		if parsed.has_method("get"):
			# si es un Resource/Wrapper que soporta get, intentamos
			var maybe_result = null
			# intentamos atraparlo sin tirar excepción
			# nota: si esto falla, entramos al fallback de abajo
			# Intento directo:
			if parsed.has("result"):
				maybe_result = parsed.get("result")
				if typeof(maybe_result) == TYPE_DICTIONARY:
					save_data = maybe_result
					if save_data.has("reliquias") and save_data["reliquias"] is Array:
						collected = save_data["reliquias"]
					print("Inventory: loaded (result field) ", save_data)
					return

	# Fallback: si no pudimos parsear correctamente, reseteamos el save y lo re-escribimos
	push_warning("Inventory: no se pudo parsear JSON correctamente. Se creará un save por defecto.")
	save_to_json()

# helper: nombre del nivel por indice (ajustalo si tenés mas niveles)
func _get_level_name(level_index: int) -> String:
	match level_index:
		1: return "limbo"
		2: return "lujuria"
		3: return "gula"
		4: return "avaricia"
		5: return "ira"
		6: return "herejia"
		7: return "fraude"
		8: return "traicion"
		9: return "dante"
		_: return "unknown"
