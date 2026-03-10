# NPC George
extends CharacterBody3D

@onready var move_speed = 3
@onready var wander_radius = 8.0 #Layo ng paglalakad nila
@onready var wait_min = 2.0 #Min time ng pag-aantay bago maglakad
@onready var wait_max = 5.0 #Max time ng pag-aantay bago maglakad

@onready var nav_agent := $NavigationAgent3D
@onready var timer := $WaitTime

var home_position: Vector3
var is_waiting := false

func _ready():
	print("NPC ready: ", global_position)
	home_position = global_position
	#nav_agent.velocity_computed.connect(_on_velocity_computed)
	timer.timeout.connect(_on_wait_finished)
	await get_tree().process_frame
	_set_new_wander_target()

func _physics_process(delta: float) -> void:
	if is_waiting:
		return
	if nav_agent.is_navigation_finished():
		_start_waiting()
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	if direction.length() > 0.1:
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 0.1)
	
	velocity = direction * move_speed
	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity

func _set_new_wander_target():
	is_waiting = false
	var random_offset = Vector3(randf_range(-wander_radius, wander_radius), 0, randf_range(-wander_radius, wander_radius))
	var target = home_position + random_offset
	print("Setting target to: ", target)
	var nav_map = get_world_3d().navigation_map
	var valid_target = NavigationServer3D.map_get_closest_point(nav_map, target)
	nav_agent.set_target_position(valid_target)

func _start_waiting():
	is_waiting = true
	timer.wait_time = randf_range(wait_min, wait_max)
	timer.start()

func _on_wait_finished():
	_set_new_wander_target()
