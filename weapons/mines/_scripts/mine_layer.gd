extends Node3D

@onready var icon_mine = $"../Hud_inGame/txtr_weapon_icon"
@onready var lbl_mines = $"../Hud_inGame/lbl_shots_left"
@onready var lbl_name = $"../Hud_inGame/lbl_weapon_name"
@onready var camera3D = $"../Turret/Barrel/Camera3D"
@onready var raycast = $"../Turret/MineCast"

var current_mine_settings: Resource
var current_mine_index = 0
var mine_lay_timer: float = 0.0
var this_node_enabled: bool = false


func _ready() -> void:
	Utilities.game_mode_changed.connect(_on_game_mode_changed)

func _on_game_mode_changed():
	await get_tree().process_frame
	update_mine_label()

func set_settings():
	current_mine_settings = UserData.UserSettings["Mine"]
	update_mine_label()


		
		
		
func _physics_process(delta: float) -> void:
	if current_mine_settings == null:
		return
	if Utilities.game_mode_index != 1:
		this_node_enabled = false
		return
	elif this_node_enabled == false:
		this_node_enabled = true
	if mine_lay_timer > 0:
		mine_lay_timer -= delta
	if Input.is_action_just_pressed("FireWeapon") and current_mine_settings.count_actual > 0 and mine_lay_timer <= 0:
		lay_mine()

	



func lay_mine():
	if raycast.is_colliding() and can_lay_mine():
		Utilities.set_allegiance(self, "Projectile_Friendly")
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		if collider.is_in_group("driveable"):
			var mine_scene = current_mine_settings.mine_prefab
			var mine_instance = mine_scene.instantiate()
			get_parent().get_parent().add_child(mine_instance)
			mine_instance.global_transform.origin = collision_point
			var up_vector = collision_normal.normalized()
			var mine_transform = mine_instance.global_transform
			mine_transform.basis.y = up_vector
			mine_transform.basis.x = Vector3(1, 0, 0).cross(up_vector).normalized()
			mine_transform.basis.z = up_vector.cross(mine_transform.basis.x).normalized()
			mine_instance.global_transform = mine_transform
			if current_mine_settings.lay_sound:
				var audio_player = AudioStreamPlayer.new()
				audio_player.stream = current_mine_settings.lay_sound
				get_parent().get_parent().add_child(audio_player)
				audio_player.play()
			current_mine_settings.count_actual -= 1
			if current_mine_settings.count_actual < 0:
				current_mine_settings.count_actual = 0
			update_mine_label()
			if mine_instance.has_method("set_settings"):
				mine_instance.set_settings(current_mine_settings, "Projectile_Friendly")
			mine_lay_timer = current_mine_settings.cool_down

func can_lay_mine() -> bool:
	var existing_mines = 0
	for child in get_parent().get_parent().get_children():
		if child.is_in_group("Mine"):
			if child.has_method("get_settings") and child.get_settings().mine_name == current_mine_settings.mine_name:
				existing_mines += 1
	return existing_mines < current_mine_settings.max_count



func update_mine_label():
	if Utilities.game_mode_index == 1:
		icon_mine.texture = current_mine_settings.mine_icon
		lbl_name.text = current_mine_settings.mine_name
		lbl_mines.text = str(current_mine_settings.count_actual) + " / " + str(current_mine_settings.count_capacity)
	
	

func reload_all_mines():
	if current_mine_settings != null:
		current_mine_settings.count_actual = UserData.UserSettings["Mine"].count_capacity
		if Utilities.game_mode_index == 1:
			update_mine_label()
