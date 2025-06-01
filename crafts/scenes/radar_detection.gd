extends Area3D

@export var radar_ui: Control
@export var collider: CollisionShape3D
@export var lbl_zoom_factor: Label

var zoom_scale = [2.0, 1.00, 0.75, 0.50, 0.25]
var zoom_index = 0
var original_radius: float = 50
var tracked_objects = {}

var radar_targets = {
	"NPC_Enemy": {"color": Color.RED, "size": Vector2(4, 4)},
	"NPC_Friendly": {"color": Color.GREEN, "size": Vector2(4, 4)},
	"Recon": {"color": Color.WHITE, "size": Vector2(6, 6)},
	"Recon_Uncaptured": {"color": Color.DIM_GRAY, "size": Vector2(4, 4)},
	"Projectile_Friendly": {"color": Color.GREEN, "size": Vector2(1, 1)},
	"Projectile_Enemy": {"color": Color.RED, "size": Vector2(1, 1)},
	"Spawner": {"color": Color.YELLOW, "size": Vector2(5, 5)},
	"Mine_Friendly": {"color": Color.GREEN, "size": Vector2(2, 2)},
	"Loot": {"color": Color.WHITE, "size": Vector2(1, 1)},
	"Target_Beacon": {"color": Color.PURPLE, "size": Vector2(5, 5)}
}

func _ready():
	original_radius = collider.shape.radius
	connect("body_entered", Callable(self, "_on_area_3d_body_entered"))
	connect("body_exited", Callable(self, "_on_area_3d_body_exited"))
	set_physics_process(true)
	var radar_timer = Timer.new()
	radar_timer.wait_time = 2.0
	radar_timer.autostart = true
	radar_timer.connect("timeout", Callable(self, "_check_tracked_objects"))
	add_child(radar_timer)
	var player_dot = ColorRect.new()
	player_dot.size = Vector2(4, 4)
	player_dot.color = Color.GREEN
	player_dot.position = radar_ui.size / 2
	radar_ui.add_child(player_dot)
	update_radar_label()

func _check_tracked_objects():
	for body in tracked_objects.keys():
		if is_instance_valid(body):
			for group in radar_targets.keys():
				if body.is_in_group(group):
					tracked_objects[body].color = radar_targets[group]["color"]
					tracked_objects[body].size = radar_targets[group]["size"]
					break
		else:
			tracked_objects.erase(body)


func _physics_process(_delta):
	var parent_transform = get_parent().global_transform
	var new_position = Vector3(parent_transform.origin.x, 0, parent_transform.origin.z)
	var new_rotation = parent_transform.basis.get_rotation_quaternion()
	new_rotation.x = 0
	new_rotation.z = 0
	global_transform.origin = new_position
	global_transform.basis = Basis(new_rotation)
	if Input.is_action_just_pressed("radar_zoom"):
		adjust_zoom()
	update_radar()

func adjust_zoom():
	zoom_index = (zoom_index + 1) % zoom_scale.size()
	var new_radius = original_radius * zoom_scale[zoom_index]
	if collider.shape is CylinderShape3D:
		collider.shape.radius = new_radius
	update_radar_label()
	
func update_radar_label():
	var zoom_factor = collider.shape.radius / original_radius
	lbl_zoom_factor.text = str(round(zoom_factor * 100)) + "%"


func _on_area_3d_body_entered(body):
	for group in radar_targets.keys():
		if body.is_in_group(group):
			var dot = ColorRect.new()
			dot.size = radar_targets[group]["size"]
			dot.color = radar_targets[group]["color"]
			radar_ui.add_child(dot)
			tracked_objects[body] = dot

func _on_area_3d_body_exited(body):
	if tracked_objects.has(body):
		tracked_objects[body].queue_free()
		tracked_objects.erase(body)

func update_radar():
	for body in tracked_objects.keys():
		if is_instance_valid(body):
			var dot = tracked_objects[body]
			dot.position = world_to_radar(body.global_position)
		else:
			tracked_objects.erase(body)

func world_to_radar(self_position: Vector3) -> Vector2:
	var local_position = to_local(self_position)
	var radar_scale = radar_ui.size.x / max(collider.shape.radius * 2, 1)
	var centered_position = Vector2(local_position.x, local_position.z) * radar_scale
	centered_position += radar_ui.size / 2
	return centered_position
