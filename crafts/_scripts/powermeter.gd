extends Control


@export var radius: float = 88.0
@export var arc_thickness: float = 8.0
@export var start_angle: float = 90.0
@export var end_angle: float = -60.0

var current_power_ratio: float = 0.0

func _ready():
	pass

func _draw():
	var sweep_angle = lerp(0.0, end_angle - start_angle, current_power_ratio)
	var start_radians = deg_to_rad(start_angle)
	var sweep_radians = deg_to_rad(sweep_angle)
	var end_radians = deg_to_rad(-60.0)
	if current_power_ratio > 0.0:
		var center = size / 2
		draw_arc(
			center,
			radius,
			start_radians,
			end_radians,
			64,
			Color(0, 0, 0, 0.5),
			10,
			true
		)
		draw_arc(
			center,
			radius,
			start_radians,
			start_radians + sweep_radians,
			64,
			Color.YELLOW,
			arc_thickness,
			true
		)
		draw_arc(
			center,
			radius + 5,
			start_radians,
			end_radians,
			64,
			Color(0, 1, 0, 0.5),
			1,
			true
		)

func update_power_meter(power_ratio: float):
	current_power_ratio = clamp(power_ratio, 0.0, 1.0)
	if current_power_ratio == 0:
		current_power_ratio = 0.001
	queue_redraw()
