extends Menu

@onready var buttons_container = %ButtonsContainer
const LOAD_GAME_BUTTON_FORMAT = "{file_name} : {info}"

func _ready():
	for c in buttons_container.get_children():
		c.queue_free()
	
	for save_file_path in SaveManager.get_all_saved_game_file_paths():
		var file_name = save_file_path.get_file()
		file_name = file_name.trim_suffix("." + save_file_path.get_extension())
		
		var button := Button.new()
		button.text = LOAD_GAME_BUTTON_FORMAT.format({
			"file_name" : file_name.capitalize(),
			"info" : SaveManager.get_save_file_info(save_file_path),
			})
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.button_up.connect(SaveManager.load_game_from_file.bind(save_file_path))
		buttons_container.add_child(button)
