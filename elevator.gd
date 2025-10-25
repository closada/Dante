extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var area = $Area2D

var is_open = false

func _ready():
	anim.play("Idle")
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D and not is_open:
		is_open = true
		anim.play("Open")

		# Si querés que deje de bloquear a Dante después de abrirse:
		await anim.animation_finished
		collision_layer = 0
		collision_mask = 0
		print("Ascensor abierto: ahora es atravesable.")
