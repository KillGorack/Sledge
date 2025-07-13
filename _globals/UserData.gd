extends Node

var emit_id: int
var user_id: int
var username: String
var email: String
var enabled: bool
var user_key: String
var freshness: String
var user_level: int
var phone: String
var game_score: int
var game_falls: int
var game_vanquishes: int
var game_level: int
var access: String
var level_progress: float
var file_path: String = ""

# New variables for local/online mode management
var is_online_mode: bool = false
var local_username: String = "LocalPlayer"
var last_sync_timestamp: int = 0
var has_unsaved_changes: bool = false

var UserSettings = {
	"primaryWeapon" : null,
	"secondaryWeapon" : null,
	"Mines" : null,
	"Craft" : null,
	"Level" : null,
	"specials" : []
}
var UserSettingsStellar = {
	"primaryWeapon" : null,
	"secondaryWeapon" : null,
	"Mines" : null,
	"Craft" : null,
	"Level" : null,
	"specials" : []
}
var settingsNPC = [
	load("res://weapons/Weapons/settings/NPC/NPC_Concussion.tres"),
	load("res://weapons/Weapons/settings/NPC/NPC_Detno.tres"),
	load("res://weapons/Weapons/settings/NPC/NPC_Laser Epoc II.tres")
]
var settingsNPCCurrent: WeaponSettings = settingsNPC[0]

var current_weapon: String = "primaryWeapon"
const MAX_LEVEL: int = 100
const MAX_VANQUISHES: int = 100000
const USER_DATA_FILE: String = "user_data.json"
const USER_LOADOUT_FILE: String = "user_loadout.json"

signal data_updated(category: String)

func _ready():
	file_path = get_user_data_file_path()
	if FileAccess.file_exists(file_path):
		load_user_data()
	else:
		# Initialize with default local user data
		initialize_local_user()
		save_user_data()

func initialize_local_user():
	"""Initialize a local user with default values"""
	user_id = 0  # Local users have ID 0
	username = local_username
	email = ""
	enabled = true
	user_key = ""
	freshness = ""
	user_level = 1
	phone = ""
	game_score = 0
	game_falls = 0
	game_vanquishes = 0
	game_level = 1
	access = "local"
	level_progress = 0.0
	is_online_mode = false
	last_sync_timestamp = int(Time.get_unix_time_from_system())

func switch_to_online_mode(online_data: Dictionary):
	"""Switch from local to online mode, potentially merging data"""
	var local_score = game_score
	var local_vanquishes = game_vanquishes
	var local_falls = game_falls
	var local_level = user_level
	
	# Load online data
	populate_user_data(online_data)
	is_online_mode = true
	
	# Merge logic: keep the higher values
	if local_score > game_score:
		game_score = local_score
		has_unsaved_changes = true
	if local_vanquishes > game_vanquishes:
		game_vanquishes = local_vanquishes
		has_unsaved_changes = true
	if local_falls < game_falls:  # Lower falls is better
		game_falls = local_falls
		has_unsaved_changes = true
	if local_level > user_level:
		user_level = local_level
		has_unsaved_changes = true
	
	calculate_level()
	save_user_data()

func switch_to_local_mode():
	"""Switch to local mode"""
	is_online_mode = false
	if username == "":
		username = local_username
	access = "local"
	save_user_data()

func get_current_data_as_dict() -> Dictionary:
	"""Get current user data as dictionary for backup/sync purposes"""
	return {
		"user_id": user_id,
		"username": username,
		"email": email,
		"enabled": enabled,
		"user_key": user_key,
		"freshness": freshness,
		"user_level": user_level,
		"phone": phone,
		"game_score": game_score,
		"game_falls": game_falls,
		"game_vanquishes": game_vanquishes,
		"game_level": game_level,
		"access": access,
		"level_progress": level_progress,
		"is_online_mode": is_online_mode,
		"local_username": local_username,
		"last_sync_timestamp": last_sync_timestamp
	}


func get_setting(key: String):
	return UserSettings.get(key, null)


func set_setting(key: String, value: Resource):
	UserSettings[key] = value.duplicate(true)  # Store the modified version
	UserSettingsStellar[key] = value.duplicate(true)  # Keep a pristine copy








