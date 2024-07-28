extends CenterContainer

@export var DOT_RADIUS : float = 1.0
@export var Clear_RADIUS : float = 5.0
@export var DOT_COLOR : Color = Color.WHITE
@export var CROSSHAIR_COLOR : Color = Color.WHITE
@export var CROSSHAIR_SIZE : float = 10.0
@export var CROSSHAIR_THICKNESS : float = 1.0

func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2(50, 50), DOT_RADIUS, DOT_COLOR)
	draw_line(Vector2(-CROSSHAIR_SIZE + 50, 50), Vector2(-Clear_RADIUS + 50, 50), CROSSHAIR_COLOR, CROSSHAIR_THICKNESS)
	draw_line(Vector2(Clear_RADIUS + 50, 50), Vector2(CROSSHAIR_SIZE + 50, 50), CROSSHAIR_COLOR, CROSSHAIR_THICKNESS)
	draw_line(Vector2(50, -CROSSHAIR_SIZE + 50), Vector2(50, -Clear_RADIUS + 50), CROSSHAIR_COLOR, CROSSHAIR_THICKNESS)
	draw_line(Vector2(50, Clear_RADIUS + 50), Vector2(50, CROSSHAIR_SIZE + 50), CROSSHAIR_COLOR, CROSSHAIR_THICKNESS)
