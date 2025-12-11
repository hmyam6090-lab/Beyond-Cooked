extends CharacterBody3D
class_name Enemy

signal reached_player

@export var max_spotting_distance := 50.0
@export var attack_range := 2.0 
@export var attack_damage := 10
@export var attack_cooldown := 4.0 

var _current_speed := 0.0
var _can_attack := true
var _is_attacking := false


@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var movement_anim: AnimationPlayer = $Movement
@onready var _eye: Node3D = $Eye
@onready var _eye_ray_cast: RayCast3D = $Eye/RayCast3D

@onready var sfx_attack = $SFX/Attack
@onready var sfx_run = $SFX/Run

@export var player: Player

func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if navigation_agent.is_navigation_finished() and not _is_attacking:
		movement_anim.play("Idle_B", 0.2)
		return
	
	if not _is_attacking:
		var next_path_position := navigation_agent.get_next_path_position()
		
		var where_to_look := next_path_position
		where_to_look.y = global_position.y
		if not where_to_look.is_equal_approx(global_position):
			look_at(where_to_look)
		
		var direction := next_path_position - global_position
		direction.y = 0.0
		direction = direction.normalized()
		velocity = direction * _current_speed
		move_and_slide()
		
	else:
		move_and_slide()


func travel_to_position(wanted_position: Vector3, speed: float, play_run_anim := false) -> void:
	navigation_agent.target_position = wanted_position
	_current_speed = speed
	
	if play_run_anim:
		sfx_attack.stop()
		sfx_run.play()
		movement_anim.play("Running_B", 0.2)
	else:
		movement_anim.play("Walking_C", 0.2)


func is_player_in_view() -> bool:
	var vec_to_player := (player.global_position - global_position)
	
	if vec_to_player.length() > max_spotting_distance:
		return false
	
	var in_fov := -_eye.global_basis.z.normalized().dot(vec_to_player.normalized()) > 0.3
	
	if in_fov:
		return not is_line_of_sight_broken()
	
	return false


func is_line_of_sight_broken() -> bool:
	_eye_ray_cast.target_position = _eye_ray_cast.to_local(player.global_position)
	_eye_ray_cast.force_raycast_update()
	return _eye_ray_cast.is_colliding()


func _attack_player() -> void:
	_can_attack = false
	sfx_run.stop()
	sfx_attack.play()
	movement_anim.play("Rig_Medium_General/Throw")
	
	player.take_damage(attack_damage)
	
	emit_signal("reached_player")
	
	await get_tree().create_timer(attack_cooldown).timeout
	
	_can_attack = true
