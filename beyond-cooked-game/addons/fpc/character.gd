extends CharacterBody3D

class_name Player

@export var walkSpeed := 6.0
@export var sprintSpeed := 9.0
@export var jumpForce := 4.8
@export var gravity := 11
@export var mouseSens = Vector2(0.2, 0.2)
var acceleration_ground = 10
var acceleration_air = 12

@onready var head = $Head
@onready var camera = $Head/Camera

var speed := 0.0
var inputDir := Vector2.ZERO
var mouseInput : Vector2 = Vector2.ZERO

@onready var HEADBOB_ANIMATION : AnimationPlayer = $Head/HeadbobAnimation
@onready var JUMP_ANIMATION : AnimationPlayer = $Head/JumpAnimation
var was_on_floor : bool = true
var current_speed : float = 0.0

const BASE_FOV := 75.0
var FOV_CHANGE := 1.5

@export_file var default_reticle
var RETICLE : Control

@export var maxStamina := 100.0
@export var staminaDrainRate := 20.0
@export var staminaRegenRate := 15.0
@export var regenDelay := 0.8
@export var exhaustionSlowdown := true

@onready var staminaBar = $UserInterface/StaminaBar
var stamina := 100.0
var canRegen := true
var regenTimer := 0.0

@export var maxHealth := 100.0
var health := 100.0
@onready var healthBar = $UserInterface/HealthBar

@export var flashlight : SpotLight3D
@export var isOnFlashlight := false

@export var throwForce = 0.75
@export var followSpeed = 5.0
@export var followDistance = 1.5
@export var maxDistanceFromCamera = 4
@export var dropBelowPlayer = false
@export var groundRay : RayCast3D
@onready var interactRay = $Head/Camera/InteractRay
var heldObject: RigidBody3D
var interact_target: Node = null

var shake_duration := 0.2
var shake_timer := 0.0
var shake_intensity := 0.1
var original_camera_position := Vector3.ZERO
var is_shaking := false

@onready var hurt_overlay: ColorRect = $UserInterface/HurtOverlay

var overlay_timer := 0.0
var overlay_duration := 0.25

@onready var you_died_screen: Control = $UserInterface/YouDiedScreen
@export var spawn_point : Marker3D

#SFXS GALORE
@onready var sfx_walk = $SFX/Walk
@onready var sfx_sprint = $SFX/Sprint
@onready var sfx_jump = $SFX/Jump
@onready var sfx_land = $SFX/Land
@onready var sfx_hurt = $SFX/Hurt
@onready var sfx_death = $SFX/Death
@onready var sfx_plop = $SFX/Plop

var footstep_timer := 0.0
var footstep_interval_walk := 0.45
var footstep_interval_sprint := 0.28

func _ready():
	flashlight.visible = isOnFlashlight
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.set_meta("player", self)
	initialize_animations()
	
	if default_reticle != "":
		change_reticle(default_reticle)
	
	original_camera_position = camera.transform.origin

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseInput = event.relative

