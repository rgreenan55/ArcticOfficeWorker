extends Control


# Title
@export var title : String :
	set(value): get_node("HBoxContainer/Title").text = value;

# Value
var desired_value : int;
var current_value : int = 0;
var post_text : String;

# Color
@onready var text_color : Color = Color.WHITE;

func _ready() -> void:
	flash_color();

func _process(_delta: float) -> void:
	if (current_value < desired_value):
		current_value += 1;
	if (current_value > desired_value):
		current_value -= 1;
	get_node("HBoxContainer/Value").text = str(current_value) + post_text;

func set_desired_value(value : int) -> void:
	desired_value = value;

func set_post_text(text : String) -> void:
	post_text = text;

func flash_color() -> void:
	self.modulate = Color.WHITE;
	await get_tree().create_timer(0.5).timeout;
	if (text_color != Color.WHITE):
		self.modulate = text_color;
	await get_tree().create_timer(0.5).timeout;
	flash_color();

func set_color(color : Color) -> void:
	text_color = color;
