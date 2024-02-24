extends Node2D

const ignore_chars_drawn: int = 13

@export var font_size: int = 16
@export var font: Font

var context: RID
var last_chars_drawn: int

func _ready():
	if !font: font = ThemeDB.fallback_font
	context = RenderingServer.canvas_item_create()
	
	RenderingServer.canvas_item_set_parent(context, get_canvas_item())
	RenderingServer.canvas_item_set_transform(context, Transform2D(0, Vector2(16, 16 + font_size)))

func _process(delta: float):
	RenderingServer.canvas_item_clear(context)
	
	var drawn_objs: int = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME) - last_chars_drawn
	var draw_calls: int = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME) - last_chars_drawn
	
	var text: String = "%s\n(PRESS TO GO BACK)\n\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		name.to_upper(),
		Engine.get_frames_per_second(),
		drawn_objs,
		draw_calls
	]
	
	font.draw_multiline_string(context, Vector2.ZERO, text, 0, -1, font_size)
	
	last_chars_drawn = text.length() - ignore_chars_drawn

func _input(event: InputEvent):
	if event is not InputEventMouseButton || !event.is_pressed(): return
	
	get_tree().change_scene_to_file("res://Main/Main.tscn")
