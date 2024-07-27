extends RigidBody3D

@onready var raycast = $RayCast3D
@export var explosion_scene: PackedScene
@export var offset_distance: float = -0.25
@export var sound: AudioStream  # Assign your sound file to this variable in the Inspector
@export var impulse_strength: float = 10.0  # Adjust this value as needed

var initial_direction: Vector3  # Add this line

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	initial_direction = -transform.basis.z  # Store the initial direction

func _on_body_entered(body: Node):
	if body != self:
		raycast.enabled = true
		
		if raycast.is_colliding():
			# Get the projectile's current velocity direction
			var trajectory_direction = -linear_velocity.normalized()

			# Apply impulse to the collided body in the direction of the projectile's velocity
			if body is RigidBody3D:
				var impulse = trajectory_direction * impulse_strength
				body.apply_central_impulse(impulse)  # Apply impulse at the center of mass
				body.angular_velocity = Vector3.ZERO  # Set angular velocity to zero

			if explosion_scene:
				var explosion_instance = explosion_scene.instantiate()
				if get_parent():
					get_parent().add_child(explosion_instance)
					explosion_instance.global_transform.origin = global_transform.origin - trajectory_direction * offset_distance
					
					# Ensure the up vector is not perfectly aligned with the direction
					if absf(trajectory_direction.dot(Vector3.UP)) > 0.999:
						explosion_instance.look_at(global_transform.origin + trajectory_direction, Vector3.UP)
					else:
						explosion_instance.look_at(global_transform.origin + trajectory_direction, Vector3.UP)

			# Create a new AudioStreamPlayer3D at the point of collision
			var audio_player = AudioStreamPlayer3D.new()
			audio_player.stream = sound
			get_parent().add_child(audio_player)
			audio_player.global_transform.origin = global_transform.origin
			audio_player.play(0)

		queue_free()
