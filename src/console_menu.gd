class_name Console
extends Control

@onready var console_history: RichTextLabel = $PanelContainer/VBoxContainer/MarginContainer/ConsoleHistory
@onready var text_input: LineEdit = $PanelContainer/VBoxContainer/TextInput

# Dictionary[String, Callable[Array[String], String]]
var commands: Dictionary[String, Callable] = {
	"echo": func (args: Array[String]) -> String: return " ".join(args)
}


func split_args(command: String) -> Array[String]:
	var args: Array[String] = []
	var quote := false
	var escape := false
	var next_arg := true
	for chr in command:
		if not escape:
			if chr == "\\":
				escape = true
				continue
			if chr == "\"":
				quote = not quote
				continue
			if chr == " " and not quote:
				next_arg = true
				continue
		escape = false
		if next_arg:
			args.append("")
			next_arg = false
		args[args.size() - 1] += chr
	return args


func _on_text_submitted(new_text: String) -> void:
	console_history.add_text("> " + new_text + "\n")
	
	var args := split_args(new_text)
	print(args)
	if not args.is_empty() and args[0].to_lower() in commands:
		var command_output: String = commands[args[0].to_lower()].call(args.slice(1))
		console_history.add_text(command_output + "\n")
	else:
		console_history.add_text("Not a command!\n")
	
	text_input.text = ""

func _on_visibility_changed() -> void:
	if visible:
		text_input.grab_focus.call_deferred()
