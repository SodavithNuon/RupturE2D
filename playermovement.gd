extends CharacterBody2D
class_name Player
# ====================
# SPEED
# ====================
const SPEED := 160
const SNEAK_MULTIPLIER := 0.5
@export var maxHealth = 5

var anim: AnimatedSprite2D
var health_bar: TextureProgressBar
var footstep_audio: AudioStreamPlayer
var damage_audio: AudioStreamPlayer
var spawn_position: Vector2
var facing := "Forward"
var health: int
var is_dead := false
var is_invulnerable := false
var invulnerability_timer := 0.0
var footstep_timer := 0.0
var footstep_interval := 0.5

func _ready():
	anim = $AnimatedSprite2D
	health_bar = get_tree().root.find_child("TextureProgressBar", true, false)
	footstep_audio = $FootstepAudio
	damage_audio = $DamageAudio
	
	if health_bar:
		health_bar.min_value = 0.0
		health_bar.max_value = 5.0
		health_bar.value = 5.0
	
	spawn_position = global_position
	health = maxHealth

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Update elapsed time
	GameState.elapsed_time += delta
	
	# Update time display
	var seconds = int(GameState.elapsed_time)
	var milliseconds = int((GameState.elapsed_time - seconds) * 100)
	var new_time_display = "%02d:%02d" % [seconds, milliseconds]
	
	if new_time_display != GameState.time_display:
		GameState.time_display = new_time_display
		GameState.time_updated.emit(GameState.time_display)
	
	# Update invulnerability timer
	if is_invulnerable:
		invulnerability_timer -= delta
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
	
	var direction := Vector2.ZERO
	# ===== INPUT =====
	if Input.is_action_pressed("Move_Left"):
		direction.x -= 1
	if Input.is_action_pressed("Move_Right"):
		direction.x += 1
	if Input.is_action_pressed("Move_Forward"):
		direction.y -= 1
	if Input.is_action_pressed("Move_Backward"):
		direction.y += 1
	direction = direction.normalized()
	
	# ===== SNEAK =====
	var speed := SPEED
	var sneaking := Input.is_action_pressed("Sneak")
	if sneaking:
		speed *= SNEAK_MULTIPLIER
	velocity = direction * speed
	move_and_slide()
	
	# ===== FOOTSTEP SOUNDS =====
	if direction != Vector2.ZERO and not sneaking:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			play_footstep_sound()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0.0
	
	# ===== IDLE =====
	if direction == Vector2.ZERO:
		anim.speed_scale = 1.0
		anim.play("Idle_" + facing)
		return
	
	# ===== FACING + WALK ANIMATION =====
	var anim_name := ""
	# Diagonal first
	if direction.x < 0 and direction.y < 0:
		anim_name = "Walk_LeftUp"
		facing = "Left"
	elif direction.x < 0 and direction.y > 0:
		anim_name = "Walk_LeftDown"
		facing = "Left"
	elif direction.x > 0 and direction.y < 0:
		anim_name = "Walk_RightUp"
		facing = "Right"
	elif direction.x > 0 and direction.y > 0:
		anim_name = "Walk_RightDown"
		facing = "Right"
	# Straight directions
	elif direction.x < 0:
		anim_name = "Walk_Left"
		facing = "Left"
	elif direction.x > 0:
		anim_name = "Walk_Right"
		facing = "Right"
	elif direction.y < 0:
		anim_name = "Walk_Forward"
		facing = "Forward"
	elif direction.y > 0:
		anim_name = "Walk_Backward"
		facing = "Backward"
	
	anim.speed_scale = 0.7 if sneaking else 1.2
	anim.play(anim_name)

func play_footstep_sound():
	"""Play footstep sound effect"""
	if footstep_audio:
		if footstep_audio.stream:
			footstep_audio.play()
		else:
			print("✗ ERROR: No footstep stream assigned!")
	else:
		print("✗ ERROR: footstep_audio is null!")

func take_damage(amount: int) -> void:
	"""Called when zombie attacks the player"""
	if is_dead:
		return
	
	if is_invulnerable:
		return
	
	health -= amount
	if health < 0:
		health = 0
	
	# Play damage sound
	if damage_audio and damage_audio.stream:
		damage_audio.play()
		print("✓ Damage sound playing!")
	
	is_invulnerable = true
	invulnerability_timer = 0.5
	
	update_health_bar()
	print("Player took damage! Health: ", health, "/", maxHealth)
	
	if health <= 0:
		die()

func die() -> void:
	"""Player death - return to Mart.tscn and reset"""
	is_dead = true
	is_invulnerable = true
	health = 0
	velocity = Vector2.ZERO
	
	# Play death animation
	anim.play("Player_Death")
	print("Player died! Returning to Mart...")
	
	# Wait for death animation to finish
	await get_tree().create_timer(2.0).timeout
	
	# Reset everything
	GameState.zombie_kills = 0
	GameState.elapsed_time = 0.0
	GameState.time_display = "00:00"
	
	# Return to Mart.tscn
	get_tree().change_scene_to_file("res://Mart.tscn")

func update_health_bar():
	"""Update the health bar display"""
	if health_bar == null:
		return
	
	health_bar.value = float(health)
