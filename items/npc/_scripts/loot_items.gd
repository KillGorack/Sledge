extends Node3D

@export var loot_resources: Array[LootSettings]

func _ready() -> void:
	pass
	
func get_items() -> Array[LootSettings]:
	return loot_resources
