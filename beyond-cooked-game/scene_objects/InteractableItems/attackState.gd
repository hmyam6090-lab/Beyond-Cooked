extends EnemyState

@export var attack_anim_name := "Rig_Medium_General/Throw"
@export var attack_range := 2.0
@export var attack_damage := 40
@export var attack_cooldown := 1.0

var _can_attack := true

func enter(previous_state_name: String, data := {}) -> void:
	_enemy._is_attacking = true

	if _enemy.movement_anim.has_animation(attack_anim_name):
		_enemy.movement_anim.play(attack_anim_name)
		_enemy.movement_anim.connect("animation_finished", Callable(self, "_on_attack_finished"))
	else:
		_on_attack_finished(attack_anim_name) # fallback

func _on_attack_finished(anim_name: String) -> void:
	if anim_name != attack_anim_name:
		return
	
	if _enemy.player and _enemy.global_position.distance_to(_enemy.player.global_position) <= attack_range:
		_enemy.player.take_damage(attack_damage)
	
	_enemy.reached_player.emit()
	
	_enemy._is_attacking = false
	_can_attack = false

	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true
	
	requested_transition_to_other_state.emit("Chasing")
