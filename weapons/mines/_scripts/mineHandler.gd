extends Area3D

var mine_settings: MineSettings
var activation_timer: Timer
var life_span: float = 1
var implosion_factor = 5

func _ready() -> void:
	activation_timer = Timer.new()
	activation_timer.set_wait_time(0.2)
	activation_timer.connect("timeout", Callable(self, "_on_activation_timer_timeout"))
	add_child(activation_timer)
	activation_timer.start()

func _process(delta: float) -> void:
	life_span -= delta
	if life_span <= 0:
		destroy_self()
	if Input.is_action_just_pressed("activate_mine") and mine_settings.triggerable == true:
		_activate_mine()

func set_settings(settings: MineSettings, _allegiance: String):
	mine_settings = settings
	life_span = mine_settings.life_span
	Utilities.set_allegiance(self, "Projectile_Friendly")

func get_settings():
	return mine_settings

func _on_activation_timer_timeout(): 
	_check_for_targets()





func _check_for_targets():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		for group in Utilities.GROUP_LAYER_SCOPE["Projectile_Friendly"]["target_groups"]:
			if body.is_in_group(group):
				if global_transform.origin.distance_to(body.global_transform.origin) <= mine_settings.activation_range:
					_activate_mine()
					return

func _activate_mine():
	var destroy = true
	
	var scope = "Friendly_Fire" if mine_settings.friendly_fire else "Projectile_Friendly"
	var result = Utilities.collect_bodies(
		get_world_3d().direct_space_state, 
		global_transform.origin, 
		420, 
		mine_settings.explosive_force_distance, 
		Utilities.GROUP_LAYER_SCOPE[scope]["target_groups"])

	
	if mine_settings.explosive_force > 0:
		applyAOEDamage(result)
		applyExplosiveForces(result)
		
	if mine_settings.unfreeze:
		freezeObjectsState(result, false)
		mine_settings.explosive_force = implosion_factor * (mine_settings.explosive_force)
		applyExplosiveForces(result)
		await get_tree().create_timer(0.3).timeout
		mine_settings.explosive_force = (mine_settings.explosive_force) / implosion_factor
		applyExplosiveForces(result)
		await get_tree().create_timer(1.0).timeout
		freezeObjectsState(result, true)
		
	if mine_settings.freeze_timer > 0:
		applyFreeze(result)
		
	if destroy == true:
		destroy_self()





func freezeObjectsState(result, freezebit):
	for item in result:
		var body = item.collider
		if body and is_instance_valid(body):
			if body != self:
				if body.has_method("setFreezeState"):
					body.call("setFreezeState", freezebit)





func applyDirectDamage(damage, target = null) -> void:
	if target.has_node("Health"):
		var healthObject = target.get_node("Health")
		if healthObject.has_method("apply_direct_damage"):
			healthObject.apply_direct_damage(damage)





func applyAOEDamage(result):
	for item in result:
		var body = item.collider
		if body != self:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			if distance < mine_settings.explosive_force_distance:
				var damage = mine_settings.hit_points * (1.0 - (distance / mine_settings.explosive_force_distance))
				applyDirectDamage(damage, body)





func applyForce(force: float, target: Object = null, direction: Vector3 = Vector3.ZERO):
	var force_direction = direction
	force_direction = force_direction
	if target != null and target.has_method("apply_directional_force"):
		target.apply_directional_force(force * force_direction)





func applyExplosiveForces(result):
	for item in result:
		var body = item.collider
		if body and is_instance_valid(body):
			if body != self and body is RigidBody3D:
				var distance = global_transform.origin.distance_to(body.global_transform.origin)
				if distance < mine_settings.explosive_force_distance:
					var force_strength = mine_settings.explosive_force * (1.0 - (distance / mine_settings.explosive_force_distance))
					var direction = (body.global_transform.origin - global_transform.origin).normalized()
					applyForce(force_strength, body, direction)



func applyFreeze(result):
	for item in result:
		var body = item.collider
		if body:
			if body != self and body is RigidBody3D:
				if body != null and body.has_method("setTempFreese"):
					body.setTempFreese(mine_settings.freeze_timer)



	
func setHitScene():
	if mine_settings.explosion_prefab:
		var explosion_instance = mine_settings.explosion_prefab.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.transform = global_transform
		
		
		
		
func create_crater():
	if mine_settings.crater_prefab:
		var crater_instance = mine_settings.crater_prefab.instantiate()
		if get_parent():
			get_parent().add_child(crater_instance)
			var mine_origin = global_transform.origin
			var mine_normal = global_transform.basis.y
			var offset_position = mine_origin + mine_normal * 0.01
			crater_instance.global_transform.origin = offset_position
			var up_vector = Vector3.UP
			if mine_normal.dot(up_vector) > 0.999:
				up_vector = Vector3.RIGHT
			var direction = mine_normal
			if not direction.is_zero_approx() and not up_vector.cross(direction).is_zero_approx():
				crater_instance.look_at_from_position(offset_position, offset_position + direction, up_vector)



func destroy_self():
	create_crater()
	setHitScene()
	queue_free()
