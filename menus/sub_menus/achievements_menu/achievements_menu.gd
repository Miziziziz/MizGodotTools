extends SubMenu


@onready var achievements_container = %AchievementsContainer
const SINGLE_ACHIEVEMENT_DISPLAY = preload("res://menus/sub_menus/achievements_menu/single_achievement_display.tscn")

func _ready() -> void:
	for c in achievements_container.get_children():
		c.queue_free()
	for ach_id in AchievementsManager.ACHIEVEMENTS:
		var ach_display = SINGLE_ACHIEVEMENT_DISPLAY.instantiate()
		achievements_container.add_child(ach_display)
		ach_display.load_achievement_id(ach_id)
	
	# for testing
	#AchievementsManager.set_achievement_completed("test_achievement_1")
	#AchievementsManager.set_achievement_completed("test_achievement_2")
	#AchievementsManager.set_achievement_completed("test_achievement_3")
