extends RigidBody3D

# ====================================
# Mark III Directed Energy Weapon
# ====================================

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var damage: int = 55
@export var projectileVelocity: float = 200.0
@export var cooldown: float = 0.55
@export var launch_sound: AudioStream

var has_started_moving: bool = false
var initial_position: Vector3
var initial_speed: float
var initial_direction: Vector3
var collision_info = {
	"position": Vector3(),
	"normal": Vector3()
}

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(_delta: float):
	if not has_started_moving and linear_velocity.length_squared() > 0.01:
		initial_position = global_transform.origin
		initial_speed = linear_velocity.length()
		initial_direction = linear_velocity.normalized()
		has_started_moving = true
		linear_velocity = initial_direction.normalized() * projectileVelocity

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state.get_contact_count() > 0:
		collision_info["position"] = state.get_contact_local_position(0)
		collision_info["normal"] = state.get_contact_local_normal(0)
		
func _on_body_entered(body: Node):
	if body != self:
		#var coll_layer = body.collision_layer
		var collision_position = collision_info["position"]
		#var collision_normal = collision_info["normal"]
		
		
		_create_explosion(collision_position)
		_apply_damage(body)
		queue_free()

func _create_explosion(collision_position: Vector3):
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		if get_parent():
			get_parent().add_child(explosion_instance)
			explosion_instance.global_transform.origin = collision_position

func _apply_damage(body: Node):
	var health_node = body.get_child(0)
	if health_node and health_node.has_method("apply_damage"):
		health_node.apply_damage(damage)

func get_cooldown() -> float:
	return cooldown

func get_projectile_speed() -> float:
	return projectileVelocity

func get_launch_sound() -> AudioStream:
	return launch_sound
