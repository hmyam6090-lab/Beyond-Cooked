extends TutorialTriggers

@export var orders : OrderManager
@onready var voice1 = $voice1
@onready var voice2 = $voice2
@onready var voice3 = $voice3

func _on_body_entered(body: Node3D) -> void:
	if body == player and not activated:
		activated = true
		orders.order_system_enabled = true
		voice1.play()
		await get_tree().create_timer(12.0).timeout
		voice2.play()
		
