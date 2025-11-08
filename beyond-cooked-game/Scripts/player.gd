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


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta):
	# Move Input
	var inputDir = Input.get_vector("left", "right", "forward", "backward")
	moveDir = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	
	# Jumping
	if Input.is_action_just_pressed("jump") && is_on_floor(): velocity.y = jumpForce
	
func _physics_process(delta):
	
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
		
