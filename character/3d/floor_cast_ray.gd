class_name FloorCastRay
extends RayCast3D

@onready var _floor_cast: FloorCast = %FloorCast
@onready var _character3D: Character3D = owner

var collision_point: Vector3
var collision_normal: Vector3
var is_slide: bool

func _ready() -> void:
	_floor_cast.connect("set_rays_enabled", set_ray_status)


func set_ray_status(status: bool):
	enabled = status


func _physics_process(delta: float) -> void:
	collision_point = get_collision_point()
	collision_normal = get_collision_normal()
	if collision_normal.angle_to(Vector3.UP) < deg_to_rad(_character3D.slope_limit):
		is_slide = false
	else:
		is_slide = true
