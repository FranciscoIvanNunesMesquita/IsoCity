#tool
extends MapEngine

onready var UI = get_node("../UI")
onready var veicleScene = load("res://src/Vehicles/Vehicle.tscn")
var selector:Node
var data_to_build:Dictionary
var area_ok = false
var pressed:bool = false
func _ready():
	#make_tileset_tool()
	selector = $Selector
	init_tile_set()
	build_ground()
	build_procedural_tiles(1000,ID_lake,1,30)
	build_procedural_tiles(1000,IDs_trees,1,30)
	creat_map_logic()
	
	#print(all_obj)
	#
	pass

func _process(delta):
	match UI.state:
		UI.states.BUILDING:
			var pos = get_mouse_position_on_tilemap()
			if pos.x > size.x-1:
				pos.x = size.x-1
			if pos.x < size.x-size.x+data_to_build.size.x-1:
				pos.x = size.x-size.x+data_to_build.size.x-1
					
			if pos.y > size.y-1: 
				pos.y = size.y-1
			if pos.y < size.y-size.y+data_to_build.size.y-1:
					pos.y = size.y-size.y+data_to_build.size.y-1
			area_ok = check_area(pos,data_to_build.size.x,data_to_build.size.y,"ground")
			if get_cellv(pos) != -1:
				selector.set_selector(pos,data_to_build,area_ok)
		UI.states.IDLE:
			if pressed&& !UI.mouse_in:
				self.position = get_global_mouse_position()-mouse_position
		UI.states.CONSTRUCTION_STARTED:
			if pressed && !UI.mouse_in:
				self.position = get_global_mouse_position()-mouse_position


func _input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			selector.visible = false
			UI.interactMenu.visible = false
		if event.is_action_pressed("ui_click") :
			pressed = true
			var pos = get_mouse_position_on_tilemap()
			if !UI.mouse_in && !(UI.state == UI.states.BUILDING):
				var obj_click = get_obj_by_pos(pos)
				if obj_click != null:
					
					if (obj_click.data.tiles[0] != ID_ground):
						if (UI.state != UI.states.DEMOLISHING):
							selector.set_selector(obj_click.pos_origin,obj_click.data)
						emit_signal("click_on_tile",obj_click)
					
			if !UI.mouse_in && (UI.state == UI.states.BUILDING) && area_ok:
				spawn_structure(world_to_map(selector.position),data_to_build)
		if event.is_action_released("ui_click"):
			pressed = false


func _on_UI_state_changed(UI):
	match UI.state:
		UI.states.BUILDING:
			data_to_build = data_manager.get_list_dic_has_key("name",UI.name_structure)[0]
		UI.states.IDLE:
			selector.visible = false
		UI.states.DEMOLISHING:
			selector.visible = false
			




func _on_Selector_visibility_changed():
	pass # Replace with function body.


