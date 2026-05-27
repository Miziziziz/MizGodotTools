extends SubMenu

## Controls changing locale for the game. You'll have to manually create your own localization files.
## How to localize: https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html

## To add another language option here, create a new button under ButtonBase, name it the language you want, 
## set the button text to the name of the language in that language (e.g. Spanish would be 'Español')
## and then add it and the locale code to the 'language_buttons' dictionary
## locale codes can be found here: https://docs.godotengine.org/en/latest/tutorials/i18n/locales.html

@onready var button_base: VBoxContainer = %ButtonBase
@onready var confirm_language_button: Button = %ConfirmLanguageButton

signal language_updated

var last_button_pressed : Button

# Add one instance to main menu and set this to true. 
@export var show_on_start_if_no_locale_loaded = false 

var locale_loaded = false

var language_buttons = {
	"English": "en",
	"Spanish": "es",
	"Portuguese": "pt",
}

func _ready():
	if show_on_start_if_no_locale_loaded:
		back_button.hide()
	
	await get_tree().process_frame
	confirm_language_button.button_down.connect(confirm_language)
	if !show_on_start_if_no_locale_loaded:
		disable_button_for_cur_language()
	
	for b in language_buttons:
		var locale = language_buttons[b]
		var button : Button = button_base.get_node(b)
		button.button_down.connect(set_language_locale.bind(locale, button))
	
	if show_on_start_if_no_locale_loaded and !locale_loaded:
		open(true)

func disable_button_for_cur_language():
	var cur_language_button : Button
	var current_locale = TranslationServer.get_locale()
	for b in language_buttons:
		var locale = language_buttons[b]
		var button : Button = button_base.get_node(b)
		if TranslationServer.compare_locales(locale, current_locale) > 0:
			last_button_pressed = button
			button.disabled = true
			cur_language_button = button
		else:
			button.disabled = false
	return cur_language_button

var focused_elm_on_open : Control
func open(enable_all_buttons_and_disable_confirm=false):
	if get_parent() is Control:
		get_parent().focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

	focused_elm_on_open = get_viewport().gui_get_focus_owner()
	show()
	
	if enable_all_buttons_and_disable_confirm:
		for b in button_base.get_children():
			if b is Button:
				b.disabled = false
		confirm_language_button.disabled = true
	else:
		disable_button_for_cur_language()
	
	for b : Button in button_base.get_children():
		if !b.disabled:
			b.grab_focus()
			break

func confirm_language():
	hide()
	if get_parent() is Control:
		get_parent().focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	language_updated.emit()
	if focused_elm_on_open:
		focused_elm_on_open.grab_focus()
	get_tree().call_group("settings_menu", "save_settings")

func set_language_locale(language_locale: String, button: Button):
	if last_button_pressed:
		last_button_pressed.disabled = false
	TranslationServer.set_locale(language_locale)
	button.disabled = true
	last_button_pressed = button
	confirm_language_button.disabled = false
	confirm_language_button.grab_focus()

func set_locale_was_loaded():
	locale_loaded = true
