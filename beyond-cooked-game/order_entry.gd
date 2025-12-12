extends Control

@onready var timer = $TimerBar
@onready var recipe_icon = $Control/Panel/TextureRect
@onready var ingredient_panels = $HBoxContainer

@export var ingredient_panel : PackedScene

var order: Order

func set_order(o: Order):
	order = o

func _ready() -> void:
	recipe_icon.texture = order.recipe_icon
	for ingredient in order.recipe.required_ingredients:
		var i = ingredient_panel.instantiate()
		i.set_ingredient(ingredient.Icon)
		ingredient_panels.add_child(i)
		

func _process(delta):
	if not order:
		return
	
	timer.set_time(order.time_left, order.recipe.time_limit)
	
	
