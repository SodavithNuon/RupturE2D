extends CharacterBody2D
@export var attack_range := 40
@export var attack_cooldown := 1.0
@export var max_health := 100
@onready var sprite := $AnimatedSprite2D
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var death_audio: AudioStreamPlayer = $DeathAudio
@onready var groan_audio: AudioStreamPlayer = $GroanAudio
const SPEED = 80
@export var player: Node2D
var _attack_timer := attack_cooldown
var health := max_health
var is_dead := false
var has_attacked_this_frame := false
var groan_timer := 0.0
var groan_interval := 3.0  # Groan every 3 seconds

func _ready():
	# CHECK IF THIS ZOMBIE IS ALREADY DEAD FROM SAVE STATE
	if SaveState.is_zombie_dead(self.name, get_tree().current_scene.name):
		print("Zombie ", self.name, " already dead. Removing.")
		queue_free()
		return
	
	print("Zombie ", self.name, " spawned in ", get_tree().current_scene.name)

func _physics_process(delta):
	if is_dead:
		return
	if player == null:
		return
	
	var dist = global_position.distance_to(player.global_position)
	var dir = (player.global_position - global_position).normalized()
	
	# Flip sprite based on direction
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
	
	# Decrease attack timer every frame
	_attack_timer -= delta
	
	# Update groan timer
	groan_timer -= delta
	if groan_timer <= 0.0:
		play_groan_sound()
		groan_timer = groan_interval
	
	# Reset the attack flag each frame
	has_attacked_this_frame = false
	
	if dist <= attack_range:
		# In attack range - try to attack
		velocity = Vector2.ZERO
		sprite.play("SleepZ_Attack")
		
		# Only attack once per cooldown period
		if _attack_timer <= 0.0 and not has_attacked_this_frame:
			_attack_on_player()
			has_attacked_this_frame = true
			_attack_timer = attack_cooldown  # Reset timer
	else:
		# Chase - move directly toward player
		sprite.play("SleepZ_Walk")
		velocity = dir * SPEED
	
	move_and_slide()

func play_groan_sound():
	"""Play zombie groaning sound"""
	if groan_audio and groan_audio.stream:
		groan_audio.play()
		print("✓ Zombie groan sound playing!")

func _attack_on_player():
	"""Deal damage to the player - only called once per cooldown"""
	if player and player.has_method("take_damage"):
		player.take_damage(1)
		
		# Play attack sound
		if attack_audio and attack_audio.stream:
			attack_audio.play()
			print("✓ Zombie attack sound playing!")
		
		print("Zombie attacked player! Player health: ", player.health)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		is_dead = true
		
		# SAVE STATE - Mark this zombie as dead so it stays dead when returning to scene
		SaveState.mark_zombie_dead(self.name, get_tree().current_scene.name)
		
		# Update kill count from SaveState (persistent across scenes)
		GameState.zombie_kills = SaveState.total_zombie_kills
		GameState.kill_count_changed.emit(GameState.zombie_kills, GameState.kills_required)
		if GameState.zombie_kills >= GameState.kills_required:
			GameState.quest_complete.emit()
		
		# Play death sound
		if death_audio and death_audio.stream:
			death_audio.play()
			print("✓ Zombie death sound playing!")
		
		sprite.play("SleepZ_Death")
		
		# Wait for death animation and sound to finish before removing
		await get_tree().create_timer(1.5).timeout
		queue_free()
	else:
		sprite.play("SleepZ_Damaged")
		await sprite.animation_finished
		sprite.play("SleepZ_Idle")
