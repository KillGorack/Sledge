extends RigidBody3D

var collided_object: Object
var collision_point: Vector3
var collision_normal: Vector3
var weapon_settings: Resource
var damage_one_off: bool = false
var aoe_damage_one_off: bool = false
var current_direction: Vector3
var RicochetCount: int = 0
var bullet_hole_one_off: bool = false
var hit_scene_one_off: bool = false
var collided_layer: int = -1
var ignored_objects: Array = []
var guidedTarget: Node = null
var targeted_group: bool = false
var result = []
var current_allegiance: String = ""
var distance_traveled: float = 0.0
var max_distance: float

@onready var raycast: RayCast3D = $RayCast3D


func _ready():
	

	
	if self.is_in_group("Projectile_Friendly"):
		weapon_settings = UserData.UserSettings[UserData.current_weapon]
		var groups = get_groups()
		if not groups.is_empty():
			current_allegiance = groups[0]
	else:
		weapon_settings = UserData.settingsNPCCurrent
		current_allegiance = "Projectile_Enemy"

	max_distance = weapon_settings.projectile_range
	current_direction = -global_transform.basis.z.normalized()
	
	

	
	
	
func _physics_process(delta: float) -> void:
	var distance_this_frame = linear_velocity.length() * delta
	distance_traveled += distance_this_frame
	linear_velocity = current_direction * weapon_settings.projectile_speed
	if distance_traveled >= max_distance:
		destroy_self()
	if weapon_settings.targeting_system == true:
		if guidedTarget == null:
			var scope = "Friendly_Fire" if weapon_settings.friendly_fire else current_allegiance
			guidedTarget = Utilities.select_target(
				global_transform.origin,
				-global_transform.basis.z,
				weapon_settings.target_system_scan_radius, 
				15, 
				Utilities.GROUP_LAYER_SCOPE[scope]["target_groups"],
				weapon_settings.targeting_system_require_marker
				)
		handleGuided(delta)
		
		

func _integrate_forces(state):
	
	if state.get_contact_count() == 0:
		return

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider:
			for target_group in Utilities.GROUP_LAYER_SCOPE[current_allegiance]["target_groups"]:
				if collider.is_in_group(target_group):
					targeted_group = true
					break
			collided_object = collider
			collided_layer = collider.collision_layer  # Assign detected collision layer
			
			# Get collision point & normal
			collision_point = state.get_contact_local_position(i)
			collision_normal = state.get_contact_local_normal(i)

			# Fallback to raycast if needed
			if collision_point == Vector3.ZERO:
				use_raycast_fallback()

			# Handle the collision
			handleCollision()
			break


func use_raycast_fallback():
	if raycast:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			collision_point = raycast.get_collision_point()
			collision_normal = raycast.get_collision_normal()







func handleCollision():
	
	var destroy = true
	targeted_group = true if weapon_settings.friendly_fire else targeted_group
	var scope = "Friendly_Fire" if weapon_settings.friendly_fire else current_allegiance
	if (weapon_settings.explosive_force > 0 and weapon_settings.explosive_force_distance > 0) or weapon_settings.unfreeze == true or weapon_settings.bounce_count > 0:
		
		var dist = weapon_settings.explosive_force_distance if weapon_settings.explosive_force_distance > 0 else weapon_settings.target_system_scan_radius
		result = Utilities.collect_bodies(
			get_world_3d().direct_space_state, 
			global_transform.origin, 
			weapon_settings.body_collection_max, 
			dist, 
			Utilities.GROUP_LAYER_SCOPE[scope]["target_groups"])
			
		if weapon_settings.explosive_force > 0 and weapon_settings.explosive_force_distance > 0:
			applyExplosiveForces(result)
			
			if weapon_settings.hit_points > 0:
				applyAOEDamage(result)
			
		if weapon_settings.unfreeze == true:
			unfreeze_targets(result)

	if targeted_group:
		
		if weapon_settings.freeze_timer > 0:
			freeze_target()
				
		if weapon_settings.hit_points > 0 && weapon_settings.weapon_type != 3:
			applyDirectDamage(weapon_settings.hit_points)
			
		if weapon_settings.projectile_force > 0:
			applyForce(weapon_settings.projectile_force)
			
		if weapon_settings.projectile_pierce_count > 0:
			destroy = handlePierce()

		
	if weapon_settings.bounce_count > 0:
		destroy = handleBounce(result)
		
	if weapon_settings.projectile_ricochet_count > 0:
		destroy = handleRicochet()
	
	if len(weapon_settings.turncoat) > 0:
		change_allegiance()

	setHitScene()
	create_bullet_hole()
	
	if destroy == true:
		destroy_self()














