#Dialogue script
extends CanvasLayer

signal dialogue_finished

@onready var npc_name_label := $Panel/MarginContainer/NPCName
@onready var dialogue_text := $Panel/MarginContainer/DialogueText
@onready var choices_container := $Panel/MarginContainer/Choices
@onready var prompt_label := $Panel/MarginContainer/Prompt

var lines := []
var current_line := 0
var is_typing := false
var is_choice_line := false
var type_speed := 0.03 #character /s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	pass # Replace with function body.

func start_dialogue(data: Dictionary):
	lines = data["Lines"]
	npc_name_label.text = data["npc_name"]
	current_line = 0
	show()
	get_tree().pause = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_show_line(current_line)

func _show_line(index: int):
	choices_container.hide()
	prompt_label.show()
	
	var line = lines[index]
	
	if typeof(line) == TYPE_DICTIONARY and line.has("choices"):
		is_choice_line = true
		await _type_text(line["text"])
		_show_choices(line["choices"])
	else:
		is_choice_line = false
		var text = line if typeof(line) == TYPE_STRING else line["text"]
		await _type_text(text)

func _type_text(text: String):
	dialogue_text.text = ""
	is_typing = true
	prompt_label.hide()
	
	for character in text:
		dialogue_text.text += character
		await get_tree().create_timer(type_speed).timeout
	
	is_typing = false
	prompt_label.show()

func _show_choices(choices: Array):
	prompt_label.hide()
	choices_container.show()
	
	for child in choices_container.get_children():
		child.queue_free()
	
	for choice in choices:
		var button = Button.new()
		button.text = choice['label']
		button.pressed.connect(_on_choice_selected.bind(choice["response"]))
		choices_container.add_child(button)
	
func _on_choice_selected(response: String):
	choices_container.hide()
	await _type_text(response)
	current_line += 1
	if current_line < lines.size():
		_show_line(current_line)
	else:
		_end_dialogue()

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("interact"):
		if is_typing:
			is_typing = false
		elif not is_choice_line:
			current_line += 1
			if current_line < lines.size():
				_show_line(current_line)
			else:
				_end_dialogue()

func _end_dialogue():
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	dialogue_finished.emit()
