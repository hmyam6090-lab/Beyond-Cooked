extends TutorialTriggers

@onready var voice1 = $voice1

func _on_body_entered(body: Node3D) -> void:
	if body == player and not activated:
		activated = true
		voice1.play()

		
