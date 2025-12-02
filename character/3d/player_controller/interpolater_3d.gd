class_name Interpolator3D
extends Node3D

@export var target: Node3D # The node to smooth (e.g., your "Head" or "Visuals")
@export var offset_pos: Vector3
@export_range(0.0, 1.0) var position_responsiveness: float = 1.0

# State
var _prev_pos: Vector3
var _current_pos: Vector3

func _ready() -> void:
	# Detach the target (Visuals/Camera) from the parent so it doesn't 
	# inherit the jittery physics movement automatically.
	if target:
		target.top_level = true
		target.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		_prev_pos = target.global_position + offset_pos
		_current_pos = target.global_position + offset_pos

func teleport() -> void:
	# Call this if you forcibly move the player (respawn), 
	# so the camera doesn't "slide" across the map.
	var parent = get_parent() as Node3D
	if parent and target:
		_prev_pos = parent.global_position + offset_pos
		_current_pos = parent.global_position + offset_pos
		target.global_position = parent.global_position + offset_pos

func _physics_process(delta: float) -> void:
	if not target: return
	
	# 1. Record where we were last tick
	_prev_pos = _current_pos
	
	# 2. Record where the physics engine says we are NOW
	_current_pos = get_parent().global_position + offset_pos

func _process(delta: float) -> void:
	if not target: return
	
	# 3. Calculate the fraction of time between physics ticks (0.0 to 1.0)
	var f = Engine.get_physics_interpolation_fraction()
	
	# 4. Interpolate Position
	# This places the visuals smoothly between the previous tick and current tick.
	# It completely eliminates wall jitter and direction-change snapping.
	target.global_position = _prev_pos.lerp(_current_pos, f)
