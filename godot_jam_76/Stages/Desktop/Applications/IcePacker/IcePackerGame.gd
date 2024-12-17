extends Node2D

const GAME_BOARD : Texture = preload("res://Stages/Desktop/Applications/IcePacker/Art/IcePackerBoard.png")
const SHIPPED_BOARD : Texture = preload("res://Stages/Desktop/Applications/IcePacker/Art/IcePackerBoardShipped.png")

var shapes : Array[String] = [
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/IShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/IShapeAlt.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/IShapeSmall.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/IShapeSmallAlt.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/LShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/LShapeAlt1.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/LShapeAlt2.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/LShapeVFlipped.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/OShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/OShapeSmall.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/TShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/TShapeAlt2.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/TShapeAlt.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/UShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/UShapeAlt2.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/UShapeAlt.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/ZShape.tscn",
	"res://Stages/Desktop/Applications/IcePacker/Shapes/ShapeScenes/ZShapeAlt.tscn",
];

var min_vector = Vector2(0, 0);
var max_vector = Vector2(512, 340);

func _ready() -> void:
	for spawner : Area2D in get_node("ShapeSpawner/SpawnAreas").get_children():
		spawn_shape(spawner);

func spawn_shape(spawner : Area2D) -> void:
	var shape_path : String = shapes.pick_random();
	var shape_scene : PackedScene = load(shape_path);
	var shape : BaseShape = shape_scene.instantiate();
	shape.connect("shape_placed", shape_placed);
	shape.scale_shape(Vector2(0.5, 0.5));
	shape.position = spawner.position;
	shape.spawner_origin = spawner;
	get_node("Shapes").add_child(shape);

func shape_placed(shape : BaseShape) -> void:
	get_node("Shapes").remove_child(shape);
	get_node("PlacedShapes").add_child(shape);
	spawn_shape(shape.spawner_origin);

func ship_package() -> void:
	for tile : Area2D in get_node("Board/BoardTiles").get_children():
		tile.monitorable = false;
		tile.monitoring = false;

	get_node("Board/Sprite").texture = SHIPPED_BOARD
	get_node("PlacedShapes").position.y += 16;
	get_node("ShippingGate").play("closing");
	get_node("ShippingGate/GateAudio").play();
	await get_node("ShippingGate").animation_finished;

	# TODO: Point System

	for shape : BaseShape in get_node("PlacedShapes").get_children():
		shape.queue_free();

	get_node("ShippingGate").play("opening");
	await get_node("ShippingGate").animation_finished;
	get_node("ShippingGate/GateAudio").stop();

	get_node("PlacedShapes").position.y -= 16;
	get_node("Board/Sprite").texture = GAME_BOARD

	for tile : Area2D in get_node("Board/BoardTiles").get_children():
		tile.monitorable = true;
		tile.monitoring = true;
