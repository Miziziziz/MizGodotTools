extends SubMenu

## Simple menu where players can easily report bugs and crashes

@onready var open_logs_button: Button = %OpenLogsButton
@onready var open_email_button: Button = %OpenEmailButton
@onready var open_discord_button: Button = %OpenDiscordButton
@onready var email_address_display: Label = %EmailAddressDisplay

@export var email_address = "email@address.com" # replace with your email address
@export var discord_channel = "https://discord.com/" # replace with your discord invite link

func _ready() -> void:
	open_logs_button.button_up.connect(open_logs_folder)
	open_email_button.button_up.connect(open_email)
	open_discord_button.button_up.connect(open_discord)
	email_address_display.text = email_address

func open_discord():
	OS.shell_open(discord_channel)

func open_email():
	OS.shell_open("mailto:%s" % email_address)

func open_logs_folder():
	var path = ProjectSettings.globalize_path("user://logs/")
	OS.shell_open(path)
