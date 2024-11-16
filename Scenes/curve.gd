extends Node3D

@onready var sphere: MeshInstance3D = $Sphere
@onready var sphere_2: MeshInstance3D = $Sphere2
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera : Camera3D = get_parent()

var p1 := Vector3(0, 0, -2)
var p2 := Vector3.ZERO

func _process(delta: float) -> void:
	# Update the sphere and ray position
	sphere.position = p1
	ray_cast_3d.position = p1
	
	ray_cast_3d.global_rotation = to_local(Vector3(camera.rotation.x, 0, 0))
	
	if ray_cast_3d.is_colliding():
		sphere_2.global_position = ray_cast_3d.get_collision_point()
