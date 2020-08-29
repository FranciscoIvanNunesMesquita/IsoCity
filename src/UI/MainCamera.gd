extends Camera2D
signal zoom_changed
signal position_changed
var zoom_min:Vector2
var zoom_max:Vector2
var map:TileMap
var speed = 20
var value = 0.2
var UI
var mouse_pos_c:Vector2
var mouse_pos_p:Vector2
var arrow_direction:String
func _ready():
	map = get_node("../MainMap")
	UI = get_node("../UI")
	zoom_min = map.size
	zoom_max = Vector2(0.5,0.5)
	set_home_position()
	map = get_parent().map
func _process(delta):
	if (UI.state == UI.states.BUILDING && UI.mouse_on_arrow) || (UI.state == UI.states.DEMOLISHING && UI.mouse_on_arrow):
		match arrow_direction:
			"bottom": position.y = position.y + speed*zoom.y
			"top": position.y = position.y - speed*zoom.y
			"left": position.x = position.x - speed*zoom.x
			"right": position.x = position.x + speed*zoom.x
		#print(make_canvas_position_local(get_local_mouse_position()))

"""-------------INPUTS--------------"""
func _input(event):
	if true:#!UI.focus_on_UI:
		if Input.is_action_pressed("ui_right"):
			position.x = position.x + speed*zoom.x
			emit_signal("position_changed")
		if Input.is_action_pressed("ui_left"):
			position.x = position.x - speed*zoom.x
			emit_signal("position_changed")
		if Input.is_action_pressed("ui_down"):
			position.y = position.y + speed*zoom.y
			emit_signal("position_changed")
		if Input.is_action_pressed("ui_up"):
			position.y = position.y - speed*zoom.y
			emit_signal("position_changed")
			
		
	if Input.is_action_pressed("ui_page_down"):
		if zoom < zoom_min:
			zoom.x = zoom.x + value*zoom.x
			zoom.y = zoom.y + value*zoom.y
			emit_signal("zoom_changed")
	if Input.is_action_pressed("ui_page_up"):
		if zoom > zoom_max:
			zoom.x = zoom.x - value*zoom.x
			zoom.y = zoom.y - value*zoom.y
			emit_signal("zoom_changed")
			
	if Input.is_action_pressed("ui_zoom_up"):
		if zoom > zoom_max && !UI.mouse_in:
			#if map.selector.visible && UI.state != UI.states.BUILDING:
			#	map.position = Vector2(0,0)
			#	position = map.selector.position
			zoom.x = zoom.x - value*zoom.x
			zoom.y = zoom.y - value*zoom.y
			
	if Input.is_action_pressed("ui_zoom_down"):
		if zoom < zoom_min && !UI.mouse_in:
			#if map.selector.visible && UI.state != UI.states.BUILDING:
				#map.position = Vector2(0,0)
				#position = map.selector.position
			zoom.x = zoom.x + value*zoom.x
			zoom.y = zoom.y + value*zoom.y

"""----------------METHODS----------------"""
func set_zoom_in_area(var pos:Vector2, var tax = 2):
	#nodeMainMap.position = Vector2(0,0)
	if zoom/tax > zoom_max:
		position = map.map_to_world(pos)+map.position
		position.y = position.y + map.cell_size.y/2
		emit_signal("position_changed")
		zoom = zoom/tax
		emit_signal("zoom_changed")
	elif zoom != zoom_max:
		position = map.map_to_world(pos)+map.position
		position.y = position.y + map.cell_size.y/2
		emit_signal("position_changed")
		zoom = zoom_max
		emit_signal("zoom_changed")
	else:
		position = map.map_to_world(pos)+map.position
		position.y = position.y + map.cell_size.y/2
		emit_signal("position_changed")
		zoom = zoom_max/4
		emit_signal("zoom_changed")

func set_home_position():
	zoom = zoom_min/25
	emit_signal("zoom_changed")
	map.position = Vector2(0,0)
	position = map.map_to_world(zoom_min/2)
	emit_signal("position_changed")

func _on_UI_mouse_entered_arrow(direction):
	arrow_direction = direction
	pass # Replace with function body.
