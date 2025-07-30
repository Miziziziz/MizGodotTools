extends ScrollContainer

@onready var difficulty_drop_down: OptionButton = $VBoxContainer/Difficulty/OptionButton


func _ready():
	difficulty_drop_down.item_selected.connect(update_difficulty)

func update_difficulty(_difficulty_val:int):
	pass # TODO manual implementation

func load_settings_data(settings_data: Dictionary):
	if "difficulty" in settings_data:
		difficulty_drop_down.selected = roundi(settings_data.difficulty)

func get_settings_save_data()->Dictionary:
	return {
		"difficulty": difficulty_drop_down.selected,
	}
