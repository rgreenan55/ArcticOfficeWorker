extends Control

# Get Setting Components
@onready var fullscreen_checkbox = %FullscreenCheckBox;

@onready var master_volume_slider = %MasterVolume;
@onready var sound_volume_slider = %SoundVolume;
@onready var music_volume_slider = %MusicVolume;


# Load Settings
func _ready() -> void:
	var graphics_settings = SettingsManager.load_graphics_settings();
	fullscreen_checkbox.button_pressed = graphics_settings.fullscreen;

	var audio_settings = SettingsManager.load_audio_settings();
	master_volume_slider.value = min(audio_settings.master_volume, 1.0) * 100;
	sound_volume_slider.value = min(audio_settings.sound_volume, 1.0) * 100;
	music_volume_slider.value = min(audio_settings.music_volume, 1.0) * 100;

	#var gameplay_settings = SettingsManager.load_gameplay_settings()


# Handle Setting Changes
func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	SettingsManager.save_graphics_setting("fullscreen", toggled_on);

func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if (value_changed): SettingsManager.save_audio_setting("master_volume", master_volume_slider.value / 100);

func _on_sound_volume_drag_ended(value_changed: bool) -> void:
	if (value_changed): SettingsManager.save_audio_setting("sound_volume", sound_volume_slider.value / 100);

func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if (value_changed): SettingsManager.save_audio_setting("music_volume", music_volume_slider.value / 100);
