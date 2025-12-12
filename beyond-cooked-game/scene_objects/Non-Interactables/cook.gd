extends Node3D
class_name Pot

@export var detection_area: Area3D
@export var pot_ui : PotUI
@export var recipes: Array[RecipeData] = []
@export var default_cook_time := 3.0

@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var sizzle = $SFX/Sizzle
@onready var finish = $SFX/Finish

var ingredients_in_pot: Array[InteractableItem] = []
var is_cooking := false
var current_timer := 0.0
var target_recipe: RecipeData = null

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _process(delta: float):
	if is_cooking:
		current_timer -= delta
		pot_ui.update_cook_progress(current_timer, target_recipe.cook_time if target_recipe and target_recipe.cook_time > 0 else default_cook_time)
		
		if current_timer <= 0:
			_finish_cooking()

func _on_body_entered(body: Node):
	if is_cooking:
		return 
	
	if body is InteractableItem and body.isIngredient:
		if body not in ingredients_in_pot:
			ingredients_in_pot.append(body)
			_update_ui()
			_check_recipes()

func _on_body_exited(body: Node):
	if body in ingredients_in_pot:
		ingredients_in_pot.erase(body)
		_update_ui()

		if is_cooking:
			_cancel_cooking()

func _cancel_cooking():
	sizzle.stop()
	is_cooking = false
	current_timer = 0

	if anim.has_animation("cook_shake"):
		anim.stop()

	target_recipe = null
	print("Cooking canceled.")

func _check_recipes():
	var current_data = ingredients_in_pot.map(func(i): return i.Data)

	for recipe in recipes:
		if _matches_recipe(current_data, recipe.required_ingredients):
			_start_cooking(recipe)
			return

func _matches_recipe(current: Array, required: Array) -> bool:
	if current.size() != required.size():
		return false

	var c_names = current.map(func(d): return d.ItemName).duplicate()
	var r_names = required.map(func(d): return d.ItemName).duplicate()

	c_names.sort()
	r_names.sort()

	return c_names == r_names

func _start_cooking(recipe: RecipeData):
	sizzle.play()
	is_cooking = true
	target_recipe = recipe
	
	if anim.has_animation("cook_shake"):
		anim.play("cook_shake")

	var cook_time = recipe.cook_time if recipe.cook_time > 0 else default_cook_time
	current_timer = cook_time

	if pot_ui:
		pot_ui.begin_cooking(recipe, cook_time)

	print("Cooking started:", recipe.recipe_name)

func _finish_cooking():
	finish.play()
	sizzle.stop()
	is_cooking = false

	if anim.has_animation("cook_shake"):
		anim.stop()
		
	if anim.has_animation("finish_puff"):
		anim.play("finish_puff")
	
	for ing in ingredients_in_pot:
		ing.queue_free()
	ingredients_in_pot.clear()

	var result = target_recipe.result_scene.instantiate()
	var spawn_offset := Vector3(0, 3, 0)
	result.global_transform.origin = global_transform.origin + spawn_offset
	
	add_child(result)
	result.global_transform = global_transform

	result.apply_impulse(Vector3(0, 5, 0)) 
	result.apply_torque_impulse(Vector3(randf()*1.5, randf()*1.5, randf()*1.5))

	if pot_ui:
		pot_ui.finish_cooking(target_recipe)

	print("Cooked:", target_recipe.recipe_name)

	target_recipe = null
	_update_ui()

func _update_ui():
	if not pot_ui:
		return

	var icons = ingredients_in_pot.map(func(i): return i.Data.Icon)
	pot_ui.update_ingredients(icons)
