extends Node

@warning_ignore("unused_signal")
signal exit_computer;
@warning_ignore("unused_signal")
signal start_game;
signal game_over;

enum Status { Normal, Warning, Alert }

const SOUND_MAX : int = 150;
var sound_meter_value : int = 99;

# fuck
var resetting : bool = true;

var start_time : float;

func reset() -> void:
	resetting = true;
	# Clear Timers
	if (snow_transport_timer): snow_transport_timer.time_left = 0;
	if (ice_packer_timer): ice_packer_timer.time_left = 0;
	if (fish_frying_timer): fish_frying_timer.time_left = 0;
	if (faculty_training_timer): snow_transport_timer.time_left = 0;
	if (sound_timer): snow_transport_timer.time_left = 0;
	# Clear Values
	sound_meter_value = 0;
	ice_breaker_health = 0;
	snow_transport_current = 0;
	snow_transport_required = 0;
	ice_boxes_shipped = 0;
	required_boxes_shipped = 0;
	current_fish = 0;
	is_hook_broken = false;
	chopped_fish = 0;
	cooked_slices = 0;
	required_slices = 0;
	required_quotes = 0;
	current_quotes = 0;

func init_shift() -> void:
	resetting = false;
	# Sound Meter

	sound_meter_value = 0;
	handle_sound_meter();

	# Init Games
	_init_ice_breaker();
	_init_snow_transport();
	_init_ice_packer();
	_init_ice_fishing();
	_init_fish_frying();
	_init_faculty_training();
	start_game.emit();

var sound_timer : SceneTreeTimer;
func handle_sound_meter() -> void:
	if (resetting): return;
	var status : Status = facility_status_get_status();
	match status:
		Status.Normal:
			if (sound_meter_value > 0): sound_meter_value -= 1;
		Status.Warning:
			sound_meter_value += 1;
		Status.Alert:
			sound_meter_value += 2;
	if (sound_meter_value >= SOUND_MAX):
		game_over.emit();
	sound_timer = get_tree().create_timer(1, false);
	sound_timer.connect("timeout", handle_sound_meter);

func get_sound_value() -> int:
	return sound_meter_value;

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Facility Status
func get_status() -> Dictionary:
	var status = {
		"Ice_Breaker": {
			"title": "Ice Blockage",
			"value": ice_breaker_get_health_percentage(),
			"value_type": "percentage",
			"status": ice_breaker_get_status(),
		},
		"Snow_Transport": {
			"title": "Transportations",
			"value": snow_transport_current,
			"total": snow_transport_required,
			"value_type": "fraction",
			"status": snow_transport_get_status(),
		},
		"Ice_Packer": {
			"title": "Boxes Packed",
			"value": floor(ice_boxes_shipped),
			"total": required_boxes_shipped,
			"value_type": "fraction",
			"status": ice_packer_get_status(),
		},
		"Ice_Fishing": {
			"title": "Fish Gathered",
			"value": current_fish,
			"value_type": "value",
			"status": ice_fishing_get_status(),
		},
		"Fish_Frying": {
			"title": "Slices Served",
			"value": cooked_slices,
			"total": required_slices,
			"value_type": "fraction",
			"status": fish_frying_get_status(),
		},
		"Faculty_Training": {
			"title": "Quota Met",
			"value": current_quotes,
			"total": required_quotes,
			"value_type": "fraction",
			"status": faculty_training_get_status(),
		}
	}
	return status;

func facility_status_get_status() -> Status:
	var alerts : int = 0;
	var warnings : int = 0;

	var status_sections = get_status();
	for section in status_sections:
		# Increment Counts
		var status = status_sections[section].status;
		if (status > 0): warnings += 1;
		if (status == 2): alerts += 1;
	# Determine Status
	if (alerts >= 2 || warnings >= 5): return Status.Alert;
	elif (warnings >= 3 || alerts == 1): return Status.Warning;
	return Status.Normal;
#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Breaker
signal ice_breaker_health_changed;
const ICE_BREAKER_WARNING : int = 15;
const ICE_BREAKER_ALERT : int = 20;
const ICE_BREAKER_MAX : int = 20;
@export var ice_breaker_health : float = 0.0:
	get:
		return ice_breaker_health;
	set(value):
		ice_breaker_health = min(value, ICE_BREAKER_MAX);
		ice_breaker_health_changed.emit();

func _init_ice_breaker() -> void:
	ice_breaker_health = 0.0;
	_ice_breaker_heal();

func ice_breaker_get_status() -> Status:
	if (ice_breaker_health == ICE_BREAKER_ALERT): return Status.Alert;
	elif (ice_breaker_health >= ICE_BREAKER_WARNING): return Status.Warning;
	else: return Status.Normal;

func ice_breaker_get_health_percentage() -> float:
	return float(ice_breaker_health) / float(ICE_BREAKER_MAX) * 100.0

func ice_breaker_hit() -> void:
	if (ice_breaker_health > 1): ice_breaker_health -= 1;
	else: ice_breaker_health = 0;

func _ice_breaker_heal() -> void:
	if (resetting): return;
	if (ice_breaker_health < ICE_BREAKER_MAX):
		ice_breaker_health += 0.20
	get_tree().create_timer(0.75, false).connect("timeout", _ice_breaker_heal);

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Snow Transport
const SNOW_TRANSPORT_WARNING : int = 2;
const SNOW_TRANSPORT_ALERT : int = 3;
var snow_transport_current : int = 0;
var snow_transport_required : int = 0;
var snow_transport_timer : SceneTreeTimer;

