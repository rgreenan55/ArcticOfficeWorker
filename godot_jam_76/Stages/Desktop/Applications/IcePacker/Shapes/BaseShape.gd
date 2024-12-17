class_name BaseShape extends CharacterBody2D

signal shape_placed(shape_placed);

# Spawner Record
@export var spawner_origin : Area2D;

# Disables Movement if Placed
var is_shape_placed : bool = false;

# Info on Shape Placement
var placement_nodes : int;
var direction_info : Dictionary;
var ghost : Sprite2D;
var ghost_present : bool = false;
var storage : Array[Area2D] = [];

# Moving Variables
var draggingDistance : float;
var direction : Vector2;
var dragging : bool;
var newPosition : Vector2 = Vector2();
var prevPosition : Vector2 = position;

func _ready() -> void:
	# Check if requires nodes are set up:
	if (get_node_or_null("Sprite2D") == null): push_warning(name, ": No Sprite Shape");
	if (get_node_or_null("CollisionShape2D") == null): push_warning(name, ": No Collision Shape");
	if (get_node_or_null("AreaDetectors") == null): push_warning(name, ": No Area Detector Node");
	if (get_node_or_null("GrabbingAreas") == null): push_warning(name, ": No Grabbing Area Node");

	placement_nodes = get_node("AreaDetectors").get_child_count();
	for grabbing_area : Control in get_node("GrabbingAreas").get_children():
		grabbing_area.connect("gui_input", _on_grabbing_area_gui_input);
	if (randi_range(0,1) == 1): _horizontal_flip();

func _physics_process(_delta: float) -> void:
	if (dragging):
		velocity = (newPosition - position) * Vector2(30, 30);
		move_and_slide();
		var half_x = get_node("CollisionShape2D").shape.size.x / 2;
		var half_y = get_node("CollisionShape2D").shape.size.y / 2;
		# The +- 8 adds some room for placing on edges easier.
		position.x = clamp(position.x, half_x-8, 512 - half_x + 8);
		position.y = clamp(position.y, half_y-16-8, 340 - half_y + 8);
	elif (ghost_present):
		_remove_ghost();

func scale_shape(scale_amount : Vector2) -> void:
	get_node("Sprite2D").scale = scale_amount;
	get_node("CollisionShape2D").scale = scale_amount;
	get_node("GrabbingAreas").scale = scale_amount;

func _horizontal_flip() -> void:
	get_node("Sprite2D").flip_h = true;
	get_node("AreaDetectors").scale.x = -1;
	get_node("GrabbingAreas").scale.x = -1;

#region Tile Placement Functionality
func _get_closest_board_tile_direction() -> Dictionary:
	# Store Each Closest Vector
	var placement_areas : Array[Area2D] = [];
	var placement_vectors : Array[Vector2] = [];

	# Loop Through Shapes Detectors
	for detector : Area2D in get_node("AreaDetectors").get_children():
		var closest_area : Area2D = null;
		var closest_distance : float;
		var closest_direction : Vector2;

		# Grab all overlapping areas, and check for ONLY BoardTiles
		var detected_areas : Array[Area2D] = detector.get_overlapping_areas();
		detected_areas = detected_areas.filter(func(area): return area.is_in_group("BoardTile"));
		if (detected_areas.size() == 0): break;
		# For each detected BoardTile area, get the closest.
		for area in detected_areas:
			if (closest_area == null || detector.global_position.distance_to(area.global_position) < closest_distance):
				closest_area = area;
				closest_distance = detector.global_position.distance_to(area.global_position)
				closest_direction = detector.global_position.direction_to(area.global_position);
		var closest_vector : Vector2 = closest_distance * closest_direction;
		closest_vector.x = snapped(closest_vector.x, 0.001);
		closest_vector.y = snapped(closest_vector.y, 0.001);
		placement_vectors.push_back(closest_vector);
		placement_areas.push_back(closest_area);

	# Check if closest are all the same.
	if (placement_vectors.size() >= placement_nodes && placement_vectors.all(func(v): return v == placement_vectors.front())):
		return { "is_valid" : true, "vector": placement_vectors.front(), "areas": placement_areas }
	return { "is_valid" : false }
#endregion

#region Shape Dragging Functionality
func _on_grabbing_area_gui_input(event: InputEvent) -> void:
	if (is_shape_placed): return;
	if (event.is_action("LeftMouseButton")):
		if (event.is_pressed()):
			_grab_shape();
		else:
			_release_shape();
	elif (dragging && event is InputEventMouseMotion):
		_handle_dragging();

func _grab_shape() -> void:
	scale_shape(Vector2(1, 1));
	move_to_front();
	dragging = true;
	prevPosition = position;
	draggingDistance = position.distance_to(get_viewport().get_mouse_position());
	direction = (get_viewport().get_mouse_position() - position).normalized();
	newPosition = get_viewport().get_mouse_position() - draggingDistance * direction;

func _release_shape() -> void:
	dragging = false;
	direction_info = _get_closest_board_tile_direction(); # Required or shape will be slightly offset.
	if (direction_info.is_valid):
		for area : Area2D in direction_info.areas:
			area.monitorable = false;
			area.monitoring = false;
		position += direction_info.vector;
		_remove_ghost();
		is_shape_placed = true;
		get_node("PlaceTileAudio").play();
		shape_placed.emit(self);
	else:
		scale_shape(Vector2(0.5, 0.5));
		position = prevPosition;

func _handle_dragging() -> void:
	newPosition = get_viewport().get_mouse_position() - draggingDistance * direction;
	# Update Direction Info on Move
	direction_info = _get_closest_board_tile_direction();
	if (direction_info.is_valid):
		if (!ghost_present):
			_create_ghost();
			ghost_present = true;
		elif (!_compare_arrays(storage, direction_info.areas)):
			storage = direction_info.areas;
			_move_ghost();
	else:
		_remove_ghost()
		ghost_present = false;

func _compare_arrays(a1 : Array, a2 : Array) -> bool:
	if (a1.size() != a2.size()): return false;
	for item in a1:
		if (!a2.has(item)): return false;
	return true;
#endregion

#region Ghost Shape
# Creates Ghost Sprite for Placement
func _create_ghost() -> void:
	ghost = get_node("Sprite2D").duplicate();
	ghost.name = "Ghost";
	ghost.modulate.a = 0.5
	add_sibling(ghost);
	ghost.global_position = global_position + direction_info.vector;

# Removes Ghost Sprite
func _remove_ghost() -> void:
	if (ghost && is_instance_valid(ghost)): ghost.queue_free();

func _move_ghost() -> void:
	ghost.global_position = global_position + direction_info.vector;
#endregion
