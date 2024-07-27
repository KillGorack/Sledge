extends Node3D

@export var destruction_delay: float = 1.2  # Delay before self-destruction in seconds

@onready var timer: Timer = Timer.new()

func _ready() -> void:
	# Add the Timer node as a child of the current node
	add_child(timer)
	
	# Set the timer's wait time
	timer.wait_time = destruction_delay
	timer.one_shot = true  # Ensure the timer only runs once
	
	# Connect the timer's timeout signal to the _on_Timer_timeout method
	timer.timeout.connect(_on_Timer_timeout)
	
	# Start the timer
	timer.start()

func _process(_delta: float) -> void:
	# Get the viewport
	var viewport = get_viewport()
	
	if viewport:
		# Get the camera from the viewport
		var camera = viewport.get_camera_3d()
		
		if camera:
			# Make the node face the camera
			look_at(camera.global_transform.origin, Vector3.UP)
		else:
			print("No 3D camera found in the viewport")
	else:
		print("No viewport found")

func _on_Timer_timeout() -> void:
	# Remove the node from its parent and free it from memory
	queue_free()
