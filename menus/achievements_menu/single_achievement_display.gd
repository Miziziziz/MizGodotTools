extends Panel

@onready var ach_texture = %AchTexture
@onready var title = %Title
@onready var description = %Description

var cur_ach_id = ""

func _ready() -> void:
	AchievementsManager.achievement_completed.connect(on_achievement_completed)

func load_achievement_id(ach_id: String):
	var achievement_data = AchievementsManager.ACHIEVEMENTS[ach_id]
	title.text = achievement_data.title
	description.text = achievement_data.text
	ach_texture.texture = load(AchievementsManager.get_ach_img_path(ach_id))
	cur_ach_id = ach_id
	
	if "secret" in achievement_data and achievement_data.secret and !AchievementsManager.has_achievement_completed(ach_id):
		title.text = AchievementsManager.SECRET_ACH_TITLE
		description.text = AchievementsManager.SECRET_ACH_DESC

func on_achievement_completed(ach_id: String):
	if cur_ach_id == ach_id:
		ach_texture.texture = load(AchievementsManager.get_ach_img_path(cur_ach_id))
