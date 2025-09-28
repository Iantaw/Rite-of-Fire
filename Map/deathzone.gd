extends Area2D

signal draggable_deleted

func _ready():
	body_entered.connect(_on_body_entered)
	print("Death Zone ready.")

func _on_body_entered(body):
	if body.is_in_group("draggable"):
		print("Draggable object entered death zone: ", body.name)
		draggable_deleted.emit()
		# Delete the draggable object
		body.queue_free()
		print("Draggable object deleted.")
