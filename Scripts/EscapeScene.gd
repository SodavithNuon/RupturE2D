extends CanvasLayer
class_name EscapeScene

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var menu_button: Button = $MenuButton

func _ready():
	print("EscapeScene _ready() called")
	
	var escape_time = GameState.time_display
	if time_label:
		time_label.text = "Time: %s" % escape_time
	
	# THIS IS IMPORTANT - allows button to work while paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button
	if menu_button:
		menu_button.pressed.connect(_on_menu_button_pressed)
		print("MenuButton connected successfully")
	else:
		print("ERROR: menu_button is null!")
	
	get_tree().paused = true

func _on_menu_button_pressed():
	print("Menu button pressed!")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
