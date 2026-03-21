extends Node2D
const BULLET = preload("res://bullet.tscn")
@onready var muzzle: Marker2D = $Marker2D
@onready var gunshot_audio: AudioStreamPlayer = $Gunshot
var can_shoot = true

func _process(delta: float) -> void:
	var direction = get_global_mouse_position() - global_position
	rotation = direction.angle()
	if abs(rotation_degrees) > 90:
		scale.y = -1
	else:
		scale.y = 1
	if Input.is_action_just_pressed("Fire") and can_shoot:
		shoot()  # Call the shoot function

func shoot():
	"""Called when you fire the gun"""
	can_shoot = false
	
	# Play gunshot sound
	if gunshot_audio and gunshot_audio.stream:
		gunshot_audio.play()
		print("✓ Gunshot!")
	else:
		print("✗ ERROR: No gunshot_audio or stream!")
	
	# Spawn bullet
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	
	# Cooldown
	await get_tree().create_timer(2.0).timeout
	can_shoot = true
