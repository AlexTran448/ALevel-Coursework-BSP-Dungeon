extends Camera2D


var bodies = []

func _process(delta):
	var centre = Vector2.ZERO
	for i in bodies:
		centre += i.position
	centre = centre / len(bodies)
	self.position = centre


func _on_TargetArea_body_entered(body):
	bodies.append(body)

func _on_TargetArea_body_exited(body):
	bodies.erase(body)



func _on_Player_send_body(body):
	bodies.append(body)
