extends LineEdit

@export var whitelisted_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
@export var set_to_this_on_blank = ""

signal whitelisted_text_entered

func _ready():
	caret_blink = true
	text_changed.connect(restrict_chars)
	text_submitted.connect(new_text_entered)
	editing_toggled.connect(on_edit_toggle)

func restrict_chars(txt: String):
	var char_deleted = false
	var c_pos = caret_column
	for c in txt:
		if c not in whitelisted_chars:
			char_deleted = true
			text = txt.replace(c, "")
	if char_deleted:
		c_pos -= 1 
	caret_column = c_pos
	if txt == "":
		text = set_to_this_on_blank

func on_edit_toggle(editing:bool):
	if !editing:
		restrict_chars(text)
		whitelisted_text_entered.emit(text)

func new_text_entered(txt: String):
	restrict_chars(txt)
	whitelisted_text_entered.emit(text)
