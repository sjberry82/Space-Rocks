extends Area2D

@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3
@export var bullet_spread = 0.2

var follow = PathFollow2D.new()
var target = null

func _ready():
	$Sprite2D.frame = randi() % 3
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false
	
#to move the character  we will still use the physics process because that is what the rest of the game uses
func _physics_process(_delta):
	rotation += deg_to_rad(rotation_speed) * _delta
	follow.progress += speed * _delta
	position = follow.global_position
	#remove enemy from game if path is completed
	if follow.progress_ratio >= 1:
		queue_free()
	
func shoot():
	$ShootSound.play()
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread)) #randomizes the accuracy of the enemy bullet
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position,dir)
	
func _on_gun_cool_down_timeout():
	shoot()
	
func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()
	
func explode():
	$ExplosionSound.play()
	speed = 0
	$GunCoolDown.stop()
	$CollisionShape2D.set_deferred("disabled",true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
	
func _on_body_entered(body):
	#this makes enemies unaffected by rocks.
	if body.is_in_group("rocks"):
		return
	explode()
	body.shield -=- 50
