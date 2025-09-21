extends Control


@onready var un_pause_button = %UnPauseButton
@onready var load_game_button = %LoadSaveButton
@onready var settings_button = %SettingsButton
@onready var main_menu_button = %MainMenuButton

@onready var index_menu = %IndexMenu
@onready var load_game_menu = %LoadGameMenu
@onready var settings_menu = %SettingsMenu

@onready var menus = $Menus.get_children()

# set this false if player dies or you don't want the game pausable for whatever reason
var can_pause_game = true

func _ready():
	for menu : SubMenu in menus:
		menu.back_button.button_up.connect(switch_to_menu_screen.bind(index_menu))
	
	settings_button.button_up.connect(switch_to_menu_screen.bind(settings_menu))
	load_game_button.button_up.connect(switch_to_menu_screen.bind(load_game_menu))
	main_menu_button.button_up.connect(LevelManager.load_main_menu)
	
	hide()
	un_pause_button.button_up.connect(toggle_pause_menu)
	tree_exiting.connect(on_exit_tree)

func _process(_delta: float) -> void:
	if !can_pause_game:
		return
	if Input.is_action_just_pressed("exit"):
		toggle_pause_menu()

func on_exit_tree():
	get_tree().paused = false

func toggle_pause_menu():
	var p = !get_tree().paused
	get_tree().paused = p
	visible = p
	if p:
		un_pause_button.grab_focus()

func switch_to_menu_screen(menu_to_switch_to : SubMenu):
	for menu in menus:
		menu.hide()
	menu_to_switch_to.switch_to_this_menu()
