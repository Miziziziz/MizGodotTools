extends Node

## Handles saving and loading data, must be set as a Global
##
## Save path on windows is %APPDATA%/Godot/app_userdata/MizGodotTools/saved_games
## Use a tool like https://jsonlint.com/ to format the json to be more readable for debugging
## F1 and F5 are quicksave and quickload
##
## Designed with an 'Open World' style game in mind, as in you can return to levels after visiting them once
## and changes will persist

const NODE_PATH_KEY = "node_path" # used by non instances to specify their path in the scene
const INSTANCE_ID_KEY = "instance_uid" # used by serializable instances to contain uid or resource path

var verbose = false
var game_loading = false

const SAVE_FILE_DIRECTORY =  "user://saved_games/"
const SAVE_FILE_PATH_FORMAT = SAVE_FILE_DIRECTORY + "%s.save"
const AUTOSAVE_PATH = SAVE_FILE_PATH_FORMAT % "autosave"
const QUICKSAVE_PATH = SAVE_FILE_PATH_FORMAT % "quicksave"
const LAST_SAVED_FILE = "user://last_played.save"

const INSTANCE_TYPE_STR = "instance_type"

signal game_saved(save_file_path: String)
signal game_load_complete

@onready var current_game_save_data = GameSaveData.new()

func _ready():
	DirAccess.make_dir_absolute(SAVE_FILE_DIRECTORY)

func _process(_delta):
	if Input.is_action_just_pressed("quicksave"):
		quicksave()
	if Input.is_action_just_pressed("quickload"):
		load_quicksave()

func load_last_played_save():
	var last_save_file = get_last_saved_file_path()
	if last_save_file != "":
		load_game_from_file(last_save_file)

func autosave():
	print_save_status("autosave")
	save_game_to_file(AUTOSAVE_PATH)

func quicksave():
	print_save_status("manual save")
	save_game_to_file(QUICKSAVE_PATH)

func load_quicksave():
	load_game_from_file(QUICKSAVE_PATH)

func save_game_with_filename(save_name: String):
	if save_name == "":
		print_debug("INVALID SAVE FILE NAME")
		return false
	print_save_status("save file " + str(save_name))
	save_game_to_file(SAVE_FILE_PATH_FORMAT % save_name)
	return true

func load_game_with_filename(save_name: String):
	print_save_status("load file " + str(save_name))
	load_game_from_file(SAVE_FILE_PATH_FORMAT % save_name)

func save_game_to_file(file_path: String):
	var game_save_data = get_game_save_data()
	game_save_data.save_data_to_file(file_path)
	record_last_saved_file_path(file_path)
	game_saved.emit(file_path)

func load_game_from_file(file_path: String, _do_fade_out=false):
	print_save_status("loading: " + file_path)
	record_last_saved_file_path(file_path)
	#if do_fade_out:
		#await ScreenFader.fade_to_black() #TODO
	
	get_tree().paused = false
	game_loading = true
	var game_save_data = GameSaveData.load_data_from_file(file_path)
	if game_save_data:
		load_game_save_data(game_save_data, true)
	else:
		print("ERROR LOADING FILE %s" % file_path)
	#if do_fade_out:
		#ScreenFader.fade_to_clear() #TODO
	
	# wait for new scene to load	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	game_loading = false
	game_load_complete.emit()

func record_last_saved_file_path(file_path: String):
	var save_file = FileAccess.open(LAST_SAVED_FILE, FileAccess.WRITE)
	save_file.store_line(file_path)

func get_last_saved_file_path() -> String:
	if not FileAccess.file_exists(LAST_SAVED_FILE):
		return ""
	var save_file = FileAccess.open(LAST_SAVED_FILE, FileAccess.READ)
	var save_path = save_file.get_line()
	if not FileAccess.file_exists(save_path):
		return ""
	return save_path

func sort_by_date_modified(file_path_a: String, file_path_b: String):
	var file_a_time = FileAccess.get_modified_time(file_path_a)
	var file_b_time = FileAccess.get_modified_time(file_path_b)
	return file_a_time > file_b_time

