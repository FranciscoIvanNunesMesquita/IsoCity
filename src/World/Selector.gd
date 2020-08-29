extends Node2D
var sprite:Sprite
var map:TileMap
export (Color,RGBA) var yellow
export (Color,RGBA) var red
func _ready():
	sprite = $Sprite
	map = get_parent()
	if map == null:
		print("map not found: ",map)

func set_selector(var pos:Vector2, var data, var color = true):
	var texture:Texture 
	if data.texture.size()>1 && !(map.UI.state == map.UI.states.BUILDING):
		texture = map.tile_set.tile_get_texture(map.get_cellv(pos))
		pass
	else:
		texture = load(data.texture[0])
	if texture != null:
		sprite.texture = texture
		match color:
			true:color = yellow
			false:color = red
			
		sprite.material.set_shader_param('current_color',color)
		position = map.map_to_world(pos)
		sprite.position = Vector2(0,0)
		var offset_y = (texture.get_height()/2) - texture.get_height()+map.cell_size.y
		var offset_x = (texture.get_width()/2) - (data.size.x * (map.cell_size.x/2))
		sprite.position.y = sprite.position.y + offset_y
		sprite.position.x  = sprite.position.x + offset_x
		visible = true
	else:
		print("in selector texture null: ", data.texture)
