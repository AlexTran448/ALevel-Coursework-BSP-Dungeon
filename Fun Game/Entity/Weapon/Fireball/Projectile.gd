extends KinematicBody2D
class_name Projectile


export var SPEED = 10
export var DAMAGE = 1
export var TIME_TO_LIVE = 10

onready var timer = $Timer
onready var sprite = $Sprite
 



var direction = Vector2.RIGHT 
# prevents direction from being 0 by default that will make projectiles stay in same spot


func _ready():
	timer.start(TIME_TO_LIVE)

func _physics_process(delta):

#	 this sets the velocity of the bullet
#	and makes it travels at constant speed in a direction
#	until it hits a wall"
	

	# move_and_collide(direction * speed) -- old version
	if move_and_collide( direction * SPEED) != null:
		queue_free()
	
	# currently stops moving when colliding with a wall
	# should instead free itself instead



func _on_Timer_timeout():
	
#	 kills this entity after a set amount of time
#	is reached to prevent too many entities that need to
#	be processed by the game engine
	
	queue_free()
