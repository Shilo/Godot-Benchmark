extends Node

@export var sprite_texture: Texture2D

@onready var scene = get_parent()

func _ready():
	scene.spawn.connect(spawn)

func spawn():
	var sprite := Sprite2D.new()
	sprite.texture = sprite_texture
	
	var viewport_size: Vector2 = get_viewport().size
	var half_size := sprite.texture.get_size() / 2
	sprite.position.x = randf_range(half_size.x, viewport_size.x - half_size.x)
	sprite.position.y = randf_range(half_size.y, viewport_size.y - half_size.y)
	scene.add_child(sprite)
