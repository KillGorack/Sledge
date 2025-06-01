extends PanelContainer

@export var levelSettings: Array[Resource] = []
@export var _vehicle_main: PackedScene
@onready var optionLevels= $margin/hbox/lst_worlds
@onready var btn_load = $margin/hbox/btn_load_game
@onready var lbl_usrstats = $"../lbl_usrstats"

var current_level_settings: LevelSettings
var levelIndex: int = 0
var level_instance
var vehicle_instance

func _ready() -> void:
	current_level_settings = levelSettings[levelIndex]
	UserData.set_setting("Level", levelSettings[levelIndex].duplicate(true))
	btn_load.connect("pressed", Callable(self, "load_selected_level"))
	populate_level_dropdown()
	


func populate_level_dropdown():
	optionLevels.clear()
	for i in range(levelSettings.size()):
		var level = levelSettings[i]
		optionLevels.add_item(level.level_name)
		optionLevels.set_item_icon(i, level.level_image)


func load_selected_level():
	Utilities.resource = 1
	if optionLevels.get_selected_items().is_empty():
		return
	var selected_index = optionLevels.get_selected_items()[0]
	var selected_level = levelSettings[selected_index]
	UserData.set_setting("Level", levelSettings[selected_index].duplicate(true))
	level_instance = selected_level.level_scene.instantiate()
	get_tree().root.add_child(level_instance)
	var player_spawn = level_instance.find_child("Player_Spawn")
	if player_spawn:
		spawn_vehicle(player_spawn)
	var main_menu = get_parent()
	if main_menu:
		main_menu.visible = false

func spawn_vehicle(spawn_point: Node3D):
	vehicle_instance = _vehicle_main.instantiate()
	get_tree().root.add_child(vehicle_instance)
	vehicle_instance.global_transform = spawn_point.global_transform


func playerDestroyed():
		UserData.game_falls += 1
		UserData.calculate_level()
		if Utilities.user_mode_index == 1:
			UserDataApi.send_data_to_server()
		UserData.save_user_data()
		unload_current_world_and_craft()
		populate_user_info()
		get_parent().show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("main_menu"):
		UserData.calculate_level()
		if Utilities.user_mode_index == 1:
			UserDataApi.send_data_to_server()
		UserData.save_user_data()
		unload_current_world_and_craft()
		populate_user_info()
		get_parent().show()


func unload_current_world_and_craft() -> void:
	junkRemover()
	if level_instance:
		level_instance.queue_free()
		level_instance = null
	if vehicle_instance:
		vehicle_instance.queue_free()
		vehicle_instance = null
		
		
		
func junkRemover() -> void:
	for group_name in Utilities.GROUP_LAYER_SCOPE.keys():
		for node in get_tree().get_nodes_in_group(group_name):
			node.queue_free()
	for node in get_tree().get_nodes_in_group("Loot"):
		node.queue_free()


func populate_user_info() -> void:
	var _usrTxt = "%s, Level: %d\nScore: %d\nVanquishes: %d, Falls: %d" % [
		UserData.username,
		UserData.game_level,
		UserData.game_score,
		UserData.game_vanquishes,
		UserData.game_falls
	]
	lbl_usrstats.text = _usrTxt
