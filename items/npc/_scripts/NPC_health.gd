extends Node3D

@export var explosion: PackedScene
@export var shield_mesh: MeshInstance3D
@export var shield_mesh_b: MeshInstance3D
@export var smoke_node: Node3D
@export var item_drop: Node3D
@export var life: float = 100.0
@export var armor: float = 100.0
@export var shield: float = 100.0
@export var Interactive: bool = false
@export var VCredit: int = 0
var life_original: float
var parent_node = get_parent()
var death_bit: bool = false
var death_bit_b: bool = false
var last_velocity: Vector3
var boss_mode: bool = false


func _ready() -> void:
	armor = armor * ((UserData.game_level / 10.0))
	shield = shield * ((UserData.game_level / 10.0))
	life_original = life
	parent_node = get_parent()
	if smoke_node:
		smoke_node.visible = false




func setBossMode(switch):
	var npc_scale: float = 1.25
	if switch:
		boss_mode = true
		armor *= 50
		shield *= 50
		var Turret = get_parent().get_node_or_null("Turret")
		var Body = get_parent().get_node_or_null("Body")
		var Col = get_parent().get_node_or_null("Collider")
		if Turret && Body && (Col && Col is CollisionShape3D):
			Turret.scale = Vector3(npc_scale, npc_scale, npc_scale)
			Body.scale = Vector3(npc_scale, npc_scale, npc_scale)
			Col.shape = Col.shape.duplicate()
			Col.shape.size *= Vector3(npc_scale, npc_scale, npc_scale)



func getBossMode():
	return boss_mode


func _process(_delta: float) -> void:
	if global_transform.origin.y < -25:
		destroy_self()





func apply_direct_damage(damage: float) -> void:
	apply_damage(damage)
	if life <= 0:
		if death_bit == false:
			UserData.game_vanquishes += VCredit
			UserData.calculate_level()
			death_bit = true
		destroy_self()





func apply_damage(damage: float) -> void:
	if shield > 0:
		shield -= damage
		if shield <= 0:
			if shield_mesh and is_instance_valid(shield_mesh): 
				shield_mesh.visible = false
			if shield_mesh_b and is_instance_valid(shield_mesh_b): 
				shield_mesh_b.visible = false
			damage = -shield
			shield = 0
		else:
			return
	if armor > 0 and damage > 0:
		armor -= damage
		if armor < 0:
			damage = -armor
			armor = 0
		else:
			return
	if damage > 0:
		life -= damage
	if life <= life_original * 0.7 and Interactive == true:
		if parent_node and parent_node.has_method("setFreezeState"):
			parent_node.call("setFreezeState", false)
	if life <= 0.25 * life_original and smoke_node.visible == false:
		if smoke_node and is_instance_valid(smoke_node): 
			smoke_node.visible = true
			







func destroy_self() -> void:
	if death_bit_b == false:
		death_bit_b = true
		if explosion:
			var instance = explosion.instantiate()
			instance.global_transform = global_transform
			get_parent().get_parent().add_child(instance)
			call_deferred("_set_instance_properties", instance)

		Utilities.addMessage("NPC Object destroyed")
		if item_drop:
			item_drop.drop_items()
		get_parent().queue_free()


func _set_instance_properties(instance: Node) -> void:
	instance.global_transform.origin = global_transform.origin
	instance.scale = Vector3(5, 5, 5)
