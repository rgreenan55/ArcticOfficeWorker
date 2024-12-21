extends CharacterBody2D

# Changes based on which direction the fish is coming from.
@export var move_direction = 1;
var speed : float = randf_range(75, 125);

# Caught Values
@onready var hook_detector : Area2D = $HookDetector;
@export var value : int = 1;
var is_caught : bool = false;
var hook : CharacterBody2D;

var time : float = 0;

func _ready():
	get_node("Sprite2D").flip_h = move_direction == -1;

func _process(_delta : float) -> void:
	if (position.x < -40 || position.x > 552):
		queue_free();

func _physics_process(delta: float) -> void:
	time += delta
	if (time > 2*PI): time -= 2*PI;
	if (is_caught):
		velocity = Vector2(0,0);
		position = hook.position + Vector2(0, 20);
	else:
		velocity = Vector2(1, 0) * speed * move_direction;
		position.y += cos(time) * randf_range(0.25, 0.75);
		position.y = clamp(position.y, 48, 224)
		move_and_slide();

func release() -> void:
	is_caught = false;
	speed = 200;
	rotation_degrees = 0;
	hook_detector.set_deferred("monitorable", false);
	hook_detector.set_deferred("monitoring", false);

func become_red_fish() -> void:
	get_node("Sprite2D").texture = load("res://Stages/Desktop/Applications/IceFishing/Art/RedFish.png");
	speed = randf_range(100, 125);
	value = 2;

func become_purple_fish() -> void:
	get_node("Sprite2D").texture = load("res://Stages/Desktop/Applications/IceFishing/Art/PurpleFish.png");
	speed = randf_range(125, 150);
	value = 3;

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("FishingHook") && !body.hook_broken):
		hook = body;
		is_caught = true;
		rotation_degrees = 90 if move_direction == -1 else -90;
		hook.fish_caught(self);
