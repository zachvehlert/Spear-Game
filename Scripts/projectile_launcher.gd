extends Node3D

#const PROJECTILE = preload("res://Scenes/projectile.tscn")
const SPEAR = preload("res://Scenes/spear.tscn")
@onready var timer: Timer = $Timer
@export var cooldown: float = 0.1

func _physics_process(delta: float) -> void:
	# Check cool down
	if timer.is_stopped():
		if Input.is_action_pressed("throw"):
			timer.start(cooldown)
			var spear = SPEAR.instantiate()
			add_child(spear)
			spear.global_transform = global_transform
