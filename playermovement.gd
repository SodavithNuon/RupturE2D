extends CharacterBody2D

# ====================
# SPEED
# ====================
const SPEED := 160
const SNEAK_MULTIPLIER := 0.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing := "Forward" # Forward, Backward, Left, Right

# ====================
# MAIN LOOP
# ====================
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

	# ===== ANIMATION =====
	if direction == Vector2.ZERO:
		anim.speed_scale = 1.0
		anim.play("Idle_" + facing)
		return

	# decide facing
	if abs(direction.x) > abs(direction.y):
		facing = "Right" if direction.x > 0 else "Left"
	else:
		facing = "Backward" if direction.y > 0 else "Forward"

	# slower anim when sneaking
	anim.speed_scale = 0.7 if sneaking else 1.2
	anim.play("Walk_" + facing)
