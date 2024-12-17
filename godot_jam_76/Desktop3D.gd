extends Node3D

#var mesh_size = Vector2();

@onready var area : Area3D = $RayCastCatcher;
@onready var viewport : SubViewport = $DesktopViewport;

var mouse_entered : bool = false;
var mouse_held : bool = false;
var mouse_exited : bool = false;

var last_mouse_pos_3D : Vector3;
var last_mouse_pos_2D : Vector2;

func _ready() -> void:
	area.mouse_entered.connect(func(): mouse_entered = true);
	#area.mouse_exited.connect(func(): mouse_exited = false);
	viewport.set_process_input(true);

func _process(delta: float) -> void:
	var camera = $Camera3D
	if (Input.is_action_just_pressed("ui_left")):
		camera.rotation.y += 1;
	if (Input.is_action_just_pressed("ui_right")):
		camera.rotation.y -= 1;


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouse):
		handle_mouse(event);
	else:
		viewport.push_input(event, true);

func handle_mouse(event : InputEventMouse) -> void:
	var area_size = area.get_node("CollisionShape3D").shape.size;

	if (event is InputEventMouseButton):
		mouse_held = event.pressed;

	var mouse_pos_3D = find_mouse(get_viewport().get_mouse_position());
	mouse_pos_3D *= Vector3(1000, 1000, 1);
	if (mouse_pos_3D != null):
		mouse_pos_3D = area.global_transform.affine_inverse() * mouse_pos_3D;
		last_mouse_pos_3D = mouse_pos_3D;
	else:
		mouse_pos_3D = last_mouse_pos_3D;

	var mouse_pos_2D = Vector2(mouse_pos_3D.x , -mouse_pos_3D.y);
	# Converts to Area Size
	mouse_pos_2D.x += area_size.x / 2;
	mouse_pos_2D.y += area_size.y / 2;

	## Unneed Code?
	#print(mouse_pos_2D);
	## Converts to a 0 to 1 percentage
	#mouse_pos_2D.x /= area_size.x;
	#mouse_pos_2D.y /= area_size.y;
	#print(mouse_pos_2D);
	## Convert to viewport range 0 to viewport size
	#mouse_pos_2D.x /= viewport.size.x
	#mouse_pos_2D.y /= viewport.size.y;
	#print(mouse_pos_2D, "\n");

	# Set Event Position
	event.position = mouse_pos_2D;
	event.global_position = mouse_pos_2D;
	if (event is InputEventMouseMotion):
		if (last_mouse_pos_2D):
			event.relative = mouse_pos_2D - last_mouse_pos_2D;
		else:
			event.relative = Vector2(0,0);
	last_mouse_pos_2D = mouse_pos_2D;
	viewport.push_input(event);


func find_mouse(mouse_global_pos : Vector2):
	# Gets the Camera & 3D Space
	var camera : Camera3D = get_viewport().get_camera_3d();
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	# Set up Camera RayCast
	var rayparams : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	rayparams.from = camera.project_ray_normal(mouse_global_pos);
	rayparams.to = rayparams.from + camera.project_ray_normal(mouse_global_pos) * -1000;
	# Ensure Collisions with Areas, not Bodies
	rayparams.collide_with_bodies = false;
	rayparams.collide_with_areas = true;
	# If it hits something, return the intersections, else nothing.
	var result = space_state.intersect_ray(rayparams);
	if (result.size() > 0): return result.position;
	return null;
