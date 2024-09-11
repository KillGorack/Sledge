extends RigidBody3D

# ====================================
# Repulsor Missile
# ====================================

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var bullet_hole_scene: PackedScene
@export var impulse_strength: float = 10.0
@export var BounceCount: int = 5
@export var BounceOffset: float = 0.25
@export var projectileVelocity: float = 25.0
@export var cooldown: float = 0.75
@export var launch_sound: AudioStream

var initial_position: Vector3
var has_started_moving: bool = false
var force_direction: Vector3
var initial_speed: float
var initial_direction: Vector3
var collision_info = {
	"position": Vector3(),
	"normal": Vector3()
}

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	initial_position = global_transform.origin
	initial_speed = linear_velocity.length()

func _physics_process(_delta: float):
	if Input.is_action_pressed("Reverso"):
		impulse_strength *= -1
	if not has_started_moving and linear_velocity.length_squared() > 0.01:
		initial_position = global_transform.origin
		initial_speed = linear_velocity.length()
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
			if direction.is_zero_approx() or decal_position.is_equal_approx(decal_position + normal):
				var arbitrary_up_vector = Vector3.UP
				bullet_hole_instance.global_transform.basis = Basis(Vector3.RIGHT, arbitrary_up_vector, Vector3.FORWARD)
			else:
				var up_vector = Vector3.UP
				if direction.is_zero_approx() or direction.cross(up_vector).is_zero_approx():
					up_vector = Vector3.RIGHT if up_vector.dot(Vector3.RIGHT) != 1.0 else Vector3.FORWARD
				bullet_hole_instance.look_at(decal_position + normal, up_vector)


		
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state.get_contact_count() > 0:
		collision_info["position"] = raycast.get_collision_point()
		collision_info["normal"] = raycast.get_collision_normal()
		
func _on_body_entered(body: Node):
	if body != self:
		var coll_layer = body.collision_layer
		var collision_position = collision_info["position"]
		var collision_normal = collision_info["normal"]
		if coll_layer == 2:
			_create_bullet_hole(collision_position, collision_normal)
		force_direction = initial_position.direction_to(collision_position)
		var reflection = -force_direction.reflect(collision_info["normal"])
		_create_explosion(collision_position)
		if BounceCount > 0 and coll_layer == 2:
			BounceCount -= 1
			global_transform.origin += reflection * BounceOffset
			linear_velocity = reflection * projectileVelocity
			var up_vector = Vector3.UP
			if reflection.is_zero_approx() or reflection.dot(up_vector) == 1.0 or reflection.dot(up_vector) == -1.0:
				up_vector = Vector3.RIGHT if up_vector.dot(Vector3.RIGHT) != 1.0 else Vector3.FORWARD
			global_transform = global_transform.looking_at(global_transform.origin + reflection, up_vector)
			initial_position = global_transform.origin
		else:
			_apply_impulse(body)
			queue_free()


func _apply_impulse(body: Node):
	if body is RigidBody3D:
		var impulse = force_direction * impulse_strength
		body.apply_central_impulse(impulse)
		if "stop_forces" in body:
			body.stop_forces = true
			body.apply_projectile_impulse(impulse, force_direction)

func _create_explosion(collision_position: Vector3):
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		if get_parent():
			get_parent().add_child(explosion_instance)
			explosion_instance.global_transform.origin = collision_position
			
func get_cooldown() -> float:
	return cooldown

func get_projectile_speed() -> float:
	return projectileVelocity

func get_launch_sound() -> AudioStream:
	return launch_sound

func get_weapon_name() -> StringName:
	return StringName("Repulsor Missile")
