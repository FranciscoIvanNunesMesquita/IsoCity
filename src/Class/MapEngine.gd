extends TileMap
class_name MapEngine
var size:Vector2=Vector2(100,100)
var cell_init:Vector2 = Vector2(0,0)
var IDs:Array
var ID_ground:int
var ID_lake:int
var IDs_trees:Array
var IDs_resource:Array
var IDs_construction_frames:Array
var all_obj:Dictionary
var obj_click
var mouse_pos:Vector2
var data_tileset
var data_manager = DataManager.new()
var mouse_position_tile
var mouse_position
signal click_on_tile
signal structure_spawn_started
signal structure_spawned
signal structure_demolished
func _ready():
	randomize()
	pass
	
func init_tile_set()->void:
	data_tileset =  data_manager.to_tileset
	ID_ground = data_manager.structures.ground.tiles[0]
	ID_lake = data_manager.structures.lake.tiles[0]
	IDs_trees = data_manager.structures.tree.tiles
	IDs_construction_frames = data_manager.structures.get("constrction frame").tiles



func build_ground()->void:
	
	for i in range(cell_init.x, cell_init.x+size.x):
		for j in range(cell_init.y, cell_init.y+size.y):
			self.set_cell(i,j,ID_ground)


func get_mouse_position_on_tilemap():
	mouse_position = get_local_mouse_position()
	mouse_position_tile = world_to_map(mouse_position)
	return mouse_position_tile
	pass
	
func normalize_textures_offset()->void:
	#add offset to tileset textures
	var list2 #= DataManager.to_tileset
	for i in IDs:
		if tile_set.tile_get_region(IDs[i]).end.y > cell_size.y && tile_set.tile_get_region(IDs[i]).end.x <= cell_size.x:
			tile_set.tile_set_texture_offset(IDs[i],Vector2(0,-(tile_set.tile_get_region(IDs[i]).end.y-cell_size.y)))
	for i in list2.size():
		if tile_set.tile_get_region(list2[i].ID).end.x > cell_size.x:
			var X = list2[i].size.x
			tile_set.tile_set_texture_offset(list2[i].ID,Vector2(-(X-1)*cell_size.x/2,-(tile_set.tile_get_region(list2[i].ID).end.y-cell_size.y)))
		
		
func build_procedural_tiles(var how_many:int, var ID_list,var density:int=1,  var radius:int = 10, var timer = 0.001):
	var tilegGroundIDList:int = ID_ground
	var usedTilesGround = get_used_cells_by_id(ID_ground)
	if !usedTilesGround.empty():
		var whatTileIDList = ID_list
		var pointZero = rand_range(0,len(usedTilesGround))
		pointZero = usedTilesGround[pointZero]
		var nextPoint 
		for i in (how_many):
			var subTilemap = get_list_positions_in_subTilemap(pointZero,density)
			nextPoint = get_random_id_in_list_positions(subTilemap,tilegGroundIDList)
			var l = 0
			while nextPoint == null:
				l +=1
				subTilemap = get_list_positions_in_subTilemap(pointZero,density+l)
				nextPoint = get_random_id_in_list_positions(subTilemap,tilegGroundIDList)
				if nextPoint == null && (density+l) == radius:
					nextPoint = get_random_id_in_list_positions(get_used_cells_by_id(tilegGroundIDList),tilegGroundIDList)
					if nextPoint == null:
						break
			if nextPoint == null:
				break
			elif pointZero != null:
				if whatTileIDList is Array:
					var cell = rand_range(0,len(whatTileIDList))
					set_cellv(nextPoint,whatTileIDList[cell])
				else:
					set_cellv(nextPoint,whatTileIDList)
				#yield(get_tree().create_timer(timer), "timeout")
				pointZero = nextPoint 
			
func get_list_positions_in_subTilemap(var pointZero:Vector2, var radius:int )->Array:
	var subTileMapList = []
	for i in range(pointZero.x-radius,pointZero.x+radius+1):
		for j in range(pointZero.y-radius,pointZero.y+radius+1):
			subTileMapList.append(Vector2(i,j))
	return subTileMapList
	
func get_random_id_in_list_positions(var listtilemap,var whatID:int):
	if check_list_position_has(listtilemap,whatID):
		var i:int = rand_range(0,len(listtilemap))
		while get_cellv(listtilemap[i]) != whatID:
			i = rand_range(0,len(listtilemap))
		return listtilemap[i]
	else:
		return null 
		
func check_list_position_has(var listSubTilemap, var whatID):
	for i in range(0,len(listSubTilemap)):
		if get_cellv(listSubTilemap[i]) == whatID:
			return true
			
	return false
	
	
	
	
	

func creat_map_logic():
	var usedTiles = get_used_cells()
	var tile
	for i in usedTiles.size():
		var id = get_cellv(usedTiles[i])
		for j in data_manager.to_tileset.size():
			var array = data_manager.to_tileset[j].tiles
			for l in array.size():
				if array[l] == id:
					tile = Structure.new(usedTiles[i],data_manager.to_tileset[j],self)
					all_obj[usedTiles[i]] = tile #Tile.new(data_manager.to_tileset[j],self)
					j  = array.size()
					break
func set_single_obj(var pos:Vector2,var obj:Object):
	set_cellv(pos,obj.data.ID)
	
	
func erase_single_obj(var pos:Vector2):
	set_cellv(pos,-1)
	
	
func get_obj_by_pos(var pos:Vector2):
	return all_obj.get(pos)


