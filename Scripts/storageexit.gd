extends Area2D
const STORAGE_EXIT = preload("uid://b5vsstqiv0ent")

func _ready():
	print("StorageExit _ready() called")
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	GameState.elapsed_time = 0.0
	GameState.time_display = "00:00"
	print("Timer reset for martstorage level")

func _process(_delta) -> void:
	if GameState.active_npc == self and Input.is_action_just_pressed("Interact") and not GameState.is_dialogue_active:
		print("Interact pressed - showing dialogue")
		DialogueManager.show_dialogue_balloon(STORAGE_EXIT, "start", [self])

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Parker":
		print("Parker entered StorageExit area")
		GameState.active_npc = self
		# Disable Martreturn to prevent interference
		var martreturn = get_tree().root.find_child("Martreturn", true, false)
		if martreturn:
			martreturn.set_process(false)
			print("Martreturn disabled")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Parker" and GameState.active_npc == self:
		print("Parker exited StorageExit area")
		GameState.active_npc = null
		# Re-enable Martreturn when leaving
		var martreturn = get_tree().root.find_child("Martreturn", true, false)
		if martreturn:
			martreturn.set_process(true)
			print("Martreturn re-enabled")

func _on_dialogue_started(dialogue):
	if dialogue != STORAGE_EXIT:
		return
	print("StorageExit dialogue started")
	GameState.is_dialogue_active = true

func _on_dialogue_ended(dialogue):
	if dialogue != STORAGE_EXIT:
		return
	print("StorageExit dialogue ended")
	await get_tree().create_timer(0.3).timeout
	GameState.is_dialogue_active = false

func go_to_escape_scene():
	print("Going to EscapeScene")
	# Use call_deferred to change scene safely after dialogue ends
	get_tree().change_scene_to_file.call_deferred("res://EscapeScene.tscn")
