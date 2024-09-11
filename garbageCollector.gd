extends Node3D

@export var destroy_time: float = 5.0

func _ready():
	await get_tree().create_timer(destroy_time).timeout
	queue_free()
