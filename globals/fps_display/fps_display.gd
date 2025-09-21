extends Label


var fps_display_visible : int :
		set(b):
			set_process(b)
			fps_display_visible = b
			visible = b

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	text = str(roundi(Engine.get_frames_per_second()))
