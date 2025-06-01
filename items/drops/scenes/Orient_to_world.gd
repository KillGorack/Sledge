extends Node3D

func _physics_process(_delta):
	# Lock rotation to keep beam upright
	global_transform.basis = Basis()  

	# Keep position locked to the parent drop
	if get_parent():
		global_transform.origin = get_parent().global_transform.origin
