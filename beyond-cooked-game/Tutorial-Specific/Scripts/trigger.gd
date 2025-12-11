extends Area3D

class_name TutorialTriggers

@export var player : Player

@onready var voiceline1 = $Welcome
@onready var voiceline2 = $Welcome2


var activated = false

func _on_body_entered(body: Node3D) -> void:
	if body == player and not activated:
		activated = true
		voiceline1.play()
		await get_tree().create_timer(7.0).timeout
		voiceline2.play()
		
	
