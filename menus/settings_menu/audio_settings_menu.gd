extends ScrollContainer

@onready var master_volume_slider: HSlider = $VBoxContainer/MasterVolume/HSlider
@onready var music_volume_slider: HSlider = $VBoxContainer/MusicVolume/HSlider
@onready var sfx_volume_slider: HSlider = $VBoxContainer/SFXVolume/HSlider


func _ready():
	master_volume_slider.value_changed.connect(update_bus_volume.bind(AudioServer.get_bus_index("Master")))
	music_volume_slider.value_changed.connect(update_bus_volume.bind(AudioServer.get_bus_index("Music")))
	sfx_volume_slider.value_changed.connect(update_bus_volume.bind(AudioServer.get_bus_index("Sfx")))

func update_bus_volume(vol: float, bus_index: int):
	AudioServer.set_bus_volume_linear(bus_index, vol)

func load_settings_data(settings_data: Dictionary):
	if "master_volume" in settings_data:
		master_volume_slider.value = settings_data.master_volume
	if "music_volume" in settings_data:
		music_volume_slider.value = settings_data.music_volume
	if "sfx_volume" in settings_data:
		sfx_volume_slider.value = settings_data.sfx_volume

func get_settings_save_data()->Dictionary:
	return {
		"master_volume": master_volume_slider.value,
		"music_volume": music_volume_slider.value,
		"sfx_volume": sfx_volume_slider.value,
	}
