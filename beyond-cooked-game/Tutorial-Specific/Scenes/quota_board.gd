extends Node3D
class_name QuotaBoard

var money = 0
var quota = 40

@onready var moneyLabel = $Sprite3D/SubViewport/Money
@onready var quotaLabel = $Sprite3D/SubViewport/Quota

func _process(delta: float) -> void:
	moneyLabel.text = "$" + str(money)
	quotaLabel.text = "$" + str(quota)
