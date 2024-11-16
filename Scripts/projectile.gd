extends RayCast3D

@export var speed := 5

var gravity = 9.8

func _physics_process(delta: float) -> void:
	position += global_transform.basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	var collider = get_collider()
	if is_colliding():
		global_position = get_collision_point()
		set_physics_process(false)

func cleanup() -> void:
	queue_free()
