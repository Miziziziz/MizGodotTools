extends ScrollContainer

# some standard graphics settings options
# you probably wont need the bullet hole decal one, it's provided here as an example of number input


@onready var resolution_drop_down: OptionButton = $VBoxContainer/Resolution/OptionButton

@onready var custom_resolution_settings: HBoxContainer = $VBoxContainer/CustomResolution
@onready var custom_resolution_x_number_input: LineEdit = $VBoxContainer/CustomResolution/Inputs/XNumberInput
@onready var custom_resolution_y_number_input: LineEdit = $VBoxContainer/CustomResolution/Inputs/YNumberInput
@onready var confirm_custom_resolution_button: Button = $VBoxContainer/CustomResolution/Inputs/ConfirmResolutionButton
@onready var confirm_resolution_change_popup: Control = %ConfirmResolutionChangePopup

@onready var fullscreen_check_box: CheckBox = $VBoxContainer/Fullscreen/CheckBox
@onready var vsync_check_box: CheckBox = $VBoxContainer/Vsync/CheckBox
@onready var fps_display_check_box: CheckBox = $VBoxContainer/FpsDisplay/CheckBox
@onready var decals_bullet_holes_number_input: LineEdit = $VBoxContainer/DecalsBulletHoles/NumberInput


# NOTE: for resolution settings to affect fullscreen mode, you have to change display settings
# Project Settings > Display > Window > Stretch 
# probably use viewport mode or something
const LIST_OF_RESOLUTIONS = [
	"Auto",
	"Custom",
	"800x1280",
	"1280x800",
	"1280x720",
	"1280x1024",
	"1360x768",
	"1366x768",
	"1440x900",
	"1470x956",
	"1512x982",
	"1600x900",
	"1680x1050",
	"1920x1200",
	"1920x1080",
	"2560x1080",
	"2560x1440",
	"2560x1600",
	"2880x1800",
	"3440x1440",
	"3840x2160",
	"5120x1440",
]

func _ready():
	initialize_resolutions()
	custom_resolution_settings.hide()
	confirm_resolution_change_popup.hide()
	resolution_drop_down.item_selected.connect(update_resolution)
	confirm_custom_resolution_button.button_up.connect(confirm_custom_resolution)
	
	fullscreen_check_box.toggled.connect(update_fullscreen)
	vsync_check_box.toggled.connect(update_vsync)
	fps_display_check_box.toggled.connect(update_fps_display)
	decals_bullet_holes_number_input.whitelisted_text_entered.connect(update_decals_setting.bind("bullet_holes", decals_bullet_holes_number_input))

func initialize_resolutions():
	for resolution in LIST_OF_RESOLUTIONS:
		resolution_drop_down.add_item(resolution)

var last_resolution_index = 0
var resolution_index_just_selected = 0
@onready var last_resolution : Vector2i = DisplayServer.window_get_size()

func update_resolution(resolution_setting: int, force=false):
	resolution_index_just_selected = resolution_setting
	var setting = resolution_drop_down.get_item_text(resolution_setting)
	var new_size = last_resolution
	
	custom_resolution_settings.hide()
	if setting == "Auto":
		new_size = DisplayServer.screen_get_size()
	elif setting == "Custom":
		custom_resolution_settings.show()
	else:
		var arr = setting.split("x")
		var x = arr[0].to_int()
		var y = arr[1].to_int()
		new_size = Vector2i(x, y)
	
	if new_size != last_resolution:
		if force:
			resolution_index_just_selected = resolution_setting
		set_new_resolution(new_size, true)

func confirm_custom_resolution(force=false):
	var x_s = custom_resolution_x_number_input.text
	var y_s = custom_resolution_y_number_input.text
	if x_s.is_valid_int() and y_s.is_valid_int():
		set_new_resolution(Vector2i(x_s.to_int(), y_s.to_int()), force)

func set_new_resolution(res: Vector2i, force=false):
	DisplayServer.window_set_size(res) 
	if force:
		confirm_resolution_change()
	else:
		confirm_resolution_change_popup.show_popup()
		

func confirm_resolution_change():
	last_resolution = DisplayServer.window_get_size()
	last_resolution_index = resolution_index_just_selected

func revert_resolution_change():
	resolution_drop_down.select(last_resolution_index)
	DisplayServer.window_set_size(last_resolution) 

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

func update_decals_setting(decal_amnt_string: String, decal_type: String, decal_input: LineEdit):
	var decal_amnt = 1
	var max_decal_amnt = 200
	if decal_amnt_string.is_valid_int():
		decal_amnt = decal_amnt_string.to_int()
		decal_amnt = clamp(decal_amnt, 1, max_decal_amnt)
		decal_input.text = str(decal_amnt)
	
	#TODO manual implementation
	print_debug("updated decal settings for %s to amount %s" % [decal_type, decal_amnt])

func get_settings_save_data()->Dictionary:
	return {
		"resolution": resolution_drop_down.selected,
		"custom_resolution": [custom_resolution_x_number_input.text, custom_resolution_y_number_input.text],
		"is_fullscreen": fullscreen_check_box.button_pressed,
		"vsync_on": vsync_check_box.button_pressed,
		"fps_display_on": fps_display_check_box.button_pressed,
		"max_decals_bullet_holes": decals_bullet_holes_number_input.text.to_int(),
	}

func load_settings_data(settings_data: Dictionary):
	if "resolution" in settings_data:
		resolution_drop_down.selected = roundi(settings_data.resolution)
		update_resolution(resolution_drop_down.selected, true)
	
	if "custom_resolution" in settings_data:
		custom_resolution_x_number_input.text = settings_data.custom_resolution[0]
		custom_resolution_y_number_input.text = settings_data.custom_resolution[1]
		if resolution_drop_down.get_item_text(resolution_drop_down.selected) == "Custom":
			confirm_custom_resolution()
	
	if "is_fullscreen" in settings_data:
		fullscreen_check_box.button_pressed = settings_data.is_fullscreen
	if "vsync_on" in settings_data:
		vsync_check_box.button_pressed = settings_data.vsync_on
	if "fps_display_on" in settings_data:
		fps_display_check_box.button_pressed = settings_data.fps_display_on
	if "max_decals_bullet_holes" in settings_data:
		decals_bullet_holes_number_input.text = str(roundi(settings_data.max_decals_bullet_holes))
