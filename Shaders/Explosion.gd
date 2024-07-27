extends MeshInstance3D

@export var total_frames: int = 36
@export var fps: int = 48
@export var columns: int = 6 # Number of columns in the texture sheet
@export var rows: int = 6 # Number of rows in the texture sheet

var current_frame: int = 0
var time_accumulator: float = 0.0
var frame_size: Vector2
var shader_material: ShaderMaterial

func _ready() -> void:
	# Calculate frame size
	frame_size = Vector2(1.0 / columns, 1.0 / rows)
	
	# Duplicate the shader material for each instance
	shader_material = preload("res://Shaders/ExplosionShaderMaterial.tres").duplicate()
	
	# Set up shader parameters
	if shader_material:
		shader_material.set_shader_parameter("frame_size", frame_size)
		shader_material.set_shader_parameter("columns", columns)
		shader_material.set_shader_parameter("rows", rows)
		shader_material.set_shader_parameter("frame", current_frame)
		self.material_override = shader_material

func _process(delta: float) -> void:
	# Update animation
	time_accumulator += delta
	var frame_time = 1.0 / fps
	
	while time_accumulator > frame_time:
		time_accumulator -= frame_time
		current_frame += 1
		if current_frame >= total_frames:
			current_frame = 0
			queue_free() # Remove the mesh after the animation completes

		# Update the shader parameter
		if shader_material:
			shader_material.set_shader_parameter("frame", current_frame)
