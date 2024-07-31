extends RigidBody3D

# Tank parameters
@export var force: float = 10.0
@export var max_speed: float = 20.0
@export var turn_rate: float = 10.0  # Adjusted to control the amount of torque applied
@export var turn_duration: float = 0.5 # Duration of the turn in seconds

# Reference to the raycasts assigned in the UI
@export var left_raycast: RayCast3D
@export var right_raycast: RayCast3D
@export var ground_raycast: RayCast3D

# Variable to store the turn state
var is_turning = false
var turn_timer = 0.0
var turn_direction = 1.0

func _ready():
	if left_raycast:
		left_raycast.enabled = true
	if right_raycast:
		right_raycast.enabled = true
	if ground_raycast:
		ground_raycast.enabled = true

func _physics_process(delta):
	
	if ground_raycast.is_colliding():
	
		if is_turning:
			turn_timer -= delta
			if turn_timer <= 0:
				is_turning = false
			return

		var forward_force = transform.basis.z * -force

		# Check if either raycast is colliding
		if (left_raycast and left_raycast.is_colliding()) or (right_raycast and right_raycast.is_colliding()):
			
			if left_raycast.is_colliding():
				turn_direction = 1.0  # Turn right
			elif right_raycast.is_colliding():
				turn_direction = 1.0  # Turn left
			
			# Apply torque to rotate the tank
			apply_torque_impulse(Vector3.UP * turn_rate * turn_direction)
			is_turning = true
			turn_timer = turn_duration

		# Apply forward force
		apply_central_force(forward_force)

		# Limit the tank's speed
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed
