extends RigidBody3D

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var sound: AudioStream
@export var impulse_strength: float = 10.0
@export var explosion_radius: float = 5.0
@export var force_curve: Curve

var initial_position: Vector3
var has_started_moving: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float):
	if not has_started_moving and linear_velocity.length_squared() > 0.01:
		initial_position = global_transform.origin
		has_started_moving = true

func _on_body_entered(body: Node):
	if body != self:
		raycast.enabled = true
		if raycast.is_colliding():
			#_apply_impulse(body)
			_create_explosion()
			_apply_explosive_force()
		queue_free()

func _apply_impulse(body: Node):
	if body is RigidBody3D:
		var force_direction = initial_position.direction_to(global_transform.origin)
		var impulse = force_direction * impulse_strength
		body.apply_central_impulse(impulse)
		body.angular_velocity = Vector3.ZERO

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
	var result = space_state.intersect_shape(query, 1000)
	for item in result:
		var body = item.collider
		if body is RigidBody3D and body != self:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			var normalized_distance = distance / explosion_radius
			var force_magnitude = impulse_strength
			if force_curve:
				force_magnitude *= force_curve.sample(normalized_distance)
			var force_direction = (body.global_transform.origin - global_transform.origin).normalized()
			body.apply_central_impulse(force_direction * force_magnitude)
