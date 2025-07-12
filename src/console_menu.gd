class_name ConsoleMenu
extends Control

@onready var console_history: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/ConsoleHistory
@onready var text_input: LineEdit = $PanelContainer/VBoxContainer/TextInput


func _on_text_input_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		accept_event()
		visible = false

func _on_text_submitted(new_text: String) -> void:
	console_history.add_text("> " + new_text + "\n")
	console_history.add_text(Console.exec_command(new_text))
	text_input.text = ""

func _on_visibility_changed() -> void:
	if visible:
		text_input.grab_focus.call_deferred()
