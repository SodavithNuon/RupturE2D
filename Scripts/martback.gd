extends Area2D

var is_player_close = false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta) -> void:
	if is_player_close and Input.is_action_just_pressed("Interact"):
		GameState.active_npc = null
		GameState.is_dialogue_active = false
		get_tree().change_scene_to_file.call_deferred("res://Mart.tscn")

func _on_body_entered(_body: Node2D) -> void:
	is_player_close = true

func _on_body_exited(_body: Node2D) -> void:
	is_player_close = false
