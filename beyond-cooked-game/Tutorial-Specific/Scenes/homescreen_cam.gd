extends Camera3D

@export var rotation_amount := 5.0       
@export var position_shift := 0.2     
@export var smoothness := 10.0           

var target_rot := Vector3.ZERO
var target_pos := Vector3.ZERO
var starting_pos := Vector3.ZERO

var ui_max_distance := 50.0

func _ready():
	starting_pos = global_transform.origin

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_check_3d_ui_click()

func _check_3d_ui_click():
	var mouse = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse)
	var to = from + project_ray_normal(mouse) * ui_max_distance

	var hit = get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(from, to)
	)

	if hit:
		var collider = hit["collider"]

		if collider is Area3D and collider.owner is MenuButton3D:
			collider.owner.emit_signal("pressed")

func _process(delta):
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse = get_viewport().get_mouse_position()

	var x = (mouse.x / viewport_size.x - 0.5) * 2.0
	var y = (mouse.y / viewport_size.y - 0.5) * 2.0

	target_rot = Vector3(
		deg_to_rad(-y * rotation_amount),
		deg_to_rad(x * rotation_amount),
		0
	)

	target_pos = starting_pos + Vector3(
		x * position_shift,
		y * position_shift,
		0
	)

	rotation = rotation.lerp(target_rot, delta * smoothness)
	global_transform.origin = global_transform.origin.lerp(target_pos, delta * smoothness)
