extends CharacterBody3D

@export var pause_menu: CanvasLayer
@export var speed = 5.0
@export var sprint_speed = 8.5
@export var crouch_speed = 2.5
const JUMP_VELOCITY = 4.5

var is_crouching := false
var is_sprinting := false
var normal_height := 2.0
var crouch_height := 1.4

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#sprint
	is_sprinting = Input.is_action_pressed("Sprint")
	
	var current_speed : float = speed
	
	if is_sprinting and not is_crouching:
		current_speed = sprint_speed
	elif is_crouching:
		current_speed = crouch_speed
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
