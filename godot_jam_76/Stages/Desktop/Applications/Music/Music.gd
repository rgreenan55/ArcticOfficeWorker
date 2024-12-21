extends MarginContainer

@onready var music_options_list: VBoxContainer = $MarginContainer/MusicOptions/MusicOptionsList
var current_song_ui_node : Control;

func _ready() -> void:
	var prev_song : SongSelection = null;
	## Once I get Song Array Created
	#for song : String in []:
		#var song_node : SongSelection = SongSelection.new();
		#if (prev_song != null): prev_song.get_node("MusicPlayer").connect("finished", song_node.play_song);
		#prev_song = song_node;
		#song_node.connect("song_played", play_song);
		#song_node.set_sound(song);
	for song in music_options_list.get_children():
		if (prev_song != null): prev_song.get_node("MusicPlayer").connect("finished", song.play_song);
		prev_song = song;
		song.connect("song_played", play_song);
		song.set_sound("res://Stages/Desktop/Applications/Music/Audio/temp_song.mp3");
	if (music_options_list.get_child_count() > 0):
		prev_song.get_node("MusicPlayer").connect("finished", music_options_list.get_child(0).play_song);


func play_song(ui_node : Control) -> void:
	if (current_song_ui_node != null):
		current_song_ui_node.stop_playing();
	if (ui_node != current_song_ui_node):
		current_song_ui_node = ui_node;
	else:
		current_song_ui_node = null;
