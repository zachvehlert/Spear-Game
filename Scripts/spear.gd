extends RigidBody3D

@export var speed := 20.0
@onready var ray = $RayCast3D
@onready var timer = $Timer

func _ready() -> void:
	# As soon as the spear is instantiated, apply a force in the forward direction relative to the projectile launcher
	# Not totally sure why I have to multiply by -1 here, but if I don't it just goes backwards
	apply_central_impulse((global_transform.basis * Vector3.FORWARD * speed) * -1)
	
	timer.start()

func _physics_process(delta: float) -> void:
	# While the spear is flying, point the thing in the direction it's moving
	# Gonna be honest, I don't know how this works
	look_at(global_position + linear_velocity, Vector3.UP)
	
	if ray.is_colliding():
		# If the raycast collides with somthing, freeze that bad larry in place
		freeze = true
		
		# target is a point that's one unit in the opposite direction of where the spear landed
		# I'm fucking stoked I figured this out
		var target = ray.get_collision_normal() + ray.get_collision_point()
		
		# Send a signal to the player controller containing where it needs to teleport the player to
		# Signal is sent by way of the SpearSignals autoload, or spear_signals.gd
		SpearSignals.spear_collison.emit(target)
		
		# STOP THE PHSYICS
		set_physics_process(false)


func _on_timer_timeout() -> void:
	# Edit the despawn time with "wait time" in the timer node
	queue_free()
