extends CenterContainer

func _on_button_left_pressed() -> void:
	get_node("SnowTransportGame").move_player_left();

func _on_button_right_pressed() -> void:
	get_node("SnowTransportGame").move_player_right();


func _on_gui_input(event: InputEvent) -> void:
	gui_input.emit(event);
