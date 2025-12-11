extends Node3D
class_name MenuButton3D

signal pressed
signal hovered(state: bool)

@export var hover_scale := 1.1
@export var click_scale := 0.9
@export var smooth_speed := 8.0

@export var label := "Play"

@onready var mesh := $MeshInstance3D
@onready var area := $Area3D

var base_scale := Vector3.ONE
var target_scale := Vector3.ONE

func _ready():
	base_scale = mesh.scale
	target_scale = base_scale
	area.mouse_entered.connect(_on_mouse_enter)
	area.mouse_exited.connect(_on_mouse_exit)
	area.input_event.connect(_on_input_event)
	$MeshInstance3D/Sprite3D/SubViewport/Label.text = label

func _process(delta):
	mesh.scale = mesh.scale.lerp(target_scale, delta * smooth_speed)

func _on_mouse_enter():
	target_scale = base_scale * hover_scale
	emit_signal("hovered", true)

func _on_mouse_exit():
	target_scale = base_scale
	emit_signal("hovered", false)

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_scale = base_scale * click_scale
		print("Pressed Play")
		emit_signal("pressed")
