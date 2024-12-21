extends Node2D

@onready var fish_slice_to_cook : PackedScene = preload("res://Stages/Desktop/Applications/FishFrying/Objects/FishSlicesToCook.tscn");

func _ready() -> void:
	DesktopManager.connect("fish_sliced", update_fish_slice_pile);
	update_fish_slice_pile();

func update_fish_slice_pile() -> void:
	var current_slices : int = DesktopManager.fish_frying_get_chopped_fish();
	if (current_slices < 1): get_node("FishSlices/FishSliceObject_1").visible = false;
	else: get_node("FishSlices/FishSliceObject_1").visible = true;
	if (current_slices < 2): get_node("FishSlices/FishSliceObject_2").visible = false;
	else: get_node("FishSlices/FishSliceObject_2").visible = true;
	if (current_slices < 3): get_node("FishSlices/FishSliceObject_3").visible = false;
	else: get_node("FishSlices/FishSliceObject_3").visible = true;
	if (current_slices < 4): get_node("FishSlices/FishSliceObject_4").visible = false;
	else: get_node("FishSlices/FishSliceObject_4").visible = true;
	if (current_slices < 5): get_node("FishSlices/FishSliceObject_5").visible = false;
	else: get_node("FishSlices/FishSliceObject_5").visible = true;
	get_node("FishSlices/FishSliceCountLabel").text = "Slices Left:" + str(current_slices);


func cook_fish_slice(cooking_spot : Node2D) -> void:
	var fish_slice : Node2D = fish_slice_to_cook.instantiate();
	cooking_spot.add_child(fish_slice);
	DesktopManager.fish_frying_cooking_fish();
	update_fish_slice_pile();

func _on_fish_object_detector_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		var current_slices : int = DesktopManager.fish_frying_get_chopped_fish();
		var open_cooking_spot : Node2D = get_open_cooking_spot()
		if (current_slices > 0 && open_cooking_spot != null):
			cook_fish_slice(open_cooking_spot);


func get_open_cooking_spot() -> Node2D:
	for spot in get_node("CookingSpots").get_children():
		if (spot.get_child_count() == 0): return spot;
	return null;
