extends CanvasLayer
enum states {IDLE,CONSTRUCTION_STARTED,BUILDING,DEMOLISHING,SETTING,RESOURCE_DEPLETED}
var state = states.IDLE
var buildingList:ItemList
var resourceList:ItemList
var interactMenu:MarginContainer
var optionsMenu:MarginContainer
var buildButton:Button
var demolitionButton:Button
var textInteractMenu:Label 
var name_structure 

var mouse_in:bool = false
var arrows:Dictionary
signal state_changed
signal mouse_entered_arrow
signal mouse_exited_arrow
var mouse_on_arrow:bool = false
func _ready():
	buildingList = $BuildingsListContainer2/BuildingsList
	resourceList = $ResourceListContainer/ResourceList
	interactMenu = $InteractMenuContainer
	optionsMenu = $Options
	buildButton = $BuildButtonContainer/BuildButton
	demolitionButton = $Options/VBoxContainer/DemolitionButton
	textInteractMenu = $InteractMenuContainer/VBoxContainer/Text
	arrows["top"] = $ArrowTop
	arrows["bottom"] = $ArrowBottom
	arrows["left"] = $ArrowLeft
	arrows["right"] = $ArrowRight
	set_visible_arrows(false)

func mouse_in_UI():
	mouse_in = true
	pass

func mouse_out_UI():
	mouse_in = false
	pass

func _on_DemolitionButton_button_down():
	match state:
		states.IDLE: 
			state = states.DEMOLISHING
			emit_signal("state_changed",self)
		states.DEMOLISHING:
			state = states.IDLE
			emit_signal("state_changed",self)
			
	pass # Replace with function body.

func _on_BuildButton_button_down():
	match state:
		states.IDLE: 
			if buildingList.visible:
				buildingList.visible = false
			else:
				buildingList.visible = true
				state = states.CONSTRUCTION_STARTED
				emit_signal("state_changed",self)
		states.CONSTRUCTION_STARTED:
			if buildingList.visible:
				buildingList.visible = false
				state = states.IDLE
				emit_signal("state_changed",self)
			else:
				buildingList.visible = true
		states.BUILDING:
			buildingList.visible = false
			state = states.IDLE
			emit_signal("state_changed",self)

func _on_MainMap_click_on_tile(tile):
	match state:
		states.DEMOLISHING:
			tile.map.demolishing_structure(tile)
		states.IDLE:
			interactMenu.visible = true
			textInteractMenu.visible = true
			textInteractMenu.text = tile.data.name


func _on_BuildingsList_item_selected(index):
	buildingList.unselect_all()
	if !buildingList.is_item_disabled(index):
		name_structure =  buildingList.get_item_text(index)
		buildingList.visible = false
		mouse_in = false
		state = states.BUILDING
		emit_signal("state_changed",self)
	
	pass # Replace with function body.

func _on_MainMap_structure_spawned(structure):
	if structure.data.has("provides"):
		resourceList.add(structure.data.provides,"value")
	if structure.data.has("demand"):
		resourceList.add(structure.data.demand,"demand_value") 
		if !resourceList.check_demand(structure.data.demand):
			structure.start_timer() 
	resourceList.show_list()
	pass # Replace with function body.

func _on_MainMap_structure_spawn_started(structure):
	if resourceList.check_debit(structure.data.requiriments):
		resourceList.debit(structure.data.requiriments,"value")
		resourceList.show_list()
		if !resourceList.check_debit(structure.data.requiriments):
			state = states.IDLE
			emit_signal("state_changed",self)
	buildingList.update_list()
	pass # Replace with function body.


func set_visible_arrows(var enable:bool):
	var keys = arrows.keys()
	for i in keys.size():
		arrows.get(keys[i]).visible = enable



func _on_UI_state_changed(UI):
	match state:
		states.BUILDING:
			set_visible_arrows(true)
			interactMenu.visible =false
			optionsMenu.visible = false
		states.IDLE:
			optionsMenu.visible = true
			set_visible_arrows(false)
		states.CONSTRUCTION_STARTED:
			optionsMenu.visible = false
		states.DEMOLISHING:
			interactMenu.visible = false
			set_visible_arrows(true)
	pass # Replace with function body.
	
func _mouse_on_arrows(direction):
	mouse_on_arrow = true
	emit_signal("mouse_entered_arrow",direction)
	pass


func  _mouse_out_arrows():
	mouse_on_arrow = false
	pass # Replace with function body.






func _on_MainMap_structure_demolished(structure):
	if structure.data.has("provides"):
		resourceList.debit(structure.data.provides,"value")
	if structure.data.has("demand"):
		resourceList.debit(structure.data.demand,"demand_value") 
	resourceList.show_list()
	pass # Replace with function body.