func populate_user_data(data: Dictionary):
	emit_id = data_updated.get_object_id()
	user_id = data.get("ID", 0)
	username = data.get("usr_login", "")
	email = data.get("usr_email", "")
	enabled = data.get("usr_enable", 0) == 1
	user_key = data.get("usr_key", "")
	freshness = data.get("usr_freshness", "")
	user_level = data.get("usr_lvl", 0)
	phone = data.get("usr_phone", "")
	game_score = data.get("game_score", 0)
	game_falls = data.get("game_falls", 0)
	game_vanquishes = data.get("game_vanquishes", 0)
	game_level = data.get("game_level", 0)
	access = data.get("access", "")
	level_progress = data.get("level_progress", 0.0)
	
	# Handle new local/online mode fields
	is_online_mode = data.get("is_online_mode", false)
	local_username = data.get("local_username", "LocalPlayer")
	last_sync_timestamp = data.get("last_sync_timestamp", int(Time.get_unix_time_from_system()))






func getUserData() -> Dictionary:
	calculate_level()
	return {
		"game_score": game_score,
		"game_falls": game_falls,
		"game_vanquishes": game_vanquishes,
		"game_level": game_level,
		"level_progress": level_progress
	}





func getJSON() -> String:
	var data_dict = {
		"user_id": user_id,
		"username": username,
		"user_key": user_key,
		"freshness": freshness,
		"user_level": user_level,
		"game_score": game_score,
		"game_falls": game_falls,
		"game_vanquishes": game_vanquishes,
		"game_level": game_level,
		"level_progress": level_progress,
		"is_online_mode": is_online_mode,
		"local_username": local_username,
		"last_sync_timestamp": last_sync_timestamp
	}
	var jsonString = JSON.stringify(data_dict)
	return jsonString





func calculate_level():
	if game_vanquishes <= 0:
		return 1
	var progress_ratio = float(game_vanquishes) / MAX_VANQUISHES
	game_level = lerp(1, MAX_LEVEL, progress_ratio ** 0.5)
	game_score = 250 * game_vanquishes
	var prev_level = lerp(1, MAX_LEVEL, ((float(game_vanquishes) - 1) / MAX_VANQUISHES) ** 0.5)
	var next_level = lerp(1, MAX_LEVEL, ((float(game_vanquishes) + 1) / MAX_VANQUISHES) ** 0.5)
	var level_range = max(1, next_level - prev_level)
	level_progress = abs((game_level - prev_level) / level_range)







func get_user_data_file_path() -> String:
	var documents_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var my_games_dir = "%s/My Games" % documents_dir
	var game_name = ProjectSettings.get_setting("application/config/name", "Game")
	var creative_space_dir = "%s/%s" % [my_games_dir, game_name]
	return "%s/%s" % [creative_space_dir, USER_DATA_FILE]





func load_user_data():
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(json_string)
		if parse_result == OK:
			var data = json_parser.get_data()
			populate_user_data(data)




func save_user_data():
	calculate_level()
	var json_string = getJSON()
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(json_string)
		file.close()




func gut_check_userloadout():
	pass

func can_upgrade_to_online() -> bool:
	"""Check if local user has progress worth merging online"""
	return not is_online_mode and (game_score > 0 or game_vanquishes > 0 or user_level > 1)

func get_local_progress_summary() -> String:
	"""Get a summary of local progress for display"""
	if not can_upgrade_to_online():
		return "No local progress to merge"
	
	return "Local Progress: Level %d, Score %d, Vanquishes %d" % [user_level, game_score, game_vanquishes]

func reset_to_new_local_user():
	"""Reset all user data to a fresh local user - for testing purposes"""
	print("Resetting to new local user...")
	
	# Clear all user data
	user_id = 0
	username = "LocalPlayer"
	email = ""
	enabled = true
	user_key = ""
	freshness = ""
	user_level = 1
	phone = ""
	game_score = 0
	game_falls = 0
	game_vanquishes = 0
	game_level = 1
	access = "local"
	level_progress = 0.0
	is_online_mode = false
	local_username = "LocalPlayer"
	last_sync_timestamp = int(Time.get_unix_time_from_system())
	has_unsaved_changes = false
	
	# Clear user settings
	UserSettings = {
		"primaryWeapon" : null,
		"secondaryWeapon" : null,
		"Mines" : null,
		"Craft" : null,
		"Level" : null,
		"specials" : []
	}
	UserSettingsStellar = {
		"primaryWeapon" : null,
		"secondaryWeapon" : null,
		"Mines" : null,
		"Craft" : null,
		"Level" : null,
		"specials" : []
	}
	
	# Save the reset data
	save_user_data()
	print("Reset complete - now a fresh local user")
