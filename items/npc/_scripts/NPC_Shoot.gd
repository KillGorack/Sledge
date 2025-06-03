extends MeshInstance3D

@export var turret: MeshInstance3D
@export var barrel: MeshInstance3D
@export var shoot_cast: RayCast3D
@export var weapon_settings: Array[Resource] = []


var target_object: RigidBody3D
var current_alegance: String = "Creative_Enemy"
var rotation_speed: float = 25
var shoot_timer = 0.0
var found_target = false
var found_settings = false
var allegiance_set = false
var parent_node: RigidBody3D

var target_previous_position: Vector3 = Vector3.ZERO
var current_weapon_settings: Resource = null

func _ready():
	parent_node = get_parent()
	select_random_weapon_setting()



	
func select_random_weapon_setting():
	var npc_weapons = UserData.settingsNPC
	if npc_weapons.size() > 0:
		UserData.settingsNPCCurrent = npc_weapons.pick_random()
		current_weapon_settings = UserData.settingsNPCCurrent
	else:
		current_weapon_settings = null
	shoot_timer = 0.0
	
	





func set_target(object):
	target_object = object






func _physics_process(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
	if is_instance_valid(target_object):
		var distance_to_player = global_transform.origin.distance_to(target_object.global_transform.origin)
		var rayZ_dist = abs(shoot_cast.target_position.z)
		if distance_to_player <= rayZ_dist:
			var turret_origin = turret.global_transform.origin
			var player_position = target_object.global_transform.origin + Vector3(0, 0.2, 0)
			var target_velocity = (player_position - target_previous_position) / delta
			target_previous_position = player_position
			var projectile_speed = current_weapon_settings.projectile_speed
			var distance = turret_origin.distance_to(player_position)
			var time_to_target = distance / projectile_speed
			var future_position = player_position + target_velocity * time_to_target
			if not parent_node.freezeBit:
				if not turret_origin.is_equal_approx(future_position):
					var turret_target_rotation = turret.global_transform.looking_at(future_position, Vector3.UP).basis
					turret.global_transform.basis = turret.global_transform.basis.orthonormalized().slerp(turret_target_rotation, rotation_speed * delta)
				turret.rotation.x = 0
				turret.rotation.z = 0
				var barrel_origin = barrel.global_transform.origin
				if not barrel_origin.is_equal_approx(future_position):
					var barrel_target_rotation = barrel.global_transform.looking_at(future_position, Vector3.UP).basis
					barrel.global_transform.basis = barrel.global_transform.basis.orthonormalized().slerp(barrel_target_rotation, rotation_speed * delta)
				barrel.rotation.y = 0
				barrel.rotation.z = 0
				if shoot_timer <= 0 and Utilities.game_mode_index != 2:
					#shoot_projectile()
					pass
	else:
		reset_turret_and_barrel(delta)





func reset_turret_and_barrel(delta):
	turret.rotation_degrees.y = lerp(turret.rotation_degrees.y, 0.0, rotation_speed * delta)
	barrel.rotation_degrees.x = lerp(barrel.rotation_degrees.x, 0.0, rotation_speed * delta)





func shoot_projectile():
	if current_weapon_settings:
		var angle_step = 360.0 / current_weapon_settings.projectile_count
		for i in range(current_weapon_settings.projectile_count):
			var angle = deg_to_rad(current_weapon_settings.projectile_start_angle + i * angle_step)
			var direction = barrel.global_transform.basis.z.normalized()
			var right = barrel.global_transform.basis.x.normalized()
			var up = barrel.global_transform.basis.y.normalized()
			var offset = (right * cos(angle) + up * sin(angle)) * current_weapon_settings.projectile_spacing
			var projectile_scene = current_weapon_settings.projectile_prefab
			var projectile_instance = projectile_scene.instantiate()
			if projectile_instance:
				shoot_timer = current_weapon_settings.cool_down
				var spawn_transform = barrel.global_transform
				spawn_transform.origin += direction * -0.5 + offset
				projectile_instance.global_transform = spawn_transform
				var initial_velocity = direction * current_weapon_settings.projectile_speed
				projectile_instance.linear_velocity = initial_velocity
				get_tree().root.add_child(projectile_instance)
				get_parent().apply_central_impulse(current_weapon_settings.projectile_recoil * direction)
				Utilities.set_allegiance(projectile_instance, "Projectile_Enemy")
				play_launch_sound()





func play_launch_sound() -> void:
	pass
