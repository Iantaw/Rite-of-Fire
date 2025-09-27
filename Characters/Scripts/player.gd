extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
var speed = 300

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("move-right") - Input.get_action_strength("move-left")
	input.y = Input.get_action_strength("move-down") - Input.get_action_strength("move-up")

	if input != Vector2.ZERO:
		velocity = input.normalized() * speed
		if input.x > 0:
			anim.play("run-right")
		elif input.x < 0:
			anim.play("run-left")
		elif input.y > 0:
			anim.play("run-down")
		else:
			anim.play("run-up")
	else:
		velocity = Vector2.ZERO
		anim.stop()

	move_and_slide()
