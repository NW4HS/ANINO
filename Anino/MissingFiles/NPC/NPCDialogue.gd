extends Area3D

@export var dialogue_resource: DialogueResource
@export var speaker_name: String = "Name"
@export var interaction_distance: float = 2.0
@export var pause_wandering_on_talk: bool = true

@onready var root_npc: CharacterBody3D = get_parent()
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var player_in_range: bool = false
var is_talking: bool = false

signal conversation_started(speaker: String)
signal conversation_ended(speaker: String)

func _ready() -> void:
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = interaction_distance
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)

func _on_body_enter(body: Node3D) -> void:
	print("Body entered: ", body.name)   # debug - check Output panel
	if body.is_in_group("player"):
		player_in_range = true
		print("Player in range!")        # debug - should print when you walk near

func _on_body_exit(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or is_talking:
		return
	if event.is_action_pressed("interact"):
		start_conversation()

func start_conversation() -> void:
	if not dialogue_resource:
		push_error("No dialogue resource set on NPC: " + speaker_name)
		return
	if is_talking:
		return

	is_talking = true
	conversation_started.emit(speaker_name)

	if pause_wandering_on_talk:
		root_npc.set_physics_process(false)

	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	await DialogueManager.dialogue_ended

	is_talking = false
	conversation_ended.emit(speaker_name)

	if pause_wandering_on_talk:
		root_npc.set_physics_process(true)
