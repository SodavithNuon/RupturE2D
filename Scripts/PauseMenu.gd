extends CanvasLayer
class_name PauseMenu

@onready var resume_button: Button = $ResumeButton
@onready var main_menu_button: Button = $MainMenuButton

var is_paused := false

func _ready():
	print("PauseMenu _ready() called")
	
	# IMPORTANT - allows menu to work while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
		print("ResumeButton connected successfully")
	else:
		print("ERROR: resume_button is null!")
	
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
		print("MainMenuButton connected successfully")
	else:
		print("ERROR: main_menu_button is null!")
	
	# Hide the menu at start
	hide()
	is_paused = false

func _input(event):
	# Check for ESC key press
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		# Consume the input so it doesn't propagate further
		get_tree().root.set_input_as_handled()
		
		# Toggle pause state
		if is_paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	print("Game paused!")
	is_paused = true
	show()
	get_tree().paused = true

func resume_game():
	print("Game resumed!")
	is_paused = false
	hide()
	get_tree().paused = false

func _on_resume_pressed():
	print("Resume button pressed!")
	resume_game()

func _on_main_menu_pressed():
	print("=== Main Menu Button Pressed ===")
	print("Current paused state: ", get_tree().paused)
	print("Attempting to unpause...")
	get_tree().paused = false
	print("Game unpaused. Current paused state: ", get_tree().paused)
	print("Current scene: ", get_tree().current_scene.name)
	print("Attempting to load: res://menu.tscn")
	var error = get_tree().change_scene_to_file("res://menu.tscn")
	print("Change scene result: ", error)
	if error != OK:
		print("ERROR CODE: ", error)
