extends Node

# Save state for zombies
var killed_zombies: Dictionary = {}  # {scene_name: [zombie_ids]}
var total_zombie_kills: int = 0  # Track total kills across all scenes
var elapsed_time: float = 0.0  # Track elapsed time persistently

func _ready():
	add_to_group("savestate")

# Called when a zombie dies
func mark_zombie_dead(zombie_id: String, scene_name: String):
	if scene_name not in killed_zombies:
		killed_zombies[scene_name] = []
	
	if zombie_id not in killed_zombies[scene_name]:
		killed_zombies[scene_name].append(zombie_id)
		total_zombie_kills += 1  # Increment total kill count
	
	print("Zombie killed: ", zombie_id, " in scene: ", scene_name)
	print("Total kills: ", total_zombie_kills)
	print("Killed zombies in ", scene_name, ": ", killed_zombies[scene_name])

# Called when loading a scene to check if zombie should be dead
func is_zombie_dead(zombie_id: String, scene_name: String) -> bool:
	if scene_name not in killed_zombies:
		return false
	return zombie_id in killed_zombies[scene_name]

# Clear all saved state (for new game)
func reset_save_state():
	killed_zombies.clear()
	total_zombie_kills = 0
	elapsed_time = 0.0
	print("Save state reset")

# Optional: Get all dead zombies in a scene
func get_dead_zombies_in_scene(scene_name: String) -> Array:
	if scene_name in killed_zombies:
		return killed_zombies[scene_name]
	return []

# Optional: Debug print
func print_save_state():
	print("=== Current Save State ===")
	for scene in killed_zombies:
		print(scene, ": ", killed_zombies[scene])
