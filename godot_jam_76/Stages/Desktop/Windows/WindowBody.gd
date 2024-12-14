extends CharacterBody2D

var draggingDistance : float;
var direction : Vector2;
var dragging : bool;
var newPosition : Vector2 = Vector2();

var mouse_in : bool = false;

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.is_pressed() && mouse_in):
			draggingDistance = position.distance_to(get_viewport().get_mouse_position());
			direction = (get_viewport().get_mouse_position() - position).normalized();
			dragging = true;
			newPosition = get_viewport().get_mouse_position() - draggingDistance * direction;
		else:
			dragging = false;
	elif (event is InputEventMouseMotion):
		if (dragging):
			newPosition = get_viewport().get_mouse_position() - draggingDistance * direction;

func _physics_process(_delta: float) -> void:
	if (dragging):
		velocity = (newPosition - position) * Vector2(30, 30);
		move_and_slide();

func _on_draggable_area_mouse_entered() -> void:
	print("Enter");
	mouse_in = true;

func _on_draggable_area_mouse_exited() -> void:
	print("Exit");
	mouse_in = false;
