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
var spawn_position: Vector2
var facing := "Forward"
var health: int
var is_dead := false
var is_invulnerable := false
var invulnerability_timer := 0.0

func _ready():
	# Get references
	anim = $AnimatedSprite2D
	health_bar = get_tree().root.find_child("TextureProgressBar", true, false)
	
	if health_bar:
		health_bar.min_value = 0.0
		health_bar.max_value = 5.0
		health_bar.value = 5.0
		print("Health bar configured")
	
	spawn_position = global_position
	health = maxHealth

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Update elapsed time in GameState
	GameState.elapsed_time += delta
	
	# Update time display (format as SS:MS - seconds:milliseconds)
	var seconds = int(GameState.elapsed_time)
	var milliseconds = int((GameState.elapsed_time - seconds) * 100)  # Get 2 digits of milliseconds
	var new_time_display = "%02d:%02d" % [seconds, milliseconds]
	
	# Only emit signal if time changed (avoid spam)
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
	# Animation speed
	anim.speed_scale = 0.7 if sneaking else 1.2
	anim.play(anim_name)

func take_damage(amount: int) -> void:
	"""Called when zombie attacks the player"""
	if is_dead:
		return
	
	# Don't take damage if invulnerable
	if is_invulnerable:
		print("Player is invulnerable!")
		return
	
	health -= amount
	if health < 0:
		health = 0
	
	# Start invulnerability window
	is_invulnerable = true
	invulnerability_timer = 0.5  # 0.5 second invulnerability
	
	update_health_bar()
	print("Player took damage! Health: ", health, "/", maxHealth)
	
	if health <= 0:
		die()

func die() -> void:
	"""Player death - play animation then restart level"""
	is_dead = true
	is_invulnerable = true  # Can't take more damage while dying
	health = 0
	velocity = Vector2.ZERO
	
	# Play death animation
	anim.play("Idle_Forward")
	print("Player died! Restarting level...")
	
	# Wait for death animation to finish
	await get_tree().create_timer(2.0).timeout
	
	# Reset GameState before reloading
	GameState.zombie_kills = 0
	GameState.elapsed_time = 0.0  # Reset timer
	GameState.time_display = "00:00"
	
	# Restart the entire level
	get_tree().reload_current_scene()

func update_health_bar():
	"""Update the health bar display"""
	if health_bar == null:
		return
	
	health_bar.value = float(health)
