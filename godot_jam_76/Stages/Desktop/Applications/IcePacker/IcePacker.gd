extends CenterContainer

func _on_gui_input(event: Variant) -> void:
	gui_input.emit(event);
