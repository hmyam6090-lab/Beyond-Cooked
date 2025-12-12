extends TutorialTriggers

@export var orders : OrderManager
@onready var voice1 = $voice1
@onready var voice2 = $voice2

func _process(delta: float) -> void:
	if orders.current_money == 20 and not activated:
		activated = true
		voice1.play()
		await get_tree().create_timer(10.0).timeout
		voice2.play()
		
