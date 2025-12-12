extends Control

@onready var home_button: Button = $Home
@onready var sfx_win = $SFX/Win

func _ready():
	sfx_win.play()
	set_process_input(true)
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	home_button.grab_focus()
	home_button.pressed.connect(_on_home_pressed)

func _on_home_pressed():
	print("home pressed")
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://Tutorial-Specific/Scenes/StartScreen.tscn")
