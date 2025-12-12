extends Node3D
class_name PotUI

@export var icon_container: GridContainer
@export var cook_bar: ProgressBar 

func update_ingredients(icons: Array):
	for c in icon_container.get_children():
		c.queue_free()

	for icon_tex in icons:
		var icon_rect := TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_container.add_child(icon_rect)

	if icons.is_empty() and cook_bar:
		cook_bar.visible = false


func begin_cooking(recipe: RecipeData, cook_time: float):
	print("UI: begin cooking ", recipe.recipe_name)

	if not cook_bar:
		return

	cook_bar.visible = true
	cook_bar.min_value = 0
	cook_bar.max_value = 1
	cook_bar.value = 0


func update_cook_progress(time_left: float, total_time: float):
	if not cook_bar or total_time <= 0:
		return

	var progress := 1.0 - (time_left / total_time)
	cook_bar.value = clamp(progress, 0, 1)


func finish_cooking(recipe: RecipeData):
	print("UI: finished cooking ", recipe.recipe_name)

	if not cook_bar:
		return

	cook_bar.value = 1.0

	await get_tree().create_timer(0.25).timeout
	cook_bar.visible = false
