extends TileMap
#NEVER SET TO TOOL, MAY PRODUCE TOO MANY TILES AND CAUSE EDITOR TO CRASH + LOSE DATA
export var dungeon_width = 100
export var dungeon_height = 100
export var minimum_width = 50
export var minimum_height = 50
export var room_standard_diviation = 5.0
export(float, 0,0.5) var clamp_length_factor = 0.3
export(float, 0, 1) var room_factor = 0.8
export var corridor_size = 0
export(float,0,1) var loop_chance = 0.5
export var area_per_enemy = 10.0

enum Tiles{
	WALL,
	FLOOR
}

var root
var rng = RandomNumberGenerator.new()
var astar = AStar2D.new()
var room_astar = AStar2D.new()
var tile_size = 16

onready var player = $Player
onready var treasure = $Treasure
onready var shopkeep = $Shop
onready var boss = $Boss
onready var enemy = $Enemy
onready var camera = $Camera2D

class BSP_Node:
	var position
	var size
	var end
	var center
	var left_child = null
	var right_child = null
	var leaf_container = []
	var visited = false
	var id
	var connection = []
	var type = null
	
	func _init(_position_x, _position_y, _size_x, _size_y):
		position = Vector2(_position_x,_position_y)
		size = Vector2(_size_x, _size_y)
		end = Vector2(_position_x + _size_x, _position_y + _size_y)
		center = Vector2(round((position.x + end.x) /2),round( (position.y + end.y) / 2))
		id = cantor_pairing_function(center.x, center.y)
		
	func cantor_pairing_function(a,b):
		return (a + b) * (a + b + 1) / 2 + b
		
func _ready():
	generate()

func generate():
	astar.clear()
	room_astar.clear()
	rng.randomize()
	set_cameabounds()
	fill_wall()
	root = BSP_Node.new(0,0, dungeon_width, dungeon_height)
	create_leaf(root)
	create_room(root)
	set_leaf_to_visited(root)
	create_corridor(root)
	var spawn = set_spawn(root)
	var boss_room = set_boss(root, spawn)
	var treasure_rooms = set_treasure(root)
	var shop = set_shop(root)
	spawn_player(spawn)
	spawn_boss(boss_room)
	spawn_treasure(treasure_rooms)
	spawn_shop(shop)
	spawn_enemy(root)
	
func set_cameabounds():
	var topleft = Vector2(0,0)
	var bottomright = Vector2(dungeon_width*tile_size,dungeon_height*tile_size)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = dungeon_width * tile_size
	camera.limit_bottom = dungeon_height * tile_size
	
func fill_wall():
	var adjacent = [Vector2.RIGHT, Vector2.DOWN]
	for x in range(dungeon_width):
		for y in range(dungeon_height):
			set_cell(x,y, Tiles.WALL)
			astar.add_point( cantor_pairing_function(x,y), Vector2(x,y), 50)
	for x in range(dungeon_width-1):
		for y in range(dungeon_height-1):
			for direction in adjacent:
				var next_cell = Vector2(x,y) + direction
				astar.connect_points(cantor_pairing_function(x,y),
				 cantor_pairing_function(next_cell.x, next_cell.y))



func create_leaf(node, depth = 0):
	var split_direction = rng.randi_range(0,1)
	if node.size.x < minimum_width:
		split_direction = 0
	if node.size.y < minimum_height:
		split_direction = 1
	if node.size.x < minimum_width and node.size.y < minimum_height:
		split_direction = null
	if split_direction == 0:
		#horizontal split
		var split = int(round(clamp(rng.randfn(node.size.y/2, room_standard_diviation),
		node.size.y*clamp_length_factor, node.size.y*(1-clamp_length_factor))))
		node.left_child = BSP_Node.new(node.position.x, node.position.y, #position
		 node.size.x, split) #size
		node.right_child = BSP_Node.new(node.position.x, node.position.y + split, #position
		 node.size.x, node.size.y - split) #size
		
	elif split_direction == 1:
		 #vertical split
		var split = int(round(clamp(rng.randfn(node.size.x/2, room_standard_diviation),
		node.size.x*clamp_length_factor, node.size.x*(1-clamp_length_factor))))
		node.left_child = BSP_Node.new(node.position.x, node.position.y, #position
		 split, node.size.y) #size
		node.right_child = BSP_Node.new(node.position.x + split, node.position.y, #position
		 node.size.x - split, node.size.y) #size
	else:
		node.leaf_container.append(node)
		return true
	create_leaf(node.left_child, depth +1)
	create_leaf(node.right_child, depth +1)

	node.leaf_container += node.left_child.leaf_container
	node.leaf_container += node.right_child.leaf_container
	return false
		
