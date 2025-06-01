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


func _ready():
	set_process_input(false)
	Utilities.game_mode_changed.connect(_on_game_mode_changed)



func receive_powerup_param(amount, setting_name: String, duration: float, target, method: String, icon: Texture2D = null):
	if icon:
		Utilities.add_icon(icon, true)
	amount = float(amount) 
	if target == 0 || target == 2:
		var originala = UserData.UserSettingsStellar["primaryWeapon"].get(setting_name)
		reversion_timer(setting_name, originala, 0, duration, icon)
		if method == "add":
			weaponArray[0].set(setting_name, originala + amount)
		elif method == "multiply":
			weaponArray[0].set(setting_name, originala * amount)
		elif method == "set":
			weaponArray[0].set(setting_name, amount)
		UserData.UserSettings["primaryWeapon"] = weaponArray[0]
	if target == 1 || target == 2:
		var originalb = UserData.UserSettingsStellar["secondaryWeapon"].get(setting_name)
		reversion_timer(setting_name, originalb, 1, duration, icon)
		if method == "add":
			weaponArray[1].set(setting_name, originalb + amount)
		elif method == "multiply":
			weaponArray[1].set(setting_name, originalb * amount)
		elif method == "set":
			weaponArray[1].set(setting_name, amount)
		UserData.UserSettings["secondaryWeapon"] = weaponArray[1]
	update_ammo_display()





func _revert_setting(setting_name: String, value: float, target, icon: Texture2D):
	if icon:
		Utilities.add_icon(icon, false)
	if target == 0 || target == 2:
		UserData.UserSettings["primaryWeapon"].set(setting_name, value)
		weaponArray[0] = UserData.UserSettings["primaryWeapon"]
	if target == 1 || target == 2:
		UserData.UserSettings["secondaryWeapon"].set(setting_name, value)
		weaponArray[1] = UserData.UserSettings["secondaryWeapon"]
	update_ammo_display()



func reversion_timer(setting_name, original_Value, target, duration, icon: Texture2D):
	var key = str(target) + "_" + setting_name
	if active_timers.has(key):
		active_timers[key].queue_free()
		active_timers.erase(key)
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_revert_setting").bind(setting_name, original_Value, target, icon))
	add_child(timer)
	timer.start()
	active_timers[key] = timer

	
	
	
	
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
