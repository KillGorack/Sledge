extends Node

@export var max_health: int = 100
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
	var explosion_instance = explosion_scene.instantiate()
	parent_node.get_parent().add_child(explosion_instance)
	explosion_instance.global_transform = parent_node.global_transform
	explosion_instance.scale = Vector3(3, 3, 3)
	parent_node.queue_free()
