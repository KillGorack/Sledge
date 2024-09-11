extends Node3D

@export var max_health: int = 100000
var current_health: int = max_health
@export var explosion_scene: PackedScene
var parent_node: Node

func _ready():
	parent_node = get_parent()

func _process(_delta):
	if parent_node.global_transform.origin.y < -10:
		die()

func apply_damage(damage: int):
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		die()

func die():
	get_parent().show()
