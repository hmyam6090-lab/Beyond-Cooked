extends InteractableItem
class_name Knife

@export var damage_per_hit: float = 1.0
@export var hit_cooldown := 1
@export var mob_damage_per_hit := 5

@onready var sfx_chop = $SFX/Chop
@onready var sfx_cut = $SFX/Cut

var hit_timer := 0.0

func _physics_process(delta: float) -> void:
	if hit_timer > 0:
		hit_timer -= delta

func _ready():
	super()  

	if has_node("Area3D"):
		$Area3D.body_entered.connect(_on_body_entered)
	else:
		push_error("Knife node requires an Area3D child for cutting!")
	

func _on_body_entered(body: Node):
	if body is InteractableItem and body.Data.IsChoppable:
		_chop(body)
	if body is LettuceFairy:
		if hit_timer <= 0.0:
			body.take_damage(mob_damage_per_hit)
			hit_timer = hit_cooldown


func _chop(item: InteractableItem):
	sfx_cut.play()
	if item.current_health <= 0:
		item.current_health = item.Data.MaxHealth

	item.current_health -= damage_per_hit
	
	item.show_health_bar()

	print("Chopping:", item.Data.ItemName, "remaining health:", item.current_health)

	if item.current_health <= 0:
		_finish_chopping(item)


func _finish_chopping(item: InteractableItem):
	sfx_chop.play()
	var chopped_data = item.Data.ChoppedItem

	if chopped_data == null:
		print(item.Data.ItemName, "has no ChoppedItem assigned!")
		item.queue_free()
		return

	if chopped_data.ModelScene == null:
		push_error("Chopped item has no ModelScene assigned!")
		item.queue_free()
		return

	var chopped_scene = chopped_data.ModelScene.instantiate()

	if chopped_scene is InteractableItem:
		chopped_scene.Data = chopped_data

	chopped_scene.global_transform = item.global_transform
	get_tree().current_scene.add_child(chopped_scene)

	item.queue_free()
	print(item.Data.ItemName, "chopped into", chopped_data.ItemName)
