class_name ConsoleMenu
extends Control

@onready var console_history: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/ConsoleHistory
@onready var text_input: LineEdit = $PanelContainer/VBoxContainer/TextInput


func _on_text_input_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		accept_event()
		visible = false

func _on_text_submitted(new_text: String) -> void:
	if Storage.settings.con_echo:
		console_history.add_text("> " + new_text + "\n")
	var feedback := Console.exec_command(new_text)
	for segment in Console.parse_color_tags(feedback):
		console_history.push_color(segment.color)
		console_history.add_text(segment.text)
		console_history.pop()
	text_input.text = ""

func _on_visibility_changed() -> void:
	if visible:
		text_input.grab_focus.call_deferred()
