class_name Character3D
extends CharacterBody3D

enum FloorState {
	AIRBORNE,
	ON_FLOOR,
	ON_SLIDE,
}

@export var controller: CharacterController3D
const SPEED = 5.5
const FLOOR_ACCELERATION = INF
const FLOOR_DECELERATION = 80.0
const AIR_ACCELERATION = 20.0
const AIR_DECELERATION = 0.0
const JUMP_VELOCITY = 5.72
const TERMINAL_VELOCITY = 30.0

@onready var _floor_cast := %FloorCast

@export var height: float = 2.0
@export var radius: float = 0.35

var _is_on_floor := false
var _jump_pending := false
var _direction := Vector3.ZERO
var _acceleration
var _deceleration

var slope_limit: float = 45.0

# Debug variables
var _debug_spheres: Array[MeshInstance3D] = []
var _debug_mesh: SphereMesh = SphereMesh.new()
var _debug_material: StandardMaterial3D = StandardMaterial3D.new()
var _debug_material_steep: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	controller.connect("rotate", _rotate)
	controller.connect("set_rotation", _set_rotation)
	controller.connect("direction_updated", _update_direction)
	controller.connect("jump_requested", _jump)
	
	# Configure the visual style of the debug sphere
	_debug_mesh.radius = 0.05
	_debug_mesh.height = 0.1
	_debug_material.albedo_color = Color.GREEN
	_debug_material_steep.albedo_color = Color.RED
	_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # Makes it glow/visible in dark
	_debug_material_steep.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED


func _check_floor() -> bool:
	var collision_points = _floor_cast.collision_points
	var collision_normals = _floor_cast.collision_normals
	var highest_point = _floor_cast.highest_collision_point
	var lowest_point = _floor_cast.lowest_collision_point
	
	for sphere in _debug_spheres:
		sphere.queue_free()
	_debug_spheres.clear()
	
	for i in range(len(collision_points)):
		var point = collision_points[i]
		var debug_sphere = MeshInstance3D.new()
		debug_sphere.mesh = _debug_mesh
		add_child(debug_sphere)
		debug_sphere.top_level = true
		debug_sphere.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		debug_sphere.global_position = point
		if collision_normals[i].angle_to(Vector3.UP) < deg_to_rad(slope_limit):
			_debug_mesh.surface_set_material(0, _debug_material)
		else:
			_debug_mesh.surface_set_material(0, _debug_material_steep)
		_debug_spheres.append(debug_sphere)
	
	var collision_point_height = highest_point.y
	if position.y - collision_point_height <= 0.0:
		return true
	return false


func _rotate(y_rotation: float):
	pass


func _set_rotation(y_rotation: float):
	self.rotation.y = y_rotation


func _update_direction(direction: Vector3) -> void:
	_direction = direction


func _jump() -> void:
	if _is_on_floor:
		_jump_pending = true
		velocity.y = JUMP_VELOCITY


func apply_impulse(impulse_velocity: Vector3, cancel_momentum: bool) -> void:
	if cancel_momentum:
		velocity = impulse_velocity
	else:
		velocity += impulse_velocity


func _physics_process(delta: float) -> void:
	_is_on_floor = _check_floor()
	
	if _is_on_floor:
		_acceleration = FLOOR_ACCELERATION
		_deceleration = FLOOR_DECELERATION
		if not _jump_pending:
			velocity.y = 0
	else:
		_acceleration = AIR_ACCELERATION
		_deceleration = AIR_DECELERATION
		_jump_pending = false
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)

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
