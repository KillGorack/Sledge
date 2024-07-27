extends RigidBody3D

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var offset_distance: float = -0.25
@export var sound: AudioStream
@export var impulse_strength: float = 10.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body != self:
		raycast.enabled = true
		
		if raycast.is_colliding():
			var trajectory_direction = -linear_velocity.normalized()
			
			if body is RigidBody3D:
				var impulse = trajectory_direction * impulse_strength
				body.apply_central_impulse(impulse)
				body.angular_velocity = Vector3.ZERO

			if explosion_scene:
				var explosion_instance = explosion_scene.instantiate()
				if get_parent():
					get_parent().add_child(explosion_instance)
					explosion_instance.global_transform.origin = global_transform.origin - trajectory_direction * offset_distance
					explosion_instance.look_at(global_transform.origin + trajectory_direction, Vector3.UP)

			var audio_player = AudioStreamPlayer3D.new()
			audio_player.stream = sound
			get_parent().add_child(audio_player)
			audio_player.global_transform.origin = global_transform.origin
			audio_player.play(0)

		queue_free()
