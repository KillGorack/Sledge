extends Node3D

@export var max_drops: int = 25
@export var chance_multiplier: float = 0.8
@export var loot_container: PackedScene
@onready var loot_default_scene = preload("res://items/drops/scenes/default_loot.tscn")
var bossBit: bool = false


func _ready():
	pass




func drop_items():
	var health_node = get_parent().get_node_or_null("Health")
	if health_node:
		bossBit = health_node.getBossMode()
	if bossBit:
		chance_multiplier = 1
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var drop_count = calculate_drop_count(rng)
	if drop_count == 0:
		return
	for i in range(drop_count):
		var selected_loot = pick_loot(rng)
		if selected_loot:
			drop_item(selected_loot, i)





func calculate_drop_count(rng: RandomNumberGenerator) -> int:
	var count = 0
	while count < max_drops:
		if rng.randf() < chance_multiplier ** (count + 1): 
			count += 1
		else:
			break
	return count





func pick_loot(rng: RandomNumberGenerator) -> LootSettings:
	var loot_candidates = []
	var loot_instance = loot_container.instantiate()
	for loot in loot_instance.loot_resources:
		if rng.randf() < loot.loot_drop_rate:
			loot_candidates.append(loot)
	loot_instance.queue_free()
	if loot_candidates.size() > 0:
		return loot_candidates.pick_random()
	return null









func drop_item(loot: LootSettings, index: int):
	if loot:
		var item_instance = loot_default_scene.instantiate()
		get_parent().get_parent().add_child(item_instance)
		item_instance.global_transform.origin = global_transform.origin + Vector3(0, (index * 0.25), 0)

		if item_instance.has_method("apply_loot_settings"):
			item_instance.apply_loot_settings(loot)
			
		if item_instance.has_node("Icon"):
			var icon_mesh = item_instance.get_node("Icon")
			if icon_mesh:
				var material = icon_mesh.material_override.duplicate() if icon_mesh.material_override else StandardMaterial3D.new()
				material.albedo_texture = loot.loot_icon
				material.emission_texture = loot.loot_icon
				material.emission_energy = 2
				icon_mesh.material_override = material



		if item_instance is RigidBody3D:
			item_instance.apply_central_impulse(Vector3(randf_range(-0.5, 0.5), 1, randf_range(-0.5, 0.5)))
