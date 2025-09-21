extends Node

## Handles going in between levels and works with SaveManager to make changes persist
## Put paths to levels in your game in LEVEL_LIST
## For a linear game with no backtracking set CLEAR_ENVIRONMENT_SAVE_DATA_ON_LEVEL_CHANGE to true

var LEVEL_LIST = [
	"res://example_scenes/level_transitions_examples/test_level_1.tscn",
	"res://example_scenes/level_transitions_examples/test_level_2.tscn",
	"res://example_scenes/level_transitions_examples/test_level_3.tscn",
]

var LEVEL_NAME_TO_LEVEL_PATH = {}

const MAIN_MENU_PATH = "res://menus/main_menu/main_menu.tscn"


# If true will wipe environment save data like dropped items and blood splatters on 
# level change to save memory since they will never been seen again
const CLEAR_ENVIRONMENT_SAVE_DATA_ON_LEVEL_CHANGE = false

var loading_next_level = false
@onready var loading_popup = $LoadingPopup

func _ready():
	for level_path in LEVEL_LIST:
		LEVEL_NAME_TO_LEVEL_PATH[get_level_name_from_path(level_path)] = level_path

func load_main_menu():
	cancel_background_loading()
	SaveManager.reset_current_game_save_data()
	load_scene_from_path(MAIN_MENU_PATH)

func start_new_game():
	cancel_background_loading()
	#await ScreenFader.fade_to_black() #TODO
	SaveManager.reset_current_game_save_data()
	load_scene_from_path(LEVEL_LIST[0])
	#ScreenFader.fade_to_clear() #TODO

var loading_level_in_background = false
var level_path_being_loaded = ""
func load_level_in_background(level_name: String):
	var level_ind = get_level_ind_from_level_name(level_name)
	var level_path = LEVEL_LIST[level_ind]
	loading_level_in_background = true
	level_path_being_loaded = level_path
	ResourceLoader.load_threaded_request(level_path)

func cancel_background_loading():
	loading_level_in_background = false
	level_path_being_loaded = ""

func load_level(level_name: String, connection_name: String, instant=false):
	if loading_next_level:
		return
	loading_next_level = true
	if !instant:
		pass
		#await ScreenFader.fade_to_black() #TODO
	else:
		pass
		#ScreenFader.set_black() #TODO
	
	var game_save_data : GameSaveData = SaveManager.get_game_save_data()
	if CLEAR_ENVIRONMENT_SAVE_DATA_ON_LEVEL_CHANGE:
		game_save_data.clear_environment_data()
	var level_ind = get_level_ind_from_level_name(level_name)
	var level_path = LEVEL_LIST[level_ind]
	
	show_loading_popup()
	get_tree().call_group("instanced", "queue_free")
	
	var load_progress_arr = []
	if loading_level_in_background:
		while true:
			var status = ResourceLoader.load_threaded_get_status(level_path_being_loaded, load_progress_arr)
			match status:
				ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
					print("ERROR WITH THREAD LOADER: ", status)
					cancel_background_loading()
					break
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					var load_amount = load_progress_arr[0]
					show_loading_popup()
					print("loading level: ", load_amount)
				ResourceLoader.THREAD_LOAD_LOADED:
					var loaded_rsrc = ResourceLoader.load_threaded_get(level_path_being_loaded)
					get_tree().change_scene_to_packed(loaded_rsrc)
					break
			await get_tree().process_frame
	
	if !loading_level_in_background:
		load_scene_from_path(level_path)
	
	cancel_background_loading()
	await get_tree().process_frame # wait for scene to change
	await get_tree().process_frame
	await get_tree().process_frame
	#print("load complete", Time.get_ticks_msec() / 1000.0)
	hide_loading_popup()
	#ScreenFader.fade_to_clear() # TODO
	
	SaveManager.load_game_save_data(game_save_data, false)
	
	if connection_name != "":
		for level_connector in get_tree().get_nodes_in_group("level_connector"):
			if level_connector.connection_name == connection_name:
				var player = get_tree().get_first_node_in_group("player")
				if player:
					player.global_transform = level_connector.get_player_transform_on_entrance()
				level_connector.player_entered_here()
				break
	
	SaveManager.autosave()
	loading_next_level = false

func show_loading_popup():
	loading_popup.show()

func hide_loading_popup():
	loading_popup.hide()

func load_scene_from_path(scene_path: String):
	get_tree().change_scene_to_file(scene_path)

func get_level_ind_from_name(level_name: String):
	var ind = 0
	for level_path in LEVEL_LIST:
		if level_name in level_path:
			return ind
		ind += 1
	return -1

func get_level_name_from_path(level_path: String) -> String:
	return level_path.get_file().replace(".tscn", "")

func get_cur_scene_level_ind() -> int:
	var path = get_tree().current_scene.scene_file_path
	return LEVEL_LIST.find(path)

func get_level_ind_from_level_name(level_name):
	var level_ind = 0
	if level_name == "": # if blank load next level in list
		level_ind = get_cur_scene_level_ind() + 1
		level_ind %= LEVEL_LIST.size()
	else:
		level_ind = get_level_ind_from_name(level_name)
	if level_ind < 0:
		print_debug("ERROR LEVEL NAME NOT FOUND %s LOADING FIRST LEVEL INSTEAD" % level_name)
		level_ind = 0
	return level_ind

func path_to_ind(path: String) -> int:
	return LEVEL_LIST.find(path)

var items_in_elevator = {} 
func set_items_in_elevator(iie : Array): # called from elevator computer
	items_in_elevator = iie

func open_making_of():
	OS.shell_open("https://youtube.com/playlist?list=PLmugv6_kd0qOHy_GhkwojiuNSiPxWgpCo&si=0-gZYOLo1FVbIeUL") 
