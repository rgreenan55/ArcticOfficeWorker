extends Node

func open_window(window_path : String) -> void:
	var window_scene : PackedScene = load(window_path);
	var window = window_scene.instantiate();
	#window.position = size / 2
	add_child(window);
