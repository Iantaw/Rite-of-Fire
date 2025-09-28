extends CharacterBody2D

@export var speed = 300.0
@export var throw_force = 300.0
@export var ui_y_offset = -30 # Offset for the UI above the NPC

var can_interact = false
var interactable_npc = null
var grabbed_npc = null

# This will be assigned dynamically when the player enters an NPC's detection area
var interaction_prompt: Label = null

@onready var animated_sprite_2d = $AnimatedSprite2D # Added for player animation

func _physics_process(delta):
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("move-right"):
		input_direction.x += 1
	if Input.is_action_pressed("move-left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move-down"):
		input_direction.y += 1
	if Input.is_action_pressed("move-up"):
		input_direction.y -= 1

	velocity = input_direction.normalized() * speed
	move_and_slide()

	update_animation(input_direction) # Call the new animation function

	if Input.is_action_just_pressed("interact"):
		if can_interact and interactable_npc and not grabbed_npc:
			grab_npc(interactable_npc)
		elif grabbed_npc:
			throw_npc()

	update_interaction_prompt()

	# Update the UI prompt's position to follow the NPC if one is interactable or grabbed
	if interaction_prompt and (interactable_npc or grabbed_npc):
		var target_npc = interactable_npc if interactable_npc else grabbed_npc
		if target_npc:
			# Convert NPC's world position to screen position
			var camera = get_viewport().get_camera_2d()
			if camera:
				var screen_position = camera.get_canvas_transform().affine_inverse() * target_npc.global_position
				interaction_prompt.global_position = screen_position + Vector2(0, ui_y_offset) - (interaction_prompt.size / 2) # Center horizontally

func update_animation(input_direction):
	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x > 0:
			animated_sprite_2d.play("run-left") 
		else:
			animated_sprite_2d.play("run-right") 
	else:
		if input_direction.y > 0:
			animated_sprite_2d.play("run-down") 
		else:
			animated_sprite_2d.play("run-up") 

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("npc") and not grabbed_npc:
		can_interact = true
		interactable_npc = body
		var npc_prompt_node = interactable_npc.find_child("InteractionPrompt", true, false)
		if npc_prompt_node and npc_prompt_node is Label:
			interaction_prompt = npc_prompt_node
		update_interaction_prompt()
		
func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("npc") and interactable_npc == body:
		can_interact = false
		interactable_npc = null
		if interaction_prompt:
			interaction_prompt.hide()
			interaction_prompt = null # Clear reference when NPC is out of range
		update_interaction_prompt()
		
func grab_npc(npc):
	grabbed_npc = npc
	grabbed_npc.grab(self)
	can_interact = false # Cannot interact with other NPCs while holding one
	interactable_npc = null
	update_interaction_prompt()

func throw_npc():
	if grabbed_npc:
		var throw_direction = get_global_mouse_position() - global_position # Or use player's last movement direction
		throw_direction = throw_direction.normalized()
		grabbed_npc.throw(throw_direction, throw_force)
		grabbed_npc = null
		# After throwing, re-evaluate if any other NPC is in range to show their prompt
		# This can be done by simulating an exit/enter or by checking the area's current bodies
		# For now, we'll just hide the prompt and let the area signals handle re-detection.
		if interaction_prompt:
			interaction_prompt.hide()
			interaction_prompt = null
		update_interaction_prompt()

func update_interaction_prompt():
	if interaction_prompt:
		if can_interact and interactable_npc and not grabbed_npc:
			interaction_prompt.text = "Press G to Grab"
			interaction_prompt.show()
		elif grabbed_npc:
			interaction_prompt.text = "Press G to Throw"
			interaction_prompt.show()
		else:
			interaction_prompt.hide()
