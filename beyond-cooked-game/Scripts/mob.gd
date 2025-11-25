extends CharacterBody3D

enum {
	IDLE,
	ROAM,
	CHASE
}

@export var roam_speed: float = 2.0
@export var chase_speed: float = 5.0
@export var roam_radius: float = 6.0
@export var vision_range: float = 12.0
@export var vision_angle_deg: float = 45.0
@export var player: Node3D

var state = IDLE
var roam_target: Vector3
var idle_timer := 0.0

func _ready() -> void:
	_set_new_roam_target()

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_process_idle(delta)
		ROAM:
			_process_roam(delta)
		CHASE:
			_process_chase(delta)

	if state != CHASE and _can_see_player():
		state = CHASE

	move_and_slide()

func _process_idle(delta: float):
	idle_timer -= delta
	if idle_timer <= 0:
		state = ROAM

func _process_roam(delta: float):
	var direction = (roam_target - global_position)
	if direction.length() < 0.5:
		state = IDLE
		idle_timer = randf_range(1.0, 2.5)
		_set_new_roam_target()
	else:
		velocity = direction.normalized() * roam_speed
		look_at(roam_target, Vector3.UP)

func _process_chase(delta: float):
	if player == null:
		state = ROAM
		return

	if not _can_see_player():
		state = ROAM
		return

	var direction = (player.global_position - global_position)
	velocity = direction.normalized() * chase_speed
	look_at(player.global_position, Vector3.UP)

func _can_see_player() -> bool:
	if player == null:
		return false

	var to_player = player.global_position - global_position
	if to_player.length() > vision_range:
		return false

	var forward = -transform.basis.z
	var angle = rad_to_deg(acos(forward.dot(to_player.normalized())))
	if angle > vision_angle_deg:
		return false

	var ray: RayCast3D = $VisionRay
	ray.target_position = to_player
	ray.force_raycast_update()

	if ray.is_colliding():
		return ray.get_collider() == player

	return false


func _set_new_roam_target():
	var random_offset = Vector3(
		randf_range(-roam_radius, roam_radius),
		0,
		randf_range(-roam_radius, roam_radius)
	)
	roam_target = global_position + random_offset
