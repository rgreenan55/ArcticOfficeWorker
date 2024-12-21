extends Node2D

var fish_on_board : bool = false;
@onready var fish_to_chop : PackedScene = preload("res://Stages/Desktop/Applications/FishFrying/Objects/FishToChop.tscn");

func _ready() -> void:
	DesktopManager.connect("fish_caught", update_fish_pile);
	update_fish_pile();

func update_fish_pile() -> void:
	var current_fish = DesktopManager.ice_fishing_get_current_fish();
	if (current_fish < 1): get_node("FishObjects/FishObject_1").visible = false;
	else: get_node("FishObjects/FishObject_1").visible = true;
	if (current_fish < 2): get_node("FishObjects/FishObject_2").visible = false;
	else: get_node("FishObjects/FishObject_2").visible = true;
	if (current_fish < 3): get_node("FishObjects/FishObject_3").visible = false;
	else: get_node("FishObjects/FishObject_3").visible = true;
	get_node("FishObjects/FishCountLabel").text = "Fish Left:" + str(current_fish);

func add_fish_to_board() -> void:
	var fish = fish_to_chop.instantiate();
	fish.connect("fish_done_chopping", fish_done_chopping);
	get_node("ChoppingSpot").add_child(fish);
	DesktopManager.fish_frying_chopping_fish();
	fish_on_board = true;
	update_fish_pile();

func _on_fish_object_detector_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		var current_fish = DesktopManager.ice_fishing_get_current_fish();
		if (current_fish == 0 || fish_on_board): return;
		add_fish_to_board();

func fish_done_chopping() -> void:
	fish_on_board = false;
