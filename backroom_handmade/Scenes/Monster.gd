extends CharacterBody3D

enum State { PATROL, CHASE }

@export var speed := 0.5
@export var patrol_radius := 10.0
@export var vision_angle_deg := 60.0
@export var vision_distance := 15.0
@export var target_path: NodePath

@onready var player: Node3D = get_node(target_path)
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var rng := RandomNumberGenerator.new()

var state: State = State.PATROL
var origin_position: Vector3
var patrol_timer := 0.0
var patrol_interval := 2.0  # temps avant un nouveau point aléatoire

func _ready() -> void:
	print("Agent trouvé :", agent)
	if agent == null:
		push_error("NavigationAgent3D non trouvé ! Vérifie la structure de la scène.")
		return
	origin_position = global_transform.origin
	agent.target_position = get_random_patrol_position()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	match state:
		State.PATROL:
			patrol_behavior(delta)
			if is_player_in_vision():
				state = State.CHASE
		State.CHASE:
			chase_behavior()
			if not is_player_in_vision():
				state = State.PATROL
				agent.target_position = get_random_patrol_position()

	# Déplacement vers la cible de navigation
	var next_path_position := agent.get_next_path_position()
	var direction := (next_path_position - global_transform.origin).normalized()
	velocity = direction * speed
	velocity.y = 0
	move_and_slide()

	# Orientation du monstre
	if direction.length() > 0.1:
		look_at(global_transform.origin + direction, Vector3.UP)
	
	if agent.is_navigation_finished():
		return  # on attend un nouveau target_position

	if agent.get_next_path_position() != Vector3.ZERO:
		var next_pos := agent.get_next_path_position()
		velocity = direction * speed
		move_and_slide()


func patrol_behavior(delta: float) -> void:
	patrol_timer -= delta
	if patrol_timer <= 0.0 or agent.is_navigation_finished():
		agent.target_position = get_random_patrol_position()
		patrol_timer = patrol_interval

func chase_behavior() -> void:
	agent.target_position = player.global_transform.origin
	print("Cible définie :", agent.target_position)

func get_random_patrol_position() -> Vector3:
	var angle := rng.randf_range(0, PI * 2)
	var distance := rng.randf_range(2, patrol_radius)
	var offset := Vector3(cos(angle), 0, sin(angle)) * distance
	return origin_position + offset

func is_player_in_vision() -> bool:
	var to_player := player.global_transform.origin - global_transform.origin
	if to_player.length() > vision_distance:
		return false

	var forward := -transform.basis.z.normalized()
	var dir_to_player := to_player.normalized()
	var angle_deg := rad_to_deg(acos(forward.dot(dir_to_player)))

	return angle_deg < vision_angle_deg * 0.5
