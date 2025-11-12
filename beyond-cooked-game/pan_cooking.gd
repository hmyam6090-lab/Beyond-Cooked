extends Area3D

var isRed : bool
var isYellow : bool

@export var ItemTypes : Array[ItemData] = []

var burger_scene = preload("res://burger.tscn")

func _on_body_entered(body: InteractableItem) -> void:
	if (body is InteractableItem):
		if (body.isIngredient):
			print("Cooked")
			var burger = burger_scene.instantiate()
			burger.global_position = body.global_position
			body.get_parent().add_child(burger)
			body.queue_free()
