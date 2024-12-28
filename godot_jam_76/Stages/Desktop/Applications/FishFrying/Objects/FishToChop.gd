extends Node2D

signal fish_done_chopping;

var step_1 : int = 0 :
	set(value):
		step_1 = value;
		if (step_1 == 2): move_to_step_2();
var step_2 : int = 0 :
	set(value):
		step_2 = value;
		if (step_2 == 2): move_to_step_3();


# Step 1 - Chop Tail & Head
func _on_cut_tail_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		get_node("ChopSound").play();
		get_node("Tail").frame = 0;
		get_node("Body3").frame = 1;
		get_node("Step1/CutTail").queue_free();
		await get_tree().create_timer(0.5, false).timeout;
		var tween : Tween = get_tree().create_tween();
		tween.tween_property(get_node("Tail"), "position", get_node("Tail").position - Vector2(32,0), 1);
		step_1 += 1;

func _on_cut_head_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		get_node("ChopSound").play();
		get_node("Head").frame = 4;
		get_node("Step1/CutHead").queue_free();
		await get_tree().create_timer(0.5, false).timeout;
		var tween : Tween = get_tree().create_tween();
		tween.tween_property(get_node("Head"), "position", get_node("Head").position + Vector2(32,0), 1);
		step_1 += 1;

func move_to_step_2() -> void:
	get_node("Step1").queue_free();
	get_node("Step2").visible = true;

# Step 2 - Chop Body
func _on_cut_left_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		get_node("ChopSound").play();
		get_node("Body2").frame = 2;
		get_node("Step2/CutLeft").queue_free();
		await get_tree().create_timer(0.5, false).timeout;
		var tween : Tween = get_tree().create_tween();
		tween.tween_property(get_node("Body3"), "position", get_node("Body3").position - Vector2(12,0), 1);
		await tween.finished;
		step_2 += 1;

func _on_cut_right_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		get_node("ChopSound").play();
		get_node("Body1").frame = 3;
		get_node("Step2/CutRight").queue_free();
		await get_tree().create_timer(0.5, false).timeout;
		var tween : Tween = get_tree().create_tween();
		tween.tween_property(get_node("Body1"), "position", get_node("Body1").position + Vector2(12,0), 1);
		await tween.finished;
		step_2 += 1;

func move_to_step_3() -> void:
	get_node("Step2").queue_free();
	get_node("Step3").visible = true;

# Step 3 - Clear Board
func _on_clear_board_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		DesktopManager.fish_frying_fish_chopped();
		fish_done_chopping.emit();
		get_node("Step3/ClearBoard").queue_free();
		get_node("ClearBoardSound").play();
		self.visible = false;
		await get_node("ClearBoardSound").finished;
		self.queue_free();
