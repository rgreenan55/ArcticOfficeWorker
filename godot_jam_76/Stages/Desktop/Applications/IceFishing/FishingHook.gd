extends CharacterBody2D

var _mouse_in : bool = false;
var speed : float = 200;
var prev_pos : Vector2 = position;

# Catching Values
@export var fish_on_hook : CharacterBody2D;
@export var hook_broken : bool = false;


func _physics_process(_delta: float) -> void:
	if (_mouse_in): _handle_hook_movement();
	elif (get_node("Audio/Reeling").playing):
		get_node("Audio/Reeling").stop();

func _handle_hook_movement() -> void:
	var mouse_pos = Vector2(position.x, get_parent().get_parent().get_local_mouse_position().y);
	if (abs(mouse_pos.y - position.y) < 4):
		position.y = mouse_pos.y

	if (velocity.y == 0):
		get_node("Audio/Reeling").stop();
	elif (!get_node("Audio/Reeling").playing):
		get_node("Audio/Reeling").play();

	var direction = (mouse_pos - position).normalized();
	velocity = direction * speed;
	move_and_slide();
	position.y = clamp(position.y, 0, 220);
	prev_pos = position;

func fish_caught(fish : CharacterBody2D) -> void:
	if (fish_on_hook != null):
		fish_on_hook.release();
		fish_on_hook = null;
		fish.release()
	else:
		fish_on_hook = fish;

func trash_caught() -> void:
	if (fish_on_hook != null):
		fish_on_hook.release();
		fish_on_hook = null;
	break_hook();

func break_hook() -> void:
	DesktopManager.ice_fishing_hook_broken();
	if (!hook_broken): get_node("Audio/Broken").play();
	get_node("Sprite2D").visible = false;
	hook_broken = true;

func fix_hook() -> void:
	DesktopManager.ice_fishing_hook_fixed();
	get_node("Audio/Fixing").play();
	get_node("Sprite2D").visible = true;
	hook_broken = false;

func _on_mouse_entered() -> void:
	_mouse_in = true;

func _on_mouse_exited() -> void:
	_mouse_in = false;
