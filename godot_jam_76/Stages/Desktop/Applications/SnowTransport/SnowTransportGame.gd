extends Node2D

@onready var snow_scene : PackedScene = preload("res://Stages/Desktop/Applications/SnowTransport/Snow.tscn")
var prev_spawn_location : int = -1;
var game_resetting : bool = false;

func _ready() -> void:
	get_node("GameResetAnimation").play("default");
	spawn_snow();

# Spawning Snow Logic
func spawn_snow() -> void:
	if (game_resetting): return;
	var sections : int = get_node("SnowSpawnArea/CollisionShape2D").shape.size.x / 16;
	var spawn_location : int = randi_range(2, sections-1);
	while (spawn_location == prev_spawn_location): spawn_location = randi_range(2, sections-1);
	prev_spawn_location = spawn_location
	var snow : Area2D = snow_scene.instantiate();
	snow.connect("hit_player", player_hit_by_snow);
	snow.position.x = spawn_location * 16 - 8;
	snow.position.y = get_node("SnowSpawnArea/CollisionShape2D").position.y;
	get_node("SnowHolder").add_child(snow);
	get_tree().create_timer(0.25).connect("timeout", spawn_snow);

# On Player Reaching Goal
func _on_goal_area_body_entered(body: Node2D) -> void:
	if (body == get_node("Player")):
		# TODO : Trigger Global Point System
		game_resetting = true;
		get_node("GameResetAnimation").play("complete");
		await get_node("GameResetAnimation").animation_finished;
		for child in get_node("SnowHolder").get_children(): child.queue_free();
		return_player_to_start();
		get_node("GameResetAnimation").play_backwards("complete");
		await get_node("GameResetAnimation").animation_finished;
		game_resetting = false;
		get_node("GameResetAnimation").play("default");
		spawn_snow();

# Move on button presses
func move_player_right() -> void:
	if (game_resetting): return;
	if (get_node("Player").position.x < get_node("SnowSpawnArea/CollisionShape2D").shape.size.x - 8):
		get_node("Player").position.x += 16;

func move_player_left() -> void:
	if (game_resetting): return;
	if (get_node("Player").position.x > 0):
		get_node("Player").position.x -= 16;

func player_hit_by_snow() -> void:
	return_player_to_start();

func return_player_to_start() -> void:
	get_node("Player").position = Vector2(0, 0);

# Collect Snow and remove from tree.
func _on_snow_collection_area_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Snow")):
		area.is_last = true;
