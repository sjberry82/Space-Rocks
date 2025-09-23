extends RigidBody2D
#first we start with a enum. enum is a list of constraints/choices that allow you to switch states
#enums are basically a numerical list with text instead of numbers
#mylist = [coke, pepsi, rc] mylist(0)
#enums are just numbers that we assign names to.
#mylist - [0,1,2] instead we say mylist = ["zero", "one", "two", "three"]
#can't set position using RigidBody2D. we use integrate forces instead
@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25
var can_shoot = true

enum {INIT,ALIVE,INVULNERABLE,DEAD}
#we crate a default state
var state = INIT
#when we load our game we want to make sure our state is alive
#that means we load the state once (_ready) and then we can create a function that will allow us to change
var thrust = Vector2.ZERO
#thrust determines direction
var rotation_dir = 0
var screensize = Vector2.ZERO

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate
	
func change_state(new_state):
	#match - which will take a new state variable and match it to one of the states we created above
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled",true)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled",false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled",true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled",true)
	state = new_state
	
#process funciton will be a little different since we are using rigidbody.
#we will have two functions
#this one will just check for input every frame
func _process(_delta):
	get_input()
	
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		#returns either internal funcion variable to something else or exits a function
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	else:
		rotation_dir = Input.get_axis("rotate_left","rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)
		
#we have a second process called physics process. When we want to apply physic to your spaceship we have
func _physics_process(delta):
	#we apply our physics forces
	#there are two forces built into godot that we will use
	#conatant force x,y movement(thrust)
	#torque = rotation
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	
func _on_gun_cooldown_timeout():
	can_shoot = true
