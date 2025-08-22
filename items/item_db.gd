class_name ItemDB extends Node

## Item Database
# assumes all textures are .png and stored in items/textures/
# and sfx are .wav and stored in items/sfx/

# paths are defined in item data as ITEMS_PATH + ITEM_TEXTURES_EXT so that it's easy to organize things 
# e.g. you can have a subfolder like so: ITEMS_PATH + "weapons/" + ITEM_TEXTURES_EXT

# a custom world item can be created by defining GRAPHICS_WORLD_PATH_STR on an item as a .tscn file instead
# see 'glowing_sword' for an example


const ITEMS_PATH = "res://items/"
const ITEM_TEXTURES_EXT = "textures/%s.png"
const ITEM_SFX_EXT = "sfx/%s.wav"
const ITEMS_CUSTOM_WORLD_EXT = "custom_world_item/%s.tscn"

const ITEM_UI = preload(ITEMS_PATH + "item_ui.tscn")
const ITEM_WORLD = preload(ITEMS_PATH + "item_world.tscn")

const ERROR_SOUND = preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_inv")

#define item data keys as constants to prevent typos
const ITEM_NAME_STR = "name"
const ITEM_TYPE_STR = "type"
const ITEM_DESCRIPTION_STR = "description"
const ITEM_WEIGHT_STR = "weight"
const ITEM_MAX_STACK_STR = "max_stack"
const GRAPHICS_WORLD_PATH_STR = "graphics_world_path"
const GRAPHICS_UI_PATH_STR = "graphics_ui_path"
const GRAB_INV_SOUND_PATH_STR = "grab_inv_sound_path"
const DROP_INV_SOUND_PATH_STR = "drop_inv_sound_path"
const GRAB_WORLD_SOUND_PATH_STR = "grab_world_sound_path"
const DROP_WORLD_SOUND_PATH_STR = "drop_world_sound_path"

# item types constants, defined as constants to prevent typos
const ITEM_TYPE_WEAPON = "weapon" 
const ITEM_TYPE_AMMO = "ammo"
const ITEM_TYPE_CONSUMABLE = "consumable"
const ITEM_TYPE_ARMOR = "armor"
const ITEM_TYPE_MISC = "misc"

static func get_item_data(item_id: String):
	if item_id in ITEMS:
		return ITEMS[item_id]
	print("ERROR: invalid item data requested. id %s does not exist" % item_id)
	return ITEMS["error"]

static func get_item_name(item_id: String):
	return get_item_data(item_id)[ITEM_NAME_STR]

static func get_item_type(item_id: String):
	return get_item_data(item_id)[ITEM_TYPE_STR]

static func create_item_for_ui(item_id: String) -> ItemUI:
	var new_item_ui : ItemUI = ITEM_UI.instantiate()
	new_item_ui.item_id = item_id
	return new_item_ui

static func create_item_for_world(item_id: String) -> ItemWorld:
	var new_item_world : ItemWorld
	var world_graphics_path = get_item_data(item_id)[GRAPHICS_WORLD_PATH_STR]
	if ".tscn" in world_graphics_path:
		new_item_world = load(world_graphics_path).instantiate()
	else:
		new_item_world = ITEM_WORLD.instantiate()
	new_item_world.add_to_group("instanced")
	new_item_world.item_id = item_id
	return new_item_world

static func get_sound_for_item(item_id: String, sound_id: String) -> AudioStream:
	var item_data = get_item_data(item_id)
	if not sound_id in item_data:
		print("ERROR: sound %s not found in %s" % [sound_id, item_id])
		return ERROR_SOUND
	var sound = item_data[sound_id]
	if sound is Array:
		sound = sound[randi_range(0, sound.size())-1]
	if sound is Dictionary:
		sound = sound["audio_stream"]
	return sound

static func get_item_grab_inv_sound(item_id: String) -> AudioStream:
	return get_sound_for_item(item_id, GRAB_INV_SOUND_PATH_STR)

static func get_item_drop_inv_sound(item_id: String) -> AudioStream:
	return get_sound_for_item(item_id, DROP_INV_SOUND_PATH_STR)
	
