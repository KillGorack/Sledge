extends MeshInstance3D

@onready var txtr_weapon_icon = $"../../Hud_inGame/txtr_weapon_icon"
@onready var lbl_weapon_name = $"../../Hud_inGame/lbl_weapon_name"
@onready var lbl_shots_left = $"../../Hud_inGame/lbl_shots_left"
@onready var camera3D = $Camera3D
@onready var power_node = $"../../power_node"
@onready var icon_node = $"../../Hud_inGame/Icons"
@onready var raycast = $TargetCast
@export var target_scene: PackedScene

var weaponArray: Array[Resource] = []
var stellar_Deep_Copy: Array[Resource] = []

var current_weapon_index: int = 0
var shoot_timer = 0.0 
var active_timers = {}
var active_powerups: Dictionary = {}
var active_powerup_timers: Dictionary = {}

func _ready():
	set_process_input(false)
	Utilities.game_mode_changed.connect(_on_game_mode_changed)


func receive_powerup_param(amount, setting_name: String, duration: float, target, method: int, icon: Texture2D = null):
	if target == 0 or target == 2:
		_apply_powerup_to_weapon(0, amount, setting_name, duration, method, icon)
	if target == 1 or target == 2:
		_apply_powerup_to_weapon(1, amount, setting_name, duration, method, icon)
	update_ammo_display()

func _apply_powerup_to_weapon(index: int, amount: float, setting_name: String, duration: float, method: int, icon: Texture2D = null):
	var key = str(index) + "_" + setting_name
	if active_powerups.has(key):
		var old_icon = null
		if active_powerup_timers.has(key):
			old_icon = active_powerup_timers[key].get("icon", null)
		_revert_setting(setting_name, index, old_icon, key)
		if active_powerup_timers.has(key):
			var prev = active_powerup_timers[key]
			if prev.has("timer"):
				prev["timer"].queue_free()
			active_powerup_timers.erase(key)
	await get_tree().process_frame
	var setting_key = "primaryWeapon" if index == 0 else "secondaryWeapon"
	var original = UserData.UserSettingsStellar[setting_key].get(setting_name)
	active_powerups[key] = {
		"setting": setting_name,
		"weapon": index,
		"icon": icon,
	}
	if icon:
		Utilities.update_hud_icon(icon, true)
	match method:
		0:
			UserData.UserSettings[setting_key].set(setting_name, original + amount)
		1:
			UserData.UserSettings[setting_key].set(setting_name, amount)
		2:
			UserData.UserSettings[setting_key].set(setting_name, original * amount)
	weaponArray = [
		UserData.UserSettings["primaryWeapon"].duplicate(true),
		UserData.UserSettings["secondaryWeapon"].duplicate(true)
	]
	_reversion_timer(setting_name, index, duration, key, icon)

func _revert_setting(setting_name: String, target, icon: Texture2D, key):
	active_powerups.erase(key)
	if icon:
		Utilities.update_hud_icon(icon, false)
	if target == 0 || target == 2:
		UserData.UserSettings["primaryWeapon"].set(setting_name, UserData.UserSettingsStellar["primaryWeapon"].get(setting_name))
		weaponArray[0] = UserData.UserSettings["primaryWeapon"]
	if target == 1 || target == 2:
		UserData.UserSettings["secondaryWeapon"].set(setting_name, UserData.UserSettingsStellar["secondaryWeapon"].get(setting_name))
		weaponArray[1] = UserData.UserSettings["secondaryWeapon"]
	update_ammo_display()

func _reversion_timer(setting_name: String, index: int, duration: float, key: String, icon: Texture2D = null) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	add_child(timer)
	timer.start()
	active_powerup_timers[key] = {
		"timer": timer,
		"icon": icon
	}
	await timer.timeout
	if not is_instance_valid(self):
		return
	if active_powerups.has(key):
		var stored_icon = null
		if active_powerup_timers.has(key):
			stored_icon = active_powerup_timers[key].get("icon", null)
		_revert_setting(setting_name, index, stored_icon, key)
	active_powerup_timers.erase(key)
	timer.queue_free()


	
	




	




	
func receive_powerup(amount):
	weaponArray[1].projectile_count_actual += amount
	if weaponArray[1].projectile_count_actual > weaponArray[1].projectile_count_capacity:
		weaponArray[1].projectile_count_actual = weaponArray[1].projectile_count_capacity
	update_ammo_display()



func _on_game_mode_changed():
	update_weapon_ui()
	update_ammo_display()

	

func _physics_process(delta):
	if shoot_timer > 0:
		shoot_timer -= delta
	if Input.is_action_pressed("FireWeapon") and shoot_timer <= 0:
		fire_weapon()




