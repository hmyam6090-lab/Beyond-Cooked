extends Node3D

@onready var level_select = $LevelSelect

func _ready():
	$PlayButton.pressed.connect(_show_level_select)
	$QuitButton.pressed.connect(_quit)

	level_select.get_node("Back").pressed.connect(_hide_level_select)
	level_select.get_node("Tutorial").pressed.connect(
		func(): _start("res://Assets/TutorialKitchen/MeshLib/tutorial.tscn")
	)
	level_select.get_node("Level1").pressed.connect(
		func(): _start("res://Scenes/demo_level.tscn")
	)

func _show_level_select():
	level_select.visible = true

func _hide_level_select():
	level_select.visible = false

func _start(path: String):
	get_tree().change_scene_to_file(path)

func _quit():
	get_tree().quit()
