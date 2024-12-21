extends Control

@export var status_section_scene : PackedScene = preload("res://Stages/Desktop/Applications/Status/StatusSection.tscn");
@onready var sound_progress: ProgressBar = $TextureRect/MarginContainer/VBoxContainer/SoundMeter/SoundProgress

func _ready() -> void:
	handle_sound_meter_color();

func _process(_delta: float) -> void:
	# Sound Meter
	sound_progress.value = DesktopManager.get_sound_value();

	# Other Status
	var status_info = DesktopManager.get_status();
	for section in status_info:
		# Find / Create
		var status_section = %StatusSectionDisplay.get_node_or_null(section);
		if (status_section == null):
			status_section = status_section_scene.instantiate();
			status_section.name = section;
		# Title
		status_section.title = status_info[section].title;
		# Value
		var value_type = status_info[section].value_type
		status_section.set_desired_value(status_info[section].value);

		if (value_type == "percentage"):
			status_section.set_post_text("%");
		elif (value_type == "fraction"):
			status_section.set_post_text("/" + str(status_info[section].total));
		elif (value_type == "value"):
			status_section.set_post_text("");
		# Status & Color
		var status = status_info[section].status
		status_section.set_color(get_status_color(status));
		# Add Node
		if (%StatusSectionDisplay.get_node_or_null(section) == null):
			%StatusSectionDisplay.add_child(status_section);

func get_status_color(status : int) -> Color:
	if (status == 1): return Color.YELLOW;
	elif (status == 2): return Color.RED;
	return Color.WHITE;

func handle_sound_meter_color() -> void:
	var sound_value = sound_progress.value;
	var style_box = sound_progress.get_theme_stylebox("fill");
	style_box.bg_color = Color.WHITE;
	if (sound_value >= 75):
		await get_tree().create_timer(0.5).timeout;
		style_box.bg_color = Color.RED;
	elif (sound_value >= 50):
		await get_tree().create_timer(0.5).timeout;
		style_box.bg_color = Color.YELLOW;
	get_tree().create_timer(0.5).connect("timeout", handle_sound_meter_color);
