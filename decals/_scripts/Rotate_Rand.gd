extends Node3D

@export_enum("X", "Y", "Z") var rotation_axis: String = "Z" # Default to Z-axis

func _ready():
	var axis_map = {
		"X": Vector3(1, 0, 0),
		"Y": Vector3(0, 1, 0),
		"Z": Vector3(0, 0, 1)
	}
	
	var random_rotation = randf_range(0, 360)
	rotate(axis_map[rotation_axis], deg_to_rad(random_rotation))
