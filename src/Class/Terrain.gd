extends Tile
class_name Terrain
func _init(pos:Vector2,_data:Dictionary,tilemap:TileMap):
	data = _data.duplicate()
	pos_origin = pos
	self_ref = self
	map = tilemap
