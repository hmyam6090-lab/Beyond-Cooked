extends ProgressBar

func set_stamina(value: float, max_value: float):
	value = clamp(value, 0, max_value)
	self.value = value
