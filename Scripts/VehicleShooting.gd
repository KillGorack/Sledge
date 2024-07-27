extends "res://Scripts/VehicleBase.gd"

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 100.0
@export var projectile_offset: Vector3 = Vector3(0, 0, 0)

camera = get_node(camera_node_path) as Camera3D

const SHOOT_COOLDOWN = 0.25
var shoot_timer = 0.0

func _physics_process(delta):
	if Input.is_action_pressed("ui_select") and shoot_timer <= 0:
		shoot_projectile()
		shoot_timer = SHOOT_COOLDOWN
	if shoot_timer > 0:
		shoot_timer -= delta

func shoot_projectile():
	if projectile_scene and camera:
		var projectile_instance = projectile_scene.instantiate()
		if projectile_instance:
			get_parent().add_child(projectile_instance)
			projectile_instance.global_transform.origin = camera.global_transform.origin + projectile_offset
			var camera_forward = -camera.global_transform.basis.z
			var camera_right = camera.global_transform.basis.x
			var camera_up = camera.global_transform.basis.y
			projectile_instance.global_transform.basis = Basis(camera_right, camera_up, -camera_forward)
			projectile_instance.linear_velocity = camera_forward * projectile_speed
