extends Area2D

signal draggable_deleted

func _ready():
	# Connect the body_entered signal to a function
	body_entered.connect(_on_body_entered)
	print("Death Zone ready.")

func _on_body_entered(body):
	# Check if the colliding body is a draggable object
	if body.is_in_group("draggable"):
		print("Draggable object entered death zone: ", body.name)
		# Emit a signal before deleting the object
		draggable_deleted.emit()
		# Delete the draggable object
		body.queue_free()
		print("Draggable object deleted.")
