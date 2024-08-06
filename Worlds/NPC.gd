extends Node

# Path to your NPC scene
@export var npc_scene: PackedScene
@export var npc_count: int = 75
@export var padding: float = 5.0
@export var height: float = 5.0

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
			randf_range(min_x, max_x), height, randf_range(min_z, max_z)
		)
		place_npc(random_position)

func place_npc(position: Vector3):
	var npc_instance = npc_scene.instantiate()
	
	# Set the NPC position
	npc_instance.transform.origin = position
	
	# Generate a random Y rotation in radians
	var random_rotation_y = randf_range(0, TAU) # TAU is equivalent to 2 * PI
	
	# Apply the random Y rotation
	npc_instance.rotate_y(random_rotation_y)
	
	# Add the NPC instance as a child
	add_child(npc_instance)
