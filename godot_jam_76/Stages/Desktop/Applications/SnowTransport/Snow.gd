extends Area2D

@export var is_last : bool = false;
signal hit_player;

func _ready() -> void:
	move_snow();

func move_snow() -> void:
	await get_tree().create_timer(0.25, false).timeout;
	if (is_last):
		queue_free();
	else:
		position.y += 16;
		move_snow();


func _on_body_entered(body: Node2D) -> void:
	if (body == get_node("../../Player")):
		hit_player.emit();
