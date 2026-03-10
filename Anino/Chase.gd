extends CharacterBody3D

@export var speed: float = 5.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D

# Better way to find the player (works even if scene changes)
@export var player_path: NodePath = "/root/Main/player"
@onready var player: Node3D = get_node_or_null(player_path)

var update_timer: float = 0.0

func _ready() -> void:
	# Agent settings
	agent.path_desired_distance = 1.0
	agent.target_desired_distance = 1.0
	
	# Give the navigation server one frame to initialize
	await get_tree().physics_frame
	
	if player:
		agent.set_target_position(player.global_position)

func _physics_process(delta: float) -> void:
	# === GRAVITY ===
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# === CHASE LOGIC ===
	if player and not agent.is_navigation_finished():
		# Update target position every 0.3–0.5 seconds (smooth but not every frame)
		update_timer -= delta
		if update_timer <= 0.0:
			agent.set_target_position(player.global_position)
			update_timer = 0.4  # feel free to tweak
		
		# Get next point on the path
		var next_pos: Vector3 = agent.get_next_path_position()
		
		# Horizontal direction only (prevents fighting gravity on slopes)
		var direction: Vector3 = (next_pos - global_position)
		direction.y = 0
		direction = direction.normalized()
		
		# Move
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Face the direction it's walking (nice touch)
		if direction.length() > 0.1:
			look_at(global_position + direction, Vector3.UP)
	
	move_and_slide()
