extends Node3D
class_name SpawnerCrate

@export var item_scene: PackedScene      
@export var item_icon: Texture2D
@export var spawn_height: float = 1.5       
@export var float_speed: float = 1.0        
@export var float_amplitude: float = 0.25  
@export var rotation_speed: float = 60.0    
@export var respawn_time: float = 5.0     

@onready var spawn_point: Node3D = $SpawnPoint
@onready var crate_item: Sprite3D = $CrateLid/Sprite3D

var spawned_item: Node3D = null
var float_timer := 0.0
var respawn_timer := 0.0
var is_on_cooldown := false

func _ready():
	crate_item.texture = item_icon
	_spawn_item()


func _process(delta):
	if spawned_item:
		float_timer += delta * float_speed
		var float_offset = sin(float_timer) * float_amplitude
		var pos = spawn_point.global_transform.origin
		pos.y += float_offset
		spawned_item.global_position = pos
		spawned_item.rotation_degrees.y += rotation_speed * delta

		spawned_item.set_meta("spawner_crate", self)
	
	
	if is_on_cooldown:
		respawn_timer -= delta
		if respawn_timer <= 0:
			is_on_cooldown = false
			_spawn_item()


func _spawn_item():
	if not item_scene:
		push_error("SpawnerCrate has no item_scene assigned!")
		return

	spawned_item = item_scene.instantiate()
	add_child(spawned_item)
	spawned_item.global_transform.origin = spawn_point.global_transform.origin + Vector3(0, spawn_height, 0)

	if spawned_item.has_method("connect"):

		spawned_item.connect("tree_exited", Callable(self, "_on_item_taken"))


func _on_item_taken():
	spawned_item = null
	is_on_cooldown = true
	respawn_timer = respawn_time
