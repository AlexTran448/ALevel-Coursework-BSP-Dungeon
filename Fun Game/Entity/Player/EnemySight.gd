extends Area2D

signal average_position(average)

func _process(delta):
	var bodies = get_overlapping_bodies()
	var average = Vector2.ZERO
	for body in bodies:
		average += body.get_position()
	average = average / len(bodies)
	emit_signal("average_position", average)
