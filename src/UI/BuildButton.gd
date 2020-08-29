extends Button
onready var icon_build:Texture = load("res://src/UI/Icons/build_button_icon.png")
onready var icon_cancel:Texture = load("res://src/UI/Icons/cancel_icon.png")
var list_structures:ItemList
func _ready():
	list_structures = get_node("../../BuildingsListContainer2/BuildingsList")

	pass



func _on_UI_state_changed(UI):
	match UI.state:
		UI.states.IDLE:
			icon = icon_build
		UI.states.CONSTRUCTION_STARTED:
			icon = icon_cancel
