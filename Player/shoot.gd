extends Node3D

const SHOOT_COOLDOWN = 1
var shoot_timer = 0.0
var camera: Camera3D
var shooting_audio: AudioStreamPlayer
var current_speed = Vector3.ZERO
var current_turn_speed = 0.0

@export var projectile_scene_1: PackedScene
@export var projectile_scene_2: PackedScene
var projectile_scenes: Array

@export var projectile_speed: float = 100.0
@export var camera_node_path: NodePath
@export var projectile_offset: Vector3 = Vector3(0, 0, 0)
@export var shooting_audio_path: NodePath
var current_projectile_index = 0

func _ready():
	camera = get_node(camera_node_path) as Camera3D
	shooting_audio = get_node(shooting_audio_path) as AudioStreamPlayer
	projectile_scenes = [projectile_scene_1, projectile_scene_2]

func _physics_process(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
	if Input.is_action_pressed("ui_select") and shoot_timer <= 0:
		shoot_projectile()
		shoot_timer = SHOOT_COOLDOWN
	if Input.is_action_just_pressed("weapon_change"):  # Assuming "ui_accept" is bound to the Tab key
		switch_projectile()

func shoot_projectile():
	if projectile_scenes.size() > 0 and camera:
		var projectile_scene = projectile_scenes[current_projectile_index]
		var projectile_instance = projectile_scene.instantiate()
		if projectile_instance:
			get_parent().get_parent().add_child(projectile_instance)
			projectile_instance.global_transform.origin = camera.global_transform.origin + projectile_offset
			var camera_forward = -camera.global_transform.basis.z
			var camera_right = camera.global_transform.basis.x
			var camera_up = camera.global_transform.basis.y
			projectile_instance.global_transform.basis = Basis(camera_right, camera_up, -camera_forward)
			projectile_instance.linear_velocity = camera_forward * projectile_speed
		if shooting_audio:
			shooting_audio.play()

func switch_projectile():
	current_projectile_index = (current_projectile_index + 1) % projectile_scenes.size()
