extends Area2D

const EXIT_MART = preload("uid://bro3gs46t1c2b")

var is_player_close = false
var is_dialogue_active = false

func ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _process(delta) -> void:
	if is_player_close and Input.is_action_just_pressed("Interact") and not is_dialogue_active:
		DialogueManager.show_dialogue_balloon(EXIT_MART, "start")

func _on_body_entered(body: Node2D) -> void:
	is_player_close = true
 
func _on_body_exited(body: Node2D) -> void:
	is_player_close = false

func _on_dialogue_started(dialogue):
	is_dialogue_active = true
 
func _on_dialogue_ended(dialogue):
	await get_tree().create_timer(0.3).timeout
	is_dialogue_active = false
