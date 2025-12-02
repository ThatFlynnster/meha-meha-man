extends CharacterBody3D

@export var controller: CharacterController3D
const SPEED = 5.5
const FLOOR_ACCELERATION = INF
const FLOOR_DECELERATION = 80.0
const AIR_ACCELERATION = 20.0
const AIR_DECELERATION = 0.0
const JUMP_VELOCITY = 5.72
const TERMINAL_VELOCITY = 30.0

var _direction := Vector3.ZERO
var _acceleration
var _deceleration


func _rotate(rotation: float):
	#rotate_y(rotation)
	pass


func _set_rotation(rotation: float):
	self.rotation.y = rotation


func _update_direction(direction: Vector3) -> void:
	_direction = direction


func _jump() -> void:
	if is_on_floor(): # this check fails sometimes
		floor_snap_length = 0.0
		velocity.y = JUMP_VELOCITY


func apply_impulse(impulse_velocity: Vector3, cancel_momentum: bool) -> void:
	if cancel_momentum:
		velocity = impulse_velocity
	else:
		velocity += impulse_velocity


func _ready() -> void:
	controller.connect("rotate", _rotate)
	controller.connect("set_rotation", _set_rotation)
	controller.connect("direction_updated", _update_direction)
	controller.connect("jump_requested", _jump)


func _physics_process(delta: float) -> void:
	# 1. Handle Gravity / Vertical Movement
	if not is_on_floor():
		floor_snap_length = 0.0
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)

	# 2. Determine Acceleration/Deceleration vars
	_acceleration = AIR_ACCELERATION
	_deceleration = AIR_DECELERATION

	if is_on_floor():
		var floor_normal = get_floor_normal()
		var slope_angle = floor_normal.angle_to(Vector3.UP)
		var slope_sine = sin(slope_angle)
		#print_debug(slope_sine)
		if slope_sine > 0.0:
			floor_snap_length = slope_sine * 0.1 * SPEED
			#floor_snap_length = 0.1
		else: floor_snap_length = 0.0
		
		_acceleration = FLOOR_ACCELERATION
		_deceleration = FLOOR_DECELERATION

	# 3. Isolate Horizontal Velocity (Discard Y)
	var h_velocity = Vector2(velocity.x, velocity.z)
	var target_direction = Vector2(_direction.x, _direction.z)
	var target_velocity = target_direction * SPEED

	if _direction:
		# This ensures we move towards the target vector maintaining magnitude
		h_velocity = h_velocity.move_toward(target_velocity, _acceleration * delta)
	else:
		h_velocity = h_velocity.move_toward(Vector2.ZERO, _deceleration * delta)

	# 4. Reapply Horizontal Velocity back to Character
	velocity.x = h_velocity.x
	velocity.z = h_velocity.y
	
	move_and_slide()
