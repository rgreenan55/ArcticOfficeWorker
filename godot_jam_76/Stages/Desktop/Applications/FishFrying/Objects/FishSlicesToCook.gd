extends Node2D

enum CookingStage { Raw, Cooking, Cooked, Burnt }
var cooking_stage : CookingStage = CookingStage.Raw;

func _ready() -> void:
	cook_slice();

func cook_slice() -> void:
	if (cooking_stage == CookingStage.Burnt):
		slice_burnt();
	else:
		await get_tree().create_timer(randf_range(5,10)).timeout;
		get_node("Sprite2D").frame += 1;
		@warning_ignore("int_as_enum_without_cast")
		cooking_stage += 1;
		cook_slice();

func slice_burnt() -> void:
	get_node("SmokeParticles").emitting = true;

func _on_mouse_detector_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		if (cooking_stage == CookingStage.Cooked):
			DesktopManager.fish_frying_fish_cooked();
		queue_free();
