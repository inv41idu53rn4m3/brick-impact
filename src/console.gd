class_name Console
extends RefCounted

enum ArgType {
	STRING,
	BOOL,
	INT,
	FLOAT,
	STRARR
}

class CommandInfo:
	var callable: Callable # Should always return String
	var help: String
	var arg_types: Array[ArgType]
	var defaults: Array[Variant]
	@warning_ignore("shadowed_variable")
	func _init(callable: Callable, help: String, arg_types: Array[ArgType], defaults: Array[Variant]) -> void:
		self.callable = callable
		self.help = help
		self.arg_types = arg_types
		self.defaults = defaults

static var commands: Dictionary[String, CommandInfo] = {
	"echo": CommandInfo.new(
		func (args: Array[String]) -> String: return " ".join(args),
		"Print arguments to the console",
		[ArgType.STRARR], [[""]]
	)
}

static func exec_command(command: String) -> String:
	var args := split_args(command)
	if args.is_empty():
		return ""
	
	var cmd_name := args[0].to_lower()
	if cmd_name not in commands:
		return "Not a command!\n"
		
	var typed_args: Array[Variant]
	match parse_typed_args(args.slice(1), commands[cmd_name].arg_types):
		{"results": var results} when results is Array[Variant]:
			var res_arr: Array[Variant] = results
			typed_args = res_arr + commands[cmd_name].defaults.slice(res_arr.size())
		{"error": var error}: return error
	
	return commands[cmd_name].callable.callv(typed_args) + "\n"

static func parse_typed_args(args: Array[String], arg_types: Array[ArgType]) -> Dictionary:
	var results: Array[Variant] = []
	var index := 0
	# GDScript doesn't support proper nested functions so this is what we get
	var type_error := func(value: String, type: String) -> Dictionary[String, String]:
		return {"error": "\"%s\" is not a valid %s!\n" % [value, type]}
	while index < mini(args.size(), arg_types.size()):
		match arg_types[index]:
			ArgType.STRING:
				# Strings are always valid!
				results.append(args[index])
			ArgType.BOOL:
				match args[index]:
					"true": results.append(true)
					"false": results.append(false)
					var arg: return type_error.call(arg, "boolean")
			ArgType.INT:
				if args[index].is_valid_int():
					results.append(args[index].to_int())
				else:
					return type_error.call(args[index], "integer")
			ArgType.FLOAT:
				if args[index].is_valid_float():
					results.append(args[index].to_float())
				else:
					return type_error.call(args[index], "float")
			ArgType.STRARR:
				# Sometimes you just need all the remaining arguments
				results.append(args.slice(index))
				break
		index += 1
	return {"results": results}

static func split_args(command: String) -> Array[String]:
	var args: Array[String] = []
	var in_quote := false
	var should_escape := false
	var split_next_arg := true
	for chr in command:
		if not should_escape:
			if chr == "\\":
				should_escape = true
				continue
			if chr == "\"":
				in_quote = not in_quote
				continue
			if chr == " " and not in_quote:
				split_next_arg = true
				continue
		should_escape = false
		if split_next_arg: # Only start a new word when the character is normal text
			args.append("")
			split_next_arg = false
		args[args.size() - 1] += chr
	return args
