extends Resource
class_name MineSettings

@export var mine_name: String = "Mine"
@export var mine_icon: Texture
@export var level_req: int = 1
@export var max_count: int = 1
@export var mine_lore: String = ""

@export var scan_time: float = 0.2
@export var cool_down: float = 0.5
@export var count_capacity: int = 1
@export var count_actual: int = 1
@export var mine_prefab: PackedScene
@export var explosion_prefab: PackedScene
@export var crater_prefab: PackedScene
@export var hit_points: float = 0.0
@export var explosive_force: float = 0.0
@export var explosive_force_distance: float = 0.0
@export var freeze_timer: float = 0.0;
@export var lay_sound: AudioStream
@export var unfreeze: bool = false
@export var triggerable: bool = false
@export var activation_range: float = 1.0
@export var life_span: float = 900.0
@export var friendly_fire: bool = false
