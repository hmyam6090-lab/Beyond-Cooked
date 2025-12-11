extends ProgressBar
class_name CustomHealthBar

var change_value_tween: Tween
var opacity_tween: Tween
const LOSS_TWEEN_TIME := 0.35
const OPACITY_TWEEN_TIME := 0.12
const VISIBILITY_TIMEOUT := 1.5
var visibility_timer := 0.0

@onready var loss_bar: ProgressBar = $ProgressBar

func setup(max_health: float) -> void:
	self.value = max_health
	self.max_value = max_health
	modulate.a = 0.0
	
	if loss_bar:
		loss_bar.value = max_health
		loss_bar.max_value = max_health
	else:
		push_warning("Loss bar not assigned!")

func set_health(current: float, max_health: float) -> void:
	current = clamp(current, 0, max_health)
	self.value = current  
	self.max_value = max_health

	_change_opacity(1.0)
	visibility_timer = VISIBILITY_TIMEOUT

	if loss_bar:
		if change_value_tween:
			change_value_tween.kill()
		change_value_tween = create_tween()
		change_value_tween.tween_property(loss_bar, "value", current, LOSS_TWEEN_TIME).set_trans(Tween.TRANS_SINE)

func _change_opacity(target_alpha: float) -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	opacity_tween.tween_property(self, "modulate:a", target_alpha, OPACITY_TWEEN_TIME).set_trans(Tween.TRANS_SINE)
	if loss_bar:
		opacity_tween.tween_property(loss_bar, "modulate:a", target_alpha, OPACITY_TWEEN_TIME).set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	if visibility_timer > 0:
		visibility_timer -= delta
		if visibility_timer <= 0:
			_change_opacity(0.0)
