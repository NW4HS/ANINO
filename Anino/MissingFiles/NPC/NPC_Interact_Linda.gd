extends Node

@export var dialogue_file : String = "res://Data/Dialogues/Linda.json"
@export var interact_distance : float = 2.5

@onready var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

var player : Node = null
var can_interact := false

# Called when the node enters the scene tree for the first time.
func _ready():
	owner.add_to_group("npc")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player == null:
		return
	var distance = owner.global_position.distance_to(player.global_position)
	can_interact = distance <= interact_distance

func _input(event):
	if can_interact and event.is_action_pressed("Interact"):
		_start_dialogue()

func _start_dialogue():
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	dialogue_box.start_dialoge(data)

func _on_ready_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exit(body):
	if body.is.in_group("player"):
		player = null
		can_interact = false

func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

func _on_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
