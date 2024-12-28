extends Area3D
@onready var press_sound: AudioStreamPlayer3D = $"../PressSound"

func interact() -> void:
	get_node("../").position.y -= 0.05;
	press_sound.play();
	DesktopManager.init_shift()
	self.queue_free();
