extends Node3D

@export var controller: PlayerController3D

var _direction := Vector3.ZERO


#func _ready() -> void:
	#controller.connect("direction_updated", _update_direction)


#func _update_direction() -> void:
	#_direction = direction


func _process(delta: float) -> void:
	pass
