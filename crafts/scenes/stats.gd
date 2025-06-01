extends Control

var user_data

@export var score_label: Label
@export var falls_label: Label
@export var vanquishes_label: Label
@export var level_label: Label
@export var p_bar: ProgressBar
@export var r_bar: ProgressBar

@export var update_interval: float = 1.0
@onready var timer = Timer.new()
@onready var halp: TextureRect = $keymap
@onready var messages: TextEdit = $txt_messages

var parent: RigidBody3D
var frict_val

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("halp"):
		toggle_halp()
	if Input.is_action_just_pressed("HideHud"):
		hide_hud()

		
		
func toggle_halp():
	var vb = halp.visible
	if vb == true:
		halp.visible = false
	else:
		halp.visible = true
		
func _ready():
	user_data = get_node("/root/UserData")
	add_child(timer)
	timer.set_wait_time(update_interval)
	timer.set_autostart(true)
	timer.set_one_shot(false)
	timer.connect("timeout", Callable(self, "update_hud"))
	timer.start()
	update_hud()
	Utilities.update_game_mode_label()
	parent = get_parent()
	r_bar.get_theme_stylebox("fill").bg_color = Color(21 / 255.0, 229 / 255.0, 238 / 255.0)

	
func hide_hud():
	visible = not visible
	

func update_hud():
	if user_data:
		var user_data_dict = user_data.getUserData()
		
		score_label.text = "Score: " + str(user_data_dict["game_score"])
		falls_label.text = "Falls: " + str(user_data_dict["game_falls"])
		vanquishes_label.text = "Vanquishes: " + str(user_data_dict["game_vanquishes"])
		level_label.text = "Level: " + str(user_data_dict["game_level"])
		p_bar.value = user_data_dict["level_progress"]
		r_bar.value = Utilities.getResourceLevel()
		messages.text = "\n".join(Utilities.messages)
		
		
