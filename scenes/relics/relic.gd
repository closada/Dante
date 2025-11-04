extends Node2D

@export var relic_id: String = ""
@export var relic_name: String = ""
@export var relic_description: String = ""
@export var pickup_radius: float = 70.0

@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
var glow_light: Light2D = null

func _ready():
	# buscar un Light2D en cualquiera de los hijos (recursivo)
	glow_light = _find_first_light2d(self)
	# conectar input_event del area
	if area:
		area.connect("input_event", Callable(self, "_on_area_input_event"))
	# conectar al Inventory autoload si existe (ruta segura)
	if has_node("/root/Inventory"):
		var inv = get_node("/root/Inventory")
		if not inv.is_connected("inventory_changed", Callable(self, "_on_inventory_changed")):
			inv.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
		_update_light_visibility()
	else:
		# modo test: mostrar la luz si existe
		if glow_light:
			glow_light.visible = true

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_pickup()

func _try_pickup():
	# intento simple: llamar Inventory para agregar ( Inventory must exist as autoload )
	if not has_node("/root/Inventory"):
		print("Inventory no encontrado; no se puede recoger.")
		return

	# intentamos agregar; Inventory.add_relic devuelve true/false
	if Inventory.add_relic({"id": relic_id, "name": relic_name, "description": relic_description}):
		queue_free()
	else:
		# feedback: no es la reliquia esperada
		print("No se pudo recoger (no era la reliquia esperada):", relic_id)

func _on_inventory_changed():
	_update_light_visibility()

func _update_light_visibility():
	if glow_light == null:
		# debug: si querés ver por qué no aparece la luz
		# print("Glow light no encontrada para relic:", relic_id)
		return
	# visible solo si la reliquia está 'activa' (siguiente en el orden) y no recolectada
	var visible_now = false
	if has_node("/root/Inventory"):
		visible_now = Inventory.is_relic_active(relic_id)
	# aplicar visibilidad y energía
	glow_light.visible = visible_now
	if visible_now:
		# restablecer energía mínima para que el script de pulso funcione
		glow_light.energy = max(glow_light.energy, 0.1)
	else:
		# apagar completamente
		glow_light.energy = 0.0

# ---------------- helper ----------------
# busca recursivamente el primer Light2D hijo y lo retorna (o null)
func _find_first_light2d(node: Node) -> Light2D:
	for child in node.get_children():
		# en GDScript 'is' chequea el tipo
		if child is Light2D:
			return child
		# recursión
		var found = _find_first_light2d(child)
		if found:
			return found
	return null
