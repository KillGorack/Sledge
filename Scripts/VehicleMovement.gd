extends "res://Scripts/VehicleBase.gd"

@export var forward_input: float
@export var turn_input: float

const MAX_SPEED = 6.0
const ACCELERATION = 800.0
const DECELERATION = 100.0
const TURN_SPEED = 3.0
const TURN_ACCELERATION = 10.0
const TURN_DECELERATION = 24.0
const SPEED_THRESHOLD = 0.01
const GROUND_CHECK_DISTANCE = 0.5
const RIGHT_SIDE_UP_THRESHOLD = 0.8
const UNTURTLE_THRESHOLD = 0.3
const UNTURTLE_FORCE = 100.0
const THRUSTER_FORCE = 800.0
const ROTATION_SPEED = 3.0

var target_pitch = 2.0
var target_volume = -30.0
var pitch_transition_speed = 5.0
var volume_transition_speed = 5.0
var current_speed = Vector3.ZERO
var current_turn_speed = 0.0
var isGrounded = true
var rotational_velocity_set_to_zero = false
var engine_audio: AudioStreamPlayer





func _ready():
	engine_audio = get_node(engine_audio_path) as AudioStreamPlayer
	if engine_audio:
		engine_audio.play()
		
		
		
		
		
func _physics_process(delta):
	var turn_input = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var forward_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if is_right_side_up() and is_on_ground():
		rotational_velocity_set_to_zero = false
		adjust_rotation(turn_input, delta)
		move_player(forward_input)
	if rotational_velocity_set_to_zero:
		set_angular_velocity(Vector3.ZERO)
	update_engine_sound()
	
	
	
	
	
func is_right_side_up() -> bool:
	return transform.basis.y.dot(Vector3.UP) > RIGHT_SIDE_UP_THRESHOLD





func is_on_ground() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_transform.origin
	query.to = global_transform.origin - Vector3.UP * GROUND_CHECK_DISTANCE
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	isGrounded = result.size() > 0
	return result.size() > 0





func adjust_rotation(turn_input, delta):
	current_turn_speed = move_toward(current_turn_speed, turn_input * TURN_SPEED, TURN_ACCELERATION * delta)
	rotation.y += current_turn_speed * delta





func move_player(forward_input):
	var direction = transform.basis.z
	if forward_input != 0:
		var force = direction * forward_input * ACCELERATION
		apply_central_force(force)
	else:
		var current_velocity = get_linear_velocity()
		var deceleration_force = -current_velocity * DECELERATION
		apply_central_force(deceleration_force)
	var clamped_velocity = get_linear_velocity().limit_length(MAX_SPEED)
	set_linear_velocity(clamped_velocity)





func activate_thrusters(delta):
	apply_central_force(Vector3.UP * THRUSTER_FORCE)
	var current_up = transform.basis.y
	var target_up = Vector3.UP
	var rotation_axis = current_up.cross(target_up).normalized()
	var angle_diff = acos(current_up.dot(target_up))
	if angle_diff > 0.1:
		var rotation_matrix = Basis()
		rotation_matrix = rotation_matrix.rotated(rotation_axis, min(ROTATION_SPEED * delta, angle_diff))
		transform.basis = rotation_matrix * transform.basis
		transform.basis = transform.basis.orthonormalized()
	else:
		rotational_velocity_set_to_zero = true





func update_engine_sound():
	if engine_audio:
		var speed : float = get_linear_velocity().length()
		if isGrounded:
			target_pitch = clamp(2.0 + speed / max(MAX_SPEED, 1.0) * 2.0, 2.0, 4.0)
			target_volume = clamp(-20 + 10 * (speed / max(MAX_SPEED, 1.0)), -60.0, -20.0)
		else:
			target_pitch = 2.0
			target_volume = -20.0
		engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, target_pitch, pitch_transition_speed * get_process_delta_time())
		engine_audio.volume_db = lerp(engine_audio.volume_db, target_volume, volume_transition_speed * get_process_delta_time())
	else:
		print("Error: Engine audio node is not initialized.")
