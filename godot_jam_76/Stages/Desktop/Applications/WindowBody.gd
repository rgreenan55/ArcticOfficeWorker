class_name DesktopWindow extends CharacterBody2D

enum Status { Normal, Warning, Alert }
var current_status : Status;

@export var window_name : String;

var draggingDistance : float;
var direction : Vector2;
var dragging : bool;
var newPosition : Vector2 = Vector2();

func _ready() -> void:
	position.x = randf_range(0, 1280 - get_node("WindowControl").size.x);
	position.y = randf_range(32, 720 - get_node("WindowControl").size.y);

func set_window_name(window_name_string : String) -> void:
	window_name = window_name_string;
	%WindowLabel.text = window_name;

func _process(_delta: float) -> void:
	var get_status_callable : Callable = Callable(DesktopManager, window_name.replace(" ", "_").to_lower() + "_get_status");
	var status : Status = get_status_callable.call();
	if (current_status != status):
		current_status = status;
		get_node("%StatusSymbol").set_status(status);

# Handles movement when the window header is clicked & dragged.
func _on_window_header_gui_input(event: InputEvent) -> void:
	if (event.is_action("LeftMouseButton")):
		if (event.is_pressed()):
			draggingDistance = position.distance_to(get_viewport().get_mouse_position());
			direction = (get_viewport().get_mouse_position() - position).normalized();
			dragging = true;
			newPosition = get_viewport().get_mouse_position() - draggingDistance * direction;
		else:
			dragging = false;
	elif (dragging && event is InputEventMouseMotion):
		newPosition = get_viewport().get_mouse_position() - draggingDistance * direction;

func _physics_process(_delta: float) -> void:
	if (dragging):
		velocity = (newPosition - position) * Vector2(30, 30);
		move_and_slide();
	position.x = clamp(position.x, 0, 1280 - get_node("WindowControl").size.x)
	position.y = clamp(position.y, 32, 720 - get_node("WindowControl").size.y)

# Application is Deleted on X Button Press
func _on_exit_button_pressed() -> void:
	queue_free();

# Moves Window to Front when Clicked
func _on_window_control_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		move_to_front();

# Used to Add the desired Content to the Window
func add_content(content_scene : PackedScene) -> void:
	var content = content_scene.instantiate();
	content.connect("gui_input", _on_window_control_gui_input)
	$"%ContentContainer".add_child(content);

# Resize Window based on Content Size
func _on_content_container_child_entered_tree(node: Node) -> void:
	if (node.name == "ContentBackground"): return;
	get_node("WindowControl").size.x = node.size.x * node.scale.x;
	get_node("WindowControl").size.y = node.size.y * node.scale.y;
	get_node("CollisionShape2D").shape.size = get_node("WindowControl").size;
	get_node("CollisionShape2D").position = get_node("WindowControl").position + get_node("WindowControl").size / 2;
