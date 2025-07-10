class_name Console
extends Control

@onready var console_history: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/ConsoleHistory
@onready var text_input: LineEdit = $PanelContainer/VBoxContainer/TextInput


var commands: Dictionary[String, Callable] = {
	"echo": func (args: Array[String]) -> String: return " ".join(args)
}


func _on_text_submitted(new_text: String) -> void:
	console_history.add_text("> " + new_text + "\n")
	
	var words := new_text.split(" ", false)
	if not words.is_empty() and words[0].to_lower() in commands:
		var command_output: String = commands[words[0].to_lower()].call(words.slice(1))
		console_history.add_text(command_output + "\n")
	else:
		console_history.add_text("Not a command!\n")
	
	text_input.text = ""

func _on_visibility_changed() -> void:
	if visible:
		text_input.grab_focus.call_deferred()
