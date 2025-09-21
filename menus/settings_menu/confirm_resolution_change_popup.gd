extends Control

@onready var graphics_menu: ScrollContainer = %Graphics

@onready var keep_resolution_button: Button = $HBoxContainer/KeepResolutionButton
@onready var revert_resolution_button: Button = $HBoxContainer/RevertResolutionButton
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var base_text = label.text


const TIME_UNTIL_REVERT = 10
var current_time = 0

func _ready():
	timer.timeout.connect(count_down_time)
	keep_resolution_button.button_up.connect(confirm_changes)
	revert_resolution_button.button_up.connect(revert_changes)

func show_popup():
	show()
	current_time = TIME_UNTIL_REVERT
	timer.start()
	update_display()

func hide_popup():
	hide()
	timer.stop()

func count_down_time():
	current_time -= 1
	if current_time <= 0:
		revert_changes()
	update_display()

func update_display():
	label.text = base_text % current_time

func confirm_changes():
	graphics_menu.confirm_resolution_change()
	hide_popup()

func revert_changes():
	graphics_menu.revert_resolution_change()
	hide_popup()
