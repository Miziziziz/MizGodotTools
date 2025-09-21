class_name GameSaveData extends Node


var last_active_level_scene_path : String
var player_data = {}
var all_levels_data: Dictionary[String, LevelSaveData] = {} # key is scene_path, value is array of LevelSaveData, cant nest types

func get_nodes_save_data_for_scene_path(scene_key: String):
	if scene_key in all_levels_data:
		return all_levels_data[scene_key].saved_nodes
	return []

func get_deleted_nodes_for_scene_path(scene_key: String) -> Array[String]:
	if scene_key in all_levels_data:
		return all_levels_data[scene_key].deleted_node_paths
	return [] as Array[String]

func store_data_for_scene_path(scene_key: String, level_save_data: LevelSaveData):
	all_levels_data[scene_key] = level_save_data
	#print_debug(all_levels_data)

func get_all_levels_data_as_dict() -> Dictionary:
	var all_levels_data_dict = {}
	for level_data_key in all_levels_data:
		all_levels_data_dict[level_data_key] = all_levels_data[level_data_key].get_level_save_data_as_dict()
	return all_levels_data_dict

func load_all_levels_data_from_dict(all_levels_data_dict: Dictionary):
	all_levels_data.clear()
	for scene_key in all_levels_data_dict:
		var new_level_save_data = LevelSaveData.new()
		var level_data_dict = all_levels_data_dict[scene_key]
		if "saved_nodes" in level_data_dict:
			new_level_save_data.saved_nodes = level_data_dict.saved_nodes
		if "deleted_node_paths" in level_data_dict:
			var str_arr : Array[String]
			str_arr.assign(level_data_dict.deleted_node_paths)
			new_level_save_data.deleted_node_paths = str_arr
		all_levels_data[scene_key] = new_level_save_data

func save_data_to_file(file_path: String):
	var data = {}
	data.last_active_level_scene_path = last_active_level_scene_path
	data.all_levels_data = get_all_levels_data_as_dict()
	data.player_data = player_data
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_game.store_string(json_string)
	#print("DATA STORED\n %s \n" % json_string)

func clear_environment_data():
	all_levels_data.clear()
	# removes saved data for things like blood splatters and dropped items

static func load_data_from_file(file_path: String) -> GameSaveData:
	if !FileAccess.file_exists(file_path):
		print("FILE NOT FOUND ", file_path)
		return null
	
	var save_game = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(save_game.get_as_text())
	if data == null:
		print("ERROR LOADING FILE, UNABLE TO PARSE")
		return null
	
	#print("DATA LOADED\n %s \n" % data)
	var new_game_save_data = GameSaveData.new()
	if "last_active_level_scene_path" in data:
		new_game_save_data.last_active_level_scene_path = data.last_active_level_scene_path
	if "all_levels_data" in data:
		new_game_save_data.load_all_levels_data_from_dict(data.all_levels_data)
	if "player_data" in data:
		new_game_save_data.player_data = data.player_data
	return new_game_save_data
