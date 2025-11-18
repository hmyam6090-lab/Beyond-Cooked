extends Control

class_name InventorySlot

signal OnItemDropped(fromSlotID, toSlotID)

@export var IconSlot : TextureRect

var InventorySlotID : int = -1
var SlotFilled : bool = false

var SlotData : ItemData

func FillSlot(data: ItemData):
	SlotData = data
	
	if (SlotData != null):
		SlotFilled = true
		IconSlot.texture = data.Icon
	else:
		SlotFilled = false
		IconSlot.texture = null
		
func Highlight(selected: bool):
	modulate = Color(1, 1, 1) if not selected else Color(1.5, 1.5, 1.5, 1.0)
