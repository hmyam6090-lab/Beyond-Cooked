extends Node

signal orders_updated
signal quota_complete
signal quota_failed

enum OrderMode { RANDOM, SEQUENCE }

@export var order_mode: OrderMode = OrderMode.RANDOM
@export var available_recipes: Array[RecipeData]
@export var max_active_orders := 1
@export var time_between_orders := 10.0
@export var daily_quota := 150


@export var quotaUIBoard : QuotaBoard

@export var daily_order_sequence: Array[RecipeData] = []
var sequence_index := 0

@export var you_won_scene: PackedScene

@export var order_system_enabled := true
@export var clear_orders_on_disable := true

var current_money := 0
var active_orders: Array[Order] = []
var order_timer := 0.0

func _ready() -> void:
	connect("quota_complete", Callable(self, "_on_quota_complete"))

func _on_quota_complete():
	if you_won_scene == null:
		push_error("YouWonScene not assigned!")
		return
	
	var won_screen = you_won_scene.instantiate() as Control
	
	get_tree().current_scene.add_child(won_screen)

func _process(delta):
	if not order_system_enabled:
		return
	
	if quotaUIBoard == null:
		return
		
	
	
	quotaUIBoard.money = current_money
	quotaUIBoard.quota = daily_quota


	order_timer -= delta
	if order_timer <= 0:
		_attempt_spawn_order()
		order_timer = time_between_orders

func set_order_system_enabled(enabled: bool) -> void:
	order_system_enabled = enabled

	if not enabled:
		if clear_orders_on_disable:
			_clear_all_orders()
	else:
		order_timer = time_between_orders

	emit_signal("orders_updated")


func _clear_all_orders():
	for order in active_orders:
		order.queue_free()
	active_orders.clear()


func _attempt_spawn_order():
	if active_orders.size() >= max_active_orders:
		return

	var recipe: RecipeData = null

	match order_mode:
		OrderMode.RANDOM:
			if available_recipes.is_empty():
				return
			recipe = available_recipes.pick_random() as RecipeData

		OrderMode.SEQUENCE:
			if daily_order_sequence.is_empty():
				return
			recipe = daily_order_sequence[sequence_index] as RecipeData
			sequence_index = (sequence_index + 1) % daily_order_sequence.size()

	if recipe == null:
		return

	_spawn_order(recipe)


func _spawn_order(recipe: RecipeData) -> void:
	var order := Order.new()
	order.setup(recipe)
	order.order_failed.connect(_on_order_failed)
	order.order_completed.connect(_on_order_completed)

	add_child(order)
	active_orders.append(order)

	emit_signal("orders_updated")


func _on_order_failed(order: Order) -> void:
	active_orders.erase(order)
	order.queue_free()
	emit_signal("orders_updated")


func _complete_order(order: Order) -> void:
	current_money += order.recipe.reward
	active_orders.erase(order)

	order.is_done = true
	order.queue_free()

	if current_money >= daily_quota:
		emit_signal("quota_complete")

	emit_signal("orders_updated")
	order.emit_signal("order_completed", order)


func _on_order_completed(order): pass


func submit_item(item: InteractableItem) -> bool:
	if not order_system_enabled:
		return false
	if item == null:
		return false
	if item.Data == null:
		push_warning("Submitted InteractableItem has no Data field.")
		return false

	for order in active_orders:
		if order.recipe.recipe_name == item.Data.ItemName:
			_complete_order(order)
			item.queue_free()
			return true

	return false
