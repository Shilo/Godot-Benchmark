extends Node2D

const ignore_chars_drawn: int = 13

@export_category("Benchmark")
@export var spawn_interval: float = 1
@export var fps_target: int = 30

@export_category("Interface")
@export var font_size: int = 16
@export var font: Font

signal spawn

var context: RID
var last_chars_drawn: int
var attempts: int
var time: float
var debug_position: Vector2 = Vector2(16, 16 + font_size)

func _ready():
	if !font: font = ThemeDB.fallback_font
	context = RenderingServer.canvas_item_create()
	
	RenderingServer.canvas_item_set_parent(context, get_canvas_item())

func _process(delta: float):
	RenderingServer.canvas_item_clear(context)
	
	var fps: int = Engine.get_frames_per_second()
	var drawn_objs: int = (Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME) as int) - last_chars_drawn
	var draw_calls: int = (Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME) as int) - last_chars_drawn
	
	var text: String = "%s\n(PRESS TO GO BACK)\n\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		name.to_upper(),
		fps,
		drawn_objs,
		draw_calls
	]
	
	font.draw_multiline_string(context, debug_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	
	if fps < fps_target:
		attempts += 1
		if attempts >= fps:
			finish()
			return
	
	time += delta
	if time >= spawn_interval:
		time -= spawn_interval
		spawn.emit()
	
	last_chars_drawn = text.length() - ignore_chars_drawn

func _input(event: InputEvent):
	if ((event is not InputEventMouseButton || !event.is_pressed())
		&& !event.is_action_pressed("ui_cancel")): return
	
	get_tree().change_scene_to_file("res://Main/Main.tscn")

func finish():
	get_tree().paused = true
	set_process(false)
	
	var done_position: Vector2 = get_viewport().size / 2
	done_position.x -= 100
	done_position.y += round(font_size)
	
	font.draw_multiline_string(context, done_position, "DONE", HORIZONTAL_ALIGNMENT_CENTER, 200, font_size*2)
