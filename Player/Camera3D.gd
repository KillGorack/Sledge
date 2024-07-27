extends Node3D

const LOOK_SENSITIVITY = 3
const RECENTER_SPEED = 10
const FINE_AIM_MULTIPLIER = 0.1

var yaw = 0.0
var pitch = 0.0
var recentering = false

func _ready():
	yaw = rotation_degrees.y
	pitch = rotation_degrees.x

func _process(_delta):
	handle_camera_look()
	
	if Input.is_action_just_pressed("ui_recenter"):
		recentering = true

	if recentering:
		recenter_camera()

func handle_camera_look():
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

func recenter_camera():
	var target_yaw = 0.0
	var target_pitch = 0.0
	
	yaw = lerp(yaw, target_yaw, RECENTER_SPEED * get_process_delta_time())
	pitch = lerp(pitch, target_pitch, RECENTER_SPEED * get_process_delta_time())
	
	if abs(yaw) < 0.1 and abs(pitch) < 0.1:
		yaw = target_yaw
		pitch = target_pitch
		recentering = false

	rotation_degrees.y = yaw
	rotation_degrees.x = pitch
