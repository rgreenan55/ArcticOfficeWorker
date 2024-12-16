extends Node2D

const GAME_BOARD : Texture = preload("res://Stages/Desktop/Applications/IcePacker/Art/IcePackerBoard.png")
const SHIPPED_BOARD : Texture = preload("res://Stages/Desktop/Applications/IcePacker/Art/IcePackerBoardShipped.png")

const SHAPES : Array[String] = [
	"res://Stages/Desktop/Applications/IcePacker/Shapes/IShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/LShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/OShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/TShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/UShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ZShape.tscn",
]

var min_vector = Vector2(0, 0);
var max_vector = Vector2(512, 340);

func _ready() -> void:
	spawn_shape();

func spawn_shape() -> void:
	var shape_path : String = SHAPES.pick_random();
	var shape_scene : PackedScene = load(shape_path);
	var shape : BaseShape = shape_scene.instantiate();
	shape.connect("shape_placed", shape_placed);
	shape.position = get_node("ShapeSpawner").get_node("SpawnArea").position;
	get_node("Shapes").add_child(shape);

func shape_placed(shape : BaseShape) -> void:
	get_node("Shapes").remove_child(shape);
	get_node("PlacedShapes").add_child(shape);
	spawn_shape();

func ship_package() -> void:
	# TODO : Lock Game
	for tile : Area2D in get_node("Board/BoardTiles").get_children():
		tile.monitorable = false;
		tile.monitoring = false;

	get_node("Board/Sprite").texture = SHIPPED_BOARD
	get_node("PlacedShapes").position.y += 16;
	get_node("ShippingGate").play("closing");
	await get_node("ShippingGate").animation_finished;

	# TODO: Reset Board & Tally Points
	for shape : BaseShape in get_node("PlacedShapes").get_children():
		shape.queue_free();

	get_node("ShippingGate").play("opening");
	await get_node("ShippingGate").animation_finished;
	get_node("PlacedShapes").position.y -= 16;
	get_node("Board/Sprite").texture = GAME_BOARD

	# TODO : Unlock Game
	for tile : Area2D in get_node("Board/BoardTiles").get_children():
		tile.monitorable = true;
		tile.monitoring = true;
