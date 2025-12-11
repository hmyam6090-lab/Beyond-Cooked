extends Node3D
class_name InteractableItem

@export var ItemHighlightMesh: MeshInstance3D
@export var isIngredient: bool
@export var isCookable: bool
@export var Data: ItemData

var current_health: float = 0.0
var health_bar: ChopHealthBar3D
var health_bar_timer := 0.0 
const HEALTHBAR_VISIBLE_TIME := 1.5

func _ready():
	if Data != null and Data.IsChoppable:
		current_health = Data.MaxHealth


func _process(delta):
	if health_bar:
		if health_bar_timer > 0:
			health_bar_timer -= delta
			if health_bar_timer <= 0:
				print("Hiding HP bar")
				health_bar.queue_free()
				health_bar = null
	
	if health_bar and health_bar.get_parent():
		var pivot = health_bar.get_parent()
		pivot.global_position = global_position + Vector3(0, 0.8, 0)
				
func show_health_bar():
	if health_bar == null:
		var bar_scene = preload("res://scene_objects/InteractableItems/ChopHealthBar.tscn")
		health_bar = bar_scene.instantiate()

		var pivot := Node3D.new()
		add_child(pivot)
		pivot.top_level = true 
		pivot.global_position = global_position + Vector3(0, 0.8, 0)

		pivot.add_child(health_bar)
		health_bar.position = Vector3.ZERO

	health_bar_timer = HEALTHBAR_VISIBLE_TIME

	if health_bar:
		health_bar.set_health(current_health, Data.MaxHealth)

func GainFocus():
	if ItemHighlightMesh:
		ItemHighlightMesh.visible = true


func LoseFocus():
	if ItemHighlightMesh:
		ItemHighlightMesh.visible = false