static func get_item_grab_world_sound(item_id: String) -> AudioStream:
	return get_sound_for_item(item_id, GRAB_WORLD_SOUND_PATH_STR)
	
static func get_item_drop_world_sound(item_id: String) -> AudioStream:
	return get_sound_for_item(item_id, DROP_WORLD_SOUND_PATH_STR)


## All items data
const ITEMS = {
	"sword": {
		#info
		ITEM_NAME_STR: "Sword",
		ITEM_TYPE_STR: ITEM_TYPE_WEAPON,
		ITEM_DESCRIPTION_STR: "A sword.",
		ITEM_WEIGHT_STR: 10,
		# graphics
		GRAPHICS_WORLD_PATH_STR: ITEMS_PATH + ITEM_TEXTURES_EXT % "sword_world",
		GRAPHICS_UI_PATH_STR: ITEMS_PATH + ITEM_TEXTURES_EXT % "sword_inv",
		# sfx
		GRAB_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_inv"),
		DROP_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_inv"),
		GRAB_WORLD_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_world"),
		DROP_WORLD_SOUND_PATH_STR: [ # optionally define array of sounds
			preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_world"),
			preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_world"),
			preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_world"),
		],
	},
	
	"glowing_sword": { # example of custom world item instead of just a texture
		#info
		ITEM_NAME_STR: "Glowing Sword",
		ITEM_TYPE_STR: ITEM_TYPE_WEAPON,
		ITEM_DESCRIPTION_STR: "A glowing sword.",
		ITEM_WEIGHT_STR: 10,
		# graphics
		GRAPHICS_WORLD_PATH_STR: ITEMS_PATH + ITEMS_CUSTOM_WORLD_EXT % "glowing_sword",
		GRAPHICS_UI_PATH_STR: ITEMS_PATH + ITEM_TEXTURES_EXT % "glowing_sword_inv",
		# sfx
		GRAB_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_inv"),
		DROP_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_inv"),
		GRAB_WORLD_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_world"),
		DROP_WORLD_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_world"),
	},
	
	
	"arrows": { # example of custom world item instead of just a texture
		#info
		ITEM_NAME_STR: "Arrows",
		ITEM_TYPE_STR: ITEM_TYPE_AMMO,
		ITEM_DESCRIPTION_STR: "Basic arrows.",
		ITEM_WEIGHT_STR: 1,
		ITEM_MAX_STACK_STR: 32, # optional parameter, adding this makes item stackable, and number indicates max stack
		# graphics
		GRAPHICS_WORLD_PATH_STR: [
			ITEMS_PATH + ITEM_TEXTURES_EXT % "arrows_world_1", # defining an array like this will show different graphics based on amount in stack
			ITEMS_PATH + ITEM_TEXTURES_EXT % "arrows_world_2",
			ITEMS_PATH + ITEM_TEXTURES_EXT % "arrows_world_3",
			],
		GRAPHICS_UI_PATH_STR: [
			ITEMS_PATH + ITEM_TEXTURES_EXT % "arrows_inv_1",
			ITEMS_PATH + ITEM_TEXTURES_EXT % "arrows_inv_2",
			ITEMS_PATH + ITEM_TEXTURES_EXT % "arrows_inv_3",
		],
		# sfx
		GRAB_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_inv"),
		DROP_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_inv"),
		GRAB_WORLD_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_world"),
		DROP_WORLD_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_world"),
	},
	
	"error": {
		#info
		ITEM_NAME_STR: "Error",
		ITEM_TYPE_STR: ITEM_TYPE_MISC,
		ITEM_DESCRIPTION_STR: "Error. You shouldn't be able to see this.",
		ITEM_WEIGHT_STR: 10,
		# graphics
		GRAPHICS_WORLD_PATH_STR: ITEMS_PATH + ITEM_TEXTURES_EXT % "error_item",
		GRAPHICS_UI_PATH_STR: ITEMS_PATH + ITEM_TEXTURES_EXT % "error_item",
		# sfx
		GRAB_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_inv"),
		DROP_INV_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_drop_inv"),
		GRAB_WORLD_SOUND_PATH_STR: preload(ITEMS_PATH + ITEM_SFX_EXT % "placeholder_grab_world"),
	},
	
}
