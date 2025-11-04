extends Node2D

@export var relic_id: String = ""
@export var relic_name: String = ""
@export var relic_description: String = ""
@export var pickup_radius: float = 70.0

@onready var area: Area2D = $Area2D
var glow_light: Light2D = null

func _ready():
	# Si ya fue recolectada, eliminarla al cargar el nivel
	var inv = get_node_or_null("/root/Inventory")
	if inv and inv.has_collected(relic_id):
		queue_free()
		return

	# Buscar un Light2D en cualquiera de los hijos (recursivo)
	glow_light = _find_first_light2d(self)

	# Conectar el input_event del área
	if area:
		area.connect("input_event", Callable(self, "_on_area_input_event"))

	# Conectar al inventario para actualizar la luz
	if inv:
		if not inv.is_connected("inventory_changed", Callable(self, "_on_inventory_changed")):
			inv.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
		_update_light_visibility()
	else:
		if glow_light:
			glow_light.visible = true  # modo test

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_pickup()

func _try_pickup():
	var inv = get_node_or_null("/root/Inventory")
	if not inv:
		print("⚠️ Inventory no encontrado; no se puede recoger.")
		return

	# Intentar agregar la reliquia (devuelve true si es la correcta)
	if inv.add_relic({
		"id": relic_id,
		"name": relic_name,
		"description": relic_description
	}):
		# Mostrar mensaje de Virgilio asociado a esta reliquia
		var virgilio = get_node_or_null("/root/Virgilio")
		if virgilio:
			virgilio.mostrar_mensaje(relic_id)
		else:
			print("⚠️ Virgilio no encontrado en /root/")

		queue_free()  # eliminar la reliquia del nivel
	else:
		print("❌ No se pudo recoger (no era la reliquia esperada):", relic_id)

func _on_inventory_changed():
	_update_light_visibility()

func _update_light_visibility():
	if glow_light == null:
		return

	var visible_now := false
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		visible_now = inv.is_relic_active(relic_id)

	glow_light.visible = visible_now
	if visible_now:
		glow_light.energy = max(glow_light.energy, 0.1)
	else:
		glow_light.energy = 0.0

# ---------------- helper ----------------
func _find_first_light2d(node: Node) -> Light2D:
	for child in node.get_children():
		if child is Light2D:
			return child
		var found = _find_first_light2d(child)
		if found:
			return found
	return null
