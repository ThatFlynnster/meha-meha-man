@tool
extends CollisionShape3D

# We use setters (set = ...) to trigger an update immediately
# when you change values in the Inspector.
@export_group("Shape Properties")
@export var height: float = 2.0:
	set(value):
		height = value
		generate_shape()

@export var radius: float = 0.5:
	set(value):
		radius = value
		generate_shape()

@export var bevel_radius: float = 0.1:
	set(value):
		bevel_radius = value
		generate_shape()

@export_range(3, 64) var radial_segments: int = 32:
	set(value):
		radial_segments = value
		generate_shape()

@export_range(1, 16) var bevel_segments: int = 5:
	set(value):
		bevel_segments = value
		generate_shape()

func _ready() -> void:
	# Generate on load so it appears when the scene opens
	generate_shape()

func generate_shape() -> void:
	# Safety check: Prevent errors if parameters are invalid while typing
	if radius <= 0 or height <= 0:
		return
		
	# Clamp bevel to ensure it fits
	var safe_bevel = clamp(bevel_radius, 0.0, min(radius, height / 2.0))
	
	var points: PackedVector3Array = []
	var profile_points: PackedVector2Array = []
	
	var half_h = height / 2.0
	var bevel_center_x = radius - safe_bevel
	var bevel_center_y = half_h - safe_bevel
	
	# 1. Calculate the 2D Bevel Curve (Top-Right quadrant)
	for i in range(bevel_segments + 1):
		var angle = (float(i) / bevel_segments) * (PI / 2.0)
		var x = bevel_center_x + cos(angle) * safe_bevel
		var y = bevel_center_y + sin(angle) * safe_bevel
		profile_points.append(Vector2(x, y))
	
	# 2. Revolve around Y axis
	for i in range(radial_segments):
		var theta = (float(i) / radial_segments) * TAU
		var cos_theta = cos(theta)
		var sin_theta = sin(theta)
		
		for p in profile_points:
			# Top Ring
			points.append(Vector3(p.x * cos_theta, p.y, p.x * sin_theta))
			# Bottom Ring (Mirror Y)
			points.append(Vector3(p.x * cos_theta, -p.y, p.x * sin_theta))

	# 3. Assign the shape
	# We create a new shape to ensure the physics engine and editor refresh correctly
	if shape is ConvexPolygonShape3D:
		shape.points = points
	else:
		var new_shape = ConvexPolygonShape3D.new()
		new_shape.points = points
		shape = new_shape
