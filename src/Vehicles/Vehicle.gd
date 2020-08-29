extends KinematicBody2D
var speed = 800
var ctlSpeedX = 0.6244
var ctlSpeedY = 0.3656
var motion:Vector2
var map:TileMap
var texture:Sprite
var pos:Vector2
var data
var path_test2 = [Vector2(2,2),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(3,5),Vector2(4,5),Vector2(5,5),Vector2(5,6),Vector2(5,7),Vector2(5,8),Vector2(5,9),Vector2(5,10),Vector2(5,11),Vector2(6,11),Vector2(7,11),Vector2(8,11),Vector2(9,11),Vector2(10,11),Vector2(11,11),Vector2(12,11),Vector2(13,11),Vector2(14,11),Vector2(15,11),Vector2(16,11),Vector2(17,11)]#,Vector2(6,11),Vector2(6,11),]
var path_test = [Vector2(2,2),Vector2(3,2),Vector2(4,2),Vector2(5,2),Vector2(6,2),Vector2(7,2),Vector2(8,2),Vector2(9,2),Vector2(10,2)]
enum d {E,N,S,W}
var move_enable = false
var l = 0
var terrain_speed_factor = 0.0
var colision_rect:CollisionShape2D
var selected = false
export (Color,RGBA) var red 
export (Color,RGBA) var yellow 
func set_data(_data:Dictionary):
	data = _data.duplicate()
	pass
func _ready():
	map = get_parent()
	if map is TileMap:
		colision_rect = $CollisionShape2D
		texture = $Sprite
		
	else:
		print("parent is not tilemap:",map)

func move_in_path(var path:Array):
		get_vehicle_position()
		if pos != path[path.size()-1]:
			if pos != path[l]:
				move_iso(get_destiny_direction(path[l]))
				yield()
			else:
				l=l+1
				yield()
		elif pos == path[path.size()-1]:
			print("in destiny, path end")
			return true
	


func get_vehicle_position():
	pos = map.world_to_map(position)
	return pos

func get_destiny_direction(var destiny:Vector2):
	get_vehicle_position()
	if destiny.x == pos.x:
		if destiny.y > pos.y:
			return "S"
		elif destiny.y < pos.y:
			return "N"
	if destiny.y == pos.y:
		if destiny.x > pos.x:
			return "E"
		elif destiny.x < pos.x:
			return "W"
	print("distace more than 1")
func move_iso(var direction):
	var terrain  = map.get_obj_by_pos(pos)
	if terrain.is_navegable:
		terrain_speed_factor = terrain.speed_factor
		if direction=='N':
			motion.y = -speed*ctlSpeedY
			motion.x =  speed*ctlSpeedX
			$AnimatedSprite.frame = d.N
		elif direction=='S':
			motion.y =  speed*ctlSpeedY
			motion.x = -speed*ctlSpeedX
			$AnimatedSprite.frame = d.S
		elif direction=='E':
			motion.y =  speed*ctlSpeedY
			motion.x =  speed*ctlSpeedX
			$AnimatedSprite.frame = d.E
		elif direction=='W':
			motion.y = -speed*ctlSpeedY
			motion.x = -speed*ctlSpeedX
			$AnimatedSprite.frame = d.W

		motion = motion*terrain_speed_factor
		move_and_slide(motion)
		
		
	
		#position.y = position.y + (map.cell_size.y/2)
	else:
		print("not navegable: ",terrain.NAME)
	
func center_tile():
		position = map.map_to_world(map.world_to_map(position))
		#position.y = position.y + (map.cell_size.y/2)
		
		


