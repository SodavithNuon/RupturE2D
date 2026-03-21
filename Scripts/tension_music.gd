extends AudioStreamPlayer

func _ready():
	# Start playing tension music
	play()
	print("Tension music started!")
	
	# Connect to quest complete signal
	GameState.quest_complete.connect(_on_quest_complete)

func _on_quest_complete():
	"""Stop music when all zombies are killed"""
	print("All zombies killed! Stopping tension music...")
	stop()
