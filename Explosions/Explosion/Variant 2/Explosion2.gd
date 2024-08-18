extends MeshInstance3D

@export var total_frames: int = 25
@export var fps: int = 48
@export var columns: int = 5
@export var rows: int = 5

var current_frame: int = 0
var time_accumulator: float = 0.0
var frame_size: Vector2
var shader_material: ShaderMaterial

func _ready() -> void:

	frame_size = Vector2(1.0 / columns, 1.0 / rows)
	shader_material = preload("res://Explosions/Explosion/Variant 2/ExplosionShaderMaterial2.tres").duplicate()

	if shader_material:
		shader_material.set_shader_parameter("frame_size", frame_size)
		shader_material.set_shader_parameter("columns", columns)
		shader_material.set_shader_parameter("rows", rows)
		shader_material.set_shader_parameter("frame", current_frame)
		self.material_override = shader_material
		
	var random_z_rotation = randf() * 360.0
	rotate_z(deg_to_rad(random_z_rotation))

func _process(delta: float) -> void:

	time_accumulator += delta
	var frame_time = 1.0 / fps
	
	while time_accumulator > frame_time:
		time_accumulator -= frame_time
		current_frame += 1
		if current_frame >= total_frames:
			current_frame = 0
			queue_free()

		if shader_material:
			shader_material.set_shader_parameter("frame", current_frame)
