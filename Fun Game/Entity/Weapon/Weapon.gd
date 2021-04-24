tool
extends Node2D


onready var sprite = $Sprite
onready var timer = $Timer
export(PackedScene) var projectile 

export var cooldown = 1.0

var parent_layer = null
var is_ready = true

func _ready():
	pass
func create_projectile(direction):
	if is_ready:
		var world = get_tree().get_current_scene()
		var instance_projectile = projectile.instance()
		instance_projectile.global_position = global_position
		instance_projectile.direction = direction
		world.add_child(instance_projectile)
		is_ready = false
		timer.start(cooldown)


func _on_Timer_timeout():
	is_ready = true
