extends Camera3D

const LOOK_SENSITIVITY = 3
const RECENTER_SPEED = 10
const FINE_AIM_MULTIPLIER = 0.1

var yaw = 0.0
var pitch = 0.0
var recentering = false

func _ready():
	yaw = rotation_degrees.y
	pitch = rotation_degrees.x

func _process(delta):
	handle_camera_look(delta)
	
	if Input.is_action_just_pressed("ui_recenter"):
		recentering = true

	if recentering:
		recenter_camera(delta)

func handle_camera_look(delta):
	if !recentering:
		var look_x = Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
		var look_y = Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
		
		var sensitivity = LOOK_SENSITIVITY
		if Input.is_action_pressed("ui_shift"):
			sensitivity *= FINE_AIM_MULTIPLIER

		yaw += look_x * sensitivity
		pitch -= look_y * sensitivity

		yaw = clamp(yaw, -90, 90)
		pitch = clamp(pitch, -90, 90)

		rotation_degrees.y = yaw
		rotation_degrees.x = pitch

func recenter_camera(delta):
	yaw = lerp(yaw, 0.0, RECENTER_SPEED * delta)
	pitch = lerp(pitch, 0.0, RECENTER_SPEED * delta)
	
	if abs(yaw) < 0.1 and abs(pitch) < 0.1:
		yaw = 0.0
		pitch = 0.0
		recentering = false

	rotation_degrees.y = yaw
	rotation_degrees.x = pitch
