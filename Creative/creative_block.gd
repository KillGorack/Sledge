extends RigidBody3D

@onready var collider = $Collider
@onready var meshes = $Mesh
@onready var healthNode = $Health
@export var explosion_scene: PackedScene

var health_threshold: int = 150
var is_static: bool = true
var health_script: GDScript

func _ready():
	switch_body_mode("STATIC")
	health_script = healthNode.get_script() as GDScript


func _process(_delta):
	if healthNode and healthNode.has_method("return_health"):
		var health_points = healthNode.call("return_health")
		if health_points < health_threshold:
			react_to_low_health()

func apply_projectile_impulse(impulse: Vector3, _direction: Vector3):
	apply_central_impulse(impulse)
	
func react_to_low_health():
	switch_body_mode("RIGID")

func switch_body_mode(mode: String):
	if mode == "RIGID":
		self.axis_lock_linear_x = false
		self.axis_lock_linear_y = false
		self.axis_lock_linear_z = false
		self.axis_lock_angular_x = false
		self.axis_lock_angular_y = false
		self.axis_lock_angular_z = false
	elif mode == "STATIC":
		self.axis_lock_linear_x = true
		self.axis_lock_linear_y = true
		self.axis_lock_linear_z = true
		self.axis_lock_angular_x = true
		self.axis_lock_angular_y = true
		self.axis_lock_angular_z = true
