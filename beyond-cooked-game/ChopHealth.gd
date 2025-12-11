extends Node3D
class_name ChopHealthBar3D

@export var progress_bar: ProgressBar

func set_health(current: float, max: float):
	if progress_bar:
		progress_bar.max_value = max
		progress_bar.value = current
