extends ProgressBar

func set_time(value: float, max_value: float):
	value = clamp(value, 0, max_value)
	self.max_value = max_value
	self.value = value

	var fill_style: StyleBoxFlat = get_theme_stylebox("fill")

	if fill_style == null:
		return

	if value <= 10:
		fill_style.bg_color = Color(1, 0, 0)       
	elif value <= 30:
		fill_style.bg_color = Color(1, 1, 0)       
	else:
		fill_style.bg_color = Color(0, 1, 0)        

	add_theme_stylebox_override("fill", fill_style)
