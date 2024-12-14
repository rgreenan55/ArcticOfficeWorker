extends Control

func _get_drag_data(at_position: Vector2) -> Variant:
	var data = make_data();
	set_drag_preview(make_preview(data));
	return data;
