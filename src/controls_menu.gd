class_name ControlsMenu
extends Control

@onready var jump_label: Label = $MarginContainer/VBoxContainer/JumpLabel
@onready var left_label: Label = $MarginContainer/VBoxContainer/LeftLabel
@onready var right_label: Label = $MarginContainer/VBoxContainer/RightLabel
@onready var console_label: Label = $MarginContainer/VBoxContainer/ConsoleLabel
@onready var input_wait_overlay: Panel = $InputWaitOverlay

signal close_requested()

# it's a hair ugly but it's convenient
var label_definitions: Dictionary[String, Dictionary] = {
	jump = {title = "Jump: "},
	left = {title = "Left: "},
	right = {title = "Right: "},
	console = {title = "Console: "}
}
# "jump", "left", "right", "console", or empty string (no I will not Enum)
var input_listen_mode: String = ""


func _ready() -> void:
	label_definitions["jump"]["label"] = jump_label
	label_definitions["left"]["label"] = left_label
	label_definitions["right"]["label"] = right_label
	label_definitions["console"]["label"] = console_label
	for key: String in label_definitions:
		update_label(key)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	
	if input_listen_mode == "":
		if InputMap.event_is_action(event, "exit"):
			close_requested.emit()
			get_viewport().set_input_as_handled()
		return
	
	if not InputMap.event_is_action(event, "exit"):
		# Input map should only depend on physical keycode
		var added_event: InputEventKey = InputEventKey.new()
		added_event.physical_keycode = (event as InputEventKey).physical_keycode
		InputMap.action_add_event(input_listen_mode, added_event)
		get_viewport().set_input_as_handled()
		update_label(input_listen_mode)
	
	input_listen_mode = ""
	input_wait_overlay.visible = false

# Refresh a label to match current input map
func update_label(action: StringName) -> void:
	var key_labels := InputMap.action_get_events(action).map(
		func (input_event: InputEvent) -> String:
			if not input_event is InputEventKey:
				# Shouldn't happen but doesn't warrant an error
				return "???"
			# Get human readable representation of key
			var physical_key: Key = (input_event as InputEventKey).physical_keycode
			return OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(physical_key))
	)
	label_definitions[action].label.text = label_definitions[action].title + ", ".join(key_labels)


func _on_add_button_down(action: String) -> void:
	input_listen_mode = action
	input_wait_overlay.visible = true

func _on_reset_button_down(action: String) -> void:
	InputMap.action_erase_events(action)
	update_label(action)


func _on_back_button_down() -> void:
	close_requested.emit()
