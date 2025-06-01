extends Node3D

@export var level_settings: LevelSettings  # Reference the level settings
@export var npc_scenes: Array[PackedScene] = []  # Load NPC scenes dynamically

@export var enemy_material: Material
@export var golden_material: Material
@export var friendly_material: Material

var time_counter: float = 0.0
var spawned_npcs: Array = []
var spawn_points: Array = [] 

func _ready():
	spawn_points = get_tree().get_nodes_in_group("Spawner")
	print("Found ", spawn_points.size(), " spawners in scene")
	if level_settings:
		npc_scenes = level_settings.npc_scenes
		var spawn_timer = Timer.new()
		spawn_timer.wait_time = level_settings.npc_spawn_rate
		spawn_timer.autostart = true
		spawn_timer.connect("timeout", Callable(self, "spawn_npc"))
		add_child(spawn_timer)


func spawn_npc():
	if spawned_npcs.size() >= level_settings.max_npc or spawn_points.is_empty() or npc_scenes.is_empty():
		return
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var random_index = randi() % npc_scenes.size()
	var npc_scene = npc_scenes[random_index]
	var npc_instance = npc_scene.instantiate()
	Utilities.set_allegiance(npc_instance, "NPC_Enemy")
	npc_instance.global_transform = spawn_point.global_transform
	add_child(npc_instance)
	spawned_npcs.append(npc_instance)
	configure_npc(npc_instance)

func configure_npc(npc_instance):
	var boss_mode = randi() % 20 == 0
	var npc_material = level_settings.enemy_material
	var set_boss = boss_mode == 1
	if set_boss:
		npc_material = level_settings.golden_material
	if npc_instance.has_node("Turret"):
		npc_instance.get_node("Turret").material_override = npc_material
	if npc_instance.has_node("Body"):
		var body_node = npc_instance.get_node("Body")
		if body_node.has_node("Hull"):
			body_node.get_node("Hull").material_override = npc_material
	var health_node = npc_instance.get_node("Health")
	if health_node:
		health_node.call("setBossMode", set_boss)
	npc_instance.add_to_group("NPC_Enemy")