func get_game_save_data() -> GameSaveData:
	#var game_save_data = GameSaveData.new()
	var game_save_data = current_game_save_data
	
	# scene path data
	var current_scene_path = get_tree().current_scene.scene_file_path
	game_save_data.last_active_level_scene_path = current_scene_path
	
	# player data
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_save_data"):
		game_save_data.player_data = player.get_save_data()
	
	# level data
	var nodes_save_data = []
	for node in get_tree().get_nodes_in_group("serializable"):
		if node.has_method("get_save_data"):
			var data = node.get_save_data()
			if INSTANCE_ID_KEY not in data:
				data[NODE_PATH_KEY] = node.get_path()
			nodes_save_data.append(data)
	var level_save_data = LevelSaveData.new()
	level_save_data.saved_nodes = nodes_save_data
	level_save_data.deleted_node_paths = deleted_node_paths
	game_save_data.store_data_for_scene_path(current_scene_path, level_save_data)
	
	print_save_status("GAME SAVED")
	return game_save_data

## loading_from_save determines if we're loading a save file or switching levels
## if switching level, scene will be changed and player transform set by LevelManager
func load_game_save_data(game_save_data: GameSaveData, loading_from_save: bool):
	# world data
	#LevelManager.show_loading_popup()
	current_game_save_data = game_save_data
	print_save_status("LOADING SAVE DATA")
	
	var current_scene_path = get_tree().current_scene.scene_file_path
	if loading_from_save:
		get_tree().call_group("instanced", "free")
		if current_scene_path == game_save_data.last_active_level_scene_path:
			get_tree().reload_current_scene()
		else:
			current_scene_path = game_save_data.last_active_level_scene_path
			get_tree().change_scene_to_file(game_save_data.last_active_level_scene_path)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		print_save_status("LOADED scene from save")
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("load_save_data"):
		player.load_save_data(game_save_data.player_data, loading_from_save)
	print_save_status("PLAYER DATA LOADED")
	
	deleted_node_paths = game_save_data.get_deleted_nodes_for_scene_path(current_scene_path)
	for node_path: String in deleted_node_paths:
		if !has_node(node_path):
			print_debug("node to delete missing %s, did you mistakenly add an instanced node?" % node_path)
			continue
		get_node(node_path).queue_free()
	print_save_status("DELETED PICKED UP ITEMS")
	
	for node_data : Dictionary in game_save_data.get_nodes_save_data_for_scene_path(current_scene_path):
		if INSTANCE_ID_KEY in node_data:
			var instance_uid = node_data[INSTANCE_ID_KEY]
			var instance = load(instance_uid).instantiate()
			instance.add_to_group("instanced")
			get_tree().get_root().add_child.call_deferred(instance)
			instance.load_save_data.call_deferred(node_data)
		elif NODE_PATH_KEY in node_data:
			var node_path = node_data[NODE_PATH_KEY]
			if !has_node(node_path):
				print_debug("missing expected node in scene ", node_path)
				continue
			var node = get_node(node_path)
			if !node.has_method("load_save_data"):
				print_debug("no load_save_data method on serializable node ", node_path)
				continue
			node.load_save_data(node_data)
		else:
			print_debug("junk data, missing scene_path or bad instance tag ", node_data)
	
	print_save_status("LOADED SAVED NODES")
	#LevelManager.hide_loading_popup()

func reset_current_game_save_data():
	current_game_save_data = GameSaveData.new()

# track what non-instanced nodes were deleted (for example, an item picked up)
var deleted_node_paths : Array[String]
func add_deleted_node_path(node_path: String):
	#print_save_status("track deleted")
	deleted_node_paths.append(node_path)

func get_save_file_info(save_file_path: String):
	var time_last_played = FileAccess.get_modified_time(save_file_path)
	#var date_time_dict = Time.get_date_dict_from_unix_time(time_last_played)
	var time_zone_offset = Time.get_time_zone_from_system().bias * 60
	time_last_played += time_zone_offset
	
	var time_string = Time.get_time_string_from_unix_time(time_last_played)
	var date_string = Time.get_date_string_from_unix_time(time_last_played)
	
	return date_string + " " + time_string

func print_save_status(text: String):
	if verbose:
		print("SaveManager: ", text)
