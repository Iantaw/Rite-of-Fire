extends Node

var score = 0
@onready var score_label = $"CanvasGroup/ScoreLabel"

var npc_scene = preload("res://npc.tscn") # Assuming your NPC scene is named npc.tscn
var spawn_points = [] # Array to hold possible spawn positions
var initial_spawn_interval = 3.0 # Seconds
var min_spawn_interval = 0.5 # Minimum spawn interval
var spawn_interval_decrease_rate = 0.1 # How much the interval decreases each time
var current_spawn_interval = initial_spawn_interval

@onready var spawn_timer = Timer.new()

func _ready():
	# Connect signals for Volcano Zone (formerly DeathZone) and Sea Zone
	var volcano_zone = get_node_or_null("VolcanoZone") # Adjust path if your VolcanoZone is elsewhere
	if volcano_zone:
		volcano_zone.npc_scored.connect(_on_npc_scored)
		print("Connected to Volcano Zone signal.")
	else:
		printerr("VolcanoZone node not found! Make sure it's in the scene and the path is correct.")

	var sea_zone = get_node_or_null("SeaZone") # Adjust path if your SeaZone is elsewhere
	if sea_zone:
		sea_zone.npc_reached_sea.connect(_on_npc_reached_sea)
		print("Connected to Sea Zone signal.")
	else:
		printerr("SeaZone node not found! Make sure it's in the scene and the path is correct.")

	# Initialize score display
	if score_label:
		update_score_display()
	else:
		printerr("ScoreLabel node not found at path 'CanvasGroup/ScoreLabel'. Please check the scene tree.")

	# Setup spawn points (example, you'll need to define these based on your map)
	# These are placeholder points. You should replace them with actual positions
	# around the island where NPCs can realistically spawn and move towards the sea.
	spawn_points.append(Vector2(100, 100)) # Top-left
	spawn_points.append(Vector2(900, 100)) # Top-right
	spawn_points.append(Vector2(100, 500)) # Bottom-left
	spawn_points.append(Vector2(900, 500)) # Bottom-right

	# Setup spawn timer
	add_child(spawn_timer)
	spawn_timer.wait_time = current_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_npc_scored():
	score += 1
	update_score_display()
	print("Score incremented (Volcano): ", score)

func _on_npc_reached_sea():
	score -= 1
	update_score_display()
	print("Score decremented (Sea): ", score)

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)
	else:
		printerr("ScoreLabel node not found! This should not happen if _ready() check passed.")

func _on_spawn_timer_timeout():
	spawn_npc()
	# Decrease spawn interval over time, but not below min_spawn_interval
	current_spawn_interval = max(min_spawn_interval, current_spawn_interval - spawn_interval_decrease_rate)
	spawn_timer.wait_time = current_spawn_interval
	spawn_timer.start() # Restart timer with new interval

func spawn_npc():
	if spawn_points.is_empty():
		printerr("No spawn points defined!")
		return

	var npc_instance = npc_scene.instantiate()
	add_child(npc_instance)

	# Choose a random spawn point
	var random_spawn_point = spawn_points[randi() % spawn_points.size()]
	npc_instance.global_position = random_spawn_point

	# Determine a target sea position for the NPC to move towards
	# This is a placeholder. You'll need to define actual sea edge coordinates
	# based on your map's layout. For the example, we'll make them move towards
	# the closest edge of the viewport.
	var target_sea_pos = Vector2.ZERO
	var viewport_rect = get_viewport_rect()

	# Simple logic: if spawned on left half, move left; if on right, move right.
	# You might need more sophisticated logic based on your island shape.
	if random_spawn_point.x < viewport_rect.size.x / 2:
		# Move towards left edge of the screen
		target_sea_pos = Vector2(0, random_spawn_point.y)
	else:
		# Move towards right edge of the screen
		target_sea_pos = Vector2(viewport_rect.size.x, random_spawn_point.y)

	# If spawned near top, move towards top edge; if near bottom, move towards bottom.
	# This adds more varied movement directions.
	if random_spawn_point.y < viewport_rect.size.y / 2:
		# If closer to top, also consider moving towards top edge
		if abs(random_spawn_point.y - 0) < abs(random_spawn_point.x - target_sea_pos.x):
			target_sea_pos = Vector2(random_spawn_point.x, 0)
	else:
		# If closer to bottom, also consider moving towards bottom edge
		if abs(random_spawn_point.y - viewport_rect.size.y) < abs(random_spawn_point.x - target_sea_pos.x):
			target_sea_pos = Vector2(random_spawn_point.x, viewport_rect.size.y)

	npc_instance.set_target_sea_position(target_sea_pos)
	print("NPC spawned at ", random_spawn_point, " and moving towards ", target_sea_pos)

