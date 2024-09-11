extends Node3D

@export var turret: MeshInstance3D
@export var barrel: MeshInstance3D
@export var projectile_scene: PackedScene
@export var shoot_cooldown: float = 1.0  # Cooldown time in seconds

var player: Node3D
var shoot_cast: RayCast3D
var rotation_speed: float = 5
var reset_interval: float = 5.0
var reset_timer: float = 0.0
var last_shot_time: float = 0.0

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	else:
		print("No player found in the 'player' group.")

	shoot_cast = barrel.get_node("ShootCast") if barrel.has_node("ShootCast") else null
	if shoot_cast == null:
		print("ShootCast node not found under barrel!")

func _physics_process(delta):
	reset_timer -= delta
	last_shot_time -= delta
	
	if reset_timer <= 0:
		reset_turret_and_barrel(delta)
		reset_timer = reset_interval

	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if distance_to_player <= 10:
		var turret_target_rotation = turret.global_transform.looking_at(player.global_transform.origin, Vector3.UP).basis
		turret.global_transform.basis = turret.global_transform.basis.slerp(turret_target_rotation, rotation_speed * delta)
		turret.rotation.x = 0
		turret.rotation.z = 0
		
		var barrel_target_rotation = barrel.global_transform.looking_at(player.global_transform.origin, Vector3.UP).basis
		barrel.global_transform.basis = barrel.global_transform.basis.slerp(barrel_target_rotation, rotation_speed * delta)
		barrel.rotation.y = 0
		barrel.rotation.z = 0

		if shoot_cast and shoot_cast.is_colliding():
			var collider = shoot_cast.get_collider()
			if collider and collider.collision_layer == 1:
				if last_shot_time <= 0:
					shoot_projectile()
					last_shot_time = shoot_cooldown
	else:
		reset_turret_and_barrel(delta)

func reset_turret_and_barrel(delta):
	turret.rotation_degrees.y = lerp(turret.rotation_degrees.y, 0.0, rotation_speed * delta)
	barrel.rotation_degrees.x = lerp(barrel.rotation_degrees.x, 0.0, rotation_speed * delta)

func shoot_projectile():
	var projectile_instance = projectile_scene.instantiate()
	get_tree().root.add_child(projectile_instance)

	# Set the position and rotation
	projectile_instance.global_transform.origin = barrel.global_transform.origin
	projectile_instance.global_transform.basis = barrel.global_transform.basis

	# Calculate direction based on the barrel's forward direction
	var direction = -barrel.global_transform.basis.z.normalized()  # -Z is forward
	
	# Set velocity if the projectile instance has the method
	if projectile_instance.has_method("get_projectile_speed"):
		projectile_instance.linear_velocity = direction * projectile_instance.get_projectile_speed()
	else:
		print("Projectile instance does not have 'get_projectile_speed' method.")
