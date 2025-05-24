extends Node3D

@export var sensitivity: float = 0.1  # Adjust to control mouse sensitivity
@export var invert_y: bool = false   # Set to true to invert Y-axis movement

var rotation_x: float = 0.0  # Vertical rotation (up and down)
var rotation_y: float = 0.0  # Horizontal rotation (left and right)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock the mouse to the window

func _input(event):
	if event is InputEventMouseMotion:
		_process_mouse_movement(event.relative)

func _process_mouse_movement(relative_motion: Vector2):
	# Adjust rotation based on mouse movement
	rotation_y -= relative_motion.x * sensitivity
	rotation_x -= relative_motion.y * sensitivity * (1 if invert_y else -1)

	# Clamp the vertical rotation to avoid flipping the camera
	rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))

	# Apply rotation to the node
	rotation_degrees = Vector3(rad_to_deg(rotation_x), rad_to_deg(rotation_y), 0)
