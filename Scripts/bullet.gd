extends Node2D

const SPEED: int = 900
const DAMAGE: int = 50  # adjust as needed

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Make sure your bullet has an Area2D with a CollisionShape2D as a child
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
	queue_free()  # bullet disappears on hit
