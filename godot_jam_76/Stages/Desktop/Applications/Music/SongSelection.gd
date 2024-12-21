class_name SongSelection extends MarginContainer

signal song_played(node);

const SONG_BACKGROUND = preload("res://Stages/Desktop/Applications/Music/Art/SongBackground.png")
const SONG_BACKGROUND_PLAYING = preload("res://Stages/Desktop/Applications/Music/Art/SongBackgroundPlaying.png")
@onready var background: TextureRect = $Background;

@onready var music_lines: TextureRect = $MarginContainer/SongSelection/MusicLines
var music_lines_path : String = "res://Stages/Desktop/Applications/Music/Art/MusicLines/MusicLines";
var current_music_line : int = 1;

@onready var play_button: TextureButton = $MarginContainer/SongSelection/PlayButton
var playing : bool = false;

func set_sound(audio_path : String) -> void:
	var file_split : PackedStringArray = audio_path.split('/');
	var file_name : String = file_split[file_split.size()-1].split(".")[0];
	var title = file_name.replace("_", " ");
	get_node("MarginContainer/SongSelection/SongName").text = title;
	var sound = load(audio_path);
	get_node("MusicPlayer").stream = sound;

func _on_margin_container_gui_input(event: InputEvent) -> void:
	if (event.is_action("LeftMouseButton") && event.is_pressed()):
		play_song();

func play_song() -> void:
		play_button.disabled = true;
		playing = true;
		background.texture = SONG_BACKGROUND_PLAYING
		get_node("MusicPlayer").play();
		animate_music_lines();
		song_played.emit(self);

func animate_music_lines() -> void:
	if (playing):
		current_music_line = current_music_line + 1
		if (current_music_line > 7): current_music_line = 1;
		music_lines.texture = load(music_lines_path + "_" + str(current_music_line) + ".png");
		get_tree().create_timer(0.15).connect("timeout", animate_music_lines);
	else:
		current_music_line = 1;
		music_lines.texture = load(music_lines_path + "_" + str(current_music_line) + ".png");

func stop_playing() -> void:
	get_node("MusicPlayer").stop();
	background.texture = SONG_BACKGROUND
	play_button.disabled = false;
	playing = false;
