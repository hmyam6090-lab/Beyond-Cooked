extends ProgressBar

func _set_value(value: float, max_value: float):
	value = clamp(self, value, max_value)
	
	self.value = value
