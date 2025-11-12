extends CharacterBody3D

@export var speed: float = 4.0             # Movement speed
@export var chase_distance: float = 10.0   # Max distance to chase player
@export var player: Node3D                 # Assign the player in the Inspector

func _physics_process(delta: float) -> void:
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player < chase_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			look_at(player.global_position, Vector3.UP)  # Rotate to face the player
		else:
			velocity = Vector3.ZERO  # Stop if too far
		move_and_slide()
