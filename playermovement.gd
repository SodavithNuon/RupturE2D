extends CharacterBody2D
class_name Player

# ====================
# SPEED
# ====================
const SPEED := 160
const SNEAK_MULTIPLIER := 0.5
@export var maxHealth = 100

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

	
var facing := "Forward"

func _physics_process(delta: float) -> void:
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
	
