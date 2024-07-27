extends Node3D

@export var destruction_delay: float = 1.0

func _ready():
	var timer = Timer.new()
	timer.wait_time = destruction_delay
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()

func _on_timeout():
	queue_free()
