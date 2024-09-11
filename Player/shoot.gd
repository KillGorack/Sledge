extends Node3D

var shoot_timer = 0.0
var camera: Camera3D
@onready var raycast = $TargetCast
var shooting_audio: AudioStreamPlayer
var current_speed = Vector3.ZERO
var current_turn_speed = 0.0
var weapon_label: RichTextLabel
var current_projectile_index = 0
var weapon_name = ""
var projectile_speed = 0.0

@export var projectile_scenes: Array[PackedScene]
@export var weapon_label_path: NodePath
@export var camera_node_path: NodePath
@export var projectile_offset: Vector3 = Vector3(0, 0, 0)
@export var shooting_audio_path: NodePath
@export var target_scene: PackedScene

func _ready():
	camera = get_node_or_null(camera_node_path) as Camera3D
	shooting_audio = get_node_or_null(shooting_audio_path) as AudioStreamPlayer
	weapon_label = get_node_or_null(weapon_label_path) as RichTextLabel

	if not camera:
		print("Warning: Camera node not found")
	if not shooting_audio:
		print("Warning: Shooting audio node not found")
	if not weapon_label:
		print("Warning: Weapon label node not found")
		
	if projectile_scenes.size() > 0:
		var initial_projectile = projectile_scenes[current_projectile_index].instantiate()
		if initial_projectile and initial_projectile.has_method("get_weapon_name"):
			weapon_name = initial_projectile.get_weapon_name()
		update_weapon_label()

func _physics_process(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
	if Input.is_action_pressed("ui_select") and shoot_timer <= 0:
		shoot_projectile()
	if Input.is_action_just_pressed("weapon_change"):
		switch_projectile()
	if Input.is_action_just_pressed("place_target"):
		place_target()




func place_target():
	var existing_targets = get_tree().get_nodes_in_group("Target_Beacon")
	if existing_targets.size() > 0:
		return
	
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_object = raycast.get_collider()
		
		if target_scene:
			var target_instance = target_scene.instantiate()
			target_instance.global_transform.origin = collision_point
			
			# Ensure that the collider is not a static body (which might not want new children)
			if collision_object is Node:
				# Add the target as a child of the hit object
				collision_object.add_child(target_instance)
				# Ensure the target's transform is correct within the new parent
				target_instance.global_transform.origin = collision_point






func shoot_projectile():
	if projectile_scenes.size() > 0 and camera:
		var projectile_scene = projectile_scenes[current_projectile_index]
		var projectile_instance = projectile_scene.instantiate()
		if projectile_instance:
			get_parent().get_parent().get_parent().add_child(projectile_instance)
			projectile_instance.global_transform.origin = camera.global_transform.origin + projectile_offset
			var camera_forward = -camera.global_transform.basis.z
			var camera_right = camera.global_transform.basis.x
			var camera_up = camera.global_transform.basis.y
			projectile_instance.global_transform.basis = Basis(camera_right, camera_up, -camera_forward)
			if projectile_instance.has_method("get_cooldown"):
				shoot_timer = projectile_instance.get_cooldown()
			if projectile_instance.has_method("get_projectile_speed"):
				projectile_instance.linear_velocity = camera_forward * projectile_instance.get_projectile_speed()
			else:
				projectile_instance.linear_velocity = camera_forward * projectile_speed
			if projectile_instance.has_method("get_launch_sound"):
				var launch_sound = projectile_instance.get_launch_sound()
				if launch_sound:
					shooting_audio.stream = launch_sound
					shooting_audio.play()




func switch_projectile():
	current_projectile_index = (current_projectile_index + 1) % projectile_scenes.size()
	var projectile_scene = projectile_scenes[current_projectile_index]
	var projectile_instance = projectile_scene.instantiate()
	if projectile_instance and projectile_instance.has_method("get_weapon_name"):
		weapon_name = projectile_instance.get_weapon_name()
	update_weapon_label()

func update_weapon_label():
	if weapon_label:
		var projectile_name = " Weapon: " + str(weapon_name)
		weapon_label.text = projectile_name
