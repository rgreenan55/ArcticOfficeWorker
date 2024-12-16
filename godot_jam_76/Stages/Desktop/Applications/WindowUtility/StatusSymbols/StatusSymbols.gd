extends Sprite2D

enum Status { Normal, Warning, Alert }

func _ready() -> void:
	alternate();

func set_status(new_status : Status) -> void:
	if (new_status == Status.Normal): frame = 0;
	elif (new_status == Status.Warning): frame = 2;
	elif (new_status == Status.Alert): frame = 4;

func alternate() -> void:
	await get_tree().create_timer(0.5).timeout;
	if (frame % 2 == 0): frame += 1;
	else: frame -= 1;
	alternate();
