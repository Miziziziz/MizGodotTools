extends Node


## should be set as Global, tracks achievements that have been unlocked
## call set_achievement_completed("achievement_id") to unlock an achievement

## NOTE: achievement image file name are expected to be this format:
## achievement_id_completed.png
## achievement_id_not_completed.png


const ACH_IMG_PATH = "res://globals/achievements_manager/achievement_icons/"
const SECRET_IMG_PATH = "res://globals/achievements_manager/achievement_icons/secret_ach_icon.png"

const SECRET_ACH_TITLE = "Secret Achievement"
const SECRET_ACH_DESC = "This is a secret achievement"


const ACHIEVEMENTS = {
	"test_achievement_1": {
		"title": "Achievement 1",
		"text": "Ach 1 description",
	},
	"test_achievement_2": {
		"title": "Achievement 2",
		"text": "Ach 2 description",
	},
	"test_achievement_3": {
		"title": "Achievement 3",
		"text": "Ach 3 description",
		"secret": true,
	},
}


var completed_achievements = []

signal achievements_completed_updated
signal achievement_completed 

var using_steam = false

func _ready():
	using_steam = OS.has_feature("steam")
	if using_steam:
		load_achievements_from_steam()
	else:
		load_achievements_from_file()
	achievements_completed_updated.emit()

func reset_achievements():
	completed_achievements = []
	if !using_steam:
		save_achievements()

func get_completed_achievements():
	return completed_achievements

func get_achievements():
	return ACHIEVEMENTS

func has_achievement_completed(achievement_condition: String):
	return achievement_condition in completed_achievements

func set_achievement_completed(achievement_condition: String):
	if not achievement_condition in ACHIEVEMENTS or achievement_condition in completed_achievements:
		return
	
	completed_achievements.append(achievement_condition)
	achievements_completed_updated.emit()
	achievement_completed.emit(achievement_condition)
	
	if using_steam:
		pass # TODO steam implementation
	else:
		save_achievements()


const ACHIEVEMENT_SAVE_FILE = "user://achievements.save"
func save_achievements():
	var save_game = FileAccess.open(ACHIEVEMENT_SAVE_FILE, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(completed_achievements))

func load_achievements_from_file():
	if not FileAccess.file_exists(ACHIEVEMENT_SAVE_FILE):
		return
	var save_game = FileAccess.open(ACHIEVEMENT_SAVE_FILE, FileAccess.READ)
	completed_achievements = JSON.parse_string(save_game.get_line())


func load_achievements_from_steam():
	pass # TODO implement steam api using whatever plugin you want, example implementation below
	#completed_achievements = []
	#for ach in ACHIEVEMENTS:
		#ach = ach.to_upper()
		#var achievement_data : Dictionary = Steam.getAchievement(ach)
		#if achievement_data['ret']:
			#if achievement_data['achieved']:
				#completed_achievements.append(ach)
		#else:
			#print('achievement does not exist: ', ach)

func get_ach_img_path(ach_ind: String):
	if ach_ind not in ACHIEVEMENTS:
		print_debug("ERROR achievement not found ", ach_ind)
		return SECRET_IMG_PATH
	if ach_ind in completed_achievements:
		return get_completed_img_name(ach_ind)
	return get_not_completed_img_name(ach_ind)

func get_completed_img_name(ach_ind: String):
	return ACH_IMG_PATH + ach_ind + "_completed.png"

func get_not_completed_img_name(ach_ind: String):
	if "secret" in ACHIEVEMENTS[ach_ind] and ACHIEVEMENTS[ach_ind].secret:
		return SECRET_IMG_PATH
	return ACH_IMG_PATH + ach_ind + "_not_completed.png"
