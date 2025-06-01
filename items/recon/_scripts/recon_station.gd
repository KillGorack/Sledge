extends Area3D

@export var reload_sound: AudioStream
@export var repair_rate: float = 10.0
@export var capture_device: PackedScene
@export var decal_uncaptured: Decal
@export var decal_captured: Decal
@export var capture_time: float
@export var increment_amount: float = 1
@export var increment_interval: float = 1.0

var ent: bool = false
var captured: bool = false
var inprogress: bool = false
var capturing: bool = false
var capture_instance: Node3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	decal_uncaptured.visible = true
	decal_captured.visible = false

	var timer = Timer.new()
	timer.wait_time = increment_interval
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_increment_resource"))
	add_child(timer)

func _increment_resource():
	if captured:
		Utilities.setResourceLevel(increment_amount)

func _physics_process(delta):
	if Input.is_action_just_pressed("CaptureCon"):
		if ent and not captured and not inprogress:
			start_capture()
	if capturing and capture_instance:
		update_capture_movement(delta)

func start_capture():
	if Utilities.getResourceLevel() < 0.5:
		Utilities.addMessage("Not enough resources for capture!")
		return
	Utilities.setResourceLevel(-0.5)
	inprogress = true
	var player_spawn = get_tree().get_nodes_in_group("PlayerSpawn")[0]
	if not player_spawn:
		return
	capture_instance = capture_device.instantiate()
	add_child(capture_instance)
	await get_tree().process_frame
	capture_instance.global_position = player_spawn.global_position + Vector3(0, 15, 0)
	capturing = true

func update_capture_movement(delta):
	if not capture_instance:
		return
	var target_xz = Vector3(global_position.x, capture_instance.global_position.y, global_position.z)
	var target_y = Vector3(target_xz.x, global_position.y + 3, target_xz.z)
	var speed = 10
	if capture_instance.global_position.distance_to(target_xz) > 0.1:
		var direction_xz = (target_xz - capture_instance.global_position).normalized()
		capture_instance.global_position += direction_xz * speed * delta
	else:
		if abs(capture_instance.global_position.y - target_y.y) > 0.1:
			var direction_y = Vector3(0, -1, 0)
			capture_instance.global_position += direction_y * speed * delta
		else:
			finalize_capture()

func finalize_capture():
	capturing = false
	capture_instance.get_node("Emmiter").visible = true
	await get_tree().create_timer(capture_time).timeout
	capture_instance.queue_free()
	decal_uncaptured.visible = false
	decal_captured.visible = true
	var detect = get_node_or_null("ForDetectionOnly")
	if detect:
		detect.remove_from_group("Recon_Uncaptured")
		detect.add_to_group("Recon")
		add_to_group("Recon")
	captured = true
	Utilities.addMessage("Recon tapped!")

func _on_body_entered(body):
	ent = true
	if body.is_in_group("Player") && captured:
		var health_node = body.get_node("health_node") if body.has_node("health_node") else null
		if health_node and health_node.has_method("set_on_repair_pad"):
			health_node.set_on_repair_pad(true)
		Utilities.play_sound(reload_sound, global_transform.origin)
		_trigger_reload_weapons(body)
		_trigger_reload_mines(body)

func _on_body_exited(body):
	ent = false
	if body.is_in_group("Player"):
		var health_node = body.get_node("health_node") if body.has_node("health_node") else null
		if health_node and health_node.has_method("set_on_repair_pad"):
			health_node.set_on_repair_pad(false)

func _trigger_reload_weapons(body):
	var turret_node = body.get_node("Turret") if body.has_node("Turret") else null
	if turret_node:
		var barrel_node = turret_node.get_node("Barrel") if turret_node.has_node("Barrel") else null
		if barrel_node and barrel_node.has_method("reload_all_weapons"):
			barrel_node.reload_all_weapons()

func _trigger_reload_mines(body):
	var mines_node = body.get_node("mine_node") if body.has_node("mine_node") else null
	if mines_node and mines_node.has_method("reload_all_mines"):
		mines_node.reload_all_mines()
