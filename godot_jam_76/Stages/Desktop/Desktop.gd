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


func _ready() -> void:
	var index : int = Time.get_datetime_dict_from_system().weekday;

	get_node("Background").texture = load(background[index]);
	if (shader[index] != ""):
		get_node("Background").material.shader = load(shader[index]);
