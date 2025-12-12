extends TutorialTriggers

@export var orders : OrderManager
@onready var voice1 = $voice1

func _process(delta: float) -> void:
	if orders.current_money == 40 and not activated:
		activated = true
		voice1.play()
		
