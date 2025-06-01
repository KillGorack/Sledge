extends Resource
class_name CraftSettings

@export var craft_name: String = "Default Craft"
@export var craft_image: Texture
@export var craft_lore: String
@export var craft_collision_scene: PackedScene
@export var engine_audio: AudioStream
@export var target_audio_pitch: float = 2.0
@export var max_speed: float = 6.0
@export var acceleration: float = 400.0
@export var deceleration: float = 100.0
@export var turn_speed: float = 3.0
@export var turn_acceleration:float = 12.0
@export var turn_deceleration:float = 25.0
@export var speed_threshold: float = 0.01
@export var right_side_up_threshold: float = 0.6
@export var unturtle_threshold: float = 0.3
@export var unturtle_force: float = 100.0
@export var thruster_force: float = 800.0
@export var rotation_speed: float =  25.0

# Weapon types avalable
@export var lasers: bool = false
@export var missiles: bool = false
@export var mines: bool = false

# Turret / Barrel movement
@export var look_sensitivity = 3
@export var recenter_speed = 10
@export var fine_aim_multiplier = 0.1

# physics stuff
@export var mass: float = 50.0
@export var cg: Vector3 = Vector3(0, -0.25, -0.25)

# Power
@export var power_capacity: float =  100
@export var power_gain_rate: float =  10
@export var max_effect_distance: float =  25.0

# Shield / Armor / Life regeneration (on repair pad)
@export var regeneration_delay: float = 5.0
@export var regeneration_rate: float = 10.0

# Health stuff
@export var shields: float = 100
@export var armor: float = 100
@export var life: float = 100
