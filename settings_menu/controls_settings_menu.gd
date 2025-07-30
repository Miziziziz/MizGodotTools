extends ScrollContainer


@onready var v_box_container: VBoxContainer = $VBoxContainer

@onready var mouse_sensitivity_slider: HSlider = $VBoxContainer/MouseSensitivity/HSlider
@onready var mouse_x_invert_check_box: CheckBox = $VBoxContainer/MouseInvertX/CheckBox
@onready var mouse_y_invert_check_box: CheckBox = $VBoxContainer/MouseInvertY/CheckBox

const KEYBIND_INPUT_SECTION = preload("res://settings_menu/keybind_input_section.tscn")

# list all rebindable input actions
const ALL_INPUT_ACTIONS = [
	"attack",
	"jump",
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"exit",
]

# if you want an action to have a different name in your keybindings, add it here.
# action as key, custom name as value
const CUSTOM_ACTION_DISPLAY_NAMES = {
	"exit": "exit/pause", 
}

# if the default string for a button isn't good you can add a custom name for it here.
# for example, the tilde key ( ` ) is listed as QuoteLeft, so I change it to show ` instead
const BUTTON_CUSTOM_NAMES = {
	"QuoteLeft" : "`"
}

const MOUSE_INPUT_NAMES = {
	MOUSE_BUTTON_LEFT: "LMB",
	MOUSE_BUTTON_RIGHT: "RMB",
	MOUSE_BUTTON_MIDDLE: "MMB",
	MOUSE_BUTTON_WHEEL_UP: "Wheel Up",
	MOUSE_BUTTON_WHEEL_DOWN: "Wheel Down",
	MOUSE_BUTTON_WHEEL_LEFT: "Wheel Left",
	MOUSE_BUTTON_WHEEL_RIGHT: "Wheel Right",
	MOUSE_BUTTON_XBUTTON1: "Mouse Side 1",
	MOUSE_BUTTON_XBUTTON2: "Mouse Side 2",
}

# if you want rebindable gamepad inputs you'll have to add it here
var REMAPPABLE_INPUT_TYPES = ["InputEventKey", "InputEventMouseButton"] 

var action_names_to_input_buttons = {}

var active_input_button : Button
var action_being_edited = ""
var last_button_text = ""
var being_edited_string = "Enter Input Key..."

func _ready():
	mouse_sensitivity_slider.drag_ended.connect(update_mouse_sensitivity)
	mouse_x_invert_check_box.toggled.connect(update_mouse_x_invert)
	mouse_y_invert_check_box.toggled.connect(update_mouse_y_invert)
	initialize_keybind_buttons()

func update_mouse_sensitivity(_sens:float):
	pass # TODO requires manual implementation
	#get_tree().call_group("player", "set_mouse_sensitivity", sens)

func update_mouse_x_invert(_inverted:bool):
	pass # TODO requires manual implementation
	#get_tree().call_group("player", "set_mouse_x_invert", inverted)

func update_mouse_y_invert(_inverted:bool):
	pass # TODO requires manual implementation
	#get_tree().call_group("player", "set_mouse_y_invert", inverted)

func initialize_keybind_buttons():
	for action_name : String in ALL_INPUT_ACTIONS:
		var new_keybind_input = KEYBIND_INPUT_SECTION.instantiate()
		v_box_container.add_child(new_keybind_input)
		
		var label : Label = new_keybind_input.get_node("Label")
		var button : Button = new_keybind_input.get_node("Button")
		
		var formatted_action_name = action_name.capitalize()
		if action_name in CUSTOM_ACTION_DISPLAY_NAMES:
			formatted_action_name = CUSTOM_ACTION_DISPLAY_NAMES[action_name].capitalize()
		label.text = "%s:" % formatted_action_name
		
		button.text = get_action_name_display_string(action_name)
		button.button_up.connect(start_updating_input_binding.bind(action_name, button))
		action_names_to_input_buttons[action_name] = button

