extends Node

# Path to your NPC scene
@export var npc_scene: PackedScene
@export var npc_count: int = 75
@export var padding: float = 5.0

# Define the bounds of your world (example values)
@export var world_min_x: float = -100.0
@export var world_max_x: float = 100.0
@export var world_min_z: float = -100.0
@export var world_max_z: float = 100.0

func _ready():
	# Calculate the usable bounds considering padding
	var min_x = world_min_x + padding
	var max_x = world_max_x - padding
	var min_z = world_min_z + padding
	var max_z = world_max_z - padding
	
	# Place NPCs at random positions within the bounds
	for i in range(npc_count):
		var random_position = Vector3(
			randf_range(min_x, max_x), 20, randf_range(min_z, max_z)
		)
		place_npc(random_position)

func place_npc(position: Vector3):
	# Instance the NPC scene and set its position
	var npc_instance = npc_scene.instantiate()
	npc_instance.transform.origin = position
	add_child(npc_instance)
