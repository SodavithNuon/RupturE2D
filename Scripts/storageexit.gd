extends Area2D
const STORAGE_EXIT = preload("uid://b5vsstqiv0ent")

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta) -> void:
	if GameState.active_npc == self and Input.is_action_just_pressed("Interact") and not GameState.is_dialogue_active:
		DialogueManager.show_dialogue_balloon(STORAGE_EXIT, "start", [self])


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Parker":
		GameState.active_npc = self

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Parker" and GameState.active_npc == self:
		GameState.active_npc = null

func _on_dialogue_started(dialogue):
	if dialogue != STORAGE_EXIT:
		return
	GameState.is_dialogue_active = true

func _on_dialogue_ended(dialogue):
	if dialogue != STORAGE_EXIT:
		return
	await get_tree().create_timer(0.3).timeout
	GameState.is_dialogue_active = false
