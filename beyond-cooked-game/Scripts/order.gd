extends Node
class_name Order

signal order_failed(order)
signal order_completed(order)

var recipe: RecipeData
var recipe_icon: Texture2D
var time_left: float
var is_done := false
var time_for_order

func setup(_recipe: RecipeData):
	recipe = _recipe
	time_left = recipe.time_limit
	recipe_icon = recipe.dish_icon

func _process(delta):
	if is_done:
		return

	time_left -= delta

	if time_left <= 0:
		is_done = true
		emit_signal("order_failed", self)
