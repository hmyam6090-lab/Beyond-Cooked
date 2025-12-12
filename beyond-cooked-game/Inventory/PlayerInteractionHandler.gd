extends Area3D

signal OnItemPickedUp(item)

var NearbyBodies: Array[InteractableItem] = []

func OnObjectEnteredArea(body: InteractableItem):
	if body is InteractableItem:
		body.GainFocus()
		NearbyBodies.append(body)
	
func OnObjectExitedArea(body: InteractableItem):
	if body is InteractableItem and NearbyBodies.has(body):	
		body.LoseFocus()
		NearbyBodies.erase(body)
