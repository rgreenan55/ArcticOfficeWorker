extends MarginContainer

const SONG_SELECTION = preload("res://Stages/Desktop/Applications/Music/SongSelection.tscn")
@onready var music_options_list: VBoxContainer = $MarginContainer/MusicOptions/MusicOptionsList
var current_song_ui_node : Control;

var song_array : Array[String] = [
	"res://Stages/Desktop/Applications/Music/Audio/Backyard.mp3",
	"res://Stages/Desktop/Applications/Music/Audio/GameOver.mp3",
	"res://Stages/Desktop/Applications/Music/Audio/GoodNight.mp3",
	"res://Stages/Desktop/Applications/Music/Audio/LadyOfThe80s.mp3",
	"res://Stages/Desktop/Applications/Music/Audio/SpaceStation.mp3",
	"res://Stages/Desktop/Applications/Music/Audio/StrangerThings.mp3",
];

func _ready() -> void:
	var prev_song = null;
	for song : String in song_array:
		var song_node : MarginContainer = SONG_SELECTION.instantiate();
		if (prev_song != null): prev_song.get_node("MusicPlayer").connect("finished", song_node.play_song);
		prev_song = song_node;
		song_node.connect("song_played", play_song);
		song_node.set_sound(song);
		music_options_list.add_child(song_node);
	if (music_options_list.get_child_count() > 0):
		prev_song.get_node("MusicPlayer").connect("finished", music_options_list.get_child(0).play_song);

func play_song(ui_node : Control) -> void:
	if (current_song_ui_node != null):
		current_song_ui_node.stop_playing();
	if (ui_node != current_song_ui_node):
		current_song_ui_node = ui_node;
	else:
		current_song_ui_node = null;
