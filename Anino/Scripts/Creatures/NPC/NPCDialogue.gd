@tool
extends Area3D
class_name NPCDialogue

@export var dialogue_resource: DialogueResource # Drag your .dialogue file (.tres) here
@export var speaker_name: String = "Linda"
@export var interaction_distance: float = 2.0
@export var pause_wandering_on_talk: bool = true
@export var resume_wandering_method: String = "resume_wander"  # Method name on root

@onready var root_npc: CharacterBody3D = get_parent()
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var player_in_range: bool = false
var is_talking: bool = false

signal conversation_started(speaker: String)
signal conversation_ended(speaker: String)

func _ready():
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = interaction_distance
	input_ray_pickable = true  # Mouse clicks work
	
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)

func _on_body_enter(body: Node3D):
	if body.is_in_group("player"):
		player_in_range = true
		# Optional: Show prompt UI "Talk (E)" or glow

func _on_body_exit(body: Node3D):
	if body.is_in_group("player"):
		player_in_range = false

func _input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if not player_in_range or is_talking: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_conversation()

func start_conversation():
	if not dialogue_resource or is_talking: 
		push_error("No dialogue_resource set on ", speaker_name)
		return
	
	# Use GLOBAL DialogueManager
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")  # Or .start() if custom balloon
	conversation_started.emit(speaker_name)
	is_talking = true
	
	# Connect once for end (safe)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)

func _on_dialogue_ended(resource: DialogueResource):
	is_talking = false
	conversation_ended.emit(speaker_name)
	if pause_wandering_on_talk:
		root_npc.call_deferred(resume_wandering_method)

# Pause on start (call from root if needed, or add signal connect)
func pause_wandering():
	if pause_wandering_on_talk:
		root_npc.call_deferred("pause_movement")
