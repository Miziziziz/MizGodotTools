extends SubMenu


@onready var graphics_settings_menu: ScrollContainer = $TabContainer/Graphics
@onready var audio_settings_menu: ScrollContainer = $TabContainer/Audio
@onready var gameplay_settings_menu: ScrollContainer = $TabContainer/Gameplay
@onready var controls_settings_menu: ScrollContainer = $TabContainer/Controls


const SETTINGS_SAVE_FILE := "user://settings.save"

func _ready() -> void:
	back_button.button_up.connect(save_settings)
	
	# make sure loading is done after _ready is called on all children and everything in the scene
	await get_tree().process_frame
	load_settings()


# setting value to itself will emit corresponding signal, calling whatever code is needed to set stuff
func update_settings(node):
	for c in node.get_children():
		update_settings(c)
	
	 # have to set to a different value first or it won't emit signal
	if node is Slider:
		var start_val = node.value
		node.value = 0.0
		node.value = start_val
	if node is CheckBox:
		node.button_pressed = !node.button_pressed
		node.button_pressed = !node.button_pressed
	if node is OptionButton:
		var id = node.get_selected_id()
		node.select(id+1)
		node.select(id)
	if node is LineEdit:
		var txt = node.text
		node.text = ""
		node.text = txt

func reset_settings():
	var save_file = FileAccess.open(SETTINGS_SAVE_FILE, FileAccess.WRITE)
	save_file.store_line(JSON.stringify({}))
	load_settings()

func save_settings():
	var settings_data = {}
	settings_data.graphics_settings = graphics_settings_menu.get_settings_save_data()
	settings_data.audio_settings = audio_settings_menu.get_settings_save_data()
	settings_data.gameplay_settings = gameplay_settings_menu.get_settings_save_data()
	settings_data.controls_settings = controls_settings_menu.get_settings_save_data()
	
	var save_file = FileAccess.open(SETTINGS_SAVE_FILE, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(settings_data))

func load_settings():
	if not FileAccess.file_exists(SETTINGS_SAVE_FILE):
		return {}
	var save_file = FileAccess.open(SETTINGS_SAVE_FILE, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(save_file.get_line())
	var settings_data = test_json_conv.get_data()
	
	if settings_data.is_empty():
		update_settings(self)
		return
	
	if "controls_settings" in settings_data:
		controls_settings_menu.load_settings_data(settings_data.controls_settings)
	if "audio_settings" in settings_data:
		audio_settings_menu.load_settings_data(settings_data.audio_settings)
	if "graphics_settings" in settings_data:
		graphics_settings_menu.load_settings_data(settings_data.graphics_settings)
	if "gameplay_settings" in settings_data:
		gameplay_settings_menu.load_settings_data(settings_data.gameplay_settings)
