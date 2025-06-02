extends RigidBody3D

@onready var area = $Area3D
@onready var flair = $Flair
var loot_settings: LootSettings

#enum LootMath { ADD, SET, MULTIPLY }

func apply_loot_settings(settings: LootSettings):
	loot_settings = settings
	Utilities.GarbageCollection(self, loot_settings.loot_life)
	if loot_settings.loot_drop_rate <= 0.01:
		flair.visible = true

func _ready():
	area.body_entered.connect(_on_body_entered)
	

func _on_body_entered(body):
	if body.collision_layer == 1:
		
		Utilities.addMessage(loot_settings.loot_name + " found.")
		Utilities.play_sound(loot_settings.loot_sound, global_transform.origin, 3)

		match loot_settings.loot_type:

			LootSettings.LootType.Health:
				var health_node = body.get_node_or_null("health_node")
				if health_node:
					health_node.receive_powerup(loot_settings.loot_param_increase)
					
					
					
					
			LootSettings.LootType.Power:
				var pwrNode = body.get_node_or_null("power_node")
				if pwrNode:
					pwrNode.receive_powerup(loot_settings.loot_param_increase)
					
					
					
					
			LootSettings.LootType.Weapon:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup(loot_settings.loot_param_increase)
						
						
						
						
			LootSettings.LootType.Mine:
				var mineNode = body.get_node_or_null("mine_node")
				if mineNode:
					mineNode.receive_powerup(loot_settings.loot_param_increase)
					
					
					
					
			LootSettings.LootType.Epoc:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "projectile_count", loot_settings.loot_duration, 2, loot_settings.loot_math, loot_settings.loot_icon)
						BarrelNode.receive_powerup_param(0.125, "projectile_spacing", loot_settings.loot_duration, 2, 1)
						
						
						
			LootSettings.LootType.Critical:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "crit_chance", loot_settings.loot_duration, 2, loot_settings.loot_math, loot_settings.loot_icon)
						BarrelNode.receive_powerup_param(10, "crit_multiplier", loot_settings.loot_duration, 2, 1)



			LootSettings.LootType.Explosive:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "hit_points", loot_settings.loot_duration, 0, 2, loot_settings.loot_icon)
						BarrelNode.receive_powerup_param(100, "explosive_force", loot_settings.loot_duration, 0, 1)
						BarrelNode.receive_powerup_param(5, "explosive_force_distance", loot_settings.loot_duration, 0, 1)
						BarrelNode.receive_powerup_param(100, "body_collection_max", loot_settings.loot_duration, 0, 1)
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "crit_chance", loot_settings.loot_duration, 0, 1)
						BarrelNode.receive_powerup_param(10, "crit_multiplier", loot_settings.loot_duration, 0, 1)





			LootSettings.LootType.Ricochet:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "projectile_ricochet_count", loot_settings.loot_duration, 1, 0, loot_settings.loot_icon)
						
							
			LootSettings.LootType.Seeker:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup_param(1, "targeting_system", loot_settings.loot_duration, 1, 1, loot_settings.loot_icon)
						BarrelNode.receive_powerup_param(12, "target_rotation_speed", loot_settings.loot_duration, 1, 1)
						BarrelNode.receive_powerup_param(250, "target_system_scan_radius", loot_settings.loot_duration, 1, 1)
						BarrelNode.receive_powerup_param(0, "targeting_system_require_marker", loot_settings.loot_duration, 1, 1)
						BarrelNode.receive_powerup_param(0, "projectile_spin", loot_settings.loot_duration, 1, 1)
						
						
						

			LootSettings.LootType.Shield:
				var health_node = body.get_node_or_null("health_node")
				if health_node:
					health_node.receive_powerup_param(loot_settings.loot_param_increase, "shields", loot_settings.loot_duration)
					
					
					
					
			LootSettings.LootType.Haste:
				var TurretNode = body.get_node_or_null("Turret")
				if TurretNode:
					var BarrelNode = TurretNode.get_node_or_null("Barrel")
					if BarrelNode:
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "cool_down", loot_settings.loot_duration, 2, 2)
						BarrelNode.receive_powerup_param(loot_settings.loot_param_increase, "projectile_speed", loot_settings.loot_duration, 2, 2)
				var movementNode = body.get_node_or_null("Movement")
				if movementNode:
					movementNode.receive_powerup_param(loot_settings, "max_speed", 2)
					movementNode.receive_powerup_param(loot_settings, "acceleration", 2)
					movementNode.receive_powerup_param(loot_settings, "turn_speed", 2)
			_:
				pass
				
	queue_free()
