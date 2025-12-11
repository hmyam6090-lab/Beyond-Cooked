extends StaticBody3D

@onready var anim = $AnimationPlayer

func close():
	anim.play("close")
	
func open():
	anim.play("open")
