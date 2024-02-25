extends Node2D

var BODY: PackedScene = load("res://Benchmarks/Nodes/2DPhysics/GDS/IconBody.tscn")

func _ready():
	get_node("%Benchmark").spawn.connect(spawn)

func spawn():
	var body = BODY.instantiate()
	
	var viewport_size: Vector2 = get_viewport().size
	var half_size: Vector2 = body.get_node("Sprite").texture.get_size() / 2
	body.position.x = randf_range(half_size.x, viewport_size.x - half_size.x)
	body.position.y = -half_size.y
	add_child(body)
