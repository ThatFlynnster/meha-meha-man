class_name PlayerController3D

extends CharacterController3D

@export var head: Node3D
@export var mesh: MeshInstance3D
@export var mouse_sensitivity: float = 0.001

var _eye_offset := Vector3(0, 1.5, 0)
var _cam_pitch: float = 0.0
var _cam_yaw: float = 0.0
var _time_since_physics : float = 0.0
var _accumulated_input_dir : Vector3 = Vector3.ZERO


func _ready() -> void:
	# Lock the mouse to the center of the screen and hide it
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head.top_level = true
	#mesh.top_level = true
	#head.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_cam_pitch = head.rotation.x
	_cam_yaw = head.rotation.y


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_handle_head_rotation(event)

	# Dev helper: Press Esc to unlock the mouse
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _handle_head_rotation(event: InputEventMouseMotion) -> void:
	_cam_yaw -= event.relative.x * mouse_sensitivity
	_cam_pitch -= event.relative.y * mouse_sensitivity
	_cam_pitch = clamp(_cam_pitch, deg_to_rad(-90), deg_to_rad(90))

	head.rotation = Vector3(_cam_pitch, _cam_yaw, 0)

	# Rotate the character body
	rotate.emit(-event.relative.x * mouse_sensitivity)
	set_rotation.emit(head.rotation.y)
	_update_direction()


func _update_throttle(throttle: Vector2) -> void:
	throttle_updated.emit(throttle)
	_last_throttle = throttle
	set_rotation.emit(head.rotation.y)
	_update_direction()


func _process(delta: float) -> void:
	_time_since_physics += delta

	# --- A. Input Accumulation (Sub-tick Movement) ---
	# We capture the input *right now* to ensure we don't miss a 
	# lightning-fast key tap that happened between physics frames.
	var raw_input = Input.get_vector("left", "right", "forward", "back")
	var frame_dir = (head.transform.basis * Vector3(raw_input.x, 0, raw_input.y)).normalized()

	# If we have input this frame, overwrite the accumulator.
	# (Simple version: assumes last input overrides. Complex version: average them)
	if frame_dir.length() > 0:
		_accumulated_input_dir = frame_dir


func _physics_process(delta: float) -> void:
	var throttle := Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()
	if throttle != _last_throttle:
		_update_throttle(throttle)

	if Input.is_action_just_pressed("jump"):
		jump_requested.emit()

	head.position = character.position + _eye_offset 
