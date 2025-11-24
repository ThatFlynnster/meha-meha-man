class_name CharacterController3D
extends Node

signal rotate(rotation: float)
signal set_rotation(rotation: float)
signal throttle_updated(throttle_velocity: Vector2)
signal jump_requested()
signal direction_updated(target_direction: Vector3)

@export var character: CharacterBody3D

var _last_throttle := Vector2.ZERO
var _last_direction := Vector3.ZERO


func _update_throttle(throttle: Vector2) -> void:
	# Meant to be overriden, otherwise leave alone if throttle inputs are not part of the game
	pass


func _update_direction() -> void:
	var target_direction := Vector3.ZERO
	target_direction += (character.transform.basis * Vector3(_last_throttle.x, 0, _last_throttle.y))
	direction_updated.emit(target_direction)


func _physics_process(delta: float) -> void:
	pass
