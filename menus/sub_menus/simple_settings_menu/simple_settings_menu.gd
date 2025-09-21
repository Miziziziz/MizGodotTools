extends SubMenu

## simplified settings menu for games with fewer options

const SETTINGS_SAVE_FILE := "user://settings.save"


@onready var master_volume_slider: HSlider = $Panel/VBoxContainer/MasterVolume/HSlider
@onready var music_volume_slider: HSlider = $Panel/VBoxContainer/MusicVolume/HSlider
@onready var sfx_volume_slider: HSlider = $Panel/VBoxContainer/SFXVolume/HSlider

@onready var fullscreen_check_box = $Panel/VBoxContainer/Fullscreen/CheckBox
@onready var vsync_check_box = $Panel/VBoxContainer/Vsync/CheckBox
@onready var fps_display_check_box = $Panel/VBoxContainer/FpsDisplay/CheckBox


func _ready() -> void:
	back_button.button_up.connect(save_settings)
	
	master_volume_slider.value_changed.connect(update_bus_volume.bind(AudioServer.get_bus_index("Master")))
	music_volume_slider.value_changed.connect(update_bus_volume.bind(AudioServer.get_bus_index("Music")))
	sfx_volume_slider.value_changed.connect(update_bus_volume.bind(AudioServer.get_bus_index("Sfx")))
	fullscreen_check_box.toggled.connect(update_fullscreen)
	vsync_check_box.toggled.connect(update_vsync)
	fps_display_check_box.toggled.connect(update_fps_display)
	
	# make sure loading is done after _ready is called on all children and everything in the scene
	await get_tree().process_frame
	load_settings()
	

func update_fullscreen(is_fullscreen: bool):
	if is_fullscreen:
		# NOTE: you may want exclusive fullscreen instead, uncomment accordingly
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func update_vsync(vsync_on: bool):
	if vsync_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func update_fps_display(fps_display_on: bool):
	FpsDisplay.fps_display_visible = fps_display_on

func update_bus_volume(vol: float, bus_index: int):
	AudioServer.set_bus_volume_linear(bus_index, vol)


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
	settings_data.master_volume = master_volume_slider.value
	settings_data.music_volume = music_volume_slider.value
	settings_data.sfx_volume = sfx_volume_slider.value
	settings_data.is_fullscreen = fullscreen_check_box.button_pressed
	settings_data.vsync_on = vsync_check_box.button_pressed
	settings_data.fps_display_on = fps_display_check_box.button_pressed
	
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
	
	if "master_volume" in settings_data:
		master_volume_slider.value = settings_data.master_volume
	if "music_volume" in settings_data:
		music_volume_slider.value = settings_data.music_volume
	if "sfx_volume" in settings_data:
		sfx_volume_slider.value = settings_data.sfx_volume
	if "is_fullscreen" in settings_data:
		fullscreen_check_box.button_pressed = settings_data.is_fullscreen
	if "vsync_on" in settings_data:
		vsync_check_box.button_pressed = settings_data.vsync_on
	if "fps_display_on" in settings_data:
		fps_display_check_box.button_pressed = settings_data.fps_display_on
