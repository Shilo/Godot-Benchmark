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
	
	var position: Vector2 = Vector2()
	position.x = randf_range(0, viewport_size.x - size.x)
	position.y = randf_range(0, viewport_size.y - size.y)
	
	RenderingServer.canvas_item_add_texture_rect(context, Rect2(position, size), sprite_texture)