func get_action_name_display_string(action_name: String) -> String:
	var action_event = InputMap.action_get_events(action_name)[0]
	var b_text = ""
	if action_event is InputEventKey:
		b_text = action_event.as_text_physical_keycode()
		if b_text in BUTTON_CUSTOM_NAMES:
			b_text = BUTTON_CUSTOM_NAMES[b_text]
	if action_event is InputEventMouseButton:
		if action_event.button_index in MOUSE_INPUT_NAMES:
			b_text = MOUSE_INPUT_NAMES[action_event.button_index]
		else:
			b_text = str(action_event.button_index)
	return b_text

func start_updating_input_binding(action_name: String, keybind_button: Button):
	cancel_input_binding()
	active_input_button = keybind_button
	action_being_edited = action_name
	last_button_text = keybind_button.text
	keybind_button.text = being_edited_string

func cancel_input_binding():
	if active_input_button == null:
		return
	active_input_button.text = last_button_text
	action_being_edited = ""
	last_button_text = ""
	active_input_button = null

func _input(event: InputEvent) -> void:
	if active_input_button == null:
		return
		
	if event.get_class() in REMAPPABLE_INPUT_TYPES:
		update_input_binding_to_event(event)

func update_input_binding_to_event(input_event: InputEvent):
	if active_input_button == null or action_being_edited == "":
		return
	
	InputMap.action_erase_events(action_being_edited)
	InputMap.action_add_event(action_being_edited, input_event)
	active_input_button.text = get_action_name_display_string(action_being_edited)
	
	action_being_edited = ""
	last_button_text = ""
	active_input_button = null
	
	get_viewport().set_input_as_handled()

func get_action_keybind_save_data(action_name: String):
	var action_event = InputMap.action_get_events(action_name)[0]
	var event_type = ""
	var event_index = 0
	if action_event is InputEventKey:
		event_type = "key"
		event_index = action_event.physical_keycode
	if action_event is InputEventMouseButton:
		event_type = "mouse"
		event_index = action_event.button_index
	if action_event is InputEventJoypadButton: # NOTE: gamepad rebinding not tested
		event_type = "gamepad"
		event_index = action_event.button_index
	if action_event is InputEventJoypadMotion: # NOTE: gamepad rebinding not tested
		event_type = "joystick"
		event_index = action_event.axis
	return [event_type, event_index]

func load_action_keybind_save_data(action_name: String, event_data: Array):
	var event_type = event_data[0]
	var event_index = roundi(event_data[1])
	
	var input_event : InputEvent
	match(event_type):
		"key":
			input_event = InputEventKey.new()
			input_event.physical_keycode = event_index
		"mouse":
			input_event = InputEventMouseButton.new()
			input_event.button_index = event_index
		"gamepad": # NOTE: gamepad rebinding not tested
			input_event = InputEventJoypadButton.new()
			input_event.button_index = event_index
		"joystick": # NOTE: gamepad rebinding not tested
			input_event = InputEventJoypadMotion.new()
			input_event.axis = event_index
	
	if !input_event:
		return
	
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, input_event)
	action_names_to_input_buttons[action_name].text = get_action_name_display_string(action_name)

func get_settings_save_data() -> Dictionary:
	var settings_data = {
		"mouse_sensitivity": mouse_sensitivity_slider.value,
		"mouse_x_inverted": mouse_x_invert_check_box.button_pressed,
		"mouse_y_inverted": mouse_y_invert_check_box.button_pressed,
	}
	var keybindings = {}
	for input_action in ALL_INPUT_ACTIONS:
		keybindings[input_action] = get_action_keybind_save_data(input_action)
	settings_data.keybindings = keybindings
	
	return settings_data

func load_settings_data(settings_data: Dictionary):
	if "mouse_sensitivity" in settings_data:
		mouse_sensitivity_slider.value = settings_data.mouse_sensitivity
	if "mouse_x_inverted" in settings_data:
		mouse_x_invert_check_box.button_pressed = settings_data.mouse_x_inverted
	if "mouse_y_inverted" in settings_data:
		mouse_y_invert_check_box.button_pressed = settings_data.mouse_y_inverted
	if "keybindings" in settings_data:
		for action_name in settings_data.keybindings:
			load_action_keybind_save_data(action_name, settings_data.keybindings[action_name])
	