func demolishing_structure(structure):
	var data = structure.data.duplicate()
	#structure.set_construction_frames(ID_ground)
	set_rect(Rect2(structure.pos_origin.x,structure.pos_origin.y,data.size.x,data.size.y),ID_ground,1)
	emit_signal("structure_demolished",structure)
	structure.queue_free()
	#yield(get_tree().create_timer(2), "timeout")
	emit_signal("structure_demolished")
	pass

func set_rect(var rect:Rect2,var ID:int, var obj = -1)->void:
		for x in range(rect.position.x,rect.position.x-rect.size.x,-1):
			for y in range(rect.position.y,rect.position.y-rect.size.y,-1):
				if obj != -1:
					all_obj[Vector2(x,y)] = Structure.new(Vector2(x,y),data_manager.structures.ground,self)
				set_cell(x,y,ID)
				pass
func spawn_structure(var pos:Vector2, var data:Dictionary):
	var structure = Structure.new(pos,data,self)
	add_child(structure)
	structure.construction_frames()
	emit_signal("structure_spawn_started",structure)

func check_area(var pos:Vector2, var lenX:int,var LenY:int, var name)->bool:
	for x in range(pos.x,pos.x-lenX,-1):
		for y in range(pos.y,pos.y-LenY,-1):
			var obj = all_obj.get(Vector2(x,y))
			if obj!=null:
				if obj.data.name != name:
					return false
			else:
				return false
	return true
























func off_set_tool():
	IDs = tile_set.get_tiles_ids()
	
	for i in IDs.size():
		var reg = tile_set.tile_get_region(IDs[i])
		if reg.size.y > cell_size.y :
			tile_set.tile_set_texture_offset(IDs[i],Vector2(0,cell_size.y-reg.size.y))#-(tile_set.tile_get_region(IDs[i]).size.y-cell_size.y)))






func make_tileset_tool():
	tile_set.clear()
	for i in data_manager.to_tileset.size():
		if data_manager.to_tileset[i].texture is Array:
			for j in data_manager.to_tileset[i].texture.size():
				creat_tileset_tool(data_manager.to_tileset[i],j)
		else:
			creat_tileset_tool(data_manager.to_tileset[i])
		
	off_set_tool()
	data_manager.save_all()

func creat_tileset_tool(var dic:Dictionary,var i_texture = 0):
	
	var path 

	if dic.texture is Array:
		path = dic.texture[i_texture]
		if i_texture == 0:
			dic.tiles.clear()
	else:
		path = dic.texture
		dic.tiles.clear()
	var texture:Texture = load(path)
	if texture == null:
		print("texture null: ",path)
		return null
	var size = Vector2(dic.size.x,dic.size.y)

	var data:Image = texture.get_data()
	var index:int
	var region = Vector2(cell_size.x,texture.get_height())
	var step = Vector2(cell_size.x/2,cell_size.y/2)
	var pos:Vector2
	var c = 0
	var l = 0
	for i in (size.x):
		var ids:Array = tile_set.get_tiles_ids()
		if ids.empty():
			index = 0
		else:
			index = ids.size()
		pos = Vector2(i*step.x, (size.x-i-1)*-(step.y))
		var rect_image:Image = data.get_rect(Rect2(pos.x,pos.y,  region.x,region.y))
		
		rect_image.convert(Image.FORMAT_R8)
		var array = rect_image.get_data()
		
		
		for j in array.size():
			if array[j] != 0:
				var aux = (j/region.x)
				var it:int = int(aux)
				var f = fmod(j,region.x)
				if f == 0:
					l = it
				else:
					l = it + 1
				break
				
		l = l-1
		tile_set.create_tile(index)
		dic.tiles.append(index)
		if dic.texture.size() > 1:
			c = i_texture
		tile_set.tile_set_name(index,dic.name+" "+str(c))
		c=c+1
		tile_set.tile_set_texture(index,texture)
		tile_set.tile_set_region(index,Rect2(pos.x,pos.y+l,  region.x,region.y-l))
		
		
	if size.y >1:
		for i in (size.y-1):
			
			var ids:Array = tile_set.get_tiles_ids()
			if ids.empty():
				
				index = 0
				
				
			else:
				index = ids.size()
			pos = Vector2(i*step.x+(size.x*step.x), (i+1)*-(step.y))
			var rect_image:Image = data.get_rect(Rect2(pos.x,pos.y,  region.x,region.y))
			rect_image.convert(Image.FORMAT_R8)
			var array = rect_image.get_data()
			
			
			for j in array.size():
				if array[j] != 0:
					var aux = (j/region.x)
					var it:int = int(aux)
					var f = fmod(j,region.x)
					if f == 0:
						l = it
					else:
						l = it + 1
		
					break
				
			l = l-1
			tile_set.create_tile(index)
			dic.tiles.append(index)
			if dic.texture.size()>1:
				c = i_texture
			tile_set.tile_set_name(index,dic.name+" "+str(c))
			c=c+1
			tile_set.tile_set_texture(index,texture)
			
			if i == (size.y-2):
				
				#region.x = uni_to_bi(array,region).x-2
				
				tile_set.tile_set_region(index,Rect2(pos.x,pos.y+l,  region.x,region.y-l))
			else:
				tile_set.tile_set_region(index,Rect2(pos.x,pos.y+l,  region.x,region.y-l))
	
		
		
		
		

func uni_to_bi(var array:PoolByteArray,var size:Vector2):
	var l = 0
	var dic:Dictionary
	
	
	for x in range(0,size.x):
		for y in range(0,size.y):
			dic[Vector2(x,y)] = array[l]
			l = l+1
			
	for x in range(size.x-1,0,-1):
		for y in range(0,size.y-1,1):
			if dic[Vector2(x,y)] != 0:
				
				return Vector2(x,y)
