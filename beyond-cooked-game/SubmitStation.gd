extends Area3D
class_name SubmitStation

@export var orders_manager: Node
@onready var collision_submission = $CollisionShape3D

@onready var sfx_success = $SFX/Success
@onready var sfx_failure = $SFX/Failure


func _ready():
	monitoring = true
	monitorable = true
	collision_submission.disabled = true

func _turn_on():
	collision_submission.disabled = false

func _turn_off():
	collision_submission.disabled = true

func _on_SubmitStation_body_entered(body):
	print("collided with ", body)
	if body is InteractableItem:
		print("Detected: ", body)
		_try_submit_item(body)


func _try_submit_item(item: InteractableItem):
	if item.Data == null:
		print("Item has no Data, cannot submit.")
		return

	var success = orders_manager.submit_item(item)
	
	if success:
		sfx_success.play()
		print("Order completed with:", item.Data.ItemName)
		item.queue_free() 
	else:
		sfx_failure.play()
		print("No order matches:", item.Data.ItemName)
