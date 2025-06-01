extends PanelContainer

@onready var opt_bindings = $margin/HBoxContainer/opt_bindings
@onready var line_action = $margin/HBoxContainer/VBoxContainer/line_action
@onready var line_key = $margin/HBoxContainer/VBoxContainer/line_key
@onready var rebind_button = $margin/HBoxContainer/VBoxContainer/rebind_button
@onready var return_button = $"../../../btn_return"

@onready var panel_login = $"../../../../../../pnl_login_group"
@onready var panel_keymap = $"../../../../.."
@onready var panel_loadgame = $"../../../../../../pnl_load_game"

var key_bindings: KeyBindSettings
var selected_action = ""
var listening_for_input = false
var current_key_sequence = []





func _ready():
	var overwrite = false
	opt_bindings.item_selected.connect(_on_opt_bindings_item_selected)
	rebind_button.pressed.connect(_on_rebind_button_pressed)
	return_button.pressed.connect(_on_return_button_pressed)
	var user_file = "user://KEY_BINDINGS_USER.tres"
	var default_file = "res://UI/_scripts/KEY_BINDINGS_DEFAULT.tres"
	if not ResourceLoader.exists(user_file) or overwrite:
		key_bindings = load(default_file)
		ResourceSaver.save(key_bindings, user_file)
	key_bindings = load(user_file)
	var default_bindings = load(default_file)
	populate_action_list(default_bindings)
	update_all_keybindings()

func _on_return_button_pressed():
	if UserData.enabled:
		panel_loadgame.visible = true
		panel_login.visible = false
	else:
		panel_loadgame.visible = false
		panel_login.visible = true
	panel_keymap.visible = false


func populate_action_list(default_bindings):
	opt_bindings.clear()
	for property in key_bindings.get_property_list():
		var action_key = property.name
		var key_event = key_bindings.get(action_key)
		var readable_name = "Unknown Action"
		for default_property in default_bindings.get_property_list():
			if default_property.name == action_key:
				var default_event = default_bindings.get(action_key)
				if default_event and default_event is InputEventKey:
					readable_name = default_event.resource_name
				break
		if not (key_event is InputEventKey):
			continue  
		var key_text = "None"
		var modifiers = []
		if key_event.alt_pressed:
			modifiers.append("Alt")
		if key_event.shift_pressed:
			modifiers.append("Shift")
		if key_event.ctrl_pressed:
			modifiers.append("Ctrl")
		if key_event.keycode != 0:
			key_text = OS.get_keycode_string(key_event.keycode)
		if modifiers.size() > 0:
			key_text = "+".join(modifiers) + " + " + key_text
		var display_text = readable_name + " - [ " + key_text + " ]"
		opt_bindings.add_item(display_text)
		opt_bindings.set_item_metadata(opt_bindings.get_item_count() - 1, action_key)





func _input(event):
	if listening_for_input and event is InputEventKey:
		if event.pressed:
			if not current_key_sequence.has(event.keycode):
				current_key_sequence.append(event.keycode)
		if not event.pressed:
			listening_for_input = false
			rebind_button.text = "Rebind this action"
			var new_key = InputEventKey.new()
			new_key.keycode = current_key_sequence[-1] if current_key_sequence.size() > 0 else 0
			new_key.ctrl_pressed = event.ctrl_pressed
			new_key.alt_pressed = event.alt_pressed
			new_key.shift_pressed = event.shift_pressed
			update_keybinding(selected_action, new_key)
			current_key_sequence.clear()





func _on_rebind_button_pressed():
	listening_for_input = true
	rebind_button.text = "Listening.."





func update_keybinding(action_name: String, new_key: InputEventKey):
	var properties = key_bindings.get_property_list()
	var found = false
	for property in properties:
		if property.name == action_name:
			found = true
			break
	if found:
		var readable_name = "Unknown Action"
		var default_file = "res://UI/_scripts/KEY_BINDINGS_DEFAULT.tres"
		var default_bindings = load(default_file)
		for default_property in default_bindings.get_property_list():
			if default_property.name == action_name:
				var default_event = default_bindings.get(action_name)
				if default_event and default_event is InputEventKey:
					readable_name = default_event.resource_name  # Preserve name
				break
		new_key.resource_name = readable_name
		key_bindings.set(action_name, new_key)
		ResourceSaver.save(key_bindings, "user://KEY_BINDINGS_USER.tres")
		var modifiers = []
		if new_key.ctrl_pressed:
			modifiers.append("Ctrl")
		if new_key.alt_pressed:
			modifiers.append("Alt")
		if new_key.shift_pressed:
			modifiers.append("Shift")
		var key_text = OS.get_keycode_string(new_key.keycode)
		if modifiers.size() > 0:
			key_text = "+".join(modifiers) + " + " + key_text
		line_action.text = readable_name
		line_key.text = key_text
		populate_action_list(default_bindings)
		update_all_keybindings()





func _on_opt_bindings_item_selected(index):
	selected_action = opt_bindings.get_item_metadata(index)  
	var key_event = key_bindings.get(selected_action)
	var readable_name = key_event.resource_name if key_event else "Unknown Action"
	var key_text = "None"
	var modifiers = []
	if key_event and key_event is InputEventKey:
		if key_event.ctrl_pressed:
			modifiers.append("Ctrl")
		if key_event.alt_pressed:
			modifiers.append("Alt")
		if key_event.shift_pressed:
			modifiers.append("Shift")
		if key_event.keycode != 0:
			key_text = OS.get_keycode_string(key_event.keycode)
	if modifiers.size() > 0:
		key_text = "+".join(modifiers) + " + " + key_text
	line_action.text = readable_name
	line_key.text = key_text





func update_all_keybindings():
	if not key_bindings:
		return
	for property in key_bindings.get_property_list():
		var action_name = property.name
		var key_event = key_bindings.get(action_name)
		if key_event and key_event is InputEventKey:
			InputMap.erase_action(action_name)
			InputMap.add_action(action_name)
			InputMap.action_add_event(action_name, key_event)
	populate_action_list(key_bindings)
