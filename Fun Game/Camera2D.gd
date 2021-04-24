extends Camera2D

export var zoom_interval = 0.2
export var min_zoom = 1
export var max_zoom = 3
func _input(event):
	if event.is_action_pressed("Zoom_In"):
		zoom = Vector2(clamp(zoom.x - zoom_interval, min_zoom, max_zoom),
		clamp(zoom.y - zoom_interval, min_zoom, max_zoom))
		
	elif event.is_action_pressed("Zoom_Out"):
		zoom = Vector2(clamp(zoom.y + zoom_interval, min_zoom, max_zoom),
		clamp(zoom.y + zoom_interval,min_zoom, max_zoom))



