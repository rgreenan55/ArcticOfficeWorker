extends Node

enum Status { Normal, Warning, Alert }

func _ready() -> void:
	_init_ice_breaker();
	_init_snow_transport();

func get_status() -> Dictionary:
	var status = {
		"Ice_Breaker": ice_breaker_get_status(),
		"Snow_Delivery": 0,
		"Ice_Packer": 0,
	}
	return status;

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Breaker
signal ice_breaker_health_changed;
const ICE_BREAKER_WARNING : int = 15;
const ICE_BREAKER_ALERT : int = 20;
const ICE_BREAKER_MAX : int = 20;
@export var ice_breaker_health : int = 7:
	get:
		return ice_breaker_health;
	set(value):
		ice_breaker_health = min(value, ICE_BREAKER_MAX);
		ice_breaker_health_changed.emit();

func _init_ice_breaker() -> void:
	get_tree().create_timer(5).connect("timeout", _ice_breaker_heal);

func ice_breaker_get_status() -> Status:
	if (ice_breaker_health == ICE_BREAKER_ALERT): return Status.Alert;
	elif (ice_breaker_health >= ICE_BREAKER_WARNING): return Status.Warning;
	else: return Status.Normal;

func ice_breaker_get_health_percentage() -> float:
	return float(ice_breaker_health) / float(ICE_BREAKER_MAX) * 100.0

func ice_breaker_hit() -> void:
	if (ice_breaker_health > 0): ice_breaker_health -= 1;

func _ice_breaker_heal() -> void:
	if (ice_breaker_health < ICE_BREAKER_MAX):
		ice_breaker_health += randi_range(3,5);
	var wait_time : float = randf_range(5, 10);
	get_tree().create_timer(wait_time).connect("timeout", _ice_breaker_heal);

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Snow Transport
const SNOW_TRANSPORT_WARNING : int = 3;
const SNOW_TRANSPORT_ALERT : int = 5;
var snow_transport_current : int = 0;
var snow_transport_required : int = 0;

func _init_snow_transport() -> void:
	pass;

func snow_transport_get_status() -> Status:
	var diff : int = snow_transport_required - snow_transport_current;
	if (diff >= SNOW_TRANSPORT_ALERT): return Status.Alert;
	elif (diff >= SNOW_TRANSPORT_WARNING): return Status.Warning;
	else: return Status.Normal;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Packer

func _init_ice_packer() -> void:
	pass;

func ice_packer_get_status() -> Status:
	return Status.Normal;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Fishing
func _init_ice_fishing() -> void:
	pass;

func ice_fishing_get_status() -> Status:
	return Status.Normal;

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Next


#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
