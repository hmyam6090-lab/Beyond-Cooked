extends Area3D

func _on_body_shape_entered(body_rid: RID, body: InteractableItem, body_shape_index: int, local_shape_index: int) -> void:
	if (body is InteractableItem):
		print("touched sth")
		if (body.isChoppable):
			print("Touched an choppable")
			body.queue_free()
