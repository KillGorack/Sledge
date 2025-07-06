extends RigidBody3D

@export var force: float = 400.0
@export var max_speed: float = 6.0
@export var turn_rate: float = 75.0
@export var turn_duration: float = 0.1
@export var left_raycast: RayCast3D
@export var right_raycast: RayCast3D
@export var ground_raycast: RayCast3D
@export var marker_raycast: RayCast3D
@export var physics_material: PhysicsMaterial
@export var detection_range: float = 20.0
@export var damage_multiplier: float = 0.5

@onready var turret_node = $Turret

var freezeBit: bool = false
var is_grounded: bool = false
var stop_forces = false
var original_friction: float = 1.0
var object: Node3D = null
var player: RigidBody3D
var markers: Array[StaticBody3D] = []
var last_markers: Array[StaticBody3D] = []
var target_marker: StaticBody3D = null
var last_position: Vector3
var stuck_timer: Timer
var should_correct_transform: bool = false
var corrected_transform: Transform3D
var player_distance: float = 0.0
var visible_markers: Array[StaticBody3D] = []
var marker_refresh_timer = 0.0

func _ready() -> void:
	_find_player()
	_find_markers()
	player = get_tree().get_first_node_in_group("Player")
	if physics_material:
		original_friction = physics_material.friction
	var distance_check_timer = Timer.new()
	distance_check_timer.wait_time = 1.0
	distance_check_timer.autostart = true
	distance_check_timer.connect("timeout", Callable(self, "_update_player_distance"))
	add_child(distance_check_timer)
	stuck_timer = Timer.new()
	stuck_timer.wait_time = 15.0 
	stuck_timer.autostart = true
	stuck_timer.connect("timeout", Callable(self, "_check_if_stuck"))
	add_child(stuck_timer)
	if turret_node and turret_node.has_method("set_target"):
		turret_node.set_target(null)





func _physics_process(delta: float) -> void:
	if should_correct_transform:
		global_transform = corrected_transform
		should_correct_transform = false
	is_grounded = ground_raycast and ground_raycast.is_colliding()
	if is_grounded && not stop_forces:
		if player_distance < detection_range and can_see_object(player):
			turn_towards_object(delta, player)
			forward_movement(delta)
			turret_node.set_target(player)
		else:
			if target_marker == null or global_transform.origin.distance_to(target_marker.global_transform.origin) < 3.0:
				target_marker = choose_marker()
			if target_marker != null:
				turn_towards_object(delta, target_marker)
				forward_movement(delta)
				turret_node.set_target(null)
	else:
		_set_friction(0)
	last_position = global_transform.origin
	marker_refresh_timer -= delta




func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	pass




func _check_if_stuck() -> void:
	if global_transform.origin.distance_to(last_position) < 0.1:
		target_marker = choose_marker()
	var up_vector = global_transform.basis.y
	if up_vector.dot(Vector3.UP) < 0.9:
		corrected_transform = global_transform
		corrected_transform.origin.y += 2.0
		corrected_transform.basis = Basis()
		should_correct_transform = true








func _update_player_distance() -> void:
	if player != null and is_instance_valid(player):
		player_distance = global_transform.origin.distance_to(player.global_transform.origin)
		



func _update_target() -> void:
	if player_distance < detection_range and can_see_object(player):
		target_marker = null
	else:
		if target_marker == null or global_transform.origin.distance_to(target_marker.global_transform.origin) < 1.0:
			target_marker = choose_marker()





func forward_movement(_delta: float) -> void:
	if freezeBit:
		return
	var forward_force = transform.basis.z * -force
	apply_central_force(forward_force)
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed





func turn_towards_object(delta: float, target: Node) -> void:
	if freezeBit:
		return
	var direction_to_object = (target.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = atan2(-direction_to_object.x, -direction_to_object.z)
	var current_rotation = rotation.y
	var new_rotation = lerp_angle(current_rotation, target_rotation, turn_rate * delta)
	rotation.y = new_rotation





func _set_friction(value: float) -> void:
	if physics_material:
		physics_material.friction = value





func apply_damage(damage: float) -> void:
	get_node("Health").apply_direct_damage(damage)





func setFreezeState(bit: bool) -> void:
	sleeping = bit
	freeze = bit
	freezeBit = bit
	if not bit:
		var freeze_timer = get_node_or_null("FreezeTimer")
		if freeze_timer:
			freeze_timer.queue_free()





func apply_directional_force(impulse: Vector3) -> void:
	stop_forces = true
	apply_central_impulse(impulse)
	await get_tree().create_timer(1.0).timeout
	stop_forces = false
	




func _find_player() -> void:
	var found_player = get_tree().get_first_node_in_group("Player")
	if found_player and is_instance_valid(found_player):
		player = found_player





func _find_markers() -> void:
	var found_markers = get_tree().get_nodes_in_group("Markers")
	for node in found_markers:
		if node is StaticBody3D:
			markers.append(node)





func can_see_object(target: Node3D) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	marker_raycast.global_transform.origin = global_transform.origin  
	marker_raycast.look_at(target.global_transform.origin, Vector3.UP)
	marker_raycast.force_raycast_update()
	var result = marker_raycast.is_colliding() and marker_raycast.get_collider() == target
	return result






func choose_marker() -> StaticBody3D:
	if marker_refresh_timer <= 0:
		visible_markers = []
		for marker in markers:
			if can_see_object(marker):
				visible_markers.append(marker)
		marker_refresh_timer = 1.5
	if visible_markers.is_empty():
		return null
	var unvisited_markers: Array[StaticBody3D] = []
	for marker in visible_markers:
		if not last_markers.has(marker):
			unvisited_markers.append(marker)
	var selected_marker: StaticBody3D
	if not unvisited_markers.is_empty():
		selected_marker = weighted_random_marker(unvisited_markers)
	else:
		selected_marker = weighted_random_marker(visible_markers)
	last_markers.append(selected_marker)
	if last_markers.size() > 5:
		last_markers.remove_at(0)
	return selected_marker
	


func weighted_random_marker(marker_list: Array[StaticBody3D]) -> StaticBody3D:
	var best_marker = marker_list[0]
	var best_score = -INF
	for marker in marker_list:
		var distance = global_transform.origin.distance_to(marker.global_transform.origin)
		var forward_factor = global_transform.basis.z.dot((marker.global_transform.origin - global_transform.origin).normalized())
		var score = (1.0 / (distance + 0.1)) + (forward_factor * 0.5)  # Weighted score
		if score > best_score:
			best_marker = marker
			best_score = score
	return best_marker
