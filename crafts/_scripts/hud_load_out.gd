extends Control

@export var LaserSettings: Array[Resource] = []
@export var MissileSettings: Array[Resource] = []
@export var mineSettings: Array[Resource] = []
@export var craftSettings: Array[Resource] = []

@onready var optionContainer = $WeaponChooser
@onready var optionLasers = $WeaponChooser/MarginContainer/VBoxContainer/opt_lasers
@onready var optionMissiles = $WeaponChooser/MarginContainer/VBoxContainer/opt_missiles
@onready var optionMines = $WeaponChooser/MarginContainer/VBoxContainer/opt_mines
@onready var optionSpecials = $WeaponChooser/MarginContainer/VBoxContainer/opt_specials

@onready var craftPrevious = $VehicleChooser/MarginContainer/VBoxContainer/HBoxContainer/Previous
@onready var craftNext = $VehicleChooser/MarginContainer/VBoxContainer/HBoxContainer/Next
@onready var craftImage = $VehicleChooser/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/img_craft
@onready var craftLore = $VehicleChooser/MarginContainer/VBoxContainer/lbl_lore
@onready var craftName = $VehicleChooser/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/lbl_craft_name
@onready var inGameHud = $"../Hud_inGame"
@onready var enter_level = $btn_enter_game

@onready var lbl_laser = $WeaponChooser/MarginContainer/VBoxContainer/lbl_laser
@onready var lbl_missile = $WeaponChooser/MarginContainer/VBoxContainer/lbl_missile
@onready var lbl_mine = $WeaponChooser/MarginContainer/VBoxContainer/lbl_mines


@onready var txt_pri_title = $pnl_lore/MarginContainer/VBoxContainer/txt_pri_title
@onready var txt_pri_lore = $pnl_lore/MarginContainer/VBoxContainer/txt_pri_lore
@onready var txt_sec_title = $pnl_lore/MarginContainer/VBoxContainer/txt_sec_title
@onready var txt_sec_lore = $pnl_lore/MarginContainer/VBoxContainer/txt_sec_lore
@onready var txt_mine_title = $pnl_lore/MarginContainer/VBoxContainer/txt_mine_title
@onready var txt_mine_lore = $pnl_lore/MarginContainer/VBoxContainer/txt_mine_lore


var current_craft_index: int = 0

func _ready() -> void:
	var oh = (((optionContainer.size.y) - 20) / 4) - 30
	optionLasers.custom_minimum_size.y = oh
	optionMissiles.custom_minimum_size.y = oh
	optionMines.custom_minimum_size.y = oh
	optionSpecials.custom_minimum_size.y = oh
	populate_dropdowns()
	update_craft_display()
	optionLasers.item_selected.connect(_on_laser_selected)
	optionMissiles.item_selected.connect(_on_missile_selected)
	optionMines.item_selected.connect(_on_mine_selected)
	craftPrevious.pressed.connect(_on_previous_pressed)
	craftNext.pressed.connect(_on_next_pressed)
	enter_level.pressed.connect(_on_enter_level)
	

func _on_laser_selected(index: int):
	var selected_laser = LaserSettings[index]
	txt_pri_title.text = selected_laser.weapon_name
	txt_pri_lore.text = selected_laser.weapon_lore

func _on_missile_selected(index: int):
	var selected_missile = MissileSettings[index]
	txt_sec_title.text = selected_missile.weapon_name
	txt_sec_lore.text = selected_missile.weapon_lore


func _on_mine_selected(index: int):
	var selected_mine = mineSettings[index]
	txt_mine_title.text = selected_mine.mine_name
	txt_mine_lore.text = selected_mine.mine_lore


func populate_dropdowns():
	_populate_option(optionLasers, LaserSettings, "weapon_name", "weapon_icon", "level_req")
	_populate_option(optionMissiles, MissileSettings, "weapon_name", "weapon_icon", "level_req")
	_populate_option(optionMines, mineSettings, "mine_name", "mine_icon", "level_req")

	if not LaserSettings.is_empty():
		optionLasers.select(0)
		_on_laser_selected(0)

	if not MissileSettings.is_empty():
		optionMissiles.select(0)
		_on_missile_selected(0)

	if not mineSettings.is_empty():
		optionMines.select(0)
		_on_mine_selected(0)


func _populate_option(option_list, settings, name_property, icon_property, level_req):
	option_list.clear()
	for i in range(settings.size()):
		var item = settings[i]
		if(item.get(level_req) <= UserData.user_level):
			option_list.add_item(item.get(name_property))
			option_list.set_item_icon(i, item.get(icon_property))







		

func update_craft_display():
	if craftSettings.is_empty():
		return
	var craft = craftSettings[current_craft_index]
	craftImage.texture = craft.craft_image
	craftName.text = craft.craft_name
	craftLore.text = craft.craft_lore
	
func _on_previous_pressed():
	if current_craft_index > 0:
		current_craft_index -= 1
	else:
		current_craft_index = craftSettings.size() - 1
	update_craft_display()

func _on_next_pressed():
	if current_craft_index < craftSettings.size() - 1:
		current_craft_index += 1
	else:
		current_craft_index = 0
	update_craft_display()
	
	
func validate_selection(option_list, label) -> bool:
	var has_selection = not option_list.get_selected_items().is_empty()
	label.add_theme_color_override("font_color", Color(1, 1, 1) if has_selection else Color(1, 0, 0))
	var required_text = " - Selection Required"
	if has_selection:
		label.text = label.text.replace(required_text, "")
	else:
		if not label.text.ends_with(required_text):
			label.text += required_text
	return has_selection

	
	

func _on_enter_level():
	
	var selections = [
		validate_selection(optionLasers, lbl_laser),
		validate_selection(optionMissiles, lbl_missile),
		validate_selection(optionMines, lbl_mine)
	]
	
	if selections.has(false):
		return

	var laser_index = optionLasers.get_selected_items()[0]
	var missile_index = optionMissiles.get_selected_items()[0]
	var mine_index = optionMines.get_selected_items()[0]

	UserData.set_setting("primaryWeapon", LaserSettings[laser_index].duplicate(true))
	UserData.set_setting("secondaryWeapon", MissileSettings[missile_index].duplicate(true))
	UserData.set_setting("Mine", mineSettings[mine_index].duplicate(true))
	UserData.set_setting("Craft", craftSettings[current_craft_index].duplicate(true))
	
	var parent = get_parent()
	if parent and parent.has_method("setCraftSettings"):
		parent.setCraftSettings()
	var barrel_node = get_parent().get_node("Turret").get_node("Barrel")
	if barrel_node and barrel_node.has_method("load_weapons"):
		barrel_node.load_weapons()

	var mine_node = get_parent().get_node("mine_node")
	if mine_node && mine_node.has_method("set_settings"):
		mine_node.set_settings()
		
	var health_node = get_parent().get_node("health_node")
	if health_node && health_node.has_method("set_settings"):
		health_node.set_settings()
		
	var power_node = get_parent().get_node("power_node")
	if power_node && power_node.has_method("set_settings"):
		power_node.set_settings()
	
	self.hide()
	inGameHud.show()
