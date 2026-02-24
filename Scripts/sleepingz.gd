extends CharacterBody2D

@export var speed := 40.0
@export var chase_range := 150.0     # how far zombie "sees" the player
@export var attack_range := 30.0     # how close before switching to attack
@export var attack_cooldown := 1.0

@onready var sprite := $AnimatedSprite2D

var player: Node2D = null
var _attack_timer := 0.0

func _ready():
	# Grab the player automatically — no signals needed
	player = get_tree().get_first_node_in_group("Player")
	print("SleepingZ found player: ", player)

func _physics_process(delta):
	if player == null:
		sprite.play("SleepZ_Idle")
		return

	var dist = global_position.distance_to(player.global_position)

	if dist <= attack_range:
		# Close enough — attack
		velocity = Vector2.ZERO
		sprite.play("SleepZ_Attack")
		# TODO: add player.take_damage() here later

	elif dist <= chase_range:
		# In range — chase
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		sprite.play("SleepZ_Walk")

	else:
		# Too far — idle
		velocity = Vector2.ZERO
		sprite.play("SleepZ_Idle")

	move_and_slide()
