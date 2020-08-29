extends ItemList
var scroll:VScrollBar
var data_manager
var data:Dictionary
var resources:ItemList
onready var parent:MarginContainer = get_parent()
func _ready():
	resources = get_node("../../ResourceListContainer/ResourceList")
	scroll = get_v_scroll()
	scroll.connect("mouse_entered",self,"emit_signal",["mouse_entered"])
	scroll.connect("mouse_exited",self,"emit_signal",["mouse_exited"])
	visible = false
	clear()
	data_manager = DataManager.new()
	data = data_manager.get_dics_has_key("buildable",true)
	if !data.empty():
		var size_cur = 0
		var size_pre = 0
		var size = 0
		var keys = data.keys()
		for i in keys.size():
			size_cur = data.get(keys[i]).name.length()
			if size_cur > size_pre:
				size_pre  = size_cur
			var texture = load(data.get(keys[i]).texture[0])
			if texture != null:
				add_item(data.get(keys[i]).name,texture)
				set_item_tooltip(i,get_requiriments(data.get(keys[i]).requiriments))
		rect_min_size.x = 11*size_pre
		update_list()
	else:
		print("data to list buildings is empty")

func update_list():
	unselect_all()
	var count = get_item_count()
	for i in count:
		var key = get_item_text(i)
		var aux:bool = match_requiriments(data.get(key).requiriments)
		set_item_disabled(i,aux)
	pass

func get_requiriments(var requi:Dictionary):
	var keys = requi.keys()
	var values = requi.values()
	var text:String
	for i in keys.size():
		text = text+keys[i]+":"+str(values[i])+"\n"
		pass
	return text
func match_requiriments(var requiriments:Dictionary):
	var keys = requiriments.keys()
	for i in keys.size():
		if resources.data.get(keys[i]) != null:
			if resources.data.get(keys[i]).value != null:
				if (resources.data.get(keys[i]).value) < (requiriments.get(keys[i])):
					#print("resource depleted:",resources.data_r.get(keys[i]).name,":",resources.data_r.get(keys[i]).value)
					return true
			else:
				return true
		else:
			#print("resource list not has: ",keys[i])
			return true
			
	return false

