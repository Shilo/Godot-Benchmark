class_name BaseBenchmark extends Node2D

var ignore_chars_drawn: int = 18 - 1 # minus one for background

@export_category("Benchmark")
@export var spawn_frame_interval: int = 1
@export var spawn_amount: int = 10
@export var fps_target: int = 60

@export_category("Interface")
@export var font_size: int = 16
@export var font: Font

signal spawn

var context: RID
var last_chars_drawn: int
var attempts: int
var debug_position: Vector2 = Vector2(16, 16 + font_size)
var duration: float
var frames: int

@onready var scene_name := get_parent().get_parent().name

func _ready():
	if !font: font = ThemeDB.fallback_font
	context = RenderingServer.canvas_item_create()
	ignore_chars_drawn += get_ignore_name_chars_drawn()
	
	RenderingServer.canvas_item_set_parent(context, get_canvas_item())

func _process(delta: float):
	RenderingServer.canvas_item_clear(context)
	
	frames += 1
	duration += delta
	
	var fps: int = round(Engine.get_frames_per_second())
	var drawn_objs: int = (Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME) as int) - last_chars_drawn
	var draw_calls: int = (Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME) as int) - last_chars_drawn
	
	var text: String = "%s\n(PRESS TO GO BACK)\n\nDURATION:   %.2f SECS\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		scene_name.to_upper(),
		duration,
		fps,
		drawn_objs,
		draw_calls
	]
	
	RenderingServer.canvas_item_add_rect(context, Rect2(0, 0, 350, 180), Color(0, 0, 0, 0.5))
	font.draw_multiline_string(context, debug_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	
	if fps < fps_target:
		attempts += 1
		if attempts >= fps:
			finish(fps, drawn_objs, draw_calls)
			return
	
	if frames >= spawn_frame_interval:
		frames = 0
		
		for i in spawn_amount:
			spawn.emit()
	
	last_chars_drawn = text.length() - ignore_chars_drawn

func _input(event: InputEvent):
	if ((event is not InputEventMouseButton || !event.is_pressed())
		&& !event.is_action_pressed("ui_cancel")): return
	
	get_tree().change_scene_to_file("res://Main/Main.tscn")

func get_ignore_name_chars_drawn():
	var regex := RegEx.new()
	regex.compile("\\s")
	return regex.search_all(scene_name).size()

func finish(fps: int, drawn_objs: int, draw_calls: int):
	get_tree().paused = true
	set_process(false)
	
	var done_width: int = 90
	var done_position: Vector2 = get_viewport().size / 2
	done_position.x -= done_width/2.0
	done_position.y += round(font_size)
	
	RenderingServer.canvas_item_add_rect(context, Rect2(done_position.x, done_position.y - font_size*2, done_width, font_size*2 + 10), Color(0, 0, 0, 0.5))
	font.draw_multiline_string(context, done_position, "DONE", HORIZONTAL_ALIGNMENT_CENTER, done_width, font_size*2)
	
	print("\n[BENCHMARK: %s]\nDATE:       %s\nDURATION:   %.2f SECS\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		scene_name.to_upper(),
		Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true),
		duration,
		fps,
		drawn_objs,
		draw_calls
	])
