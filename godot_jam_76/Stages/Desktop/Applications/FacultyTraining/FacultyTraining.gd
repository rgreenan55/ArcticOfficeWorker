extends CenterContainer

@onready var sample_text : Label = $"%SampleText";
@onready var user_input : LineEdit = $"%UserInput";
@onready var user_input_display : RichTextLabel = $"%UserInputDisplay";

var errors : int = 0;

var last_text_index : int = -1;
var text_options : Array[String] = [
	"I am a valuable asset to the company",
	"Company production is of great importance",
	"The company values my wellbeing",
	"My three vacation days a year are plenty",
	"Management knows better then myself",
	"I am proud to contribute to the company's success",
	"The company's growth is a reflection upon myself",
	"Personal relationships hinder my ability to work",
	"The company will ensure my safety",
	"I am valued beyond my ability to work",
	"I will not gamble while on the job",
	"My salary should be considered above average",
	"My co-workers are not missing, they are away",
	"I am not sick of fish, it is my favourite",
	"The ice will not pack itself",
	"There are no creatures in the Arctic",
];


func _ready() -> void:
	setup();

func setup() -> void:
	# Ensure no Repeats
	var text_index : int = randi_range(0, text_options.size()-1);
	while text_index == last_text_index:
		text_index = randi_range(0, text_options.size()-1);
	last_text_index = text_index;
	# Setup
	var text : String = text_options[text_index];
	sample_text.text = text;
	user_input_display.text = "";
	user_input.text = "";
	user_input.max_length = text.length();

func _on_user_input_text_changed(new_text: String) -> void:
	get_node("TypeKeySound").play();
	user_input_display.text = format_text(new_text);
	if (errors == 0):
		get_node("CorrectSound").play();
		DesktopManager.faculty_training_correct();
		setup();

func format_text(text_in : String) -> String:
	var base : String = sample_text.text;
	var new_text : String = "";
	errors = base.length();
	for i in text_in.length():
		if (base[i] != text_in[i]):
			var c = text_in[i] if text_in[i] != " " else "_";
			new_text += "[color=red]" + c + "[/color]";
		else:
			errors -= 1;
			new_text += text_in[i];
	return new_text;


func _on_gui_input(event: InputEvent) -> void:
	gui_input.emit(event);
