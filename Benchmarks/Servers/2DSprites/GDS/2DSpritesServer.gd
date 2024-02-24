extends Node2D

var sprite_texture: Texture2D = load("res://icon.svg")

func _ready():
	get_node("%Benchmark").spawn.connect(spawn)

func spawn():
	var sprite := Sprite2D.new()
	sprite.texture = sprite_texture
	
	var viewport_size: Vector2 = get_viewport().size
	var half_size := sprite.texture.get_size() / 2
	sprite.position.x = randf_range(half_size.x, viewport_size.x - half_size.x)
	sprite.position.y = randf_range(half_size.y, viewport_size.y - half_size.y)
	add_child(sprite)
