extends CharacterBody2D

@export var attack_range := 90
@export var attack_cooldown := 3

@onready var sprite := $AnimatedSprite2D

var player: Node2D = null
var _attack_timer := 0.0

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
		sprite.play("SleepZ_Idle")
		return
	
	var dist = global_position.distance_to(player.global_position)
	print("dist: ", dist)
	
	if dist <= attack_range:
		print("ATTACKING")
		velocity = Vector2.ZERO
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			sprite.play("SleepZ_Attack")
			_attack_timer = attack_cooldown
	else:
		velocity = Vector2.ZERO
		sprite.play("SleepZ_Idle")
	
	move_and_slide()
