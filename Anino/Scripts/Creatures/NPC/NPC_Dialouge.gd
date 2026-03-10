@tool  # Hot-reload in editor!
extends Area3D
class_name NPC_Dialogue

@export var dialogue_resource: DialogueResource = # Drag your .dialogue file here (e.g., villager_intro.dialogue)
@export var speaker_name: String = "Linda"  # Auto-fills UI
@export var interaction_distance: float = 2.0  # Sphere radius
@export var pause_wandering_on_talk: bool = true  # Stops root movement during chat
@export var resume_wandering_label: String = "resume_wander"  # Custom signal for root script

@onready var dialogue_manager: DialogueManager = get_parent().get_node("DialogueManager")
@onready var root_npc: CharacterBody3D = get_parent()  # Assumes root is CharacterBody3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var player_in_range: bool = false
var is_talking: bool = false

signal conversation_started(speaker: String)
signal conversation_ended(speaker: String)

func _ready():
	# Setup interact bubble
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = interaction_distance
	input_ray_pickable = true  # For mouse clicks
	
	# Connect DialogueManager (auto-pauses game if addon set)
	if dialogue_manager:
		dialogue_manager.conversation_started.connect(_on_convo_start)
		dialogue_manager.conversation_ended.connect(_on_convo_end)
	
	# Player enter/exit for hints (e.g., "Press E to talk")
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)

func _on_body_enter(body: Node3D):
	if body.is_in_group("player"):
		player_in_range = true
		# TODO: Show UI prompt "Talk to [speaker_name] (E)"

func _on_body_exit(body: Node3D):
	if body.is_in_group("player"):
		player_in_range = false

func _input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if not player_in_range or is_talking: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_conversation()

func start_conversation():
	if not dialogue_resource or is_talking: return
	dialogue_manager.start(dialogue_resource, "start")  # "start" label
	conversation_started.emit(speaker_name)
	is_talking = true

func _on_convo_start(resource: DialogueResource):
	# Pause wandering (call virtual on root)
	if pause_wandering_on_talk:
		root_npc.call_deferred("pause_movement")  # Root implements this!

func _on_convo_end(resource: DialogueResource):
	is_talking = false
	conversation_ended.emit(speaker_name)
	# Resume wandering
	if pause_wandering_on_talk:
		root_npc.call_deferred(resume_wandering_label)  # e.g., "resume_wander()"

# Virtual: Override per-NPC for custom logic (e.g., Aswang NPC spawns hint item)
func _custom_on_start(): pass
func _custom_on_end(): pass
