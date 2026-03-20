extends CharacterBody2D
@export var attack_range := 40
@export var attack_cooldown := 1.0
@export var max_health := 100
@onready var sprite := $AnimatedSprite2D
const SPEED = 80
@export var player: Node2D
var _attack_timer := attack_cooldown  # Start with cooldown ready
var health := max_health
var is_dead := false
var has_attacked_this_frame := false

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

func _attack_on_player():
	"""Deal damage to the player - only called once per cooldown"""
	if player and player.has_method("take_damage"):
		player.take_damage(1)  # Deal 1 damage per hit
		print("Zombie attacked player! Player health: ", player.health)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		is_dead = true
		GameState.zombie_kills += 1
		GameState.kill_count_changed.emit(GameState.zombie_kills, GameState.kills_required)
		if GameState.zombie_kills >= GameState.kills_required:
			GameState.quest_complete.emit()
		sprite.play("SleepZ_Death")
		sprite.animation_finished.connect(func(): queue_free())
	else:
		sprite.play("SleepZ_Damaged")
		await sprite.animation_finished
		sprite.play("SleepZ_Idle")
