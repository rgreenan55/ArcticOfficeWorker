extends Label

enum Weekday { Sunday, Monday, Tuesday, Wednesday, Thrusday, Friday, Saturday }

func _process(_delta: float) -> void:
	var date : Dictionary = Time.get_datetime_dict_from_system();
	text = Weekday.keys()[date.weekday] + "    " + Time.get_datetime_string_from_system().replace("T", "    ");
