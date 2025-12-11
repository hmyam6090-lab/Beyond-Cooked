extends Control

@export var order_manager: OrderManager
@onready var order_list = $HBoxContainer
@export var order_entry_scene: PackedScene

@onready var moneyUI = $Control/Money

func _ready():
	order_manager.orders_updated.connect(_refresh_ui)
	_refresh_ui()


func _refresh_ui():
	moneyUI.text = "Quota: " + str(order_manager.current_money) + "/" + str(order_manager.daily_quota)
	
	for c in order_list.get_children():
		c.queue_free()

	for order in order_manager.active_orders:
		var e = order_entry_scene.instantiate()
		e.set_order(order)
		order_list.add_child(e)
		
