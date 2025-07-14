extends Node3D

@onready var sky_controller = $NoiseSkyController

func _ready():
	print("Proving Grounds level loaded with Simple Noise Sky!")
	print("Controls:")
	print("- 1: Day sky")
	print("- 2: Sunset sky") 
	print("- 3: Stormy sky")
	print("- 4: Alien sky")
	print("- R: Randomize clouds")
	print("- Plus/Minus: Adjust cloud density")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				sky_controller.set_sky_preset("day")
			KEY_2:
				sky_controller.set_sky_preset("sunset")
			KEY_3:
				sky_controller.set_sky_preset("stormy")
			KEY_4:
				sky_controller.set_sky_preset("alien")
			KEY_R:
				sky_controller.randomize_clouds()
			KEY_EQUAL: # Plus key
				adjust_cloud_density(0.1)
			KEY_MINUS:
				adjust_cloud_density(-0.1)

func adjust_cloud_density(change: float):
	var current = sky_controller.sky_material.get_shader_parameter("cloud_density")
	var new_density = clamp(current + change, 0.0, 1.0)
	sky_controller.set_cloud_density(new_density)
	print("Cloud density: ", new_density)