func change_allegiance():
	pass
		
		
		
		
		

func unfreeze_targets(body_result):
	if weapon_settings.body_collection_max > 0 and weapon_settings.explosive_force_distance > 0:
		for item in body_result:
			var body = item.collider
			if body and is_instance_valid(body):
				if body != self:
					if body.has_method("setFreezeState"):
						body.call("setFreezeState", false)





func freeze_target():
	if collided_object and collided_object.has_method("setFreezeState"):
		var existing_timer = collided_object.get_node_or_null("FreezeTimer")
		if existing_timer:
			existing_timer.wait_time += weapon_settings.freeze_timer
			if not existing_timer.is_stopped():
				existing_timer.start()
		else:
			var timer = Timer.new()
			timer.name = "FreezeTimer"
			timer.wait_time = weapon_settings.freeze_timer
			timer.one_shot = true
			collided_object.add_child(timer)
			timer.timeout.connect(Callable(collided_object, "setFreezeState").bind(false))
			collided_object.call("setFreezeState", true)
			timer.start()





func applyDirectDamage(damage: float, target = null) -> void:
	if not damage_one_off:
		var stdev = damage * (0.2 / 6)
		var varied_damage = damage + randfn(0, stdev)
		varied_damage = clamp(varied_damage, damage - (3 * stdev), damage + (3 * stdev))
		if randf() < weapon_settings.crit_chance:
			varied_damage *= weapon_settings.crit_multiplier
			setCriticalDecal()
			playCritSound()
			Utilities.addMessage("Critical damage dealt!!")
		var parental_object = target if target != null else collided_object
		if parental_object.has_method("apply_damage"):
			parental_object.apply_damage(varied_damage)
		damage_one_off = true






func applyAOEDamage(bodies):
	if aoe_damage_one_off == false:
		for item in bodies:
			var body = item.collider
			if body != self:
				var distance = global_transform.origin.distance_to(body.global_transform.origin)
				if distance < weapon_settings.explosive_force_distance:
					var damage = weapon_settings.hit_points * (1.0 - (distance / weapon_settings.explosive_force_distance))
					var stdev = damage * (0.2 / 6)
					var varied_damage = damage + randfn(0, stdev)
					varied_damage = clamp(varied_damage, damage - (3 * stdev), damage + (3 * stdev))
					if randf() < weapon_settings.crit_chance:
						varied_damage *= weapon_settings.crit_multiplier
						setCriticalDecal()
						playCritSound()
						Utilities.addMessage("Critical damage dealt!!")
					if body.has_method("apply_damage"):
						body.apply_damage(varied_damage)
		aoe_damage_one_off = true





func applyForce(force: float, target: Object = null, direction: Vector3 = Vector3.ZERO):
	var force_target = target if target != null else collided_object
	var force_direction = direction if not direction.is_zero_approx() else current_direction.normalized()
	if Input.is_action_pressed("Reverso") and weapon_settings.bi_directional:
		force_direction = -force_direction
	if force_target != null and force_target:
		if force_target.has_method("apply_directional_force"):
			force_target.apply_directional_force(force * force_direction)





func applyExplosiveForces(body_result):
	for item in body_result:
		var body = item.collider
		if body != self and body is RigidBody3D:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			if distance < weapon_settings.explosive_force_distance:
				var force_strength = weapon_settings.explosive_force * (1.0 - (distance / weapon_settings.explosive_force_distance))
				var direction = (body.global_transform.origin - global_transform.origin).normalized()
				applyForce(force_strength, body, direction)





func handleRicochet():
	RicochetCount += 1
	if RicochetCount <= weapon_settings.projectile_ricochet_count:
		playHitSound()
		var reflect_direction = current_direction.bounce(collision_normal).normalized()
		current_direction = reflect_direction
		linear_velocity = reflect_direction * weapon_settings.projectile_speed
		global_transform.origin += collision_normal * 0.05
		angular_velocity = current_direction * weapon_settings.projectile_spin
		var adjusted_direction = reflect_direction
		if abs(reflect_direction.dot(Vector3.UP)) > 0.99:
			adjusted_direction += Vector3(0.001, 0, 0)
		look_at(global_transform.origin + adjusted_direction, Vector3.UP)
		hit_scene_one_off = false
		bullet_hole_one_off = false
		damage_one_off = false
		aoe_damage_one_off = false
		return false
	else:
		return true





