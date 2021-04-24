extends TileMap


enum Tiles{
	WALL,
	FLOOR
}
func _on_Area2D_body_entered(body):
	for x in range(10,15):
		set_cell(x, 25, Tiles.WALL)