func _init_snow_transport() -> void:
	snow_transport_current = 0;
	snow_transport_update_required();

func snow_transport_update_required() -> void:
	if (resetting): return;
	snow_transport_timer = null;
	snow_transport_required += 1
	snow_transport_timer = get_tree().create_timer(75, false);
	snow_transport_timer.connect("timeout", snow_transport_update_required);

func snow_transport_delivered() -> void:
	snow_transport_current += 1;

func snow_transport_get_status() -> Status:
	var diff : int = snow_transport_required - snow_transport_current;
	if (diff >= SNOW_TRANSPORT_ALERT): return Status.Alert;
	elif (diff >= SNOW_TRANSPORT_WARNING): return Status.Warning;
	else: return Status.Normal;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Packer

const ICE_PACKER_WARNING : int = 1;
const ICE_PACKER_ALERT : int = 2;
var ice_boxes_shipped : float = 0;
var required_boxes_shipped : int = 0;
var ice_packer_timer : SceneTreeTimer;

func _init_ice_packer() -> void:
	ice_boxes_shipped = 0;
	ice_packer_timer = get_tree().create_timer(45, false);
	ice_packer_timer.connect("timeout", ice_packed_updated_required);

func ice_packed_updated_required() -> void:
	if (resetting): return;
	ice_packer_timer = null;
	required_boxes_shipped += 1;
	ice_packer_timer = get_tree().create_timer(75, false);
	ice_packer_timer.connect("timeout", ice_packed_updated_required);

func ice_packer_get_status() -> Status:
	var diff = required_boxes_shipped - floor(ice_boxes_shipped);
	if (diff >= ICE_PACKER_ALERT): return Status.Alert;
	elif (diff >= ICE_PACKER_WARNING): return Status.Warning;
	return Status.Normal;

func ice_packer_shipped(tiles_shipped : int) -> void:
	var percent : float = tiles_shipped / 25.0;
	ice_boxes_shipped += percent;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Fishing
signal fish_caught;
var current_fish : int = 0;
var is_hook_broken : bool = false;

func _init_ice_fishing() -> void:
	current_fish = 0;

func ice_fishing_get_status() -> Status:
	if (is_hook_broken): return Status.Warning;
	return Status.Normal;

func ice_fishing_fish_caught(value : int) -> void:
	current_fish += value;
	fish_caught.emit();

func ice_fishing_get_current_fish() -> int:
	return current_fish;

func ice_fishing_hook_broken() -> void:
	is_hook_broken = true;

func ice_fishing_hook_fixed() -> void:
	is_hook_broken = false;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Fish Frying
signal fish_sliced;
const FISH_FRYING_WARNING : int = 4;
const FISH_FRYING_ALERT : int = 8;
var chopped_fish : int = 0;
var cooked_slices : int = 0;
var required_slices : int = 0;
var fish_frying_timer : SceneTreeTimer;

func _init_fish_frying() -> void:
	chopped_fish = 0;
	cooked_slices = 0;
	fish_frying_timer = get_tree().create_timer(50, false);
	fish_frying_timer.connect("timeout", fish_frying_update_required);

func fish_frying_update_required() -> void:
	if (resetting): return;
	fish_frying_timer = null;
	required_slices += 1;
	fish_frying_timer = get_tree().create_timer(15, false);
	fish_frying_timer.connect("timeout", fish_frying_update_required);

func fish_frying_get_status() -> Status:
	var diff = required_slices - cooked_slices;
	if (diff >= FISH_FRYING_ALERT): return Status.Alert;
	elif (diff >= FISH_FRYING_WARNING): return Status.Warning;
	return Status.Normal;

func fish_frying_get_chopped_fish() -> int:
	return chopped_fish;

func fish_frying_chopping_fish() -> void:
	current_fish -= 1;

func fish_frying_fish_chopped() -> void:
	chopped_fish += 3;
	fish_sliced.emit();

func fish_frying_cooking_fish() -> void:
	chopped_fish -= 1;

func fish_frying_fish_cooked() -> void:
	cooked_slices += 1;


#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Faculty Training

const FACULTY_TRAINING_WARNING : int = 1;
const FACULTY_TRAINING_ALERT : int = 2;
var required_quotes : int = 0;
var current_quotes : int = 0;
var faculty_training_timer : SceneTreeTimer;

func _init_faculty_training() -> void:
	current_quotes = 0;
	faculty_training_timer = get_tree().create_timer(30, false);
	faculty_training_timer.connect("timeout", faculty_training_update_required);

func faculty_training_update_required() -> void:
	if (resetting): return;
	required_quotes += 1;
	faculty_training_timer =get_tree().create_timer(45, false)
	faculty_training_timer.connect("timeout", faculty_training_update_required);

func faculty_training_get_status() -> Status:
	var diff = required_quotes - current_quotes;
	if (diff >= FACULTY_TRAINING_ALERT): return Status.Alert;
	elif (diff >= FACULTY_TRAINING_WARNING): return Status.Warning;
	return Status.Normal;

func faculty_training_correct() -> void:
	current_quotes += 1;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Music
func music_get_status() -> Status:
	return Status.Normal;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
