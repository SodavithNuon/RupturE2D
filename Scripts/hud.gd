extends CanvasLayer
@onready var quest_label: Label = $QuestLabel
@onready var timer_label: Label = $TimerLabel  # Add a new Label node for the timer

func _ready() -> void:
	quest_label.text = "Zombies killed: 0 / 5"
	GameState.kill_count_changed.connect(_on_kill_count_changed)
	GameState.time_updated.connect(_on_time_updated)
	
	# Initialize timer display
	if timer_label:
		timer_label.text = "Time: 00:00"

func _on_kill_count_changed(current: int, required: int) -> void:
	quest_label.text = "Zombies killed: %d / %d" % [current, required]

func _on_time_updated(time_string: String) -> void:
	if timer_label:
		timer_label.text = "Time: %s" % time_string
