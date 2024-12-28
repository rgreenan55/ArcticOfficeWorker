extends TextureButton

@export var idle_icon : Texture;
@export var hover_icon : Texture;
@export var pressed_icon : Texture;

@export var application_name : String;
@export var window_content : PackedScene;

@export var is_exit : bool = false;

func _ready() -> void:
	if (idle_icon): texture_normal = idle_icon;
	if (hover_icon): texture_hover = hover_icon;
	if (pressed_icon): texture_pressed = pressed_icon;

func _on_pressed() -> void:
	if (is_exit): DesktopManager.exit_computer.emit();
	if (window_content): get_node("../../Windows").open_window(application_name, window_content);
