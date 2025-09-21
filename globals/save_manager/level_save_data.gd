class_name LevelSaveData extends Node


var saved_nodes : Array = [] # array of saved nodes data
var deleted_node_paths : Array[String] = [] # array of paths of deleted nodes in this scene

func get_level_save_data_as_dict() -> Dictionary:
	return {
		"saved_nodes" : saved_nodes,
		"deleted_node_paths" : deleted_node_paths,
	}
