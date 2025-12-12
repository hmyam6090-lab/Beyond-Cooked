extends InteractableItem
class_name Lever

signal lever_pulled

var player_in_range := false
var is_pulled := false

@onready var anim = $AnimationPlayer
@onready var UI = $UI

@export var submit : SubmitStation
@export var trapdoor: StaticBody3D

@onready var sfx_pulled = $SFX/Pulled

func _ready():
	super._ready()
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_range:
		if (Input.is_action_just_pressed('interact')):
			pull_lever()

func _on_body_entered(body):
	if body.has_meta("player"):
		if UI:
			UI.visible = true
		if ItemHighlightMesh:
			ItemHighlightMesh.visible = true
		player_in_range = true


func _on_body_exited(body):
	if body.has_meta("player"):
		if UI:
			UI.visible = false
		if ItemHighlightMesh:
			ItemHighlightMesh.visible = false
		player_in_range = false


func pull_lever():
	if !trapdoor or !submit:
		sfx_pulled.play()
		anim.play("pull_lever")
		return
	sfx_pulled.play()
	print("Lever pulled!")
	anim.play("pull_lever")
	trapdoor.close()
	await get_tree().create_timer(0.5).timeout
	submit._turn_on()
	await get_tree().create_timer(2.0).timeout
	trapdoor.open()
	submit._turn_off()
	
