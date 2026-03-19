extends Node2D

const BULLET = preload("res://bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D

var can_shoot = true

func _process(delta: float) -> void:
	var direction = get_global_mouse_position() - global_position
	rotation = direction.angle()
	if abs(rotation_degrees) > 90:
		scale.y = -1
	else:
		scale.y = 1
	if Input.is_action_just_pressed("Fire") and can_shoot:
		can_shoot = false
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = rotation
		await get_tree().create_timer(2.0).timeout
		can_shoot = true
