extends Node3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0

var can_fire: bool = true

func _ready() -> void:
	# Ensure projectile scene is set
	if not projectile_scene:
		print("Projectile scene not assigned!")

func _process(delta: float) -> void:
	# Check for firing input
	if Input.is_action_pressed("fire") and can_fire:
		fire_projectile()
		can_fire = false
		# Reset firing ability after delay
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true

func fire_projectile() -> void:
	# Instantiate projectile
	if projectile_scene:
		var projectile = projectile_scene.instantiate() as RigidBody3D
		# Set initial position and direction
		projectile.global_transform.origin = global_transform.origin
		projectile.transform.basis = transform.basis
		get_parent().add_child(projectile)
