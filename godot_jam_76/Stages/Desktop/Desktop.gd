extends Control

@onready var background : Array[String] = [
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_1.png",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_2.png",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_3.png",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_4.png",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_5.png",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_6.png",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_7.png",
];

@onready var shader : Array[String] = [
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_1.gdshader",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_2.gdshader",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_3.gdshader",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_1.gdshader",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_1.gdshader",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_4.gdshader",
	"res://Stages/Desktop/DesktopBackgrounds/DesktopBackground_4.gdshader",
]

const FACULTY_INSTRUCTIONS = preload("res://Stages/Desktop/Applications/FacultyInstructions.tscn");

func _ready() -> void:
	DesktopManager.connect("start_game", start_game);
	get_node("Windows/Tutorial").add_content(FACULTY_INSTRUCTIONS);
	var index : int = Time.get_datetime_dict_from_system().weekday;
	get_node("Background").texture = load(background[index]);

func start_game() -> void:
	for window : DesktopWindow in get_node("Windows").get_children():
		if (window.name != "Tutorial"): window.queue_free();
