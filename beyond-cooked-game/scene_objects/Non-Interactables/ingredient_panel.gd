extends Control

@export var ingredient_icon: TextureRect

func set_ingredient(icon: Texture2D):
	ingredient_icon.texture = icon
