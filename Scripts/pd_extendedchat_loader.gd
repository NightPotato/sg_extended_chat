extends Node

func _init() -> void:
	print("WARNING: This mod contains code that will overwrite base game functionality!")
	var node = load("res://Scenes/ecapi_node.tscn").instantiate()
	add_child(node, true)
	print("ECAPI is now Globally Accessible.")