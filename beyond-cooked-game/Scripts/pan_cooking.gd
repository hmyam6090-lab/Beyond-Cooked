extends Area3D

@export var Recipes : Array[RecipeData] = []    
var InPan : Array[String] = []                 

func _on_body_entered(body: InteractableItem) -> void:
	if not (body is InteractableItem):
		return
	if not body.isIngredient:
		return

	print("Ingredient in pan: ", body.Data.ItemName)

	InPan.append(body.Data.ItemName)

	body.queue_free()

	_check_recipes()


func _check_recipes():
	for recipe in Recipes:
		if _matches_recipe(recipe.RequiredItems, InPan):
			print("Recipe matched! Cooking...")
			_spawn_output(recipe.OutputScene)
			InPan.clear()
			return


func _matches_recipe(required: Array[String], inside: Array[String]) -> bool:
	for item in required:
		if not inside.has(item):
			return false

	return true


func _spawn_output(scene: PackedScene):
	var obj = scene.instantiate()
	get_parent().add_child(obj)
	obj.transform.origin = Vector3.ZERO
	obj.transform.origin = Vector3(0, 0.5, 0)

	print("Cooked: ", obj.name)
