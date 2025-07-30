extends Control

@onready var settings_menu: Control = $SettingsMenu
@onready var open_settings_button: Button = $OpenSettingsButton

func _ready():
	open_settings_button.button_up.connect(settings_menu.show)
	open_settings_button.button_up.connect(open_settings_button.hide)
	
	settings_menu.back_button.button_up.connect(open_settings_button.show)
	settings_menu.back_button.button_up.connect(settings_menu.hide)
