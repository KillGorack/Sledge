extends Control

@onready var http_request = $HTTPRequest
@onready var quit_button = $btn_quit
@onready var music_player = $AmbientMusic
@onready var login_group = $pnl_login_group
@onready var pnl_settings = $Settings
@onready var register_button = $btn_register
@onready var btn_settings = $btn_settings
@onready var username_field = $pnl_login_group/margin/vbox_login_form/hbox_username/txt_username
@onready var password_field = $pnl_login_group/margin/vbox_login_form/hbox_password/txt_password
@onready var login_button = $pnl_login_group/margin/vbox_login_form/btn_login
@onready var btn_play_offline = get_node_or_null("pnl_login_group/margin/vbox_login_form/btn_play_offline")
@onready var volume_slider = $sld_musicVolume
@onready var welcome_label = $lbl_welcome
@onready var load_group = $pnl_load_game

@onready var login_timer = Timer.new()

var login_attempts: int = 0
var max_attempts: int = 5
var cooldown_seconds: int = 30
var is_cooldown: bool = false
var LOGGED_IN: bool = false
var is_http_busy: bool = false
var api_url = "https://www.killgorack.com/PX4/api.php"





func _ready():
	username_field.grab_focus()
	add_child(login_timer)
	quit_button.connect("pressed", Callable(self, "_on_close"))
	login_button.connect("pressed", Callable(self, "_on_login"))
	register_button.connect("pressed", Callable(self, "_on_register"))
	btn_settings.connect("pressed", Callable(self, "_on_settings"))
	if btn_play_offline:
		btn_play_offline.connect("pressed", Callable(self, "_on_play_offline"))
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	volume_slider.value = music_player.volume_db
	volume_slider.connect("value_changed", Callable(self, "_on_volume_slider_value_changed"))
	login_timer.connect("timeout", Callable(self, "_on_cooldown_finished"))
	login_timer.one_shot = true
	login_group.show()
	load_group.hide()





func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_login()
	
	# Temporary testing: Press F12 to reset to new local user
	if event is InputEventKey and event.pressed and 1 == 2:
		if event.keycode == KEY_F12:
			print("F12 pressed - resetting to new local user")
			UserData.reset_to_new_local_user()
			welcome_label.text = "Reset to new local user (F12)"
			LOGGED_IN = false
			login_group.show()
			load_group.hide()


func _on_settings():
	pnl_settings.visible = true
	login_group.visible = false
	load_group.visible = false


func _on_login():
	if LOGGED_IN:
		return
	if is_http_busy:
		welcome_label.text = "Please wait, processing your previous request."
		return

	var username = username_field.text
	var password = password_field.text
	if username == "" or password == "":
		welcome_label.text = "Please enter both username and password."
		return

	login_attempts += 1
	if login_attempts > max_attempts:
		is_cooldown = true
		resetForm()
		username_field.editable = false
		password_field.editable = false
		login_button.disabled = true
		welcome_label.text = "Too many attempts. Please wait 30 seconds before trying again."
		login_timer.start(cooldown_seconds)
		return

	var post_data = {
		"function": "authenticate",
		"userName": username,
		"password": password,
		"formidentifier": "alacarte\\game\\gameAPI"
	}
	var api_params = {
		"ap": "game",
		"cn": "hme",
		"apikeyid": Creds.apiID,
		"api": "json",
		"vc": Creds.apiKEY
	}
	var post_data_encoded = encode_dict_string(post_data)
	var full_url = api_url + "?" + encode_dict_string(api_params)
	var headers = ["Content-Type: application/x-www-form-urlencoded"]

	is_http_busy = true
	http_request.request(full_url, headers, HTTPClient.METHOD_POST, post_data_encoded)





func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var user_data = json_parser.get_data()
			if user_data.data.access == "granted":
				login_attempts = 0
				is_cooldown = false
				
				# If we were in local mode, merge the data
				if not UserData.is_online_mode:
					UserData.switch_to_online_mode(user_data.data)
					welcome_label.text = "Welcome! Local progress merged with online account."
				else:
					UserData.populate_user_data(user_data.data)
					UserData.is_online_mode = true
					welcome_label.text = "Welcome, login successful!"
				
				login_group.hide()
				load_group.show()
				load_group.populate_user_info()
				Utilities.user_mode_index = 1
				LOGGED_IN = true
			else:
				resetForm()
				welcome_label.text = "Login NOT successful, please try again!"
		else:
			welcome_label.text = "Server error. Please try again later."
	is_http_busy = false
	
	
	
func resetForm():
	username_field.text = ""
	password_field.text = ""
	username_field.grab_focus()





func _on_cooldown_finished():
	login_attempts = 4
	is_cooldown = false
	username_field.editable = true
	password_field.editable = true
	login_button.disabled = false
	welcome_label.text = "You can try logging in again now."




## Directs user to registration form on killgorack.com
func _on_register():
	var url = "https://www.killgorack.com/PX4/index.php?ap=hme&ala=register"
	OS.shell_open(url)
	
	
	
	
	
# Volume changer on the main screens.
func _on_volume_slider_value_changed(value):
	music_player.volume_db = value


func _on_play_offline():
	"""Handle offline play - load local user data and proceed to game"""
	if LOGGED_IN:
		return
	
	# Switch to local mode
	UserData.switch_to_local_mode()
	
	# Check if we need to prompt for local username
	if UserData.username == "" or UserData.username == "LocalPlayer":
		# Could add a simple input dialog here, or just use default
		UserData.username = "LocalPlayer"
	
	welcome_label.text = "Playing offline as: " + UserData.username
	login_group.hide()
	load_group.show()
	load_group.populate_user_info()
	Utilities.user_mode_index = 0  # 0 for local, 1 for online
	LOGGED_IN = true
	


func encode_dict_string(data: Dictionary) -> String:
	var query_string = []
	for key in data.keys():
		var encoded_key = String(key).uri_encode()
		var encoded_value = str(data[key]).uri_encode()
		query_string.append(encoded_key + "=" + encoded_value)
	return String(",").join(query_string).replace(",", "&")
	
	
	
	
## Game exit point
func _on_close() -> void:
	get_tree().quit()


# Add method to save progress during gameplay
func save_progress():
	"""Save current progress - locally always, and to server if online"""
	UserData.save_user_data()
	
	# If online and has unsaved changes, could sync to server here
	if UserData.is_online_mode and UserData.has_unsaved_changes:
		# Could implement server sync here
		pass

# Add method to show current mode status
func get_mode_status() -> String:
	if UserData.is_online_mode:
		return "Online Mode - Progress synced to server"
	else:
		return "Offline Mode - Progress saved locally"
