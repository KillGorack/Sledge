extends RigidBody3D

const MAX_SPEED = 10.0
const ACCELERATION = 15.0
const DECELERATION = 15.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 3.0
const TURN_ACCELERATION = 10.0
const TURN_DECELERATION = 12.0
const SPEED_THRESHOLD = 0.01

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_speed = Vector3.ZERO
var current_turn_speed = 0.0

func _ready():
	# Initialize any necessary settings here
	pass

func _physics_process(delta):
	#if is_on_floor():
	#	apply_gravity()
	pass

	var forward_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var turn_input = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")

	adjust_rotation(turn_input, delta)
	move_player(forward_input, delta)

func apply_gravity():
	var gravity_vector = Vector3(0, gravity, 0)
	var gravity_force = gravity_vector * mass
	apply_impulse(Vector3.ZERO, gravity_force)

func adjust_rotation(turn_input, delta):
	current_turn_speed = move_toward(current_turn_speed, turn_input * TURN_SPEED, TURN_ACCELERATION * delta)
	rotation.y += current_turn_speed * delta

func move_player(forward_input, delta):
	var target_direction = Vector3(0, 0, forward_input).normalized()

	if forward_input != 0:
		if current_speed.length() < SPEED_THRESHOLD:
			current_speed.x = forward_input * ACCELERATION * delta
			current_speed.z = forward_input * ACCELERATION * delta
		else:
			current_speed.x = move_toward(current_speed.x, MAX_SPEED * target_direction.z, ACCELERATION * delta)
			current_speed.z = move_toward(current_speed.z, MAX_SPEED * target_direction.z, ACCELERATION * delta)
	else:
		current_speed.x = move_toward(current_speed.x, 0, DECELERATION * delta)
		current_speed.z = move_toward(current_speed.z, 0, DECELERATION * delta)

	var linear_velocity = Vector3(sin(rotation.y) * current_speed.z, get_linear_velocity().y, cos(rotation.y) * current_speed.z)
	set_linear_velocity(linear_velocity)
