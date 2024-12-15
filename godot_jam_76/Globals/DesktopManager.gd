extends Node

func _ready() -> void:
	_init_ice_breaker();

func get_status() -> Dictionary:
	var status = {
		"Ice_Breaker": ice_breaker_get_health_percentage(),
		"Snow_Delivery": 0,
		"Ice_Packer": 0,
	}
	return status;

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Breaker
signal ice_breaker_health_changed;
const ICE_BREAKER_MAX : int = 20;
@export var ice_breaker_health : int = 7:
	get:
		return ice_breaker_health;
	set(value):
		ice_breaker_health = min(value, ICE_BREAKER_MAX);
		ice_breaker_health_changed.emit();

func _init_ice_breaker() -> void:
	get_tree().create_timer(5).connect("timeout", _ice_breaker_heal);

func ice_breaker_get_health_percentage() -> float:
	return float(ice_breaker_health) / float(ICE_BREAKER_MAX) * 100.0

func ice_breaker_hit() -> void:
	if (ice_breaker_health > 0): ice_breaker_health -= 1;

func _ice_breaker_heal() -> void:
	if (ice_breaker_health < ICE_BREAKER_MAX):
		ice_breaker_health += randi_range(1,5);
	var wait_time : float = randf_range(5, 15);
	get_tree().create_timer(wait_time).connect("timeout", _ice_breaker_heal);

#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Snow Transport


#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Ice Packer


#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#region Next


#endregion
# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
