extends CharacterBody3D

const SPEED = 3
const JUMP_VELOCITY = 4.5
@export var sensitivity: float = 0.03  # Sensibilité de la souris
@export var invert_y: bool = true   # Inverser l'axe Y
@onready var camera_3d: Camera3D = $Neck/Camera3D

var rotation_x: float = 0.0  # Rotation verticale (haut/bas)
var rotation_y: float = 0.0  # Rotation horizontale (gauche/droite)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Capture la souris dans la fenêtre

func _input(event) -> void:
	if event is InputEventMouseMotion:
		_process_mouse_movement(event.relative)

func _physics_process(delta: float) -> void:
	# Appliquer la gravité si pas sur le sol
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Gérer le saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Gérer le déplacement basé sur les entrées
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process_mouse_movement(relative_motion: Vector2) -> void:
	# Ajuster les rotations avec les mouvements de la souris
	rotation_y -= relative_motion.x * sensitivity
	rotation_x -= relative_motion.y * sensitivity * (1 if invert_y else -1)

	# Limiter la rotation verticale pour éviter le retournement
	rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))

	# Appliquer les rotations
	rotation_degrees.y = rad_to_deg(rotation_y)  # Tourne le personnage (gauche/droite)
	camera_3d.rotation_degrees.x = rad_to_deg(rotation_x)  # Ajuste la caméra (haut/bas)
