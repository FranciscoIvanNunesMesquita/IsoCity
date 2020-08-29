extends ItemList
var scroll:VScrollBar
var data_manager
var data:Dictionary
var list:Dictionary
export (Color,RGBA) var yellow
export (Color,RGBA) var red
func _ready():
	data_manager = DataManager.new()
	data = data_manager.resources.duplicate()
	scroll = get_v_scroll()
	scroll.connect("mouse_entered",self,"emit_signal",["mouse_entered"])
	scroll.connect("mouse_exited",self,"emit_signal",["mouse_exited"])
	visible = true
	make_list()
	show_list()

func show_list():
	var texture:Texture
	var text
	var size_cur = 0
	var size_pre = 0 
	var keys = list.keys()
	clear()
	for i in keys.size():
		texture = load(list[keys[i]].texture)
		if list[keys[i]].has("demand_value"):
			
			text = short_number(list[keys[i]].demand_value)+"/"+short_number(list[keys[i]].value)
		elif list[keys[i]].has("storage"):
			text = short_number(list[keys[i]].value)+"/"+short_number(list[keys[i]].storage)
		else:
			text = short_number(list[keys[i]].value)
		if texture != null:
			add_item(text,texture)
		else:
			add_item(text)
		if list[keys[i]].has("demand_value"):
			if list.get(keys[i]).demand_value > list.get(keys[i]).value:
				set_item_custom_fg_color(i,red)
		if list[keys[i]].has("storage"):
			if list[keys[i]].get("value") >= list[keys[i]].get("storage"):
				set_item_custom_fg_color(i,red)
		size_cur = get_item_text(i).length()
		if size_cur > size_pre:
			size_pre  = size_cur
	
	rect_min_size.x = 12*size_pre

func make_list():
	var keys = data.keys()
	for i in keys.size():
		if data.get(keys[i]) != null:
			if data.get(keys[i]).value != null:
				list[keys[i]] = data.get(keys[i])
				
				

func short_number(var number)->String:
	var unit:int
	if number >=0 && number<1000:
		return str(number)
	elif number>=1000 && number < 1000000 :
		unit = number/1000
		return str(unit)+"K"
	elif number>=1000000 && number < 1000000000:
		unit = number/1000000
		return str(unit)+"M"
	elif number>=1000000000:
		unit = number/1000000000
		return str(unit)+"G"
	return str(number/1000000000)+"G"
	
func check_debit(var debit:Dictionary)->bool:
	var keys = debit.keys()
	for i in keys.size():
		if data.get(keys[i]) != null:
			if data.get(keys[i]).value != null:
				if (data.get(keys[i]).value) < (debit.get(keys[i])):
					return false
			else:
				return false
		else:
			return false
	return true
	
func debit(var debit:Dictionary, var key):
	var keys:Array = debit.keys()
	for i in keys.size():
		if list.has(keys[i]):
			if list.get(keys[i]).get(key) != null:
				if !(list.get(keys[i]).get(key) - debit.get(keys[i]) < 0):
					list.get(keys[i])[key] -= debit.get(keys[i])
				else:
					print(" diferença menor que zero: ",key[i])
		else:
			print("list has't resource:",keys[i])
		
func add(var add:Dictionary, var key):
	var keys:Array = add.keys()
	for i in keys.size():
		if data.get(keys[i]) != null:
			if list.has(keys[i]):
				if list[keys[i]].has(key):
					list[keys[i]][key] += add.get(keys[i])
				else:
					print(keys[i]," not has: ",key)
			else:
				list[keys[i]] = data.get(keys[i])
				list[keys[i]].value = 0
				if list[keys[i]].has(key):
					list[keys[i]][key] = add.get(keys[i])
				else:
					print(keys[i]," not has: ",key)
		else:
			print("nao encotrado no arquivo resource:",keys[i])
func check_demand(var debit:Dictionary)->bool:
	var keys = debit.keys()
	for i in keys.size():
		if data.get(keys[i]) != null:
			if data.get(keys[i]).value != null:
				if data.get(keys[i]).demand_value <= data.get(keys[i]).value:
					pass
				else:
					return false
			else:
				return false
		else:
			return false
			
	return true
