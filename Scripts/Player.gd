extends CharacterBody3D

# Constants
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
# Mouse Variables
var mouse_captured = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

# Head bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Teleport Variables
@export var teleport_speed := 4.0
var is_teleporting := false
var target_tele_pos := Vector3.ZERO
var first_tele_pos := Vector3.ZERO
var t := 0.0

# Node Variables
@onready var head = $Head
@onready var camera = $Head/Camera3D
const SPEAR = preload("res://Scenes/spear.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SpearSignals.spear_collison.connect(spear_teleport)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			head.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	# Free the mouse if escape is pressed
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = !mouse_captured


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	# TODO: Jump distance and height should be based on movement speed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle Sprint.
	var speed = WALK_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# I'm gonna admit it, this code is a bit shit and probably super over complicated
	if is_teleporting:
		# Use a threshold for comparison
		if position.distance_to(target_tele_pos) < 1:
			# If the position is close enough to the target, we're no longer teleporting
			is_teleporting = false
			
			# Snap to target to avoid jitter
			position = target_tele_pos
			
			# Reset t so the next throw works properly
			t = 0
		else:
			t += delta * teleport_speed
			# Ensure t stays in range [0, 1]
			t = clamp(t, 0, 1)
			
			# I still don't really understand lerp tbh but it works
			position = first_tele_pos.lerp(target_tele_pos, t)


	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

# This function gets triggered via a signal from the spear and starts off the teleporting process
func spear_teleport(targert_pos):
	target_tele_pos = targert_pos
	first_tele_pos = position
	is_teleporting = true
