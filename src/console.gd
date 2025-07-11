class_name Console
extends RefCounted

# Dictionary[String, Callable[Array[String], String]]
static var commands: Dictionary[String, Callable] = {
	"echo": func (args: Array[String]) -> String: return " ".join(args)
}

static func exec_command(command: String) -> String:
	var args := split_args(command)
	if not args.is_empty() and args[0].to_lower() in commands:
		var command_output: String = commands[args[0].to_lower()].call(args.slice(1))
		return command_output + "\n"
	else:
		return "Not a command!\n"

static func split_args(command: String) -> Array[String]:
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
