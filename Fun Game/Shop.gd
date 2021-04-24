extends KinematicBody2D

export var MOVE_SPEED = 500

onready var weapon = $Weapon

var nearby_enemies = []
var room_area = Rect2(position, Vector2(2,2))

signal interact_enter(item)
signal interact_exit(item)

func _physics_process(delta):
	print(room_area.has_point(position))
	if room_area.has_point(position): pass
	else: move_and_slide(position.move_toward(room_area.position, MOVE_SPEED))
	if len(nearby_enemies) == 0: pass
	else:	
		var target = nearby_enemies[0]
		weapon.create_projectile(position.direction_to(target.position))
		move_and_slide(position.move_toward(target.position, MOVE_SPEED))
		pass
func use():
	pass
	
func _on_PlayerSight_body_entered(_body):
	emit_signal("interact_enter",self)


func _on_PlayerSight_body_exited(_body):
	emit_signal("interact_exit",self)


func _on_EnemySight_body_entered(body):
	nearby_enemies.append(body)


func _on_EnemySight_body_exited(body):
	nearby_enemies.erase(body)	
