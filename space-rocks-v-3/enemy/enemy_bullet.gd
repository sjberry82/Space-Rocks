extends Area2D
@export var speed = 1000
@export var damage = 15

func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()
	
func _process(_delta):
	position += transform.x * speed * _delta
	
func _on_body_entered(body):
	if body.name == "Player":
		body.shield -= damage
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
