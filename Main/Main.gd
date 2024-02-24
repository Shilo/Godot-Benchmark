extends Control

@export var root_scene_path: String = "Benchmarks/"
@export var quit_button: Button

func _enter_tree():
	get_tree().paused = false

func _ready():
	if quit_button:
		quit_button.pressed.connect(get_tree().quit)
	
	foreach_button(
		func(button: Button):
			button.pressed.connect(self.button_pressed.bind(button))
	)

func button_pressed(button: Button):
	var scene_path = button.name.replace("_", "/") + ".tscn"
	get_tree().change_scene_to_file(root_scene_path + scene_path)

func foreach_button(callable: Callable, parent: Node = self):
	for child in parent.get_children():
		if child is Button && child != quit_button:
			callable.call(child)
		foreach_button(callable, child)
