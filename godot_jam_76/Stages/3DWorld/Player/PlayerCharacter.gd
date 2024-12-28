extends CharacterBody3D

const SPEED = 50.0
const JUMP_VELOCITY = 10

@onready var neck : Node3D = $Neck
@onready var normal_view : Camera3D = $Neck/Camera
@onready var transition_camera: Camera3D = $Neck/TransitionCamera
@onready var interact_label : Label = $Neck/Camera/InteractLabel
@onready var crosshair: TextureRect = $Neck/Camera/Crosshair

# Computer Views
@onready var computer_views : Array[Camera3D] = [
	$"../Objects/Computer/CloseCamera",
	$"../Objects/Computer/ScreenCamera",
	$"../Objects/Computer/RealisticCamera",
]
@onready var computer_view_index : int = 0;

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

# If User is in World
var interactable_hover : Node3D;

func _ready() -> void:
	DesktopManager.reset();
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	DesktopManager.connect("game_over", handle_game_over)
	DesktopManager.connect("exit_computer", transition_to_world);
	area.mouse_entered.connect(func(): mouse_in = true);
	area.mouse_exited.connect(func(): mouse_out = false);
	viewport.set_process_input(true);

func _process(_delta: float) -> void:
	if (in_computer_view):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _physics_process(delta: float) -> void:
	if (in_computer_view): return;
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction := (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if (!get_node("Footsteps").playing): get_node("Footsteps").play();
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if (get_node("Footsteps").playing): get_node("Footsteps").stop();
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if (in_computer_view):
		handle_computer_view(event);
	else:
		handle_world_view(event);

#region Handle Inputs per View
# Pass events to computer
func handle_computer_view(event: InputEvent) -> void:
	if (interact_label.visible): interact_label.visible = false;
	if (event is InputEventMouse):
		handle_mouse_computer(event);
	elif (event.is_action_pressed("SwapCameras")):
		computer_view_index = (computer_view_index + 1) % 3
		computer_views[computer_view_index].make_current();
	else:
		viewport.push_input(event, true);

func handle_world_view(event: InputEvent) -> void:
	# Handle Mouse Movement
	if (event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		neck.rotate_y(-event.relative.x * 0.005);
		normal_view.rotate_x(-event.relative.y * 0.005);
		normal_view.rotation.x = clamp(normal_view.rotation.x, deg_to_rad(-45), deg_to_rad(60));
		# Get Areas Mouse Hovers Over
		var collisions = find_mouse_collisions(event.position);
		if (collisions && collisions.collider.has_method("interact")):
			interact_label.visible = true;
			interactable_hover = collisions.collider;
		else:
			interact_label.visible = false;
			interactable_hover = null;
	# Interact with Interactables
	elif (event.is_action_pressed("Interact") && interactable_hover != null):
		if (interactable_hover.has_method("interact")):
			interactable_hover.interact();
#endregion

#region Transition Camera Functions
func transition_to_computer() -> void:
	# Swap to transiton camera
	transition_camera.global_position = normal_view.global_position;
	transition_camera.global_rotation = normal_view.global_rotation;
	transition_camera.make_current();
	in_computer_view = true;
	crosshair.visible = false;
	interact_label.visible = false;
	# Move to computer camera
	var camera_to = computer_views[computer_view_index];
	var tween : Tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(transition_camera, "global_position", camera_to.global_position, 1);
	tween.tween_property(transition_camera, "global_rotation", camera_to.global_rotation, 1);
	await tween.finished;
	# Swap to computer camera
	camera_to.make_current();
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func transition_to_world() -> void:
	# Swap to transiton camera
	transition_camera.global_position = computer_views[computer_view_index].global_position;
	transition_camera.global_rotation = computer_views[computer_view_index].global_rotation;
	transition_camera.make_current();
	crosshair.visible = false;
	in_computer_view = true;
	# Move to computer camera
	var tween : Tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(transition_camera, "global_position", normal_view.global_position, 1);
	tween.tween_property(transition_camera, "global_rotation", normal_view.global_rotation, 1);
	await tween.finished;
	# Swap to world camera
	crosshair.visible = true;
	in_computer_view = false;
	normal_view.make_current();
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
#endregion

#region Mouse Raycasts
func handle_mouse_computer(event : InputEventMouse) -> void:
	var area_size = area.get_node("Shape").shape.size;

	if (event is InputEventMouseButton):
		mouse_held = event.pressed;

	var mouse_pos_3D : Vector3;
	var collision = find_mouse_collisions(event.position);
	if (collision != null):
		mouse_pos_3D = collision.position;
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

func find_mouse_collisions(mouse_global_pos : Vector2):
	# Gets the Camera & 3D Space
	var camera : Camera3D = get_viewport().get_camera_3d();
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	# Set up Camera RayCast
	var rayparams : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	rayparams.from = camera.project_ray_origin(mouse_global_pos);
	rayparams.to = camera.project_position(mouse_global_pos, 25);
	# Ensure Collisions with Areas, not Bodies
	rayparams.collide_with_bodies = false;
	rayparams.collide_with_areas = true;
	rayparams.collision_mask = 1 if in_computer_view else 2;
	# If it hits something, return the intersections, else nothing.
	var result = space_state.intersect_ray(rayparams);
	@warning_ignore("incompatible_ternary")
	return result if !result.is_empty() else null;
#endregion

func handle_game_over() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	get_node("../GameOver").visible = true;
	get_tree().paused = true;
