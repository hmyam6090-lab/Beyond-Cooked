extends Node
class_name InteractableItem

@export var ItemHighlightMesh : MeshInstance3D
@export var isChoppable : bool
@export var isIngredient : bool

@export var Data : ItemData

func GainFocus():
	ItemHighlightMesh.visible = true
	
func LoseFocus():
	ItemHighlightMesh.visible = false
