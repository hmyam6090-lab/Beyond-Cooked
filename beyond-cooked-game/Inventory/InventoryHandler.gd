extends Control

class_name InventoryHandler

@export var PlayerBody : CharacterBody3D
@export_flags_3d_physics var CollisionMask: int

@export var InteractRay : RayCast3D

@export var ItemSlotsCount : int = 4

@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload("res://Assets/Prefab/InventorySlot.tscn")

var InventorySlots : Array[InventorySlot] = []
var CurrentSlotIndex : int = 0

func _ready() -> void:
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		InventorySlots.append(slot)
	_update_slot_highlight()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("slot1"):
		_select_slot(1)
	elif Input.is_action_just_pressed("slot2"):
		_select_slot(2)
	elif Input.is_action_just_pressed("slot3"):
		_select_slot(3)
	elif Input.is_action_just_pressed("slot4"):
		_select_slot(4)
	
	
func _select_slot(slot : int):
	CurrentSlotIndex = slot-1
	_update_slot_highlight()

func _update_slot_highlight():
	for i in InventorySlots.size():
		InventorySlots[i].Highlight(i == CurrentSlotIndex)

func PickUpItem(item: ItemData):
	if (!isInventoryFull()):
		for slot in InventorySlots:
			if(!slot.SlotFilled):
				slot.FillSlot(item)
				break
	else: 
		print("Inventory FULL!")

func isInventoryFull():
	for i in InventorySlots:
		if(!i.SlotFilled):
			return false;
	return true;

func _drop_current_item():
	var current_slot = InventorySlots[CurrentSlotIndex]
	if not current_slot.SlotFilled:
		return

	var item_data = current_slot.SlotData
	var new_item = item_data.ItemModelPrefab.instantiate()
	current_slot.FillSlot(null)

	PlayerBody.get_parent().add_child(new_item)
	new_item.global_position = GetWorldMousePosition()
	
func GetWorldMousePosition() -> Vector3:
	var mousePos = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera_3d()
	var ray_start = cam.project_ray_origin(mousePos)
	var ray_end = ray_start + cam.project_ray_normal(mousePos) * cam.global_position.distance_to(PlayerBody.global_position * 2)
	var world3d : World3D = PlayerBody.get_world_3d()
	var space_state = world3d.direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, CollisionMask)
	
	var results = space_state.intersect_ray(query)
	if (results):
		return results["position"] as Vector3 + Vector3(0.0, 0.5, 0.0)
	else:
		return ray_start.lerp(ray_end, 0.5) + Vector3(0.0, 0.5, 0.0)
	
