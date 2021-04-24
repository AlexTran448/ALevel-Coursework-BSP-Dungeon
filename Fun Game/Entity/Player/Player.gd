extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 800
export var ROLL_SPEED = 120
export var FRICTION = 500

enum {
	MOVE
	DODGE
	ATTACK
}

onready var sprite = $Sprite
onready var weapon = $Weapon
onready var interactable_nearby = $InteractableNearby


var state = MOVE

var is_attacking = false
var velocity = Vector2.ZERO
var fire_vector = Vector2.RIGHT
var roll_vector = Vector2.DOWN
var interactable = []

signal send_body(body)

func _ready():
	emit_signal("send_body", self)
	
func _input(event):
	if event.is_action_pressed("Open_Inventory"):
		open_inventory()
	if event.is_action_pressed("Interact"):
		interact()
		
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)

		DODGE:
			pass
	

func movement_input():
	var vector = Vector2.ZERO
	vector.x =Input.get_action_strength("Right") -  Input.get_action_strength("Left")
	vector.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	return vector.normalized()
	
func move_state(delta):
	var input_vector = movement_input()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED * delta, ACCELERATION * delta)
		velocity = move_and_slide(velocity)
		sprite.flip_h = velocity.x < 0
	
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("Attack"):

		fire_vector = weapon.global_position.direction_to(get_global_mouse_position())
		is_attacking = true
		weapon.create_projectile(fire_vector)


	if is_attacking:

		weapon.create_projectile(fire_vector)
		is_attacking = false	
	weapon.set_rotation(fire_vector.angle())
	
	
	
	if len(interactable) != 0: interactable_nearby.visible	 = true
	else: interactable_nearby.visible = false
	

func open_inventory():
	print("open inventory")
	
func interact():
	var object = interactable.back()
	if object != null: object.use()


func interact_enter(item):
	interactable.append(item)

func interact_exit(item):
	interactable.erase(item)

