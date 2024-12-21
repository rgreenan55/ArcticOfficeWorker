extends CharacterBody3D

const SPEED = 50.0
const JUMP_VELOCITY = 10

@onready var neck : Node3D = $Neck
@onready var view : Camera3D = $Neck/Camera


# Important Nodes
@onready var area: Node3D = $"../Objects/Computer/Screen/ScreenClickDetector"
@onready var viewport : SubViewport = $"../Objects/Computer/Screen/ViewportSizer/DesktopViewport";

# Mouse Variables
var mouse_in : bool = false;
var mouse_held : bool = false;
var mouse_out : bool = false;
var last_mouse_pos_3D : Vector3;
var last_mouse_pos_2D : Vector2;

# If User is viewing Computer
var in_computer_view : bool = false;

func _ready() -> void:
	#cameras[0].current = true;
	area.mouse_entered.connect(func(): mouse_in = true);
	area.mouse_exited.connect(func(): mouse_out = false);
	viewport.set_process_input(true);

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction := (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		if (event is InputEventMouseMotion):
			neck.rotate_y(-event.relative.x * 0.005);
			view.rotate_x(-event.relative.y * 0.005);
			view.rotation.x = clamp(view.rotation.x, deg_to_rad(-30), deg_to_rad(60));

	if (event is InputEventMouse):
		handle_mouse(event);
	else:
		viewport.push_input(event, true);

func handle_mouse(event : InputEventMouse) -> void:
	var area_size = area.get_node("Shape").shape.size;

	if (event is InputEventMouseButton):
		mouse_held = event.pressed;

	var mouse_pos_3D = find_mouse(event.position);
	if (mouse_pos_3D != null):
		mouse_pos_3D = area.global_transform.affine_inverse() * mouse_pos_3D;
		last_mouse_pos_3D = mouse_pos_3D;
	else:
		mouse_pos_3D = last_mouse_pos_3D;
	var mouse_pos_2D = Vector2(mouse_pos_3D.x , -mouse_pos_3D.y);

	# Converts to Area Size
	mouse_pos_2D.x += area_size.x / 2;
	mouse_pos_2D.y += area_size.y / 2;
	# Converts to a 0 to 1 percentage
	mouse_pos_2D.x /= area_size.x;
	mouse_pos_2D.y /= area_size.y;
	# Convert to viewport dimensions using percentage
	mouse_pos_2D.x *= viewport.size.x
	mouse_pos_2D.y *= viewport.size.y;

	# Set Event Position
	event.position = mouse_pos_2D;
	event.global_position = mouse_pos_2D;
	if (event is InputEventMouseMotion):
		if (last_mouse_pos_2D):
			event.relative = mouse_pos_2D - last_mouse_pos_2D;
		else:
			event.relative = Vector2(0,0);
	last_mouse_pos_2D = mouse_pos_2D;
	# Push Event to Viewport
	viewport.push_input(event);


func find_mouse(mouse_global_pos : Vector2):
	# Gets the Camera & 3D Space
	var camera : Camera3D = get_viewport().get_camera_3d();
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	# Set up Camera RayCast
	var rayparams : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	rayparams.from = camera.project_ray_origin(mouse_global_pos);
	rayparams.to = camera.project_position(mouse_global_pos, 100);
	# Ensure Collisions with Areas, not Bodies
	rayparams.collide_with_bodies = false;
	rayparams.collide_with_areas = true;
	# If it hits something, return the intersections, else nothing.
	var result = space_state.intersect_ray(rayparams);
	return result.position if !result.is_empty() else null;
