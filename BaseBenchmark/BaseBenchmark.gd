extends Node2D

@export var font_size: int = 16
@export var font: Font

var context: RID

func _ready():
	if !font: font = ThemeDB.fallback_font
	context = RenderingServer.canvas_item_create()
	
	RenderingServer.canvas_item_set_parent(context, get_canvas_item())
	RenderingServer.canvas_item_set_transform(context, Transform2D(0, Vector2(16, 16 + font_size)))

func _process(delta: float):
	RenderingServer.canvas_item_clear(context)
	
	var text: String = "%s\n\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		name.to_upper(),
		Engine.get_frames_per_second(),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	]
	
	font.draw_multiline_string(context, Vector2.ZERO, text, 0, -1, font_size)