func create_room(node):
	for room in node.leaf_container:
		var room_width = room.size.x * (1- room_factor)
		var room_height = room.size.y * (1 - room_factor)
		for x in range (room.position.x + room_width/2 , room.end.x - room_width/2):
			for y in range(room.position.y + room_height/2, room.end.y - room_height/2):
				astar.set_point_weight_scale(cantor_pairing_function(x,y), 1)
				room_astar.add_point(cantor_pairing_function(x,y), Vector2(x,y) )
				set_cell(x, y, Tiles.FLOOR)

func set_leaf_to_visited(nodes):
	for node in nodes.leaf_container:
		if node.left_child == null:
			node.visited = true
			
func create_corridor(node):
	var l_child = node.left_child
	var r_child = node.right_child
	if not l_child.visited:
		create_corridor(l_child)
	if not r_child.visited:
		create_corridor(r_child)
	node.visited = true

	var distances = []
	for l_pair in l_child.leaf_container:
		for r_pair in r_child.leaf_container:
			
			var pairs =  {
			"left_pair": l_pair,
			"right_pair": r_pair,
			"distance": l_pair.center.distance_to(r_pair.center)}
			distances.append(pairs)
	

	distances = dict_bubble_sort(distances,"distance", true)
	var path = astar.get_point_path(distances[0].left_pair.id,
	distances[0].right_pair.id)
	distances[0].left_pair.connection.append(distances[0].right_pair)
	distances[0].right_pair.connection.append(distances[0].left_pair)
	room_astar.connect_points(distances[0].left_pair.id, distances[0].right_pair.id)
	if rng.randf() < loop_chance and len(distances) != 1:	
		path += astar.get_point_path(distances[1].left_pair.id,
		distances[1].right_pair.id)
		distances[1].left_pair.connection.append(distances[1].right_pair)
		distances[1].right_pair.connection.append(distances[1].left_pair)
		room_astar.connect_points(distances[1].left_pair.id, distances[1].right_pair.id)
	for point in path:
		for x in range(point.x-corridor_size, point.x+corridor_size):
			for y in range(point.y-corridor_size, point.y+corridor_size):
				set_cell(x,y, Tiles.FLOOR)
				astar.set_point_weight_scale(cantor_pairing_function(x,y), 1)

func set_spawn(root):
	var iteration = 1
	while true:
		for room in root.leaf_container:
			if len(room.connection) == iteration and room.type == null:
				room.type = "spawn"
				return room
		iteration += 1

func set_boss(root,spawn):
	var maximum_distance = 0
	var boss_room = null
	for room in root.leaf_container:
		var path = room_astar.get_point_path(cantor_pairing_function(spawn.center.x,spawn.center.y),
		cantor_pairing_function(room.center.x,room.center.y))
		if len(path) > maximum_distance:
			maximum_distance == len(path)
			boss_room = room
	boss_room.type = "boss"
	return boss_room

func set_treasure(root):
	var treasure_rooms = []
	for room in root.leaf_container:
		if len(room.connection )== 1 and room.type == null:
			room.type = "treasure"
			treasure_rooms.append(room)
	return treasure_rooms
	

func set_shop(root):
	var container = root.leaf_container
	container.shuffle()
	for room in container:
		if room.type == null:
			room.type = "shop"
			return room

func spawn_player(spawn):
	var instance = spawn_entity(player, spawn.center)
	var remote_transform = RemoteTransform2D.new()
	remote_transform.remote_path = "Camera2D"
	instance.add_child(remote_transform)

func spawn_boss(boss_room):
	#spawn_entity(boss, boss_room.center * tile_size)
	pass
	
func spawn_treasure(treasure_rooms):
	for room in treasure_rooms:
		spawn_entity(treasure, room.center)
		
func spawn_shop(shop):
	var instance = spawn_entity(shopkeep, shop.center)
	instance.room_area = Rect2(shop.position * tile_size, shop.size * tile_size)


func spawn_enemy(root):
	for room in root.leaf_container:
		if room.type == null:
			for enemy_count in range(room.size.x * room.size.y / area_per_enemy):
				var instance = spawn_entity(enemy, room.center)
				instance.player = player


func spawn_entity(entity, position):
	remove_child(entity)
	var instance = entity.duplicate()
	instance.set_position(position * tile_size)
	instance.pause_mode = false
	instance.visible = true
	add_child(instance)
	return instance

func cantor_pairing_function(a,b):
	return (a + b) * (a + b + 1) / 2 + b

func dict_bubble_sort(array,key, accending = true):
	var swap = true
	var pass_count = 0
	while swap and len(array) > 1:
		swap = false
		pass_count += 1
		for pointer in range(len(array)-pass_count):
			if array[pointer][key] > array[pointer+1][key]:
				swap = true
				var temp = array[pointer]
				array[pointer] = array[pointer+1]
				array[pointer+1] = temp
		
	if accending:
		pass
	else:
		array.invert()
	return array
			


