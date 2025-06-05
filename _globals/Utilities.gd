extends Node

var audio_pool: Array = []
var user_modes: Array = ["Undecided", "logged in", "Local user"]
var user_mode_index: int = 0
var user_mode: String = user_modes[user_mode_index]
var game_modes: Array = ["Battle Mode", "Mine Mode", "Creative Mode"]
var game_mode_index: int = 0
var game_mode: String = game_modes[game_mode_index]
var user_space_access: bool = false

const CREATIVES_PATH = "res://Creatives/Settings/"
const MAX_PLAYERS = 100
const GROUP_LAYER_SCOPE = {
	"NPC_Friendly": {"layer": 3, "layer_mask": [1, 2, 5, 6, 7], "target_groups" : ["NPC_Enemy", "Projectile_Enemy"]},
	"NPC_Enemy": {"layer": 5, "layer_mask": [1, 2, 3, 4, 5,  7], "target_groups" : ["NPC_Friendly", "Projectile_Friendly"]},
	"Projectile_Friendly": {"layer": 4, "layer_mask": [2, 5, 6, 7], "target_groups" : ["NPC_Enemy", "Projectile_Enemy"]},
	"Projectile_Enemy": {"layer": 6, "layer_mask": [1, 2, 3, 4, 7], "target_groups" : ["Player", "NPC_Friendly", "Projectile_Friendly"]},
	"Mine_Friendly": {"layer": 4, "layer_mask": [2, 5, 6, 7], "target_groups" : ["NPC_Enemy", "Projectile_Enemy"]},
	"Mine_Enemy": {"layer": 6, "layer_mask": [1, 2, 3, 4, 7], "target_groups" : ["Player", "NPC_Friendly", "Projectile_Friendly"]},
	"Friendly_Fire": {"layer": 7, "layer_mask": [1, 2, 3, 4, 5, 6, 7], "target_groups" : ["Player", "NPC_Enemy", "Projectile_Enemy", "NPC_Friendly", "Projectile_Friendly"]},
	"Player": {"layer": 1, "layer_mask": [2, 3, 5, 6, 7], "target_groups" : ["NPC_Enemy", "Projectile_Enemy"]},
	"World": {"layer": 2, "layer_mask": [1, 3, 4, 5, 6, 7], "target_groups" : []}
}

var creative_resources = {}
var messages = []
var resource: float = 1
var npc_max_count: int = 70
var npc_spawn_rate: float = 20.0

signal messages_updated
signal update_icon(icon: Texture2D, add_icon: bool)
signal game_mode_changed(new_value)


static func get_keys() -> Array:
	return GROUP_LAYER_SCOPE.keys()




func _ready():
	randomize()
	for i in range(MAX_PLAYERS):
		var player = AudioStreamPlayer3D.new()
		player.name = "AudioStreamPlayer3D_{}".format([i])
		player.finished.connect(_on_audio_finished.bind(player))
		add_child(player)
		audio_pool.append(player)

	


func addMessage(message: String):
	if messages.size() >= 20:
		messages.pop_back()
	messages.insert(0, message)
	emit_signal("messages_updated")

	
	



func update_hud_icon(icon: Texture2D, addIcon: bool) -> void:
	emit_signal("update_icon", icon, addIcon)



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("game_mode"):
		Utilities.toggle_game_mode()






func update_game_mode_label():
	var player_nodes = get_tree().get_nodes_in_group("Player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		var hud = player.get_node("Hud_inGame")
		var lbl_game_mode = hud.get_node("lbl_game_mode")
		lbl_game_mode.text = game_modes[game_mode_index]
		addMessage("Game mode changed: " + game_modes[game_mode_index])





func reset_game_mode():
	game_mode_index = 0
	game_mode = game_modes[game_mode_index]
	update_game_mode_label()
	
	
	
	

func toggle_game_mode():
	game_mode_index += 1
	if game_mode_index > 2 or (game_mode_index == 2 and user_space_access == false):
		game_mode_index = 0
	game_mode = game_modes[game_mode_index]
	game_mode_changed.emit()
	update_game_mode_label()





func play_sound(audio_input: Variant, position: Vector3 = Vector3.ZERO, vol: float = 1.0):
	var stream = null
	if typeof(audio_input) == TYPE_STRING:
		stream = load(audio_input)
	elif audio_input is AudioStream:
		stream = audio_input
	else:
		return
	var player = get_free_player()
	if player:
		player.stream = stream
		player.global_transform.origin = position
		player.volume_db = linear_to_db(vol)
		player.play()






func get_free_player() -> AudioStreamPlayer3D:
	for player in audio_pool:
		if !player.is_playing():
			return player
	return null





func _on_audio_finished(player: AudioStreamPlayer3D):
	if player:
		player.stream = null





func GarbageCollection(node: Node, delay: float) -> void:
	if not node:
		return
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	node.add_child(timer)
	timer.connect("timeout", func():
		if is_instance_valid(node):
			node.queue_free()
		timer.queue_free()
	)
	timer.start()







func collect_bodies(space_state: PhysicsDirectSpaceState3D, origin: Vector3, n: int, dist: float, target_groups: Array) -> Array:
	var query = PhysicsShapeQueryParameters3D.new()
	query.transform = Transform3D(Basis(), origin)
	query.shape = SphereShape3D.new()
	query.shape.radius = dist
	var result = space_state.intersect_shape(query, n)
	var filtered_result = []
	for item in result:
		for group in target_groups:
			if item.collider.is_in_group(group):
				filtered_result.append(item)
				break
	return filtered_result





func select_target(origin: Vector3, forward_direction: Vector3, radius: float, max_angle: float, target_group: Array, targeting_system_require_marker: bool) -> Node:
	var target_beacons = get_tree().get_nodes_in_group("Target_Beacon")
	if target_beacons.size() > 0:
		return target_beacons[0]
	if not targeting_system_require_marker:
		var min_bound = origin - Vector3(radius, radius, radius)
		var max_bound = origin + Vector3(radius, radius, radius)
		var max_angle_rad = deg_to_rad(max_angle)
		var potential_targets = []
		for group in target_group:
			for body in get_tree().get_nodes_in_group(group):
				if not is_instance_valid(body):
					continue
				var pos = body.global_position
				if pos.x >= min_bound.x and pos.x <= max_bound.x and pos.y >= min_bound.y and pos.y <= max_bound.y and pos.z >= min_bound.z and pos.z <= max_bound.z:
					var to_target = (pos - origin).normalized()
					if abs(to_target.angle_to(forward_direction)) <= max_angle_rad:
						potential_targets.append(body)
		if potential_targets.size() > 0:
			return potential_targets[randi() % potential_targets.size()]
	return null





func getResourceLevel():
	return resource

func setResourceLevel(value: float):
	resource += value
	resource = clamp(resource, 0.0, 1.0)





func set_allegiance(body: Node3D, group_name: String):
	if body and GROUP_LAYER_SCOPE.has(group_name):
		var layer_data = GROUP_LAYER_SCOPE[group_name]
		
		# Set collision layer and mask for both RigidBody3D & Area3D
		var collision_flags = 1 << (layer_data["layer"] - 1)
		var mask_flags = 0
		for mask_layer in layer_data["layer_mask"]:
			mask_flags |= 1 << (mask_layer - 1)

		# Apply settings based on body type
		if body is RigidBody3D or body is Area3D:
			body.collision_layer = collision_flags
			body.collision_mask = mask_flags

		# Add body to the correct group
		body.add_to_group(group_name)
