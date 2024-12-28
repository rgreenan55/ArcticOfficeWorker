extends Area3D

@onready var alarm_sound: AudioStreamPlayer3D = $"../AlarmSound"

func _process(_delta: float) -> void:
	var status : int = DesktopManager.facility_status_get_status();

	if (status == 0):
		if (alarm_sound.playing):
			alarm_sound.stop();
	else:
		if (!alarm_sound.playing): alarm_sound.play()
		if (status == 1): alarm_sound.volume_db = -20;
		else: alarm_sound.volume_db = -12.5;

func interact() -> void:
	var player : CharacterBody3D = $"../../../PlayerCharacter";
	player.transition_to_computer();
