extends Node3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.0

var can_fire: bool = true

func _ready() -> void:
	if not projectile_scene:
		print("Projectile scene not assigned!")

func _process(delta: float) -> void:
	if Input.is_action_pressed("fire") and can_fire:
		fire_projectile()
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true

func fire_projectile() -> void:
	if projectile_scene:
		var projectile = projectile_scene.instantiate() as RigidBody3D
		projectile.global_transform.origin = global_transform.origin
		projectile.transform.basis = transform.basis
		get_parent().add_child(projectile)
