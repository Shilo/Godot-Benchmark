extends Node2D

var sprite_texture: Texture2D = load("res://icon.svg")

var context: RID

func _ready():
	context = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(context, get_canvas_item())
	
	get_node("%Benchmark").spawn.connect(spawn)

func spawn():
	var viewport_size: Vector2 = get_viewport().size
	var size := sprite_texture.get_size()
	
	var texture_position: Vector2 = Vector2()
	texture_position.x = randf_range(0, viewport_size.x - size.x)
	texture_position.y = randf_range(0, viewport_size.y - size.y)
	
	RenderingServer.canvas_item_add_texture_rect(context, Rect2(texture_position, size), sprite_texture)