func load_weapons():
	if not UserData.UserSettings.has("primaryWeapon") or not UserData.UserSettings.has("secondaryWeapon"):
		return
	weaponArray = [
		UserData.UserSettings["primaryWeapon"].duplicate(true),
		UserData.UserSettings["secondaryWeapon"].duplicate(true)
	]
	current_weapon_index = 1
	switch_weapon()
	update_weapon_ui()
	update_ammo_display()
	set_process_input(true)
	
	
	

func _input(event):
	if Utilities.game_mode_index == 0:
		if event.is_action_pressed("weapon_change"):
			switch_weapon()
		if event.is_action_pressed("paint_target"):
			place_target()
		if event.is_action_pressed("unpaint_target"):
			kibash_target()

func fire_weapon():	
	if weaponArray.is_empty() || Utilities.game_mode_index != 0:
		return
		
	var weapon_settings = null
	
	if current_weapon_index == 0:
		weapon_settings = weaponArray[0]
	else:
		weapon_settings = weaponArray[1]

	if not weapon_settings:
		return
	if shoot_timer > 0:
		return
	if power_node.getPower() < weapon_settings.power_consumption:
		return
	if weapon_settings.projectile_count_capacity != 0:  # If NOT unlimited
		if weapon_settings.projectile_count_actual < weapon_settings.projectile_count:
			return
		weapon_settings.projectile_count_actual -= weapon_settings.projectile_count
	power_node.spendPower(weapon_settings.power_consumption)
	update_ammo_display()
	shoot_timer = weapon_settings.cool_down
	var projectile_scene: PackedScene = weapon_settings.projectile_prefab
	if not projectile_scene:
		return
	var direction = -camera3D.global_transform.basis.z.normalized()
	var right = camera3D.global_transform.basis.x.normalized()
	var up = camera3D.global_transform.basis.y.normalized()
	var angle_step = 360.0 / weapon_settings.projectile_count
	for i in range(weapon_settings.projectile_count):
		var angle = deg_to_rad(weapon_settings.projectile_start_angle + (i * angle_step))
		var offset = (right * cos(angle) + up * sin(angle)) * weapon_settings.projectile_spacing
		var spawn_position = camera3D.global_position + offset + (direction * weapon_settings.launch_offset)
		var projectile_instance = projectile_scene.instantiate()
		Utilities.set_allegiance(projectile_instance, "Projectile_Friendly")
		if projectile_instance:
			projectile_instance.position = spawn_position
			projectile_instance.rotation = camera3D.global_rotation
			projectile_instance.linear_velocity = direction * weapon_settings.projectile_speed
			var world_parent = get_parent().get_parent().get_parent()
			if world_parent:
				world_parent.add_child(projectile_instance)
	Utilities.play_sound(weapon_settings.launch_sound, global_transform.origin, 3)
	get_parent().get_parent().apply_central_impulse(weapon_settings.projectile_recoil * direction)


func reload_all_weapons():
	weaponArray[0].projectile_count_actual = weaponArray[0].projectile_count_capacity
	weaponArray[1].projectile_count_actual = weaponArray[1].projectile_count_capacity
	update_weapon_ui()
	update_ammo_display()
	



func switch_weapon():
	if weaponArray.is_empty():
		return
	current_weapon_index = (current_weapon_index + 1) % weaponArray.size()
	if current_weapon_index == 0:
		UserData.current_weapon = "primaryWeapon"
	else:
		UserData.current_weapon = "secondaryWeapon"
		
	update_weapon_ui()
	update_ammo_display()



func update_ammo_display():
	var weapon_settings = weaponArray[current_weapon_index]
	if not weapon_settings:
		lbl_shots_left.text = "Error"
		return
	if weapon_settings.power_consumption > 0:
		lbl_shots_left.text = "Power"
	elif weapon_settings.projectile_count_capacity == 0:
		lbl_shots_left.text = "Unlimited"
	else:
		lbl_shots_left.text = str(weapon_settings.projectile_count_actual) + " / " + str(weapon_settings.projectile_count_capacity)







func update_weapon_ui():
	if Utilities.game_mode_index == 0:
		if weaponArray.is_empty():
			txtr_weapon_icon.texture = null
			lbl_weapon_name.text = "No Weapon Selected"
		else:
			txtr_weapon_icon.texture = weaponArray[current_weapon_index].weapon_icon
			lbl_weapon_name.text = weaponArray[current_weapon_index].weapon_name


func place_target():
	kibash_target()
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collision_object = raycast.get_collider()
		if target_scene and collision_object:
			var target_instance = target_scene.instantiate()
			collision_object.add_child(target_instance)
			target_instance.global_transform.origin = collision_point + (collision_normal * 0.01)
			var loc_basis = Basis.looking_at(-collision_normal, Vector3.UP)
			target_instance.global_transform.basis = loc_basis
			
func kibash_target():
	var existing_targets = get_tree().get_nodes_in_group("Target_Beacon")
	for target in existing_targets:
		target.queue_free()
