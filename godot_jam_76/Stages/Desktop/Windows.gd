extends Node

@onready var window_scene : PackedScene = preload("res://Stages/Desktop/Applications/DesktopWindow.tscn")

# TODO : Prevent two identical windows from opening.
func open_window(application_name : String, window_content : PackedScene) -> void:
	var window : DesktopWindow = window_scene.instantiate();
	window.set_window_name(application_name);
	window.add_content(window_content);
	window.position = Vector2(50,50);
	add_child(window);