func handlePierce() -> bool:
	if collided_layer == 2:
		return true
	if RicochetCount <= weapon_settings.projectile_pierce_count and collided_object not in ignored_objects:
		RicochetCount += 1
		ignored_objects.append(collided_object)
		global_transform.origin += current_direction.normalized() * 0.1
		look_at(global_transform.origin + current_direction, Vector3.UP)
		linear_velocity = current_direction.normalized() * weapon_settings.projectile_speed
		angular_velocity = Vector3.ZERO
		hit_scene_one_off = false
		bullet_hole_one_off = false
		damage_one_off = false
		aoe_damage_one_off = false
		return false
	else:
		return true






func handleBounce(bodies):
	if bodies.size() > 0 and RicochetCount <= weapon_settings.bounce_count:
		RicochetCount += 1 
		for item in bodies:
			var body = item.collider
			var direction = (body.global_transform.origin - global_transform.origin).normalized()
			linear_velocity = direction * weapon_settings.projectile_speed
			hit_scene_one_off = false
			bullet_hole_one_off = false
			damage_one_off = false
			aoe_damage_one_off = false
			return false
		return true
	else:
		return true





func playHitSound() -> void:
	if weapon_settings.hit_sound:
		Utilities.play_sound(weapon_settings.hit_sound, global_transform.origin, 0.1)





func playCritSound() -> void:
	if weapon_settings.crit_sound:
		Utilities.play_sound(weapon_settings.crit_sound, global_transform.origin, 10.0)





func handleGuided(delta):
	if not weapon_settings.targeting_system:
		return
	if guidedTarget and is_instance_valid(guidedTarget): 
		guide_to_target(delta)






func guide_to_target(delta: float):
	if guidedTarget and is_instance_valid(guidedTarget):
		var direction_to_target = (guidedTarget.global_transform.origin - global_transform.origin).normalized()
		var missile_forward = -global_transform.basis.z
		var rotation_axis = missile_forward.cross(direction_to_target)
		if rotation_axis.length() == 0:
			rotation_axis = Vector3.UP
		else:
			rotation_axis = rotation_axis.normalized()
		var rotation_delta = Quaternion(rotation_axis, missile_forward.angle_to(direction_to_target) * weapon_settings.target_rotation_speed * delta).normalized()
		global_transform.basis = (Basis(rotation_delta) * global_transform.basis).orthonormalized()
		linear_velocity = -global_transform.basis.z * weapon_settings.projectile_speed





func create_bullet_hole():
	if bullet_hole_one_off == false:
		if weapon_settings.bullet_hole_prefab and collided_layer == 2:
			var bullet_hole_instance = weapon_settings.bullet_hole_prefab.instantiate()
			if get_parent():
				get_parent().add_child(bullet_hole_instance)
				var offset_position = collision_point + collision_normal * 0.01
				bullet_hole_instance.global_transform.origin = offset_position
				var up_vector = Vector3.UP
				if collision_normal.dot(up_vector) > 0.999:
					up_vector = Vector3.RIGHT
				var direction = (offset_position + collision_normal) - offset_position
				if not direction.is_zero_approx() and not up_vector.cross(direction).is_zero_approx():
					bullet_hole_instance.look_at_from_position(offset_position, offset_position + collision_normal, up_vector)
		bullet_hole_one_off = true





func setCriticalDecal():
	if weapon_settings.critical_hit_prefab:
		var crit_instance = weapon_settings.critical_hit_prefab.instantiate()
		get_parent().add_child(crit_instance)
		crit_instance.transform = global_transform
	
	
	
	
	
func setHitScene():
	if hit_scene_one_off == false:
		playHitSound()
		if weapon_settings.explosion_prefab:
			var explosion_instance = weapon_settings.explosion_prefab.instantiate()
			get_parent().add_child(explosion_instance)
			explosion_instance.transform = global_transform
		hit_scene_one_off = true



func destroy_self():
	setHitScene()
	await get_tree().create_timer(weapon_settings.projectile_destruction_delay).timeout
	queue_free()
