extends Control

@onready var jump_label: Label = $JumpLabel
@onready var left_label: Label = $LeftLabel
@onready var right_label: Label = $RightLabel
@onready var input_wait_overlay: Panel = $InputWaitOverlay

signal close_requested()

# it's a hair ugly but it's convenient
var label_definitions: Dictionary = {
	jump = {title = "Jump: "},
	left = {title = "Left: "},
	right = {title = "Right: "}
}
# "jump", "left", "right", or empty string (no I will not Enum)
var input_listen_mode: String = ""


func _ready() -> void:
	label_definitions["jump"]["label"] = jump_label
	label_definitions["left"]["label"] = left_label
	label_definitions["right"]["label"] = right_label
	update_label("jump")
	update_label("left")
	update_label("right")


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


func _on_add_jump_button_down() -> void:
	input_listen_mode = "jump"
	input_wait_overlay.visible = true

func _on_add_left_button_down() -> void:
	input_listen_mode = "left"
	input_wait_overlay.visible = true

func _on_add_right_button_down() -> void:
	input_listen_mode = "right"
	input_wait_overlay.visible = true


func _on_reset_jump_button_down() -> void:
	InputMap.action_erase_events("jump")
	update_label("jump")

func _on_reset_left_button_down() -> void:
	InputMap.action_erase_events("left")
	update_label("left")

func _on_reset_right_button_down() -> void:
	InputMap.action_erase_events("right")
	update_label("right")


func _on_back_button_down() -> void:
	close_requested.emit()
