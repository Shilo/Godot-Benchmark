extends Node2D

var ignore_chars_drawn: int = 18

@export_category("Benchmark")
@export var spawn_interval: float = 0.1
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
var duration: float

func _ready():
	if !font: font = ThemeDB.fallback_font
	context = RenderingServer.canvas_item_create()
	ignore_chars_drawn += get_ignore_name_chars_drawn()
	
	RenderingServer.canvas_item_set_parent(context, get_canvas_item())

func _process(delta: float):
	RenderingServer.canvas_item_clear(context)
	
	duration += delta
	var fps: int = round(Engine.get_frames_per_second())
	var drawn_objs: int = (Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME) as int) - last_chars_drawn
	var draw_calls: int = (Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME) as int) - last_chars_drawn
	
	var text: String = "%s\n(PRESS TO GO BACK)\n\nDURATION:   %.2f SECS\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		name.to_upper(),
		duration,
		fps,
		drawn_objs,
		draw_calls
	]
	
	font.draw_multiline_string(context, debug_position, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	
	if fps < fps_target:
		attempts += 1
		if attempts >= fps:
			finish(fps, drawn_objs, draw_calls)
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

func get_ignore_name_chars_drawn():
	var regex := RegEx.new()
	regex.compile("\\s")
	return regex.search_all(name).size()

func finish(fps: int, drawn_objs: int, draw_calls: int):
	get_tree().paused = true
	set_process(false)
	
	var done_position: Vector2 = get_viewport().size / 2
	done_position.x -= 100
	done_position.y += round(font_size)
	
	font.draw_multiline_string(context, done_position, "DONE", HORIZONTAL_ALIGNMENT_CENTER, 200, font_size*2)
	
	print("\n[BENCHMARK: %s]\nDATE:       %s\nDURATION:   %.2f SECS\nFRAMES/SEC: %s\nDRAWN OBJS: %s\nDRAW CALLS: %s" % [
		name.to_upper(),
		Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true),
		duration,
		fps,
		drawn_objs,
		draw_calls
	])
