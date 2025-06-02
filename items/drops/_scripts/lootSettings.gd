extends Resource
class_name LootSettings

enum LootType { Health, Power, Weapon, Mine, Shield, Epoc, Ricochet, Seeker, Critical, Powerless, Explosive, Haste }
@export var loot_type: LootType = LootType.Health

enum LootTarget { Missile, Laser, Both, Neither }
@export var loot_target: LootTarget = LootTarget.Missile

enum LootMath { ADD, SET, MULTIPLY }
@export var loot_math: LootMath = LootMath.ADD



@export var loot_name: String = "Default loot"
@export var loot_icon: Texture2D
@export var loot_param_increase: float = 0.0
@export var loot_drop_rate: float = 0.0
@export var loot_life: float = 0.0
@export var loot_temp_effect: bool = false
@export var loot_duration: float = 30.0
@export var loot_sound: AudioStream
@export var loot_level: int = 1
