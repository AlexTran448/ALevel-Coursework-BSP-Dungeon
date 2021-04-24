extends KinematicBody2D

onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var direct_sight = $RayCast2D
onready var weapon = $Weapon
onready var navigation = $Navigation2D
onready var timer = $Timer

export var SPEED = 5
export var HOME_AREA = 10
export var SEARCH_TIME = 10
export var SEARCH_TIME_DROPOFF = 1

onready var player = get_node("../Player")
var sees_player = false
var velocity = Vector2.ZERO
var last_location
onready var home_position = Rect2(position - Vector2(HOME_AREA/2,HOME_AREA/2) ,Vector2(HOME_AREA,HOME_AREA) )

enum {
	ATTACK
	STANDBY
	RETURN_HOME
	SEARCH
}

var state = STANDBY

func _ready():
	home_position = Rect2(position - Vector2(HOME_AREA/2,HOME_AREA/2) ,Vector2(HOME_AREA,HOME_AREA) )
	
func _process(delta):
	if player != null:
		direct_sight.cast_to = player.position
	match state:
		ATTACK:
			attack_state()
		STANDBY:
			standby_state()
		RETURN_HOME:
			return_home()
		SEARCH:
			search_state()
		

func _on_Hurtbox_area_entered(area):
	stats.health -= area.DAMAGE

func return_home():
	var path = navigation.get_simple_path(position, home_center())
	move_and_slide(position.move_toward(path[0], SPEED))

func standby_state():
	if sees_player:
		state = ATTACK
		

func search_state():
	var path = navigation.get_simple_path(position, player.position)
	if len(path) != 0:
		move_and_slide(position.move_toward(path[0], SPEED))
	if position.distance_to(home_center())*SEARCH_TIME_DROPOFF > 0:
		timer.start(SEARCH_TIME - (position.distance_to(home_center())*SEARCH_TIME_DROPOFF))
	
func attack_state():
	if direct_sight.get_collider() and player != null: pass
	else: weapon.create_projectile(position.direction_to(player.position))
	var path = navigation.get_simple_path(position, player.position)
	if len(path) != 0:
		move_and_slide(position.move_toward(path[0], SPEED))
	

	if not sees_player:
		state = search_state()
		

func home_center():
	return Vector2((home_position.position.x+home_position.end.x)/2,
	(home_position.position.y + home_position.end.y)/2)

func _on_Stats_no_health():
	queue_free()


func _on_PlayerSight_body_entered(body):
	sees_player = true

func _on_PlayerSight_body_exited(body):
	sees_player = false

func _on_Timer_timeout():
	state = RETURN_HOME

func _on_Player_send_body(body):
	player = body
