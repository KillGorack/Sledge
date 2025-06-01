extends Node3D

var craft_settings: CraftSettings = null

@export var powermeter_graphic: Control
@export var icon_node: Control

var lastIconState: bool = false
var currentPower: float = 5
var power_feed_icon = load("res://UI/Icons/power_feed.png") as Texture2D

func _ready():
	powermeter_graphic.update_power_meter(0)

func set_settings():
	craft_settings = UserData.UserSettings["Craft"]
	
func receive_powerup(amount: float) -> void:
	currentPower += amount
	if craft_settings.power_capacity < currentPower:
		currentPower = craft_settings.power_capacity
	var pr = currentPower / craft_settings.power_capacity
	powermeter_graphic.update_power_meter(pr)

func _process(delta: float) -> void:
	if craft_settings == null:
		return
	adjust_power_based_on_distance(delta)
	var pr = currentPower / craft_settings.power_capacity
	powermeter_graphic.update_power_meter(pr)

func adjust_power_based_on_distance(delta: float) -> void:
	var recon_nodes = get_tree().get_nodes_in_group("Recon")
	var total_power_gain = 0.0
	for recon_node in recon_nodes:
		if recon_node is Area3D:
			var distance = global_transform.origin.distance_to(recon_node.global_transform.origin)
			if distance <= craft_settings.max_effect_distance:
				var power_ratio = 1.0 - (distance / craft_settings.max_effect_distance)
				total_power_gain += craft_settings.power_gain_rate * power_ratio * delta
	currentPower = clamp(currentPower + total_power_gain, 0, craft_settings.power_capacity)
	var shouldActivateIcon = total_power_gain > 0
	if shouldActivateIcon != lastIconState:
		Utilities.add_icon(power_feed_icon, shouldActivateIcon)
		lastIconState = shouldActivateIcon

func spendPower(consumed: float):
	currentPower -= consumed

func getPower():
	return currentPower
