extends Resource
class_name WeaponSettings


# Directed energy
# Explosive missile
# Repulsor missile
# Magnetic rail
# Artillary
# Specials

enum WeaponType { Default, Force, Pierce, Explosive, Bounce }
@export var weapon_type: WeaponType = WeaponType.Default

@export var weapon_name: String = "Default Weapon"
@export var weapon_lore: String = ""
@export var weapon_icon: Texture
@export var level_req: int = 1
@export var sizing_scale: int = 1
@export var hit_points: float = 0.0
@export var crit_chance: float = 0.0
@export var crit_multiplier: float = 1.0
@export var cool_down: float = 0.5

@export var projectile_prefab: PackedScene
@export var explosion_prefab: PackedScene
@export var bullet_hole_prefab: PackedScene
@export var critical_hit_prefab: PackedScene

@export var launch_sound: AudioStream
@export var hit_sound: AudioStream
@export var crit_sound: AudioStream

@export var power_consumption: float = 0.0 #
@export var projectile_count_capacity: int = 1 # 0 is infinite
@export var projectile_count_actual: int = 1

@export var projectile_pierce_count: int = 0
@export var projectile_ricochet_count: int = 0
@export var bounce_count: int = 0
@export var freeze_timer: float = 0.0
@export var unfreeze: bool = false
@export var projectile_force: float = 0.0
@export var bi_directional: bool = false

@export var explosive_force: float = 0.0
@export var explosive_force_distance: float = 0.0
@export var body_collection_max: int = 0

@export var targeting_system: bool = false
@export var targeting_system_require_marker: bool = true
@export var target_rotation_speed: float = 0.0
@export var target_system_scan_radius: float = 40

@export var projectile_count: int = 1
@export var projectile_spacing: float = 0.0
@export var projectile_start_angle: float = 0.0

@export var projectile_recoil: float = 0.0

@export var projectile_range: float = 100.0
@export var projectile_speed: float = 45.0
@export var projectile_spin: float = 0.0

@export var launch_offset: float = -0.5
@export var projectile_fire_delay: float = 0.0
@export var projectile_destruction_delay: float = 0.0
@export var friendly_fire: bool = false
@export var turncoat: String = ""

@export var use_gravity: bool = false
