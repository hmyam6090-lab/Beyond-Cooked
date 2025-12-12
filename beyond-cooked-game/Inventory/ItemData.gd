extends Resource
class_name ItemData

@export var ItemName: String
@export var Icon: Texture2D
@export var ModelScene: PackedScene

@export var IsChoppable: bool = false
@export var MaxHealth: float = 3.0    
@export var ChoppedItem: ItemData  
@export var HoldRotationOffset: Vector3 = Vector3.ZERO
