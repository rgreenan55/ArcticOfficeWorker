extends Control

func _on_retry_pressed() -> void:
	get_tree().paused = false;
	get_tree().reload_current_scene();

func _on_quit_pressed() -> void:
	get_tree().paused = false;
	get_tree().change_scene_to_file("res://Stages/Title.tscn");
