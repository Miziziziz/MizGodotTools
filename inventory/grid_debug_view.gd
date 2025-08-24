@tool
extends Control

## should be child of GridInventoryContainer
## for use in editor

@export var line_width = 2
@export var line_color = Color.WHITE

func _ready() -> void:
	if !Engine.is_editor_hint():
		set_process(false)
		hide()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var grid_inventory_container : GridInventoryContainer = get_parent()
	var x_count = grid_inventory_container.num_of_columns
	var y_count = grid_inventory_container.num_of_rows
	var x_size = size.x / x_count
	var y_size = size.y / y_count
	
	for x in x_count+1:
		var start_pos = Vector2(x * x_size, 0.0)
		var end_pos = Vector2(x * x_size, size.y)
		draw_line(start_pos, end_pos, line_color, line_width)
	for y in y_count+1:
		var start_pos = Vector2(0.0, y * y_size)
		var end_pos = Vector2(size.x, y * y_size)
		draw_line(start_pos, end_pos, line_color, line_width)
