@tool
class_name FloorCast
extends Node3D

enum FloorCastType {
	RADIAL,
	GRID,
}

@export var character3D: Character3D
@export var floorCastType: FloorCastType
@export_range(0.0, 100.0, 0.001) var raySpacing: float = 0.1
@export var rays: Array[RayCast3D]

var _ray_count: int

var collision_points: Array[Vector3] = []
var collision_normals: Array[Vector3] = []
var is_walkable_list: Array[bool] = []
var highest_collision_point: Vector3
var lowest_collision_point: Vector3
var is_on_ground
var is_on_slide

signal set_rays_enabled(status: bool)


func _ready() -> void:
	position_rays()
	set_rays_enabled.emit(true)


func _check_collision_points() -> void:
	collision_points.clear()
	collision_normals.clear()
	highest_collision_point = Vector3.DOWN * INF
	lowest_collision_point = Vector3.UP * INF
	is_on_ground = false
	is_on_slide = false
	
	for ray in rays:
		if not ray.is_colliding(): continue
		
		var collision_normal = ray.collision_normal
		collision_normals.append(collision_normal)
		
		var collision_point = ray.collision_point
		collision_points.append(collision_point)
		if collision_point.y > highest_collision_point.y:
			highest_collision_point = collision_point
		if collision_point.y < lowest_collision_point.y:
			lowest_collision_point = collision_point
		
		var is_slide = ray.is_slide
		if (not is_on_ground) and (not is_slide): 
			if _is_within_stepping_range(collision_point):
				is_on_ground = true


func _is_within_stepping_range(point: Vector3) -> bool:
	if character3D.position.y - point.y <= 0.0:
		return true
	return false


func _check_floor() -> void:
	pass


func position_rays() -> void:
	if not character3D: return
	if rays.is_empty() or len(rays) != _ray_count: _instantiate_rays()
	
	var origin := Vector3.ZERO
	origin.y = character3D.radius
	if position != origin: position = origin
	
	if floorCastType == FloorCastType.RADIAL:
		_radial_composition()
	else:
		_grid_composition()


func _instantiate_rays() -> void:
	pass


func _radial_composition() -> void:
	for i in range(len(rays)):
		rays[i].target_position = Vector3(0, character3D.radius * -2, 0)
		if (i == len(rays)):
			rays[i].position = Vector3.ZERO
		else:
			var xpos = character3D.radius / 2 * cos(i * 0.25 * PI)
			var zpos = character3D.radius / 2 * sin(i * 0.25 * PI)
			rays[i].position = Vector3(xpos, 0, zpos)


func _grid_composition() -> void:
	pass


func set_ray_length(length: float = character3D.radius * 2) -> void:
	for ray in rays:
		ray.target_position.y = ray.position.y - length


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		#position_rays()
		pass


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_check_collision_points()
