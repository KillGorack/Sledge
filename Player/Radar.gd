extends TextureRect

# ======================================
# Radar
# ======================================

@export var radar_radius: float = 25.0
@export var npc_dot_color: Color = Color(1, 0, 0)
@export var recon_dot_color: Color = Color(0, 1, 0)
@export var player_dot_color: Color = Color(0, 1, 0)
@export var dot_radius: float = 5.0

var radar_scales = [5.0, 25.0, 50.0, 100.0]
var current_scale_index = 3

var camera: Camera3D
var radar_center: Vector2





func _ready():
	camera = get_parent().get_parent().get_node("Camera3D")
	radar_center = size / 2
	set_pivot_offset(radar_center)
	queue_redraw()





func _process(delta):
	if Input.is_action_just_pressed("RadarZoom"):
		current_scale_index = (current_scale_index + 1) % radar_scales.size()
		radar_radius = radar_scales[current_scale_index]
		queue_redraw()
	if camera:
		var camera_forward = camera.global_transform.basis.z.normalized()
		rotation = atan2(camera_forward.x, camera_forward.z)
	queue_redraw()





func _draw():
	var player_position = get_parent().get_parent().global_transform.origin
	draw_dot(radar_center, player_dot_color)
	var npc_nodes = get_tree().get_nodes_in_group("NPC")
	for node in npc_nodes:
		draw_node_on_radar(node, player_position, npc_dot_color)
	var recon_nodes = find_recon_nodes(get_tree().root)
	for node in recon_nodes:
		draw_node_on_radar(node, player_position, recon_dot_color)





func draw_node_on_radar(node: Node3D, player_position: Vector3, color: Color):
	var radar_position = position_on_radar(node.global_transform.origin, player_position)
	if radar_position != Vector2.INF:
		draw_dot(radar_position, color)





func draw_dot(position: Vector2, color: Color):
	draw_circle(position, dot_radius, color)





func position_on_radar(node_position: Vector3, player_position: Vector3) -> Vector2:
	var relative_position = Vector2(node_position.x, node_position.z) - Vector2(player_position.x, player_position.z)
	if relative_position.length_squared() <= radar_radius * radar_radius:
		return radar_center + (relative_position / radar_radius) * radar_center
	return Vector2.INF





func find_recon_nodes(node: Node) -> Array:
	var recon_nodes = []
	if node.is_in_group("Recon"):
		recon_nodes.append(node)
	for child in node.get_children():
		if child is Node:
			recon_nodes.append_array(find_recon_nodes(child))
	return recon_nodes
