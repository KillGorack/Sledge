extends RigidBody3D

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var sound: AudioStream
@export var impulse_strength: float = 10.0

var initial_position: Vector3
var has_started_moving: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float):
	if not has_started_moving and linear_velocity.length_squared() > 0.01:
		initial_position = global_transform.origin
		has_started_moving = true

func _on_body_entered(body: Node):
	if body != self:
		raycast.enabled = true
		if raycast.is_colliding():
			_apply_impulse(body)
			_create_explosion()
			_play_sound()
		queue_free()


func _apply_impulse(body: Node):
	if body is RigidBody3D:
		var force_direction = initial_position.direction_to(global_transform.origin)
		var impulse = force_direction * impulse_strength
		body.apply_central_impulse(impulse)
		body.angular_velocity = Vector3.ZERO


func _create_explosion():
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		if get_parent():
			get_parent().add_child(explosion_instance)
			explosion_instance.global_transform.origin = global_transform.origin


func _play_sound():
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = sound
	get_parent().add_child(audio_player)
	audio_player.global_transform.origin = global_transform.origin
	audio_player.play(0)
