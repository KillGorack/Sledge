extends MeshInstance3D

var yaw = 0.0
var pitch = 0.0
var recentering = false

@onready var barrel = $Barrel

func _ready():
	yaw = rotation_degrees.y
	pitch = barrel.rotation_degrees.x
	
func _physics_process(_delta):
	if UserData.UserSettings["Craft"] == null:
		return
	handle_turret_barrel_look()
	if Input.is_action_just_pressed("ui_recenter"):
		recentering = true
	if recentering:
		recenter_turret_barrel()

func handle_turret_barrel_look():
	if not recentering:
		var look_x = Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
		var look_y = Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
		var sensitivity = UserData.UserSettings["Craft"].look_sensitivity
		if Input.is_action_pressed("ui_shift"):
			sensitivity *= UserData.UserSettings["Craft"].fine_aim_multiplier
		yaw += look_x * sensitivity
		pitch -= look_y * sensitivity
		yaw = clamp(yaw, -90, 90)
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		barrel.rotation_degrees.x = pitch

func recenter_turret_barrel():
	var target_yaw = 0.0
	var target_pitch = 0.0
	yaw = lerp(yaw, target_yaw, UserData.UserSettings["Craft"].recenter_speed * get_process_delta_time())
	pitch = lerp(pitch, target_pitch, UserData.UserSettings["Craft"].recenter_speed * get_process_delta_time())
	if abs(yaw) < 0.1 and abs(pitch) < 0.1:
		yaw = target_yaw
		pitch = target_pitch
		recentering = false
	rotation_degrees.y = yaw
	barrel.rotation_degrees.x = pitch
