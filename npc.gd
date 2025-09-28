# npc_random_movement.gd
extends CharacterBody2D

@export var speed = 50.0
@export var detection_range = 50.0

var rng = RandomNumberGenerator.new()
var target_position = Vector2()
var is_moving = false
var is_grabbed = false
var grabber = null

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var chat_detection_area = $chat_detection_area
@onready var movement_timer = $Timer

func _ready():
	rng.randomize()
	set_random_target_position()
	movement_timer.timeout.connect(set_random_target_position)

func _physics_process(delta):
	if is_grabbed:
		global_position = grabber.global_position + Vector2(0, -16) # Adjust offset as needed
		return

	if is_moving:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		update_animation(direction)

		if global_position.distance_to(target_position) < 5:
			is_moving = false
			velocity = Vector2.ZERO
			animated_sprite_2d.play("idle")
			movement_timer.start(rng.randf_range(2.0, 5.0)) # Wait before moving again
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.play("idle")

func set_random_target_position():
	var random_angle = rng.randf_range(0, PI * 2)
	var random_distance = rng.randf_range(20, 100) # NPC moves within a certain radius
	target_position = global_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
	is_moving = true
	movement_timer.start(rng.randf_range(3.0, 7.0)) # Move for a random duration

func update_animation(direction):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite_2d.play("walk_e")
		else:
			animated_sprite_2d.play("walk_w")
	else:
		if direction.y > 0:
			animated_sprite_2d.play("walk_s")
		else:
			animated_sprite_2d.play("walk_n")

func grab(player_node):
	is_grabbed = true
	grabber = player_node
	set_physics_process(false) # Stop NPC's own physics processing

func release():
	is_grabbed = false
	grabber = null
	set_physics_process(true) # Resume NPC's own physics processing

func throw(throw_direction: Vector2, throw_force: float):
	release()
	velocity = throw_direction * throw_force
	# Re-enable physics processing and let it move with the new velocity
	set_physics_process(true)
	# Optionally, you might want to stop random movement for a bit after being thrown
	movement_timer.stop()
	movement_timer.start(rng.randf_range(1.0, 2.0)) # Short delay before resuming random movement
	is_moving = true # Ensure it starts moving after the throw
