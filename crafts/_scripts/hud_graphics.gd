extends Control

@export var circle_thickness: float = 4.0
var circle_radius: float = 75
var shield_progress: float
var armor_progress: float
var life_progress: float

func _ready():
	pass

func _draw() -> void:
	var center = size / 2
	draw_circle(center, circle_radius + circle_thickness + 3, Color(0, 0, 0, 0.5))
	draw_arc(
		center,
		circle_radius + circle_thickness + 3,
		0,
		PI * 2,
		64,
		Color(0, 1, 0, 0.5),
		1.0 , true
	)
	draw_arc(
		center,
		circle_radius,
		0,
		PI * 2 * shield_progress,
		64,
		Color(1.0, shield_progress, shield_progress),
		circle_thickness,
		true
	)
	draw_arc(
		center,
		circle_radius - 8,
		0,
		PI * 2 * armor_progress,
		64,
		Color(1.0, armor_progress, armor_progress),
		circle_thickness,
		true
	)
	draw_arc(
		center,
		circle_radius - 16,
		0,
		PI * 2 * life_progress,
		64,
		Color(1.0, life_progress, life_progress),
		circle_thickness,
		true
	)

func set_circle_properties(progress: float, category: String) -> void:
	match category:
		"shield":
			shield_progress = clamp(progress, 0.0, 1.0)
		"armor":
			armor_progress = clamp(progress, 0.0, 1.0)
		"life":
			life_progress = clamp(progress, 0.0, 1.0)
	queue_redraw()
