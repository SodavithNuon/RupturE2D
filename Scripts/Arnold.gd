extends Area2D
@onready var exclamation_mark: AnimatedSprite2D = $ExclamationMark
const ARNOLD_DIALOGUE = preload("uid://d2nciq4rt6flq")
const ARNOLD_BALLOON = preload("res://Dialogue/arnold_balloon.tscn")

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _process(delta) -> void:
	if GameState.active_npc == self and Input.is_action_just_pressed("Interact") and not GameState.is_dialogue_active:
		DialogueManager.show_dialogue_balloon_scene(ARNOLD_BALLOON, ARNOLD_DIALOGUE, "start")

func _on_body_entered(body: Node2D) -> void:
	exclamation_mark.visible = true
	GameState.active_npc = self

func _on_body_exited(body: Node2D) -> void:
	exclamation_mark.visible = false
	if GameState.active_npc == self:
		GameState.active_npc = null

func _on_dialogue_started(dialogue):
	if dialogue != ARNOLD_DIALOGUE:
		return
	GameState.is_dialogue_active = true

func _on_dialogue_ended(dialogue):
	if dialogue != ARNOLD_DIALOGUE:
		return
	await get_tree().create_timer(0.3).timeout
	GameState.is_dialogue_active = false
