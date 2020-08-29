extends Node
class_name DataManager
var resources:Dictionary
var structures:Dictionary
var vehicles:Dictionary
var all_data_dic:Dictionary
var all_data:Array
var to_tileset:Array
var id_construction_frame:int = 74
func _init():
	structures = import("res://src/Data/data_structures.json")
	resources = import("res://src/Data/data_resources.json")
	vehicles = import("res://src/Data/data_vehicles.json")
	unpackge(structures)
	unpackge(resources)
	unpackge(vehicles)
	to_tileset = get_list_dic_has_key("to_tileset",true)

	
func unpackge(var dic:Dictionary) -> void:
	var structures:Array  = dic.values()
	var keys:Array = dic.keys()
	for i in structures.size():
			all_data.append(structures[i])
			all_data_dic[keys[i]] = structures[i]


func import(var path:String)->Dictionary:
	var data_file = File.new()
	data_file.open(path,File.READ)
	var data_json = JSON.parse(data_file.get_as_text())
	if !(data_json.error == OK):
		print("erro file, number: ",data_json.error)
		print("path :",path)
		print("in line: ",data_json.error_line)
		print(data_json.error_string)
		data_file.close()
	data_file.close()
	return data_json.result
	
		
func get_list_dic_has_key(var key:String,var value = null,var list_to_search = null)->Array:
	#if value not null,get only that has key and value
	
	var aux = []
	var list:Array
	if list_to_search != null:
		list = list_to_search
	else:
		list = all_data
		#print(all_data)
	if value != null:
		for i in list.size():
			if list[i].has(key):
				if list[i].get(key) == value:
					aux.append(list[i])
		return aux
	else:
		for i in list.size():
			if list[i].has(key):
				aux.append(list[i])
		return aux
func get_dics_has_key(var key, var value)->Dictionary:
	var keys = all_data_dic.keys()
	var sub_dic:Dictionary
	for i in keys.size():
		if all_data_dic.get(keys[i]).get(key) != null:
			if all_data_dic.get(keys[i]).get(key) == value:
				sub_dic[keys[i]] = all_data_dic.get(keys[i])
	return sub_dic

func save(var data_to_save, var name:String = "save"): #tool 
	if !data_to_save.empty():
		var file = File.new()
		file.open("res://src/Data/"+name+".json",File.WRITE)
		file.store_line(to_json(data_to_save))
		file.close()
	else:
		print("data empty: ",data_to_save)
func save_all():
	save(structures,"data_structures")
	save(resources,"data_resources")
	#save(vehicles,"data_vehicles")
	pass

func get_list_values_by_combined_keys(var key_to_get,var key_to_filter:String,var value=null)->Array:
	var aux=[]
	if value == null:
		aux = get_list_dic_has_key(key_to_filter)
	else:
		aux = get_list_dic_has_key(key_to_filter,value)
	
	var list=[]
	for i in aux.size():
		list.append(aux[i].get(key_to_get))
	return list
	
	
func get_value(var list:Array,var value):
	for i in list.size():
		if list[i].get(value):
			pass

func set_value(var when , var key, var value):
	
	pass


