extends Node

const ACH_IMG_PATH = "res://singletons/achievements_manager/textures/"

const ACHIEVEMENTS = {
	"zombie_kill": {
		"title": "ACH_ZOMBIE_KILL_TITLE",
		"text": "ACH_ZOMBIE_KILL_TEXT",
	},
	"limbs_kill": {
		"title": "ACH_LIMBS_KILL_TITLE",
		"text": "ACH_LIMBS_KILL_TEXT",
	},
	"ghost_kill": {
		"title": "ACH_GHOST_KILL_TITLE",
		"text": "ACH_GHOST_KILL_TEXT",
	},
	"hydra_kill": {
		"title": "ACH_HYDRA_KILL_TITLE",
		"text": "ACH_HYDRA_KILL_TEXT",
	},
	"weapon_upgrade": {
		"title": "ACH_WEP_UPGRADED_TITLE",
		"text": "ACH_WEP_UPGRADED_TEXT",
	},
	"weapon_max_upgrade": {
		"title": "ACH_WEP_MAX_UPGRADED_TITLE",
		"text": "ACH_WEP_MAX_UPGRADED_TEXT",
	},
	"bag_max_upgrade": {
		"title": "ACH_BAG_MAX_UPGRADED_TITLE",
		"text": "ACH_BAG_MAX_UPGRADED_TEXT",
	},
	"final_boss_kill": {
		"title": "ACH_FINAL_BOSS_KILL_TITLE",
		"text": "ACH_FINAL_BOSS_KILL_TEXT",
	},
	"antidote_created": {
		"title": "ACH_ANTIDOTE_TITLE",
		"text": "ACH_ANTIDOTE_TEXT",
	},
	"hard_mode": {
		"title": "ACH_HARD_MODE_TITLE",
		"text": "ACH_HARD_MODE_TEXT",
	},
}


var completed_achievements = []

signal achievements_completed_updated
signal achievement_completed 

var using_steam = false
var testing_steam = false
const STEAM_GAME_ID = 2990640
	
func _ready():
	var in_editor = OS.has_feature("editor")
	if !in_editor:
		testing_steam = false
	
	using_steam = OS.has_feature("steam") or testing_steam
	
	if using_steam:
		OS.set_environment("SteamAppId", str(STEAM_GAME_ID))
		OS.set_environment("SteamGameId", str(STEAM_GAME_ID))
		Steam.steamInit()
		if Steam.isSteamRunning():
			load_achievements_from_steam()
		else:
			print_debug("steam failed to run")
		
		load_achievements_from_steam()
	else:
		load_achievements()
	
	achievements_completed_updated.emit()
	
	#if in_editor:
		#reset_achievements()

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
		Steam.setAchievement(achievement_condition.to_upper())
	else:
		save_achievements()


const ACHIEVEMENT_SAVE_FILE = "user://achievements.save"
func save_achievements():
	var save_game = FileAccess.open(ACHIEVEMENT_SAVE_FILE, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(completed_achievements))

func load_achievements():
	if not FileAccess.file_exists(ACHIEVEMENT_SAVE_FILE):
		return
	var save_game = FileAccess.open(ACHIEVEMENT_SAVE_FILE, FileAccess.READ)
	completed_achievements = JSON.parse_string(save_game.get_line())

func load_achievements_from_steam():
	completed_achievements = []
	for ach in ACHIEVEMENTS:
		ach = ach.to_upper()
		var achievement_data : Dictionary = Steam.getAchievement(ach)
		if achievement_data['ret']:
			if achievement_data['achieved']:
				completed_achievements.append(ach)
		else:
			print('achievement does not exist: ', ach)

func get_ach_img_path(ach_ind: String):
	if ach_ind in completed_achievements:
		return get_completed_img_name(ach_ind)
	return get_not_completed_img_name(ach_ind)

func get_completed_img_name(ach_ind: String):
	return ACH_IMG_PATH + ach_ind + "_completed.png"

func get_not_completed_img_name(ach_ind: String):
	return ACH_IMG_PATH + ach_ind + "_not_completed.png"
