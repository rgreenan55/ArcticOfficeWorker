extends Node

const SETTINGS_FILE_PATH = "res://Config/Settings/Settings.cfg"

var config = ConfigFile.new();

# Set Defaults / Load Existing Settings File
func _ready() -> void:
	if (!FileAccess.file_exists(SETTINGS_FILE_PATH)):
		# Graphic Defaults
		config.set_value("graphics", "fullscreen", false);

		# Audio Defaults
		config.set_value("audio", "master_volume", 1.0);
		config.set_value("audio", "sound_volume", 1.0);
		config.set_value("audio", "music_volume", 1.0);

		# Gameplay Defaults
		config.set_value("gameplay", "temp", false);

		config.save(SETTINGS_FILE_PATH);
	else:
		config.load(SETTINGS_FILE_PATH);

# Graphics -------------------------------------------------------------------------------------------------------------------------------
func save_graphics_setting(key : String, value) -> void:
	config.set_value("graphics", key, value);
	config.save(SETTINGS_FILE_PATH);

func load_graphics_settings() -> Dictionary:
	var graphics_settings = {};
	for key in config.get_section_keys("graphics"):
		graphics_settings[key] = config.get_value("graphics", key);
	return graphics_settings;

# Audio ----------------------------------------------------------------------------------------------------------------------------------
func save_audio_setting(key : String, value) -> void:
	config.set_value("audio", key, value);
	config.save(SETTINGS_FILE_PATH);

func load_audio_settings() -> Dictionary:
	var audio_settings = {};
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key);
	return audio_settings;

# Gameplay -------------------------------------------------------------------------------------------------------------------------------
func save_gameplay_setting(key : String, value) -> void:
	config.set_value("gameplay", key, value);
	config.save(SETTINGS_FILE_PATH);

func load_gameplay_settings() -> Dictionary:
	var gameplay_settings = {};
	for key in config.get_section_keys("gameplay"):
		gameplay_settings[key] = config.get_value("gameplay", key);
	return gameplay_settings;
