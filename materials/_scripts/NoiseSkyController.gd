extends Node

@export var environment: Environment
@export var auto_animate: bool = true

var sky_material: ShaderMaterial
var time_accumulator: float = 0.0

# Simple sky presets
var sky_presets = {
	"day": {
		"sky_top_color": Color(0.385, 0.454, 0.55),
		"sky_horizon_color": Color(0.646, 0.655, 0.67),
		"ground_color": Color(0.2, 0.169, 0.133),
		"cloud_density": 0.4
	},
	"sunset": {
		"sky_top_color": Color(0.8, 0.4, 0.2),
		"sky_horizon_color": Color(1.0, 0.6, 0.3),
		"ground_color": Color(0.3, 0.2, 0.1),
		"cloud_density": 0.6
	},
	"stormy": {
		"sky_top_color": Color(0.3, 0.3, 0.4),
		"sky_horizon_color": Color(0.4, 0.4, 0.5),
		"ground_color": Color(0.1, 0.1, 0.1),
		"cloud_density": 0.8
	},
	"alien": {
		"sky_top_color": Color(0.6, 0.2, 0.8),
		"sky_horizon_color": Color(0.3, 0.8, 0.4),
		"ground_color": Color(0.2, 0.1, 0.3),
		"cloud_density": 0.3
	}
}

func _ready():
	print("Noise Sky Controller: Starting setup...")
	
	if not environment:
		environment = load("res://materials/environments/noise_sky.tres")
		print("Loaded noise sky environment")
	
	if environment and environment.sky and environment.sky.sky_material:
		sky_material = environment.sky.sky_material as ShaderMaterial
		print("Sky material found and assigned")
	else:
		print("ERROR: Could not find sky material!")
	
	# Apply the environment to the scene
	apply_environment()
	print("Noise Sky Controller: Setup complete!")

func apply_environment():
	var camera = get_viewport().get_camera_3d()
	if camera:
		camera.environment = environment
		print("Environment applied to camera")
	else:
		# Try to find camera in parent
		var parent = get_parent()
		if parent:
			camera = parent.get_node_or_null("Camera3D")
			if camera:
				camera.environment = environment
				print("Environment applied to found camera")

func _process(delta):
	if auto_animate and sky_material:
		time_accumulator += delta
		# Animate cloud movement
		sky_material.set_shader_parameter("cloud_speed", 0.05)

# Set sky to a specific preset
func set_sky_preset(preset_name: String):
	if not sky_material or not sky_presets.has(preset_name):
		print("Sky preset not found: ", preset_name)
		return
	
	var preset = sky_presets[preset_name]
	sky_material.set_shader_parameter("sky_top_color", preset["sky_top_color"])
	sky_material.set_shader_parameter("sky_horizon_color", preset["sky_horizon_color"])
	sky_material.set_shader_parameter("ground_color", preset["ground_color"])
	sky_material.set_shader_parameter("cloud_density", preset["cloud_density"])
	
	print("Sky set to: ", preset_name)

# Adjust cloud parameters
func set_cloud_density(density: float):
	if sky_material:
		sky_material.set_shader_parameter("cloud_density", clamp(density, 0.0, 1.0))

func set_cloud_scale(scale: float):
	if sky_material:
		sky_material.set_shader_parameter("cloud_scale", clamp(scale, 0.1, 5.0))

func set_cloud_speed(speed: float):
	if sky_material:
		sky_material.set_shader_parameter("cloud_speed", clamp(speed, 0.0, 1.0))

# Quick sky variations
func randomize_clouds():
	if not sky_material:
		return
	
	set_cloud_density(randf_range(0.2, 0.9))
	set_cloud_scale(randf_range(0.5, 3.0))
	set_cloud_speed(randf_range(0.02, 0.2))
	print("Clouds randomized!")
