extends RigidBody3D

@export var force: float = 10.0
@export var max_speed: float = 20.0
@export var turn_rate: float = 10.0
@export var turn_duration: float = 0.5

@export var left_raycast: RayCast3D
@export var right_raycast: RayCast3D
@export var ground_raycast: RayCast3D

var is_turning = false
var turn_timer = 0.0
var turn_direction = 1.0
var stop_forces = false

func _ready():
	if left_raycast:
		left_raycast.enabled = true
	if right_raycast:
		right_raycast.enabled = true
	if ground_raycast:
		ground_raycast.enabled = true

func _physics_process(delta):
	if stop_forces:
		return

	if ground_raycast.is_colliding():
		if is_turning:
			turn_timer -= delta
			if turn_timer <= 0:
				is_turning = false
			return

		var forward_force = transform.basis.z * -force
		if (left_raycast and left_raycast.is_colliding()) or (right_raycast and right_raycast.is_colliding()):
			turn_direction = 1.0
			apply_torque_impulse(Vector3.UP * turn_rate * turn_direction)
			is_turning = true
			turn_timer = turn_duration
		apply_central_force(forward_force)

		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed

func apply_projectile_impulse(impulse: Vector3, direction: Vector3):
	stop_forces = true
	apply_central_impulse(impulse)
	await get_tree().create_timer(0.1).timeout
	stop_forces = false
