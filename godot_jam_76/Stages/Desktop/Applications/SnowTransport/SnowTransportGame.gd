extends Node2D

@onready var snow_scene : PackedScene = preload("res://Stages/Desktop/Applications/SnowTransport/Snow.tscn")

var prev_spawn_location : int = -1;

func _ready() -> void:
	spawn_snow();

# Spawning Snow Logic
func spawn_snow() -> void:
	var sections : int = get_node("SnowSpawnArea/CollisionShape2D").shape.size.x / 16;
	var spawn_location : int = randi_range(2, sections-1);
	while (spawn_location == prev_spawn_location): spawn_location = randi_range(1, sections);
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
		return_player_to_start();

# Move on button presses
func move_player_right() -> void:
	if (get_node("Player").position.x < get_node("SnowSpawnArea/CollisionShape2D").shape.size.x - 8):
		get_node("Player").position.x += 16;

func move_player_left() -> void:
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
