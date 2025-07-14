class_name Settings
extends RefCounted

const SETTING_TYPES: Array[Variant.Type] = [TYPE_FLOAT, TYPE_INT, TYPE_STRING, TYPE_BOOL]

var password := ""
var con_echo := true

func _init(json: String = "") -> void:
	if json == "":
		return
	var parser := JSON.new()
	var error := parser.parse(json)
	if error != OK:
		#TODO: Warning to console
		return
	if parser.data is not Dictionary:
		#TODO: Warning to console!
		return
	var dict: Dictionary = parser.data
	var properties := get_setting_info()
	for key: String in dict:
		if key not in properties:
			#TODO: Warning to console!
			continue
		set(key, type_convert(dict[key], properties[key]))

func _to_string() -> String:
	var result := {}
	for key in get_setting_info():
		result[key] = get(key)
	return JSON.stringify(result)

# get_property_list() returns a bunch of things we don't want
func get_setting_info() -> Dictionary[String, Variant.Type]:
	var properties: Dictionary[String, Variant.Type] = {}
	for property in get_property_list():
		if property.type in SETTING_TYPES and property.name[0] != "_":
			properties[property.name] = property.type
	return properties
