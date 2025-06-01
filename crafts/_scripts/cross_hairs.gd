extends CenterContainer

@export var DOT_RADIUS : float = 1.0
@export var Clear_RADIUS : float = 5.0
@export var DOT_COLOR : Color = Color.WHITE
@export var CROSSHAIR_COLOR : Color = Color.WHITE
@export var CROSSHAIR_SIZE : float = 10.0
@export var CROSSHAIR_THICKNESS : float = 1.0
var color_timer: Timer

func _ready():
	queue_redraw()
	color_timer = Timer.new()
	color_timer.one_shot = true
	color_timer.wait_time = 1.0
	color_timer.connect("timeout", Callable(self, "_reset_crosshair_color"))
	add_child(color_timer)
	queue_redraw()

func _draw():
	draw_crosshairs(DOT_COLOR, CROSSHAIR_COLOR)

func draw_crosshairs(dot_color: Color, crosshair_color: Color):
	draw_circle(Vector2(50, 50), DOT_RADIUS, dot_color)
	draw_line(Vector2(-CROSSHAIR_SIZE + 50, 50), Vector2(-Clear_RADIUS + 50, 50), crosshair_color, CROSSHAIR_THICKNESS)
	draw_line(Vector2(Clear_RADIUS + 50, 50), Vector2(CROSSHAIR_SIZE + 50, 50), crosshair_color, CROSSHAIR_THICKNESS)
	draw_line(Vector2(50, -CROSSHAIR_SIZE + 50), Vector2(50, -Clear_RADIUS + 50), crosshair_color, CROSSHAIR_THICKNESS)
	draw_line(Vector2(50, Clear_RADIUS + 50), Vector2(50, CROSSHAIR_SIZE + 50), crosshair_color, CROSSHAIR_THICKNESS)

func colorCrossHairs(color_name: String, duration: float):
	CROSSHAIR_COLOR = get_color_from_name(color_name)
	DOT_COLOR = get_color_from_name(color_name)
	color_timer.wait_time = duration
	color_timer.start()
	queue_redraw()

func get_color_from_name(color_name: String) -> Color:
	match color_name:
		"RED":
			return Color.RED
		"GREEN":
			return Color.GREEN
		"BLUE":
			return Color.BLUE
		"YELLOW":
			return Color.YELLOW
		_:
			return Color.WHITE

func _reset_crosshair_color():
	CROSSHAIR_COLOR = Color.WHITE
	DOT_COLOR = Color.WHITE
	queue_redraw()
