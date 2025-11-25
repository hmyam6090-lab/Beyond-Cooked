extends CharacterBody3D

@export_group("Movement")
@export var walkSpeed := 3.0
@export var sprintSpeed := 6.0
@export var jumpForce := 4.8
@export var gravity := 9.8
@export var acceleration_ground := 10.0
@export var acceleration_air := 4.0

var speed := 0.0
var inputDir := Vector2.ZERO

#Headbob
const BOB_FREQ := 1
const BOB_AMP := 0.08
var t_bob := 0.0

#Camera FOV
const BASE_FOV := 75.0
var FOV_CHANGE := 1.5

#STAMINA SYSTEM
@export_group("Stamina")
@export var maxStamina := 100.0
@export var staminaDrainRate := 40.0     
@export var staminaRegenRate := 15.0      
@export var regenDelay := 0.8             
@export var exhaustionSlowdown := true    

@onready var staminaBar = $CanvasLayer/UI/StaminaBar

var stamina := 100.0
var canRegen := true
var regenTimer := 0.0

#HEALTH SYSTEM
@export_group("Health")
@export var maxHealth := 100.0
var health := 100.0

@onready var healthBar = $CanvasLayer/UI/HealthBar

@export_group("Camera")
@export var mouseSens = Vector2(0.2, 0.2)
@onready var head = $Head
@onready var camera = $Head/Camera3D


@export_group("Holding Objects")
@export var throwForce = 0.75
@export var followSpeed = 5.0
@export var followDistance = 1.5
@export var maxDistanceFromCamera = 4
@export var dropBelowPlayer = false
@export var groundRay : RayCast3D

@onready var interactRay = $Head/Camera3D/InteractRay
var heldObject: RigidBody3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSens.x * 0.01)
		camera.rotate_x(-event.relative.y * mouseSens.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	handle_holding_objects()

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpForce

	# Sprint
	var wantsToSprint = Input.is_action_pressed("sprint") and inputDir.length() > 0.1
	staminaBar.set_stamina(stamina, maxStamina)
	healthBar.set_health(health, maxHealth)

	if wantsToSprint and stamina > 1:
		FOV_CHANGE = 2.5
		speed = sprintSpeed
		
		stamina -= staminaDrainRate * delta
		stamina = max(stamina, 0)

		canRegen = false
		regenTimer = 0.0
	else:
		FOV_CHANGE = 1.5
		speed = walkSpeed
		if not canRegen:
			regenTimer += delta
			if regenTimer >= regenDelay:
				canRegen = true


		if canRegen:
			stamina += staminaRegenRate * delta
			stamina = min(stamina, maxStamina)
	if stamina <= 0 and exhaustionSlowdown:
		FOV_CHANGE = 0.25
		speed = walkSpeed * 0.5

	# Movement input
	inputDir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()

	# Dynamic movement feel
	var accel = acceleration_ground if is_on_floor() else acceleration_air
	velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
	velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV Boost
	var vel_clamped = clamp(velocity.length(), 1.0, sprintSpeed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * vel_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ * 0.5) * BOB_AMP
	return pos

#Physical Interaction System (Should really organize this into a different file)		
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
			print(interactRay.get_collider())
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

func get_stamina_percent() -> float:
	return stamina / maxStamina
	
func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func die():
	print("Player has died!")
	# TODO: Add respawn, reload level, animation, etc
	
func get_health_percent() -> float:
	return health / maxHealth
