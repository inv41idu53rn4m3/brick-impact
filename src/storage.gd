class_name Storage
extends RefCounted

const SETTINGS_FILE_PATH = "user://settings.json"
const CONTROLS_FILE_PATH = "user://controls.json"
const PLAYER_SKIN_FILE_PATH = "user://skin.png"

static var settings: Settings

static func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if not file:
		#TODO: Warning in console!
		return
	file.store_line(settings.to_string())
	file.close()

static func load_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if not file:
		#TODO: Warning in console!
		settings = Settings.new()
		return
	settings = Settings.new(file.get_as_text())
	file.close()

static func save_controls() -> void:
	var controls: Dictionary[String, Array] = {}
	controls["jump"] = ([] as Array[Key])
	controls["left"] = ([] as Array[Key])
	controls["right"] = ([] as Array[Key])
	controls["console"] = ([] as Array[Key])
	
	for control_type: StringName in controls:
		for bind: InputEventKey in InputMap.action_get_events(control_type):
			var cs: Array[Key] = controls[control_type]
			cs.append(bind.physical_keycode)
	
	var file := FileAccess.open(CONTROLS_FILE_PATH, FileAccess.WRITE)
	if not file:
		print("Could not open controls file for writing: " + error_string(FileAccess.get_open_error()))
		return
	
	file.store_line(JSON.stringify(controls))
	file.close()

static func load_controls() -> void:
	var file := FileAccess.open(CONTROLS_FILE_PATH, FileAccess.READ)
	if not file:
		print("Could not open controls file for reading: " + error_string(FileAccess.get_open_error()))
		return
	
	var controls: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	for control_type: StringName in controls:
		InputMap.action_erase_events(control_type)
		for key: Key in controls[control_type]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(control_type, event)

static func load_player_skin() -> PackedByteArray:
	if not FileAccess.file_exists(PLAYER_SKIN_FILE_PATH):
		return PackedByteArray()
	
	var skin_image := Image.load_from_file(PLAYER_SKIN_FILE_PATH)
	skin_image.resize(16, 16)
	skin_image.convert(Image.FORMAT_RGBA8)
	
	return skin_image.data["data"]
