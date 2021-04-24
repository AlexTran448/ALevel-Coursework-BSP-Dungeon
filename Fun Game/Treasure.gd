extends StaticBody2D

signal interact_enter(item)
signal interact_exit(item)


func _on_Area2D_body_entered(body):
	emit_signal("interact_enter",self)
	
func _on_Area2D_body_exited(body):
	emit_signal("interact_exit",self)

func use():
	print("add x to inventory")



