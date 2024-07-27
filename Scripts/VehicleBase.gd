extends RigidBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera: Camera3D

@export var camera_node_path: NodePath
@export var engine_audio_path: NodePath

func _ready():
	camera = get_node(camera_node_path) as Camera3D

func _physics_process(delta):
	pass
