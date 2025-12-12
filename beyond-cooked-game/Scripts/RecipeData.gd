extends Resource
class_name RecipeData

@export var recipe_name: String
@export var cook_time: float = 0.0
@export var required_ingredients: Array[ItemData] = []
@export var result_scene: PackedScene
@export var dish_icon: Texture2D
@export var reward : int = 20
@export var time_limit: float = 60
