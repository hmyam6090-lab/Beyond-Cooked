extends CharacterBody3D
class_name LettuceFairy

@export_group("Animations")
@export var anim : AnimationPlayer
@export var roam_eyes : Node3D
@export var flee_eyes: Node3D

@export_group("Stats")
@export var max_health := 10
var health := 10

@export var roam_speed := 2.0
@export var flee_speed := 6.0
@export var detection_radius := 8.0
@export var drop_scene: PackedScene

@export_group("AI")
@export var turn_speed := 6.0     
@export var roam_point_radius := 5.0
@export var flee_distance := 10.0

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@export var fairy_model: Node3D
@export var player: CharacterBody3D

@export_group("UI")
@export var healthbar: ChopHealthBar3D
@export var healthbar_pivot: Node3D

@export_group("Spawn Behavior")
@export var respawnOn = false
@export var respawnTime = 20.0
@export var spawnPoint : Marker3D
@export var heaven : Marker3D

@onready var hurt = $SFX/Chopped
@onready var dies = $SFX/Die

var state := "ROAM"
var roam_target := Vector3.ZERO
var EPS := 0.0001

func _ready():
	health = max_health
	_pick_new_roam_point()

func _physics_process(delta: float):
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < detection_radius:
			state = "FLEE"
		else:
			state = "ROAM"

	match state:
		"ROAM":
			_update_roam(delta)
		"FLEE":
			_update_flee(delta)

	_update_facing(delta)
	
	var coll_info = move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			if state == "ROAM":
				_pick_new_roam_point()
			elif state == "FLEE":
				_update_flee_target_after_collision()
	
	_update_healthbar()

func _update_healthbar():
	if not healthbar:
		return

	healthbar.set_health(health,max_health)

	var pivot_transform = healthbar_pivot.global_transform
	pivot_transform.basis = Basis() 
	healthbar_pivot.global_transform = pivot_transform

func _update_roam(delta: float):
	anim.play("roam")
	flee_eyes.visible = false
	roam_eyes.visible = true

	if nav.is_navigation_finished():
		_pick_new_roam_point()
	
	var next = nav.get_next_path_position()
	var dir = (next - global_position).normalized()
	velocity = dir * roam_speed
	nav.max_speed = roam_speed

func _pick_new_roam_point():
	var rand_offset = Vector3(
		randf_range(-roam_point_radius, roam_point_radius),
		0,
		randf_range(-roam_point_radius, roam_point_radius)
	)
	roam_target = global_position + rand_offset
	nav.target_position = _get_safe_nav_point(roam_target)

func _update_flee(delta: float):
	anim.play("run")
	flee_eyes.visible = true
	roam_eyes.visible = false
	if not player:
		state = "ROAM"
		return

	var away_dir = (global_position - player.global_position).normalized()
	var rand_offset = Vector3(
		randf_range(-2, 2),
		0,
		randf_range(-2, 2)
	)
	var flee_target = global_position + away_dir * flee_distance + rand_offset
	nav.target_position = _get_safe_nav_point(flee_target)

	var next = nav.get_next_path_position()
	var dir = (next - global_position).normalized()
	velocity = dir * flee_speed
	nav.max_speed = flee_speed

func _update_flee_target_after_collision():
	if not player:
		return
	var away_dir = (global_position - player.global_position).normalized()
	var rand_offset = Vector3(
		randf_range(-2, 2),
		0,
		randf_range(-2, 2)
	)
	var flee_target = global_position + away_dir * flee_distance + rand_offset
	nav.target_position = _get_safe_nav_point(flee_target)

func _update_facing(delta: float):
	var dir = Vector3(velocity.x, 0, velocity.z)
	if dir.length_squared() < EPS:
		return
	dir = dir.normalized()
	var target_basis := Basis().looking_at(dir, Vector3.UP)
	var q_current := Quaternion(fairy_model.global_transform.basis)
	var q_target := Quaternion(target_basis)
	var q_interp := q_current.slerp(q_target, clamp(turn_speed * delta, 0.0, 1.0))
	fairy_model.global_transform.basis = Basis(q_interp)

func _get_safe_nav_point(point: Vector3) -> Vector3:
	var map_rid: RID = get_world_3d().get_navigation_map()
	if map_rid == RID():
		return point
	var closest: Vector3 = NavigationServer3D.map_get_closest_point(map_rid, point)
	if closest.is_zero_approx():
		return point
	return closest

func take_damage(amount: float):
	hurt.play()
	health -= amount
	if healthbar:
		healthbar.set_health(health, max_health)
	if health <= 0:
		die()

func die():
	dies.play()
	state = "DEAD"
	velocity = Vector3.ZERO
	health = 0

	if drop_scene:
		var drop = drop_scene.instantiate()
		drop.global_position = global_position
		get_parent().add_child(drop)

	set_physics_process(false)

	if heaven:
		fairy_model.visible = false
		global_position = heaven.global_position
	else:
		queue_free()
		return

	if respawnOn:
		await get_tree().create_timer(respawnTime).timeout
		_respawn()

func _respawn():
	health = max_health
	state = "ROAM"

	if spawnPoint:
		global_position = spawnPoint.global_position

	fairy_model.visible = true
	anim.play("roam")
	velocity = Vector3.ZERO
	_pick_new_roam_point()

	if healthbar:
		healthbar.set_health(max_health, max_health)

	set_physics_process(true)
