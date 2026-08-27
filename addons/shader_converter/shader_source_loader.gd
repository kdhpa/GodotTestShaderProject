@tool
class_name ShaderSourceLoader
extends RefCounted

## Loads Godot shader sources and recursively expands Godot #include directives.


static func read_with_includes(shader_path: String) -> Dictionary:
	var errors := PackedStringArray()
	var included_files := PackedStringArray()
	var stack := PackedStringArray()
	var content := _read_recursive(shader_path.simplify_path(), stack, included_files, errors)
	return {
		"ok": errors.is_empty(),
		"content": content,
		"included_files": included_files,
		"errors": errors,
	}


static func _read_recursive(path: String, stack: PackedStringArray, included_files: PackedStringArray, errors: PackedStringArray) -> String:
	if stack.has(path):
		errors.append("Circular shader include: %s -> %s" % [" -> ".join(stack), path])
		return ""

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		errors.append("Unable to read shader source: %s" % path)
		return ""

	var source := file.get_as_text()
	file.close()
	stack.append(path)

	var output_lines := PackedStringArray()
	var include_regex := RegEx.new()
	include_regex.compile("^\\s*#include\\s+[\\\"<]([^\\\">]+)[\\\">]\\s*$")

	for line in source.split("\n", true):
		var include_match := include_regex.search(line)
		if include_match == null:
			output_lines.append(line)
			continue

		var include_ref := include_match.get_string(1)
		var include_path := include_ref if include_ref.begins_with("res://") else path.get_base_dir().path_join(include_ref)
		include_path = include_path.simplify_path()
		included_files.append(include_path)
		var include_source := _read_recursive(include_path, stack, included_files, errors)
		output_lines.append("// BEGIN inlined include: %s" % include_path)
		output_lines.append(include_source)
		output_lines.append("// END inlined include: %s" % include_path)

	stack.remove_at(stack.size() - 1)
	return "\n".join(output_lines)
