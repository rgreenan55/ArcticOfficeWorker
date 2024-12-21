extends CharacterBody2D


var sprites : Array[String] = [
	"res://Stages/Desktop/Applications/IceFishing/Art/Trash1.png",
	"res://Stages/Desktop/Applications/IceFishing/Art/Trash2.png",
	"res://Stages/Desktop/Applications/IceFishing/Art/Trash3.png",
	"res://Stages/Desktop/Applications/IceFishing/Art/Trash4.png",
	"res://Stages/Desktop/Applications/IceFishing/Art/Trash5.png",
]

# Changes based on which direction the fish is coming from.
@export var move_direction = 1;
var speed : float = randf_range(75, 100);

# Caught Values
@onready var hook_detector : Area2D = $HookDetector;

func _ready():
	get_node("Sprite2D").texture = load(sprites.pick_random());
	get_node("Sprite2D").flip_h = move_direction == -1;

func _process(_delta : float) -> void:
	if (position.x < -40 || position.x > 552):
		queue_free();

func _physics_process(_delta: float) -> void:
		velocity.x = speed * move_direction;
		velocity.y += randf_range(-3, 3);
		position.y = clamp(position.y, 48, 224)
		rotation_degrees += randf_range(0, 2);
		move_and_slide();

func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("FishingHook")):
		body.trash_caught();
