extends Node3D

var craft_settings: CraftSettings = null
var active_health_modifiers = {} 

@export var shield_mesh: MeshInstance3D
@export var Interactive: bool = false
@export var hud_shields: Label
@export var hud_armor: Label
@export var hud_health: Label
@export var hud_draw_target: Control
@export var icon_node: Control

@onready var load_out_hud: Control = $"../Hud_loadOut"
@onready var in_game_hud: Control = $"../Hud_inGame"
@onready var creative_hud: Control = $"../HUD_Creative"

var shield_original: float
var armor_original: float
var life_original: float
var parent_node = get_parent()
var regeneration_timer: Timer
var is_regenerating: bool = false
var on_repair_pad: bool = false
var distructo: bool = false

func _ready() -> void:
	parent_node = get_parent()


func enter_recon_station():
	load_out_hud.visible = true
	in_game_hud.visible = false
	creative_hud.visible = false

func set_settings():
	craft_settings = UserData.UserSettings["Craft"].duplicate(true)  # Make a deep copy
	shield_original = craft_settings.shields
	armor_original = craft_settings.armor
	life_original = craft_settings.life

	_update_hud()
	_draw_hud_circle()

	regeneration_timer = Timer.new()
	regeneration_timer.set_wait_time(craft_settings.regeneration_delay)
	regeneration_timer.set_one_shot(true)
	regeneration_timer.connect("timeout", Callable(self, "_on_regeneration_timeout"))
	add_child(regeneration_timer)

	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter_recon"):
		if on_repair_pad:
			enter_recon_station()
	if craft_settings == null:
		return
	if global_transform.origin.y < -25:
		destroy_self()
	if on_repair_pad:
		if craft_settings.life < life_original:
			craft_settings.life = min(life_original, craft_settings.life + craft_settings.regeneration_rate * _delta)
		elif craft_settings.armor < armor_original:
			craft_settings.armor = min(armor_original, craft_settings.armor + craft_settings.regeneration_rate * _delta)
		elif craft_settings.shields < shield_original:
			craft_settings.shields = min(shield_original, craft_settings.shields + craft_settings.regeneration_rate * _delta)
		_update_hud()
		_draw_hud_circle()
	elif is_regenerating and craft_settings.shields < shield_original:
		craft_settings.shields = min(shield_original, craft_settings.shields + craft_settings.regeneration_rate * _delta)
		_update_hud()
		_draw_hud_circle()


func receive_powerup_param(amount, setting_name: String, time: float):
	if craft_settings:
		if craft_settings.get(setting_name) != null:
			if active_health_modifiers.has(setting_name):
				var stored_data = active_health_modifiers[setting_name]
				if stored_data[1].is_inside_tree():
					stored_data[1].queue_free()
				craft_settings.set(setting_name, stored_data[0])
			var original_value = craft_settings.get(setting_name)
			craft_settings.set(setting_name, original_value + amount)
			var timer = Timer.new()
			timer.wait_time = time
			timer.one_shot = true
			timer.connect("timeout", Callable(self, "_revert_health_stat").bind(setting_name))
			add_child(timer)
			timer.start()
			active_health_modifiers[setting_name] = [original_value, timer]
	_update_hud()
	_draw_hud_circle()
	
func _revert_health_stat(setting_name: String):
	if craft_settings:
		if active_health_modifiers.has(setting_name):
			var original_value = active_health_modifiers[setting_name][0]
			craft_settings.set(setting_name, original_value)
			var timer = active_health_modifiers[setting_name][1]
			if timer.is_inside_tree():
				timer.queue_free()
			active_health_modifiers.erase(setting_name)
	_update_hud()
	_draw_hud_circle()



func receive_powerup(amount: float) -> void:
	var remaining = amount
	var life_deficit = life_original - craft_settings.life
	var life_restore = min(life_deficit, remaining)
	craft_settings.life += life_restore
	remaining -= life_restore
	if remaining > 0:
		var armor_deficit = armor_original - craft_settings.armor
		var armor_restore = min(armor_deficit, remaining)
		craft_settings.armor += armor_restore
		remaining -= armor_restore
	if remaining > 0:
		var shield_deficit = shield_original - craft_settings.shields
		var shield_restore = min(shield_deficit, remaining)
		craft_settings.shields += shield_restore
		remaining -= shield_restore
	_update_hud()
	_draw_hud_circle()
		
		

func apply_direct_damage(damage: float) -> void:
	apply_damage(damage)
	if craft_settings.life <= 0:
		destroy_self()



func apply_damage(damage: float) -> void:
	regeneration_timer.start()
	is_regenerating = false
	if craft_settings.shields > 0:
		craft_settings.shields -= damage
		if craft_settings.shields <= 0:
			if shield_mesh and is_instance_valid(shield_mesh): 
				shield_mesh.visible = false
			damage = -craft_settings.shields
			craft_settings.shields = 0
		else:
			_update_hud()
			_draw_hud_circle()
			return
	if craft_settings.armor > 0 and damage > 0:
		craft_settings.armor -= damage
		if craft_settings.armor < 0:
			damage = -craft_settings.armor
			craft_settings.armor = 0
		else:
			_update_hud()
			_draw_hud_circle()
			return
	if damage > 0:
		craft_settings.life -= damage
	_update_hud()
	_draw_hud_circle()
	if craft_settings.life <= life_original * 0.7 and Interactive == true:
		if parent_node and parent_node.has_method("setFreezeState"):
			parent_node.call("setFreezeState", false)





func destroy_self() -> void:
	var main_menu = get_tree().get_root().get_node("Index")
	if main_menu:
		var load_group = main_menu.get_node_or_null("pnl_load_game")
		if load_group and load_group.has_method("playerDestroyed") and distructo == false:
			load_group.call("playerDestroyed")
			distructo = true


func return_to_menu() -> void:
	pass


func _update_hud() -> void:
	if hud_shields:
		hud_shields.text = "S: %d" % int(craft_settings.shields)
	if hud_armor:
		hud_armor.text = "A: %d" % int(craft_settings.armor)
	if hud_health:
		hud_health.text = "H: %d" % int(craft_settings.life)





func _draw_hud_circle() -> void:
	if hud_draw_target and hud_draw_target is Control:
		var shield_progress = craft_settings.shields / shield_original
		var armor_progress = craft_settings.armor / armor_original
		var life_progress = craft_settings.life / life_original
		hud_draw_target.set_circle_properties(shield_progress, "shield")
		hud_draw_target.set_circle_properties(armor_progress, "armor")
		hud_draw_target.set_circle_properties(life_progress, "life")





func _on_regeneration_timeout() -> void:
	is_regenerating = true





func set_on_repair_pad(value: bool) -> void:
	var icon_texture = load("res://UI/Icons/recon_station.png") as Texture2D
	Utilities.add_icon(icon_texture, value)
	on_repair_pad = value
