extends Resource
class_name LevelSettings

@export var level_name: String = "Default Level"
@export var level_image: Texture
@export var level_scene: PackedScene
#@export var level_ambient_audio: AudioStream
@export var max_npc: int = 10
@export var npc_spawn_rate: int = 20
@export var creative_space: bool = false
