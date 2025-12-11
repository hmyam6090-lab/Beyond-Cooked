extends State
class_name EnemyState

@onready var _enemy: Enemy = owner

var is_locked: bool = false

func enter(previous_state_name: String, data := {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass

func lock_state() -> void:
	is_locked = true
	
func unlock_state() -> void:
	is_locked = false
