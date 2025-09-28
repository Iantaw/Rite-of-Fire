extends Node

var score = 0
<<<<<<< Updated upstream
@onready var score_label = $"CanvasGroup/ScoreLabel" # Corrected path based on your scene tree
=======
@onready var score_label = $"CanvasGroup/ScoreLabel"
@onready var time_label = $"CanvasGroup/TimeLabel"

var elapsed_time = 0.0

var spawn_points = [] # Array to hold possible spawn positions
var initial_spawn_interval = 3.0 # Seconds
var min_spawn_interval = 0.5 # Minimum spawn interval
var spawn_interval_decrease_rate = 0.1 # How much the interval decreases each time
var current_spawn_interval = initial_spawn_interval

@onready var spawn_timer = Timer.new()

# Preload your NPC scene here
# IMPORTANT: You MUST create an NPC scene (e.g., npc.tscn) and set its path here.
# This scene should be a CharacterBody2D with an AnimatedSprite2D and CollisionShape2D child.
var npc_scene = preload("res://npc.tscn") # <--- REPLACE WITH YOUR ACTUAL NPC SCENE PATH
>>>>>>> Stashed changes

func _ready():
	var death_zone = get_node_or_null("DeathZone") # DeathZone is a direct child of the root node
	if death_zone:
		death_zone.draggable_deleted.connect(_on_draggable_deleted)
		print("Connected to DeathZone signal.")
	else:
		printerr("DeathZone node not found! Make sure it's in the scene and the path is correct.")

	if score_label:
		update_score_display()
	else:
		printerr("ScoreLabel node not found at path 'CanvasGroup/ScoreLabel'. Please check the scene tree.")


<<<<<<< Updated upstream
func _on_draggable_deleted():
	score += 1
	update_score_display()
	print("Score incremented: ", score)
=======
	if spawn_points.is_empty():
		printerr("No spawn points found! Add Marker2D nodes to the 'spawn_points' group in the editor.")

	# Setup spawn timer
	add_child(spawn_timer)
	spawn_timer.wait_time = current_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

	# Set initial score text
	update_score_display()

func _on_npc_scored():
	score += 1
	update_score_display()
	print("Score incremented (Volcano): ", score)

func _on_npc_reached_sea():
	score -= 1
	update_score_display()
	print("Score decremented (Sea): ", score)
	if score < 0:
		game_over()
>>>>>>> Stashed changes

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)
	else:
		printerr("ScoreLabel node not found! This should not happen if _ready() check passed.")
<<<<<<< Updated upstream
=======

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

	# Instantiate the preloaded NPC scene
	var npc_character = npc_scene.instantiate() as CharacterBody2D
	if not npc_character:
		printerr("Failed to instantiate NPC scene. Check if npc.tscn is a valid CharacterBody2D scene.")
		return

	npc_character.name = "NPC_" + str(get_tree().get_nodes_in_group("draggable").size() + 1)
	add_child(npc_character)

	# Choose a random spawn point
	var random_spawn_point = spawn_points[randi() % spawn_points.size()]
	npc_character.global_position = random_spawn_point

	# Ensure the newly created NPC processes input (script on NPC scene should handle this, but good to double check)
	npc_character.set_process_input(true)
	npc_character.set_process_unhandled_input(true)

	# Determine a target sea position for the NPC to move towards
	var target_sea_pos = Vector2.ZERO
	var viewport_rect = get_viewport().get_visible_rect()

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

	# Call the set_target_sea_position function on the instantiated NPC
	if npc_character.has_method("set_target_sea_position"):
		npc_character.set_target_sea_position(target_sea_pos)
	else:
		printerr("Error: \"set_target_sea_position\" method not found on instantiated NPC. Ensure drag-and-drop.gd is attached to your npc.tscn and contains this function.")
	print("NPC spawned at ", random_spawn_point, " and moving towards ", target_sea_pos)


func _process(delta):
	# Don't update the timer if the game is paused (game over)
	if get_tree().paused:
		return

	# Update and display the survival timer
	elapsed_time += delta
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	if time_label:
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]


func game_over():
	# Switch to the user's winning scene when you lose
	# Ensure the path exists: res://winning.tscn
	get_tree().change_scene_to_file("res://winning.tscn")
	print("Game Over! Switching to winning.tscn.")
>>>>>>> Stashed changes
