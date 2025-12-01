extends Node2D

@export var relic_number := 6        # foto quemada
@export var flash_time := 0.25       # duración del flash
@export var pause_short := 0.4
@export var pause_long := 0.9

var flashes := []       # lista de nodos flash
var active := false


func _ready():
	# obtener todos los flashes automáticamente
	flashes = get_children()

	# apagar todos los flashes
	for f in flashes:
		f.modulate.a = 0.0

	Inventory.inventory_changed.connect(_check_state)
	_check_state()


func _check_state():
	var num = Inventory.get_active_relic_id_num()
	
	if num == relic_number:
		if not active:
			active = true
			_start_flash_sequence()
	else:
		active = false
		_turn_off()


func _turn_off():
	for f in flashes:
		var sprite : Sprite2D = f.get_node_or_null("Sprite2D")
		var light : PointLight2D = f.get_node_or_null("PointLight2D")

		if sprite:
			sprite.modulate.a = 0.0

		if light:
			light.energy = 0.0



func _start_flash_sequence():
	await get_tree().process_frame

	while active:
		# encenderlos en orden (efecto cascada)
		for i in range(flashes.size()):
			if not active:
				return
			_flash_once(flashes[i])
			await get_tree().create_timer(pause_short).timeout

		# pausa larga antes de repetir todo el camino
		await get_tree().create_timer(pause_long).timeout


func _flash_once(node: Node2D):
	var sprite := node.get_node_or_null("Sprite2D")
	var light := node.get_node_or_null("PointLight2D")
	print("sprite: ", sprite, "light: ", light)

	# Parpadeo del sprite
	if sprite:
		var t1 = create_tween()
		t1.tween_property(sprite, "modulate:a", 1.0, flash_time)
		t1.tween_property(sprite, "modulate:a", 0.0, flash_time)

	# Parpadeo de la luz
	if light:
		var t2 = create_tween()
		t2.tween_property(light, "energy", 1.0, flash_time)
		t2.tween_property(light, "energy", 0.0, flash_time)
