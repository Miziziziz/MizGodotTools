extends Node

@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var start_drag_click_sound: AudioStreamPlayer = $StartDragClickSound

@export var delay_by_frames = 1 # in case some control nodes need to be instanced at start

func _ready():
	for _i in delay_by_frames:
		await get_tree().process_frame
	connect_sounds_to_node(get_parent())

func connect_sounds_to_node(node: Node):
	for c in node.get_children():
		connect_sounds_to_node(c)
	
	if node is TabContainer:
		node.tab_changed.connect(on_control_val_changed)
	if node is Slider:
		node.mouse_entered.connect(hover_sound.play)
		node.drag_started.connect(start_drag_click_sound.play)
		node.drag_ended.connect(on_control_val_changed)
	if node is CheckBox:
		node.mouse_entered.connect(hover_sound.play)
		node.toggled.connect(on_control_val_changed)
	elif node is OptionButton:
		node.mouse_entered.connect(hover_sound.play)
		node.item_selected.connect(on_control_val_changed)
	elif node is Button:
		node.mouse_entered.connect(hover_sound.play)
		node.button_up.connect(click_sound.play)
	if node is LineEdit:
		node.text_submitted.connect(on_control_val_changed)
		#node.editing_toggled.connect(on_line_edit_stopped_editing)
	

func on_control_val_changed(_val):
	click_sound.play()

#func on_line_edit_stopped_editing(is_editing: bool):
	#if !is_editing:
		#click_sound.play()
