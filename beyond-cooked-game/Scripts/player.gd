extends CharacterBody3D

@export_group("Movement")
@export var moveSpeed = 5.0
@export var acceleration = 7.5
var moveDir: Vector3

@export var jumpForce = 4.5
@export var gravity = 9.8

@export_group("Camera")
@export var mouseSens = Vector2(0.2, 0.2)
@onready var camera = $Camera3D

@export_group("Holding Objects")
@export var throwForce = 7.5
@export var followSpeed = 5.0
@export var followDistance = 2.5
@export var maxDistanceFromCamera = 5.0
@export var dropBelowPlayer = false
@export var groundRay : RayCast3D

@onready var interactRay = $Camera3D/InteractRay
var heldObject: RigidBody3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta):
	# Move Input
	var inputDir = Input.get_vector("left", "right", "forward", "backward")
	moveDir = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	
	# Jumping
	if Input.is_action_just_pressed("jump") && is_on_floor(): velocity.y = jumpForce
	
func _physics_process(delta):
	handle_holding_objects()
	
	# Gravity
	if !is_on_floor(): velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") && is_on_floor(): velocity.y = jumpForce
	
	# Movement
	velocity.x = lerp(velocity.x, moveDir.x * moveSpeed, acceleration * delta)
	velocity.z = lerp(velocity.z, moveDir.z * moveSpeed, acceleration * delta)
	
	move_and_slide()
	
func _unhandled_input(event):
	# Camera Rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSens.x * 0.01)
		camera.rotate_x(-event.relative.y * mouseSens.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(45))
		
func set_held_object(body: Node3D):
	heldObject = body

func drop_held_object():
	heldObject = null

func throw_held_object():
	var obj = heldObject
	drop_held_object()
	obj.apply_central_impulse(-camera.global_transform.basis.z * throwForce * 10)
	
func handle_holding_objects():
	if Input.is_action_just_pressed("throw"):
		if heldObject != null: throw_held_object()
	
	if Input.is_action_just_pressed("interact_p"):
		if heldObject != null: drop_held_object()
		elif interactRay.is_colliding(): 
			var target = interactRay.get_collider()
			if target is RigidBody3D: set_held_object(target)
	
	if heldObject != null:
		var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -followDistance))
		var objectPos = heldObject.global_transform.origin
		heldObject.linear_velocity = (targetPos - objectPos) * followSpeed
		
		if heldObject.global_position.distance_to(camera.global_position) > maxDistanceFromCamera:
			drop_held_object()
		if dropBelowPlayer && groundRay.isColliding():
			if groundRay.get_collider() == heldObject: drop_held_object()
