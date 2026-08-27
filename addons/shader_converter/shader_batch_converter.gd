@tool
class_name Epic7ShaderBatchConverter
extends RefCounted

const Parser = preload("res://addons/shader_converter/shader_parser.gd")
const SourceLoader = preload("res://addons/shader_converter/shader_source_loader.gd")


static func convert_project(output_path: String) -> Dictionary:
	var normalized_output := output_path.strip_edges().trim_suffix("/").trim_suffix("\\")
	var failures := PackedStringArray()
	var manifest_entries: Array[Dictionary] = []
	var warning_count := 0

	if normalized_output.is_empty():
		failures.append("Output path is empty.")
		return _batch_result(0, manifest_entries, failures, warning_count)
	if not ensure_directory(normalized_output):
		failures.append("Unable to create output directory: %s" % normalized_output)
		return _batch_result(0, manifest_entries, failures, warning_count)

	var shader_files := scan_gdshader_files(normalized_output)
	if shader_files.is_empty():
		failures.append("No .gdshader files were found under res://.")
		return _batch_result(0, manifest_entries, failures, warning_count)

	for shader_path in shader_files:
		var file_result := convert_file(shader_path, normalized_output)
		if file_result.ok:
			manifest_entries.append(file_result.manifest)
			warning_count += file_result.warning_count
		else:
			failures.append("%s\n  %s" % [shader_path, "\n  ".join(file_result.errors)])

	var manifest_error := write_manifest(normalized_output, manifest_entries)
	if not manifest_error.is_empty():
		failures.append(manifest_error)
	return _batch_result(shader_files.size(), manifest_entries, failures, warning_count)


static func scan_gdshader_files(output_path: String = "") -> Array[String]:
	var files: Array[String] = []
	var project_output := _output_as_res_path(output_path)
	_scan_directory("res://", project_output, files)
	files.sort()
	return files


static func convert_file(shader_path: String, output_path: String) -> Dictionary:
	var source_result := SourceLoader.read_with_includes(shader_path)
	if not source_result.ok:
		return {"ok": false, "errors": source_result.errors}

	var conversion := Parser.convert_to_epic7_frag(source_result.content, shader_path)
	if not conversion.ok:
		return {"ok": false, "errors": conversion.errors}

	var relative_stem := shader_path.trim_prefix("res://").trim_suffix(".gdshader")
	var frag_path := output_path.path_join(relative_stem + ".frag")
	var lua_path := output_path.path_join(relative_stem + ".uniforms.lua")
	if not ensure_directory(frag_path.get_base_dir()):
		return {"ok": false, "errors": PackedStringArray(["Unable to create output folder: %s" % frag_path.get_base_dir()])}

	var write_error := write_text_file(frag_path, conversion.content)
	if not write_error.is_empty():
		return {"ok": false, "errors": PackedStringArray([write_error])}
	write_error = write_text_file(lua_path, Parser.generate_lua_uniform_setup(conversion))
	if not write_error.is_empty():
		return {"ok": false, "errors": PackedStringArray([write_error])}

	var manifest := {
		"source": shader_path,
		"fragment": frag_path,
		"lua_uniform_setup": lua_path,
		"includes": Array(source_result.included_files),
		"uses_time": conversion.uses_time,
		"uses_resolution": conversion.uses_resolution,
		"uniforms": conversion.uniforms,
		"warnings": Array(conversion.warnings),
	}
	return {"ok": true, "manifest": manifest, "warning_count": conversion.warnings.size()}


static func write_manifest(output_path: String, entries: Array[Dictionary]) -> String:
	var manifest := {
		"converter": "Epic7 Shader Converter",
		"version": Parser.CONVERTER_VERSION,
		"target_vertex_shader": "system/program_v4/sprite_base.vert",
		"shader_count": entries.size(),
		"shaders": entries,
	}
	return write_text_file(output_path.path_join("shader_manifest.json"), JSON.stringify(manifest, "\t") + "\n")


static func write_text_file(path: String, content: String) -> String:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "Unable to write: %s (error %s)" % [path, FileAccess.get_open_error()]
	file.store_string(content)
	file.close()
	return ""


static func ensure_directory(path: String) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	return DirAccess.make_dir_recursive_absolute(absolute_path) == OK


static func _scan_directory(directory_path: String, project_output: String, files: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return

	for file_name in directory.get_files():
		if file_name.ends_with(".gdshader"):
			files.append(directory_path.path_join(file_name))

	for child_name in directory.get_directories():
		if directory_path == "res://" and child_name in [".godot", "addons"]:
			continue
		var child_path := directory_path.path_join(child_name)
		if _is_same_or_child(child_path, project_output):
			continue
		_scan_directory(child_path, project_output, files)


static func _output_as_res_path(output_path: String) -> String:
	if output_path.is_empty():
		return ""
	if output_path.begins_with("res://"):
		return output_path.simplify_path()
	var project_root := ProjectSettings.globalize_path("res://").replace("\\", "/").trim_suffix("/")
	var normalized_output := output_path.replace("\\", "/").trim_suffix("/")
	if normalized_output == project_root:
		return "res://"
	if normalized_output.begins_with(project_root + "/"):
		return "res://" + normalized_output.trim_prefix(project_root + "/")
	return ""


static func _is_same_or_child(candidate_path: String, parent_path: String) -> bool:
	if parent_path.is_empty():
		return false
	var candidate := candidate_path.replace("\\", "/").trim_suffix("/")
	var parent := parent_path.replace("\\", "/").trim_suffix("/")
	return candidate == parent or candidate.begins_with(parent + "/")


static func _batch_result(shader_count: int, entries: Array[Dictionary], failures: PackedStringArray, warning_count: int) -> Dictionary:
	return {
		"ok": failures.is_empty(),
		"shader_count": shader_count,
		"converted_count": entries.size(),
		"failed_count": failures.size(),
		"warning_count": warning_count,
		"failures": failures,
		"manifest_entries": entries,
	}
