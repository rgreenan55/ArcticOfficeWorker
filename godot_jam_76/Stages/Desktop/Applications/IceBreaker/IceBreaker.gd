extends CenterContainer

@onready var ice100 : Texture = load("res://Stages/Desktop/Applications/IceBreaker/Art/Ice100.png");
@onready var ice75 : Texture = load("res://Stages/Desktop/Applications/IceBreaker/Art/Ice75.png");
@onready var ice50 : Texture = load("res://Stages/Desktop/Applications/IceBreaker/Art/Ice50.png");
@onready var ice25 : Texture = load("res://Stages/Desktop/Applications/IceBreaker/Art/Ice25.png");
@onready var ice0 : Texture = load("res://Stages/Desktop/Applications/IceBreaker/Art/Ice0.png");
@onready var ice_texture : TextureRect = $IceTexture

func _ready() -> void:
	DesktopManager.connect("ice_breaker_health_changed", update_texture);
	update_texture();

# Signal Window to move to front.
func _on_texture_button_gui_input(event: InputEvent) -> void:
	gui_input.emit(event);

func _on_pick_button_pressed() -> void:
	DesktopManager.ice_breaker_hit();

func update_texture():
	var percentage = DesktopManager.ice_breaker_get_health_percentage();
	if (percentage > 75): ice_texture.texture = ice100;
	elif (percentage > 50): ice_texture.texture = ice75;
	elif (percentage > 25): ice_texture.texture = ice50;
	elif (percentage > 0): ice_texture.texture = ice25;
	else: ice_texture.texture = ice0;
