extends RigidBody3D

# ====================================
# Detno Missile
# ====================================

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var bullet_hole_scene: PackedScene
@export var impulse_strength: float = 10.0
@export var explosion_radius: float = 5.0
@export var force_curve: Curve
@export var damage: int = 55
@export var projectileVelocity: float = 55.0
@export var cooldown: float = 1.0
@export var launch_sound: AudioStream

var initial_position: Vector3
var has_started_moving: bool = false
var initial_direction: Vector3

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(_delta: float):
	if not has_started_moving and linear_velocity.length_squared() > 0.01:
		initial_position = global_transform.origin
		initial_direction = linear_velocity.normalized()
		has_started_moving = true
		linear_velocity = initial_direction.normalized() * projectileVelocity

func _create_bullet_hole(decal_position: Vector3, normal: Vector3):
	if bullet_hole_scene:
		var bullet_hole_instance = bullet_hole_scene.instantiate()
		if get_parent():
			get_parent().add_child(bullet_hole_instance)
			bullet_hole_instance.global_transform.origin = decal_position
			var direction = decal_position + normal - bullet_hole_instance.global_transform.origin
			var up_vector = Vector3.UP
			if direction.is_zero_approx() or direction.cross(up_vector).is_zero_approx():
				up_vector = Vector3.RIGHT if up_vector.dot(Vector3.RIGHT) != 1.0 else Vector3.FORWARD
			bullet_hole_instance.look_at(decal_position + normal, up_vector)

			
func _on_body_entered(body: Node):
	if body != self:
		var coll_layer = body.collision_layer
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		if coll_layer == 2:
			_create_bullet_hole(collision_point, collision_normal)
		_create_explosion()
		_apply_explosive_force()
		queue_free()

func _create_explosion():
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		if get_parent():
			get_parent().add_child(explosion_instance)
			explosion_instance.global_transform.origin = global_transform.origin


func _apply_explosive_force():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.transform = Transform3D(Basis(), global_transform.origin)
	query.shape = SphereShape3D.new()
	query.shape.radius = explosion_radius
	var result = space_state.intersect_shape(query, 150)
	for item in result:
		var body = item.collider
		if body is RigidBody3D and body != self:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			var normalized_distance = distance / explosion_radius
			var force_magnitude = impulse_strength
			if force_curve:
				force_magnitude *= force_curve.sample(normalized_distance)
			var child_node = body.get_child(0)
			if child_node and child_node.has_method("apply_damage"):
				var scaled_damage = damage * force_curve.sample(normalized_distance)
				child_node.apply_damage(scaled_damage)
			var force_direction = (body.global_transform.origin - global_transform.origin).normalized()
			if body.has_method("apply_projectile_impulse"):
				body.call("apply_projectile_impulse", force_direction * force_magnitude, force_direction)



func get_cooldown() -> float:
	return cooldown

func get_projectile_speed() -> float:
	return projectileVelocity

func get_launch_sound() -> AudioStream:
	return launch_sound
	
func get_weapon_name() -> StringName:
	return StringName("Detno Missile")
