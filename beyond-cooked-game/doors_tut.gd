extends Node3D

@export var player : CharacterBody3D

@onready var openRange = $Area3D
@onready var anim = $AnimationPlayer

@export var ui : Sprite3D
@export var outline : MeshInstance3D

@onready var sfx_open = $SFX/Open
@onready var sfx_close = $SFX/Close

var interactable = false
var isOpened = false

func _process(delta: float) -> void:

	if interactable:
		print("Door is Interactable")
		ui.visible = true
		outline.visible = true
		if (Input.is_action_just_pressed("interact") && !isOpened):
			anim.play("open")
			sfx_close.stop()
			sfx_open.play()
			isOpened = true
		elif (Input.is_action_just_pressed("interact") && isOpened):
			anim.play("close")
			sfx_open.stop()
			sfx_close.play()
			isOpened = false
	else:
		ui.visible = false
		outline.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		interactable = true;

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		interactable = false;
