
extends Node2D
var map:TileMap
var camera:Camera2D
var UI
var map_size:Vector2
func _enter_tree():
	map = $MainMap
	camera = $MainCamera
	map_size = Vector2(50,50)
	pass



func _input(event):
	pass