func _physics_process(delta):
	handle_holding_objects()

	if Input.is_action_just_pressed("drop_item"):
		flashlight.visible = !flashlight.visible

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		if sfx_jump:
			sfx_jump.play()
		velocity.y = jumpForce

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

	inputDir = Input.get_vector("left", "right", "forward", "backward")
	var cam_yaw = Basis(Vector3.UP, rotation.y)
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var accel = acceleration_ground if is_on_floor() else acceleration_air
	velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
	velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)

	handle_camera_rotation()

	play_headbob_animation(inputDir)

	play_jump_animation()

	var vel_clamped = clamp(velocity.length(), 1.0, sprintSpeed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * vel_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	if is_on_floor() and inputDir.length() > 0.1:
		var is_sprinting = speed == sprintSpeed

		footstep_timer -= delta
		if footstep_timer <= 0:
			if is_sprinting:
				if sfx_sprint:
					sfx_sprint.play()
				footstep_timer = footstep_interval_sprint
			else:
				if sfx_walk:
					sfx_sprint.stop()
					sfx_walk.play()
				footstep_timer = footstep_interval_walk
	else:
		footstep_timer = 0.0

	move_and_slide()
	was_on_floor = is_on_floor()
	
	if is_shaking:
		shake_timer -= delta
		if shake_timer <= 0:
			is_shaking = false
			camera.transform.origin = original_camera_position
		else:
			var offset = Vector3(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
			camera.transform.origin = original_camera_position + offset
	_update_camera_shake(delta)
	if overlay_timer > 0:
		overlay_timer -= delta
		var t = overlay_timer / overlay_duration
		hurt_overlay.modulate.a = 0.5 * t 
	else:
		hurt_overlay.modulate.a = 0.0
		
func handle_camera_rotation():
	rotate_y(-mouseInput.x * mouseSens.x * 0.01)

	camera.rotate_x(-mouseInput.y * mouseSens.y * 0.01)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	mouseInput = Vector2.ZERO

func initialize_animations():
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")

func play_headbob_animation(input_dir):
	if input_dir.length() > 0.1 and is_on_floor():
		var anim = "walk" if speed == walkSpeed else "sprint"
		if HEADBOB_ANIMATION.current_animation != anim:
			HEADBOB_ANIMATION.play(anim, 0.25)
			HEADBOB_ANIMATION.speed_scale = (velocity.length() / walkSpeed) * 1.75
	else:
		if HEADBOB_ANIMATION.current_animation in ["walk", "sprint"]:
			HEADBOB_ANIMATION.play("RESET", 1)

func play_jump_animation():
	if !was_on_floor and is_on_floor(): 
		if sfx_land:
			sfx_land.play()
		var facing_dir = camera.global_transform.basis.x
		var facing_dir_2d = Vector2(facing_dir.x, facing_dir.z).normalized()
		var velocity_2d = Vector2(velocity.x, velocity.z).normalized()
		var side_landed = round(velocity_2d.dot(facing_dir_2d))
		if side_landed > 0:
			JUMP_ANIMATION.play("land_right", 0.25)
		elif side_landed < 0:
			JUMP_ANIMATION.play("land_left", 0.25)
		else:
			JUMP_ANIMATION.play("land_center", 0.25)

func set_held_object(body: RigidBody3D):
	sfx_plop.play()
	heldObject = body

func drop_held_object():
	heldObject = null

func throw_held_object():
	var obj = heldObject
	drop_held_object()
	obj.apply_central_impulse(-camera.global_transform.basis.z * throwForce * 10)

func handle_holding_objects():
	if Input.is_action_just_pressed("throw") and heldObject:
		throw_held_object()

	if Input.is_action_just_pressed("interact_p"):
		if heldObject:
			drop_held_object()
		elif interactRay.is_colliding():
			var target = interactRay.get_collider()
			if target is RigidBody3D:
				set_held_object(target)
				if target.has_meta("spawner_crate"):
					target.get_meta("spawner_crate")._on_item_taken()
					target.set_meta("spawner_crate", null)

	if heldObject:
		var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0,0,-followDistance))
		var objectPos = heldObject.global_transform.origin
		if heldObject is RigidBody3D:
			heldObject.linear_velocity = (targetPos - objectPos) * followSpeed
			if heldObject.Data and "HoldRotationOffset" in heldObject.Data:
				var offset = heldObject.Data.HoldRotationOffset
				heldObject.global_rotation = camera.global_rotation + offset * (PI/180)
		else:
			var newTransform = heldObject.global_transform
			newTransform.origin = targetPos
			heldObject.global_transform = newTransform

		if heldObject.global_position.distance_to(camera.global_position) > maxDistanceFromCamera:
			drop_held_object()

		if dropBelowPlayer and groundRay.isColliding():
			if groundRay.get_collider() == heldObject:
				drop_held_object()

func get_stamina_percent() -> float:
	return stamina / maxStamina

func take_damage(amount: float):
	if sfx_hurt:
		sfx_hurt.play()
	health -= amount
	start_camera_shake(0.15, 0.25) 
	_show_hurt_overlay(0.25)
	if health <= 0:
		die()

func die():
	if sfx_death:
		sfx_death.play()
	health = 0
	stamina = 0
	speed = 0
	set_physics_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if you_died_screen:
		you_died_screen.visible = true
		var respawn_button = you_died_screen.get_node("Respawn")
		if respawn_button:
			respawn_button.pressed.connect(_on_respawn_pressed)
		var home_button = you_died_screen.get_node("Home")
		if home_button:
			home_button.pressed.connect(_on_home_pressed)

func _on_respawn_pressed():
	you_died_screen.visible = false
	
	health = maxHealth
	stamina = maxStamina
	healthBar.set_health(health, maxHealth)
	staminaBar.set_stamina(stamina, maxStamina)

	global_position = spawn_point.global_position
	velocity = Vector3.ZERO

	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_home_pressed():
	get_tree().change_scene_to_file("res://Tutorial-Specific/Scenes/StartScreen.tscn")

func get_health_percent() -> float:
	return health / maxHealth
	
	
func change_reticle(reticle_path: String):
	if RETICLE:
		RETICLE.queue_free()
		RETICLE = null
	if reticle_path != "":
		RETICLE = load(reticle_path).instantiate()
		if RETICLE:
			RETICLE.character = self
			$UserInterface.add_child(RETICLE)
			
func start_camera_shake(intensity := 0.1, duration := 0.2):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	is_shaking = true
	
func _update_camera_shake(delta):
	if is_shaking:
		shake_timer -= delta
		if shake_timer <= 0:
			is_shaking = false
			camera.transform.origin = original_camera_position
		else:
			var t = shake_timer / shake_duration
			var current_intensity = shake_intensity * t
			var offset = Vector3(
				randf_range(-current_intensity, current_intensity),
				randf_range(-current_intensity, current_intensity),
				randf_range(-current_intensity, current_intensity)
			)
			camera.transform.origin = original_camera_position + offset

func _show_hurt_overlay(duration := 0.25):
	overlay_duration = duration
	overlay_timer = duration
	hurt_overlay.modulate.a = 0.5 
