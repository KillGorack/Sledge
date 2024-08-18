extends Node

@export var npc_scene: PackedScene
@export var npc_count: int = 75
@export var padding: float = 5.0
@export var height: float = 5.0
@export var world_min_x: float = -100.0
@export var world_max_x: float = 100.0
@export var world_min_z: float = -100.0
@export var world_max_z: float = 100.0

func _ready():
	var min_x = world_min_x + padding
	var max_x = world_max_x - padding
	var min_z = world_min_z + padding
	var max_z = world_max_z - padding
	for i in range(npc_count):
		var random_position = Vector3(
			randf_range(min_x, max_x), height, randf_range(min_z, max_z)
		)
		place_npc(random_position)

func place_npc(position: Vector3):
	var npc_instance = npc_scene.instantiate()
	npc_instance.transform.origin = position
	var random_rotation_y = randf_range(0, TAU)
	npc_instance.rotate_y(random_rotation_y)
	add_child(npc_instance)
