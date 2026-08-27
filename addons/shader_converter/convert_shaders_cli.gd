extends SceneTree

const BatchConverter = preload("res://addons/shader_converter/shader_batch_converter.gd")
const DEFAULT_OUTPUT := "res://converted_epic7_shaders"


func _init() -> void:
	var output_path := DEFAULT_OUTPUT
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output_path = argument.trim_prefix("--output=").strip_edges()

	var result := BatchConverter.convert_project(output_path)
	print("Epic7 Shader Converter: converted=%d failed=%d warnings=%d output=%s" % [result.converted_count, result.failed_count, result.warning_count, output_path])
	for failure in result.failures:
		push_error(failure)
	quit(0 if result.ok else 1)
