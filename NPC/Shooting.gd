extends Node3D

@export var turret: MeshInstance3D
@export var barrel: MeshInstance3D

var player: Node3D

var rotation_speed: float = 5

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	else:
		print("No player found in the 'player' group.")
		
func _physics_process(delta):
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if distance_to_player <= 5:
		var turret_target_rotation = turret.global_transform.looking_at(player.global_transform.origin, Vector3.UP).basis
		turret.global_transform.basis = turret.global_transform.basis.slerp(turret_target_rotation, rotation_speed * delta)
		turret.rotation.x = 0
		turret.rotation.z = 0
		
		var barrel_target_rotation = barrel.global_transform.looking_at(player.global_transform.origin, Vector3.UP).basis
		barrel.global_transform.basis = barrel.global_transform.basis.slerp(barrel_target_rotation, rotation_speed * delta)
		barrel.rotation.y = 0
		barrel.rotation.z = 0
		
	elif distance_to_player > 5:
		turret.rotation_degrees.y = 0
		barrel.rotation_degrees.x = 0

