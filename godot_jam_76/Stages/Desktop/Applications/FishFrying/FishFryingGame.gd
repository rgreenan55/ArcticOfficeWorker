extends Node2D

signal gui_input(event);

# Screens
@onready var chopping_board : Node2D = $ChoppingBoard;
@onready var cooking_station : Node2D = $CookingStation;
# Screen Info
enum Screen { Chopping, Cooking };
@export var screen : Screen = Screen.Chopping :
	get:
		return screen;
	set(value):
		if (value == screen): return;
		screen = value;
		if (value == Screen.Chopping):
			chopping_board.visible = true;
			cooking_station.visible = false;
		if (value == Screen.Cooking):
			cooking_station.visible = true;
			chopping_board.visible = false;

func _on_to_chopping_board_pressed() -> void:
	screen = Screen.Chopping;

func _on_to_cooking_station_pressed() -> void:
	screen = Screen.Cooking;

func _on_gui_input(event: InputEvent) -> void:
	gui_input.emit(event);
