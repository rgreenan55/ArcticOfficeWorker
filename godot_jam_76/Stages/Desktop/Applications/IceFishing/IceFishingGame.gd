extends Node2D

# Fishing Rod
@onready var hook : CharacterBody2D = $FishingRod/FishingHook;
@onready var string : Line2D = $FishingRod/String;

# Spawners
@onready var left_spawner : Area2D = $Spawners/SpawnerLeft
@onready var right_spawner : Area2D = $Spawners/SpawnerRight

# Fish
var fish_scene : PackedScene = preload("res://Stages/Desktop/Applications/IceFishing/Entities/Fish.tscn");
# Trash
var trash_scene : PackedScene = preload("res://Stages/Desktop/Applications/IceFishing/Trash.tscn");

func _ready() -> void:
	get_tree().create_timer(randf_range(2, 5)).connect("timeout", _spawn_fish);
	get_tree().create_timer(2).connect("timeout", _spawn_trash);
	string.add_point(Vector2(256, 0));
	string.add_point(hook.position, 1);

func _process(_delta: float) -> void:
	string.remove_point(1)
	string.add_point(hook.position, 1);

func _spawn_fish():
	# Get Spawn Location
	var decider : bool = randi_range(1,0) == 0;
	var spawner : Area2D = left_spawner if decider else right_spawner;
	var spawner_half_height : float = spawner.get_node("CollisionShape2D").shape.size.y / 2;
	var random_height : float = spawner.position.y + randf_range(-spawner_half_height, spawner_half_height);
	var spawn_location : Vector2 = Vector2(spawner.position.x-32, random_height);
	# Spawn Fish
	var fish = fish_scene.instantiate();
	fish.position = spawn_location;
	fish.move_direction = 1 if decider else -1;
	# Determine Fish Type
	var type = randi_range(0, 100);
	if (type <= 3): fish.become_purple_fish();
	elif (type <= 25): fish.become_red_fish();
	get_node("SpawnedEntities").add_child(fish);
	# Prep for Next Fish
	get_tree().create_timer(randf_range(2, 5)).connect("timeout", _spawn_fish);

func _spawn_trash() -> void:
	# Get Spawn Location
	var decider : bool = randi_range(1,0) == 0;
	var spawner : Area2D = left_spawner if decider else right_spawner;
	var spawner_half_height : float = spawner.get_node("CollisionShape2D").shape.size.y / 2;
	var random_height : float = spawner.position.y + randf_range(-spawner_half_height, spawner_half_height);
	var spawn_location : Vector2 = Vector2(spawner.position.x-32, random_height);
	# Spawn Trash
	var trash = trash_scene.instantiate();
	trash.position = spawn_location;
	trash.move_direction = 1 if decider else -1;
	get_node("SpawnedEntities").add_child(trash);
	# Prep for Next Trash
	get_tree().create_timer(2).connect("timeout", _spawn_trash);

func _on_fish_collector_body_entered(body: Node2D) -> void:
	if (body.is_in_group("FishingHook")):
		if (body.hook_broken): body.fix_hook();
		var fish = body.fish_on_hook;
		if (!fish): return;
		DesktopManager.ice_fishing_fish_caught(fish.value);
		get_node("FishingRod/FishingHook/Audio/Caught").play();
		body.fish_on_hook = null;
		fish.queue_free();
