extends Control


@onready var continue_button = %ContinueButton
@onready var new_game_button = %NewGameButton
@onready var load_game_button = %LoadGameButton
@onready var settings_button = %SettingsButton
@onready var achievements_button = %AchievementsButton
@onready var credits_button = %CreditsButton
@onready var making_of_button = %MakingOfButton
@onready var exit_button = %ExitButton

@onready var menus = $Menus.get_children()

@onready var index_menu = %IndexMenu
@onready var achievements_menu = %AchievementsMenu
@onready var settings_menu = %SettingsMenu
@onready var credits_menu = %CreditsMenu
@onready var load_game_menu = %LoadGameMenu


func _ready():
	for menu : SubMenu in menus:
		menu.back_button.button_up.connect(switch_to_menu_screen.bind(index_menu))
	
	settings_button.button_up.connect(switch_to_menu_screen.bind(settings_menu))
	achievements_button.button_up.connect(switch_to_menu_screen.bind(achievements_menu))
	credits_button.button_up.connect(switch_to_menu_screen.bind(credits_menu))
	load_game_button.button_up.connect(switch_to_menu_screen.bind(load_game_menu))
	
	continue_button.button_up.connect(continue_game)
	new_game_button.button_up.connect(new_game)
	making_of_button.button_up.connect(open_making_of)
	exit_button.button_up.connect(exit_game)
	
	if SaveManager.get_last_saved_file_path() == "":
		continue_button.hide()

func continue_game():
	SaveManager.load_game_from_file(SaveManager.get_last_saved_file_path())

func new_game():
	LevelManager.start_new_game()
	# might want to implement some save file system here

func open_making_of():
	OS.shell_open("https://www.youtube.com/@Miziziziz")

func exit_game():
	get_tree().quit()

func switch_to_menu_screen(menu_to_switch_to : SubMenu):
	for menu in menus:
		menu.hide()
	menu_to_switch_to.switch_to_this_menu()
