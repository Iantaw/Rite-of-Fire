extends Node

var score = 0
@onready var score_label = $"CanvasGroup/ScoreLabel" # Corrected path based on your scene tree

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


func _on_draggable_deleted():
	score += 1
	update_score_display()
	print("Score incremented: ", score)

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)
	else:
		printerr("ScoreLabel node not found! This should not happen if _ready() check passed.")
