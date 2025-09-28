# drag-and-drop.gd - Attach this to your draggable objects (Area2D)
extends CharacterBody2D

var is_dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	# Connect input events for dragging
	input_event.connect(_on_input_event)
	
	# Add to draggable group so death zones can identify it
	add_to_group("draggable")
	
	print("Draggable object ready: ", name)

func _process(delta):
	if is_dragging:
		# Follow the mouse cursor every frame
		var mouse_pos = get_global_mouse_position()
		global_position = mouse_pos + drag_offset

func _on_input_event(viewport, event, shape_idx):
	# Start dragging when clicked
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Calculate offset so object doesn't jump to cursor
			drag_offset = global_position - get_global_mouse_position()
			is_dragging = true
			print("Started dragging: ", name)
	elif event is InputEventScreenTouch:
		if event.pressed:
			# Same for mobile touch
			drag_offset = global_position - event.position
			is_dragging = true
			print("Started touch dragging: ", name)

func _input(event):
	if not is_dragging:
		return
	
	# Stop dragging when mouse/touch is released
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
			print("Stopped dragging: ", name)
	elif event is InputEventScreenTouch:
		if not event.pressed:
			is_dragging = false
			print("Stopped touch dragging: ", name)
