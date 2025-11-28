extends Node2D

# Path al TileMap (ajustalo si tu nodo se llama distinto)
@export var tilemap_path: NodePath = "TileMapLayer"

# Duraciones (ajustalas en Inspector)
@export var fade_duration: float = 0.20        # duración del fade-in / fade-out
@export var hold_after_fade: float = 0.09     # pequeño hold entre fade in y fade out (puede ser 0)
@export var short_pause: float = 1.5         # pausa corta entre pares
@export var long_pause: float = 3.0           # pausa larga al final del ciclo

# Alphas
@export var bright_alpha: float = 1.0
@export var dim_alpha: float = 0.12

# Internals
var tilemap: TileMapLayer = null
var _blinking: bool = false
var _current_tween: Tween = null


func _ready():
	# obtener el TileMap
	if has_node(tilemap_path):
		tilemap = get_node(tilemap_path) as TileMapLayer
	else:
		push_error("ClockBlink (TileMap): no se encontró el TileMap en: " + str(tilemap_path))
		return

	# arrancar oculto
	tilemap.modulate.a = 0.0
	tilemap.visible = false

	# conectar Inventory para reaccionar en tiempo real
	var inv = get_node_or_null("/root/Inventory")
	if inv:
		if not inv.is_connected("inventory_changed", Callable(self, "_on_inventory_changed")):
			inv.connect("inventory_changed", Callable(self, "_on_inventory_changed"))

	# evaluar estado inicial (por carga de save o reentrada)
	_on_inventory_changed()


func _on_inventory_changed() -> void:
	var inv = get_node_or_null("/root/Inventory")
	if not inv:
		_stop_blinking()
		return

	# obtén el número activo con tipo explícito (evita errores de tipado)
	var active_num: int = inv.get_active_relic_id_num()
	if active_num == 4:
		# mostrar y comenzar parpadeo
		tilemap.visible = true
		_start_blinking()
	else:
		# ocultar y detener parpadeo
		_stop_blinking()
		tilemap.visible = false
		tilemap.modulate.a = 0.0


# Inicia el loop de parpadeo (no lanza múltiples loops)
func _start_blinking() -> void:
	if _blinking:
		return
	_blinking = true
	call_deferred("_blink_loop_async")  # iniciar coroutine de forma segura


func _stop_blinking() -> void:
	_blinking = false
	# matar tween activo si lo hay
	if _current_tween:
		_current_tween.kill()
		_current_tween = null
	# restaurar visual
	if tilemap:
		tilemap.modulate.a = 0.0
		tilemap.visible = false


# --- Coroutine principal ---
func _blink_loop_async() -> void:
	if tilemap == null:
		_blinking = false
		return

	# asegurarnos visible
	tilemap.visible = true

	while _blinking:
		# Primer par (2 flashes)
		if not _blinking:
			break
		yield_from_flash_pair()
		if not _blinking:
			break
		await get_tree().create_timer(short_pause).timeout

		# Segundo par (2 flashes)
		if not _blinking:
			break
		yield_from_flash_pair()
		if not _blinking:
			break
		await get_tree().create_timer(short_pause).timeout

		# Tercer par (2 flashes)
		if not _blinking:
			break
		yield_from_flash_pair()
		if not _blinking:
			break
		# Pausa larga antes de repetir
		await get_tree().create_timer(long_pause).timeout

	# Al salir del loop
	if tilemap:
		tilemap.modulate.a = 0.0
		tilemap.visible = false


# Hace dos flash suaves (fade-in -> hold -> fade-out) x2 usando tweens, de forma sincrónica
func yield_from_flash_pair() -> void:
	# primer flash
	_perform_smooth_flash()
	# pequeña espera entre flashes (opcional muy breve)
	await get_tree().create_timer(0.70).timeout
	# segundo flash
	_perform_smooth_flash()
	# al regresar, el caller espera la pausa correspondiente


# Crea y espera un tween que realiza fade-in -> hold -> fade-out
func _perform_smooth_flash() -> void:
	# si interrumpieron:
	if not _blinking:
		return

	# matar tween anterior si existe
	if _current_tween:
		_current_tween.kill()
		_current_tween = null

	# preparar tween: fade a bright_alpha y luego a dim_alpha
	tilemap.modulate.a = dim_alpha  # empezar en dim para que el fade sea visible

	_current_tween = create_tween()
	_current_tween.tween_property(tilemap, "modulate:a", bright_alpha, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_current_tween.tween_interval(hold_after_fade) # pequeño hold en bright
	_current_tween.tween_property(tilemap, "modulate:a", dim_alpha, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# esperar a que termine el tween
	await _current_tween.finished
	_current_tween = null
