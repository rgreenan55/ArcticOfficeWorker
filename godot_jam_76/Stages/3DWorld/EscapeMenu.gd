extends Control

var paused : bool = false;

func _unhandled_input(event: InputEvent) -> void:
	if (get_node("../GameOver").visible == true): return;
	if (event.is_action_pressed("ui_cancel")):
		paused = !paused
		if (paused):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
			get_tree().paused = true;
			self.visible = true;
		else:
			get_tree().paused = false;
			self.visible = false
