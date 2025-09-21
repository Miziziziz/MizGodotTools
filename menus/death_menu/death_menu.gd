extends Control

## when player dies, call display_death_menu()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var load_last_save_button = %LoadLastSaveButton
@onready var load_game_button = %LoadSaveButton
@onready var main_menu_button = %MainMenuButton

@onready var load_game_menu = %LoadGameMenu
@onready var index_menu = %IndexMenu
@onready var menus = $Menus.get_children()


func _ready() -> void:
	for menu : SubMenu in menus:
		menu.back_button.button_up.connect(switch_to_menu_screen.bind(index_menu))
	
	load_game_button.button_up.connect(switch_to_menu_screen.bind(load_game_menu))
	main_menu_button.button_up.connect(LevelManager.load_main_menu)

	hide()
	load_last_save_button.button_up.connect(SaveManager.load_last_played_save)

func display_death_menu():
	animation_player.play("fade_in")
	await animation_player.animation_finished
	load_last_save_button.grab_focus()

func switch_to_menu_screen(menu_to_switch_to : SubMenu):
	for menu in menus:
		menu.hide()
	menu_to_switch_to.switch_to_this_menu()
