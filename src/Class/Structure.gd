extends Tile
class_name Structure
var progressBar:ProgressBar
var timer:Timer 
signal completed_construction
enum states {IDLE,BUILDING,PRODUCING,ELETRIC_DEPLETED}
var state = states.IDLE
var eletric

func _init(pos:Vector2,_data:Dictionary,tilemap:TileMap):
	data = _data.duplicate()
	pos_origin = pos
	self_ref = self
	map = tilemap


func _process(delta):
	if state == states.BUILDING:
		if progressBar.value == 50:
			set_construction_frames(map.IDs_construction_frames[1])
	if state == states.ELETRIC_DEPLETED:
		if eletric != null:
			eletric.position = map.position+ map.map_to_world(Vector2(pos_origin.x - (data.size.x)/2,pos_origin.y - (data.size.y)/2))
	if progressBar != null:
		progressBar.rect_position = map.position+map.map_to_world(Vector2(pos_origin.x - (data.size.x)/2,pos_origin.y - (data.size.y)/2))
		progressBar.rect_position.x -= progressBar.rect_size.x/2

func bar_filled():
	if state == states.BUILDING:
		construction()
		state = states.IDLE
		progressBar.queue_free()
		pass

func construction_frames():
	set_construction_frames(map.IDs_construction_frames[0])
	for x in range(pos_origin.x,pos_origin.x-data.size.x,-1):
		for y in range(pos_origin.y, pos_origin.y-data.size.y,-1):
			map.all_obj[Vector2(x,y)] = self.self_ref
			pass
	state = states.BUILDING
	var progressBarscene = load("res://src/UI/ProgressBar/ProgressBar.tscn")
	progressBar = progressBarscene.instance()
	add_child(progressBar)
	progressBar.rect_position = map.position + map.map_to_world(Vector2(pos_origin.x - (data.size.x)/2,pos_origin.y - (data.size.y)/2))
	progressBar.rect_position.x -= progressBar.rect_size.x/2
	progressBar.connect("bar_filled",self,"bar_filled")
	progressBar.start(0.03)
	#yield(get_tree().create_timer(1.0), "timeout")
	#construction()
func set_construction_frames(var id:int):
	for x in range(pos_origin.x,pos_origin.x-data.size.x,-1):
		for y in range(pos_origin.y,pos_origin.y-data.size.y,-1):
			map.set_cell(x,y,id)
func construction():
	set_construction_frames(map.ID_ground)
	var i = 0
	for x in range(pos_origin.x-data.size.x+1,pos_origin.x+1):
		map.set_cell(x,pos_origin.y,data.tiles[i])
		i = i +1
	for y in range(pos_origin.y-1,pos_origin.y-data.size.y,-1):
		map.set_cell(pos_origin.x,y,data.tiles[i])
		i = i +1
	map.emit_signal("structure_spawned",self)
	map.connect("structure_demolished",self,"start_timer")

func start_timer():
	timer =  Timer.new()
	add_child(timer)
	set_icon_eletric()
	timer.connect("timeout",self,"request_demand")
	timer.connect("timeout",self,"blink")
	timer.autostart = true
	timer.start(1)
	pass
func request_demand():
	if data.has("demand"):
		if map.UI.resourceList.check_demand(data.demand):
			print("energia restaurada")
			if eletric != null:
				eletric.visible = false
				eletric.queue_free()
			if timer != null:
				timer.stop()
				timer.queue_free()
			
			state = states.IDLE
			#map.UI.resourceList.add(data.demand,"demand_value")
			#map.UI.resourceList.show_list()
	else:
			timer.stop()
			timer.queue_free()
			eletric.queue_free()
			state = states.IDLE


func set_icon_eletric():
	var eletricScene = load("res://src/UI/eletric.tscn")
	eletric = eletricScene.instance()
	self.add_child(eletric)
	state = states.ELETRIC_DEPLETED
	eletric.position =map.position+ map.map_to_world(Vector2(pos_origin.x - (data.size.x)/2,pos_origin.y - (data.size.y)/2))
	eletric.visible = false
	pass
func blink():
	state = states.ELETRIC_DEPLETED
	if eletric != null:
		eletric.position = map.position+ map.map_to_world(Vector2(pos_origin.x - (data.size.x)/2,pos_origin.y - (data.size.y)/2))	
		eletric.visible = !eletric.visible
