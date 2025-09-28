extends Control

@onready var time_label = %TimeLabel
@onready var try_again_button = %TryAgainButton

func _ready():
	# Make sure the button is connected
	try_again_button.pressed.connect(_on_try_again_pressed)

	# Get the final time from the global GameManager
	var final_time = GameManager.final_survival_time

	# Format the time into MM:SS
	var minutes = int(final_time / 60)
	var seconds = int(final_time) % 60

	# Display the final time
	time_label.text = "Time Survived: %02d:%02d" % [minutes, seconds]

func _on_try_again_pressed():
	# Reload the main game scene. 
	# IMPORTANT: Make sure this path points to your main game scene file.
	get_tree().change_scene_to_file("res://Map/main_scene.tscn")
