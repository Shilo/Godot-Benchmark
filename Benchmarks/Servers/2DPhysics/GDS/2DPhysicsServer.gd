extends Node2D

var sprite_texture: Texture2D = load("res://icon.svg")

var camera: Camera2D
var camera_bounds: Rect2

var body_sprites: Dictionary

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
	var size: Vector2 = sprite_texture.get_size()
	var body = new_body()
	
	var body_position: Vector2 = Vector2.ZERO
	body_position.x = randf_range(camera_bounds.position.x, camera_bounds.position.x + camera_bounds.size.x - size.x)
	body_position.y = camera_bounds.position.y - size.y
	
	var body_transform = Transform2D(0, body_position)
	PhysicsServer2D.body_set_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM, body_transform)
	RenderingServer.canvas_item_set_transform(body_sprites[body], body_transform)

func get_camera_bounds() -> Rect2:
	var size = get_viewport_rect().size / camera.zoom
	var camera_position = camera.global_position - size / 2
	return Rect2(camera_position, size)

func new_body() -> RID:
	var size := sprite_texture.get_size()
	
	var body = PhysicsServer2D.body_create()
	var body_shape = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(body_shape, size/2)
	
	PhysicsServer2D.body_set_space(body, get_world_2d().space)
	PhysicsServer2D.body_add_shape(body, body_shape)
	var sprite = RenderingServer.canvas_item_create()
	
	RenderingServer.canvas_item_add_texture_rect(sprite, Rect2(0, 0, size.x, size.y), sprite_texture)
	RenderingServer.canvas_item_set_parent(sprite, get_canvas_item())
	
	body_sprites[body] = sprite
	return body

func _physics_process(_delta):
	for body in body_sprites:
		var sprite = body_sprites[body]
		var body_transform = PhysicsServer2D.body_get_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM)
		RenderingServer.canvas_item_set_transform(sprite, body_transform)

func _exit_tree():
	for body in body_sprites:
		var sprite = body_sprites[body]
		PhysicsServer2D.free_rid(body)
		RenderingServer.free_rid(sprite)
