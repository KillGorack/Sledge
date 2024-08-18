extends Control


@onready var registration_button = get_node("..").get_node("Registration")
@onready var login_group = get_node("..").get_node("LoginGroup")
@onready var play_game_group = get_node("..").get_node("PlayGameGroup")
@onready var welcome_message = get_node("..").get_node("Welcome")
@onready var username_input = $Username
@onready var password_input = $Password
@onready var login_button = $LoginButton
@export var apiKey: String = ""

var error
var serverUrlBase = "https://www.killgorack.com/PX4/api.php?ap=sledge&apikeyid=4&api=json&vc="
var registrationUrl = "https://www.killgorack.com/PX4/index.php?ap=hme&ala=register"


func _ready():
	login_button.connect("pressed", Callable(self, "_on_LoginButton_pressed"))
	registration_button.connect("pressed", Callable(self, "_on_Registration_pressed"))
	username_input.grab_focus()
	username_input.connect("gui_input", Callable(self, "_on_gui_input"))
	password_input.connect("gui_input", Callable(self, "_on_gui_input"))
	login_button.connect("gui_input", Callable(self, "_on_gui_input"))





func _on_LoginButton_pressed():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var userName = $Username.text
	var password = $Password.text
	var form_data = {
		"userName": userName,
		"password": password,
		"formidentifier": "alacarte\\sledge\\unityAuth"
	}
	var body = build_form_data(form_data)
	error = http_request.request(serverUrlBase + apiKey, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	else:
		http_request.connect("request_completed", Callable(self, "_on_request_completed"))





func build_form_data(data: Dictionary) -> String:
	var form_data = []
	for key in data.keys():
		var value = data[key]
		form_data.append(escape_string(key) + "=" + escape_string(value))
	return "&".join(form_data)





func escape_string(value: String) -> String:
	return value.replace(" ", "%20").replace("!", "%21").replace("\"", "%22").replace("#", "%23").replace("$", "%24").replace("%", "%25").replace("&", "%26").replace("'", "%27").replace("(", "%28").replace(")", "%29").replace("*", "%2A").replace("+", "%2B").replace(",", "%2C").replace("/", "%2F").replace(":", "%3A").replace(";", "%3B").replace("<", "%3C").replace("=", "%3D").replace(">", "%3E").replace("?", "%3F").replace("@", "%40").replace("[", "%5B").replace("\\", "%5C").replace("]", "%5D").replace("^", "%5E").replace("_", "%5F").replace("`", "%60").replace("{", "%7B").replace("|", "%7C").replace("}", "%7D").replace("~", "%7E")





func _on_request_completed(result, response_code, headers, body):
	var body_string = body.get_string_from_utf8()
	if response_code == 200:
		if body_string.strip_edges() == "":
			print("Response body is empty.")
		else:
			var json = JSON.new()
			var parse_result = json.parse(body_string)
			if parse_result == OK:
				var response_data = json.get_data()
				if response_data.has("status") and response_data.status == "success":
					var data = response_data.data
					if data.has("access") and data.access == "granted":
						Global.set_user_data(data)
						login_group.visible = false
						play_game_group.visible = true
						registration_button.visible = false
						welcome_message.text = "  Welcome: " + Global.get_user_data().get("usr_login")





func _on_gui_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ENTER:
			_on_LoginButton_pressed()




func _on_Registration_pressed():
	OS.shell_open(registrationUrl)
