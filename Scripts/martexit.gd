extends Area2D
const EXIT_MART = preload("uid://bro3gs46t1c2b")

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _process(delta) -> void:
	if GameState.active_npc == self and Input.is_action_just_pressed("Interact") and not GameState.is_dialogue_active:
		DialogueManager.show_dialogue_balloon(EXIT_MART, "start", [self])

func go_to_storage():
	get_tree().change_scene_to_file.call_deferred("res://martstorage.tscn")

func _on_body_entered(body: Node2D) -> void:
	GameState.active_npc = self

func _on_body_exited(body: Node2D) -> void:
	if GameState.active_npc == self:
		GameState.active_npc = null

func _on_dialogue_started(dialogue):
	if dialogue != EXIT_MART:
		return
	GameState.is_dialogue_active = true

func _on_dialogue_ended(dialogue):
	if dialogue != EXIT_MART:
		return
	await get_tree().create_timer(0.3).timeout
	GameState.is_dialogue_active = false
