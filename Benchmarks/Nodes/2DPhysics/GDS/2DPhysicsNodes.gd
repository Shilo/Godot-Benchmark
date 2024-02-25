extends Node2D

var BODY: PackedScene = load("res://Benchmarks/Nodes/2DPhysics/GDS/IconBody.tscn")
var camera: Camera2D
var camera_bounds: Rect2

func _ready():
	camera = get_node("%Camera2D")
	camera.position = get_viewport().size / 2
	camera_bounds = get_camera_bounds()
	
	var ground: CollisionShape2D = get_node("%Ground")
	
	for x in range(0, 2):
		var wall = ground.duplicate()
		wall.shape = RectangleShape2D.new()
		wall.shape.size = ground.shape.size
		wall.position = camera.position
		
		var offset = (camera_bounds.size.x + ground.shape.size.x) / 2
		if x == 0: offset = -offset
		wall.position.x += offset
		wall.position.y -= camera_bounds.size.y / 2
		wall.shape.size.y = camera_bounds.size.y + camera_bounds.size.y
		
		var wall_body = StaticBody2D.new()
		wall_body.add_child(wall)
		add_child(wall_body)
	
	ground.position = camera.position
	ground.position.y += (camera_bounds.size.y + ground.shape.size.y) / 2
	ground.shape.size.x = camera_bounds.size.x * 2
	ground.shape = ground.shape.duplicate() # fix bug with Rapier 2D Physics engine
	
	get_node("%Benchmark").spawn.connect(spawn)

func spawn():
	var body = BODY.instantiate()
	
	var half_size: Vector2 = body.get_node("Sprite").texture.get_size() / 2
	body.position.x = randf_range(camera_bounds.position.x + half_size.y, camera_bounds.position.x + camera_bounds.size.x - half_size.x)
	body.position.y = camera_bounds.position.y - half_size.y
	add_child(body)

func get_camera_bounds() -> Rect2:
	var size = get_viewport_rect().size / camera.zoom
	var camera_position = camera.global_position - size / 2
	return Rect2(camera_position, size)
