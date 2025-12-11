extends ProgressBar
class_name CustomStaminaBar

var change_value_tween: Tween
var opacity_tween: Tween

@export var loss_bar: ProgressBar

func _ready():
	
	modulate.a = 0.0

func _change_opacity(amount: float):
	if opacity_tween:
		opacity_tween.kill()

	opacity_tween = create_tween()
	opacity_tween.tween_property(self, "modulate:a", amount, 0.12)


func set_stamina(new_value: float, max_value: float):
	_change_opacity(1.0)

	new_value = clamp(new_value, 0, max_value)
	self.max_value = max_value
	loss_bar.max_value = max_value

	self.value = new_value

	if change_value_tween:
		change_value_tween.kill()

	change_value_tween = create_tween()
	change_value_tween.tween_property(
		loss_bar,
		"value",
		new_value,
		0.35
	).set_trans(Tween.TRANS_SINE)

	change_value_tween.finished.connect(_fade_out_delayed)


func _fade_out_delayed():
	var t := create_tween()
	t.tween_interval(0.6)
	t.tween_callback(func(): _change_opacity(0.0))
