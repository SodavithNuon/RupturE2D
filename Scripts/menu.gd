extends Node

@onready var menu_music = $MenuMusic

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_music.play()

func _on_startbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Mart.tscn")
	
func _on_quitbutton_pressed() -> void:
	get_tree().quit()
