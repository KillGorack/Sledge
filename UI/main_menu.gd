extends Control

@onready var play_button = $PlayButton
@onready var world_dropdown = $WorldDropdown
@onready var quit_button = get_parent().get_node("QuitButton")

@export var world_scene_1: PackedScene
@export var world_scene_2: PackedScene
@export var world_scene_3: PackedScene
@export var world_scene_4: PackedScene

var world_instance: Node = null

func _ready():

	world_dropdown.selected = 0
	play_button.connect("pressed", Callable(self, "_on_PlayButton_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_QuitButton_pressed"))

func _on_PlayButton_pressed():
	get_parent().hide()
	load_selected_world()

func load_selected_world():
	var selected_scene: PackedScene = null
	match world_dropdown.selected:
		0:
			selected_scene = world_scene_1
		1:
			selected_scene = world_scene_2
		2:
			selected_scene = world_scene_3
		3:
			selected_scene = world_scene_4
			
	if selected_scene:
		world_instance = selected_scene.instantiate()
		get_tree().root.add_child(world_instance)
		world_instance.global_transform.origin = Vector3(0, 0, 0)
	else:
		print("World scene not assigned!")

func _input(event):
	if event.is_action_pressed("MainMenu"):
		unload_world()
		get_parent().show()

func unload_world():
	if world_instance:
		world_instance.queue_free()
		world_instance = null

func _on_QuitButton_pressed():
	get_tree().quit()
