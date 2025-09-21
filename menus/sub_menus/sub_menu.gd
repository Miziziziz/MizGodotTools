class_name SubMenu extends Control

@onready var back_button = $BackButton

@export var custom_focus_button : Button #optional

func switch_to_this_menu():
	show()
	back_button.grab_focus()
	if custom_focus_button:
		custom_focus_button.grab_focus()
