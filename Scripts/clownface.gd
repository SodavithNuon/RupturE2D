extends CharacterBody2D

@export var speed := 40.0

@onready var sprite := $AnimatedSprite2D

var player: Node2D = null
var chasing := false


func _physics_process(delta):
	if chasing and player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		_update_animation(dir)
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _update_animation(dir: Vector2):
	# Up / Down has priority
	if abs(dir.y) > abs(dir.x):
		if dir.y < 0:
			sprite.play("Beast_Up")
		else:
			sprite.play("Beast_Down")
		sprite.flip_h = false
	else:
		sprite.play("Beast_Left")
		sprite.flip_h = dir.x > 0   # flip to face right


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body
		chasing = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player = null
		chasing = false


func _on_character_body_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		chasing = true


func _on_character_body_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		chasing = false
