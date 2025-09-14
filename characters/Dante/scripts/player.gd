class_name Player extends CharacterBody2D


@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D

var move_speed := 200

var last_direction := "Up"


func _physics_process(delta: float) -> void:
	var move_direction := Input.get_vector("ui_left", "ui_right","ui_up", "ui_down")
	# print(move_direction)
	
	if move_direction:
		velocity = move_direction * move_speed
	
	# Decidir la animación según hacia dónde va
		if abs(move_direction.x) > abs(move_direction.y):
			if move_direction.x > 0:
				sprite_animation.play("Walking_Right")
				last_direction = "Right"
			else:
				sprite_animation.play("Walking_Left")
				last_direction = "Left"
		else:
			if move_direction.y > 0:
				sprite_animation.play("Walking_Down")
				last_direction = "Down"
			else:
				sprite_animation.play("Walking_Up")
				last_direction = "Up"
	else:
		velocity = Vector2.ZERO
		sprite_animation.play("Idle_" + last_direction)
		
	move_and_slide()
	
func _process(delta):
	if sprite_animation.animation == "Walking_Down":
		sprite_animation.scale = Vector2(0.7, 0.7)
	else:
			if sprite_animation.animation == "Idle_Down":
				sprite_animation.scale = Vector2(0.9,0.9)
			else:
				sprite_animation.scale = Vector2(1, 1)
