extends CharacterBody2D

# Changes based on which direction the fish is coming from.
@export var move_direction = 1;
var speed : float = randf_range(100, 150);

# Caught Values
@onready var hook_detector : Area2D = $HookDetector;

func _ready():
	get_node("Sprite2D").flip_h = move_direction == -1;

func _process(delta : float) -> void:
	if (position.x < -40 || position.x > 552):
		queue_free();

func _physics_process(_delta: float) -> void:
		velocity = Vector2(1, 0) * speed * move_direction;
		move_and_slide();

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("FishingHook")):
		body.trash_caught();
