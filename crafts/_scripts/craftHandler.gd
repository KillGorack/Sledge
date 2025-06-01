extends RigidBody3D

@onready var hud_in_game = $Hud_inGame
@onready var hud_load_out = $Hud_loadOut
@export var old_collider: CollisionShape3D
@export var old_ground_check: CollisionShape3D

var laserSettings: Resource
var missileSettings: Resource
var mineSettings: Resource
var craftSettings: Resource
var stop_forces: bool = false

func _ready() -> void:
	hud_in_game.visible = false
	hud_load_out.visible = true
	Utilities.set_allegiance(self, "Player")
	
func _physics_process(_delta: float) -> void:
	pass
	
func setCraftSettings():
	craftSettings = UserData.UserSettings["Craft"]
	if craftSettings:
		mass = craftSettings.mass
		center_of_mass = craftSettings.cg
	setCraftCollider(craftSettings.craft_collision_scene)
	self.sleeping = false


func setCraftCollider(new_collision_scene: PackedScene):
	if old_collider and old_ground_check:
		old_collider.queue_free()
		old_ground_check.queue_free()
		var new_collision_instance = new_collision_scene.instantiate()
		var new_collider = new_collision_instance.get_node("Collider")
		var new_ground_check = new_collision_instance.get_node("Ground_Check")
		if new_collider and new_ground_check:
			var new_collider_dup = new_collider.duplicate()
			var new_ground_check_dup = new_ground_check.duplicate()
			add_child(new_collider_dup)
			old_collider = new_collider_dup
			$GroundCheck.add_child(new_ground_check_dup)
			old_ground_check = new_ground_check_dup
			await get_tree().process_frame
			old_collider.name = "Collider"
			old_ground_check.name = "Collider"
			new_collision_instance.queue_free()






func apply_damage(damage: float) -> void:
	get_node("health_node").apply_direct_damage(damage)
	
func apply_directional_force(impulse: Vector3) -> void:
	stop_forces = true
	apply_central_impulse(impulse)
	await get_tree().create_timer(1.0).timeout
	stop_forces = false
