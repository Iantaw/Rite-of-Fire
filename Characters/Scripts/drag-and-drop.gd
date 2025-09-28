extends CharacterBody2D

var is_dragging = false
var drag_offset = Vector2.ZERO
var movement_speed = 50.0 # Pixels per second
var target_sea_position = Vector2.ZERO # This will be set by the main scene or calculated
var is_moving = true

signal npc_dropped_on_sea # Signal to indicate NPC was dropped on sea (not reached by itself)

func _ready():
	input_event.connect(_on_input_event)
	add_to_group("draggable")
	print("Draggable object ready: ", name)

func _physics_process(delta):
	if is_moving and not is_dragging:
		# Move towards the target sea position
		var direction = (target_sea_position - global_position).normalized()
		velocity = direction * movement_speed
		move_and_slide()

func _on_input_event(viewport, event, shape_idx):
	# Start dragging when clicked
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			drag_offset = global_position - get_global_mouse_position()
			is_dragging = true
			is_moving = false # Stop moving when dragged
			print("Started dragging: ", name)
	elif event is InputEventScreenTouch:
		if event.pressed:
			drag_offset = global_position - event.position
			is_dragging = true
			is_moving = false # Stop moving when dragged
			print("Started touch dragging: ", name)

func _input(event):
	if not is_dragging:
		return
	
	# Stop dragging when mouse/touch is released
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
			is_moving = true # Resume moving after dropped
			print("Stopped dragging: ", name)
			# Check if dropped on sea (this will be handled by SeaZone, but good to have a signal here too)
			# For now, this signal is not used, but could be for more complex logic.
			npc_dropped_on_sea.emit()
	elif event is InputEventScreenTouch:
		if not event.pressed:
			is_dragging = false
			is_moving = true # Resume moving after dropped
			print("Stopped touch dragging: ", name)
			npc_dropped_on_sea.emit()

# Function to set the target sea position (called by the main scene when NPC is spawned)
func set_target_sea_position(pos: Vector2):
	target_sea_position = pos

