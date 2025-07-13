extends Node3D

@export var npc_scenes: Array[PackedScene] = [] # Array to hold multiple NPC scenes
@export var TimeInSeconds: float = 5.0
@export var MAX_NPC_COUNT: int = 70
@export var friendly_material: Material
@export var enemy_material: Material
@export var golden_material: Material
@export var player_near_distance: float = 25.0

var player_near: bool = false
var originalTime: float = TimeInSeconds
var set_defaults: bool = false
var set_boss: bool = true;

func _ready():
	var usr_lvl: int =  UserData.user_level
	originalTime = TimeInSeconds
	MAX_NPC_COUNT = Utilities.npc_max_count
	TimeInSeconds = Utilities.npc_spawn_rate

	var level_factor = float(usr_lvl) / 100.0
	level_factor = clamp(level_factor, 0.1, 1.0)
	var spawn_multiplier = lerp(10.0, 1.0, level_factor)
	TimeInSeconds *= spawn_multiplier
	originalTime = TimeInSeconds
	
	var npc_multiplier = lerp(0.1, 1.0, level_factor)
	MAX_NPC_COUNT = int(MAX_NPC_COUNT * npc_multiplier)

	


func get_material(allegiance):
	if allegiance == 0:
		return friendly_material
	return enemy_material

func _process(delta):
	if TimeInSeconds > 0:
		TimeInSeconds -= delta
	else:
		spawn_npc()
		TimeInSeconds = originalTime

func spawn_npc():
	if Utilities.game_mode_index != 2:
		if npc_scenes.is_empty():
			return
		if get_tree().get_nodes_in_group("NPC_Enemy").size() >= MAX_NPC_COUNT:
			return
		var random_index = randi() % npc_scenes.size()
		var npc_scene = npc_scenes[random_index]
		var npc_instance = npc_scene.instantiate()
		Utilities.set_allegiance(npc_instance, "NPC_Enemy")
		var root = get_tree().root
		root.add_child(npc_instance)
		npc_instance.global_transform = global_transform
		configure_npc(npc_instance)

		
		
func configure_npc(npc_instance):
	var boss_mode = randi_range(1, 20)
	var npc_material = enemy_material
	set_boss = false;
	if boss_mode == 1:
		npc_material = golden_material
		set_boss = true;
	if npc_instance.has_node("Turret"):
		var turret_node = npc_instance.get_node("Turret")
		turret_node.material_override = npc_material
	if npc_instance.has_node("Body"):
		var body_node = npc_instance.get_node("Body")
		if body_node.has_node("Hull"):
			var hull_node = body_node.get_node("Hull")
			hull_node.material_override = npc_material
	var health_node = npc_instance.get_node("Health")
	if health_node:
		health_node.call("setBossMode", set_boss)
	npc_instance.add_to_group("NPC_Enemy") 
