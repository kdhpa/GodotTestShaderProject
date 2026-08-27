extends SceneTree

const Parser = preload("res://addons/shader_converter/shader_parser.gd")
const SourceLoader = preload("res://addons/shader_converter/shader_source_loader.gd")
const BatchConverter = preload("res://addons/shader_converter/shader_batch_converter.gd")

var failures := PackedStringArray()


func _init() -> void:
	_test_simple_conversion()
	_test_rejects_vertex_shader()
	_test_czn_shader_pack()
	_test_batch_file_output()

	if failures.is_empty():
		print("PASS: Epic7 shader converter tests completed successfully.")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("FAIL: %d Epic7 shader converter assertion(s) failed." % failures.size())
	quit(1)


func _test_simple_conversion() -> void:
	var source := """shader_type canvas_item;
render_mode unshaded;
uniform vec4 tint : source_color = vec4(1.0, 0.5, 0.25, 1.0);
uniform float speed : hint_range(0.0, 3.0) = 2.0;
void fragment() {
	vec4 sample_color = texture(TEXTURE, UV);
	COLOR = sample_color * tint * (0.5 + TIME * speed) * COLOR;
}
"""
	var result := Parser.convert_to_epic7_frag(source, "res://test.gdshader")
	_assert(result.ok, "Simple canvas_item shader should convert: %s" % result.errors)
	if not result.ok:
		return
	_assert(result.content.contains("#ifdef GLSL300ES"), "GLSL300ES branch is missing.")
	_assert(result.content.contains("#define OUTPUT_COLOR gl_FragColor"), "Legacy GLES output macro is missing.")
	_assert(_has_regex(result.content, "SAMPLE_TEXTURE\\(\\s*v_texCoord\\s*\\)"), "Main texture sampling was not converted.")
	_assert(result.content.contains("uniform vec4 u_tint;"), "Color uniform was not renamed/declared.")
	_assert(result.content.contains("uniform float u_time;"), "TIME runtime uniform is missing.")
	_assert(not result.content.contains("uniform float u_speed ="), "Godot uniform defaults must not remain in GLSL.")
	_assert(not result.content.contains("hint_range"), "Godot uniform hints must not remain in GLSL.")
	var lua_setup := Parser.generate_lua_uniform_setup(result)
	_assert(lua_setup.contains("setUniformVec4( 'u_tint', cc.vec4( 1.0, 0.5, 0.25, 1.0 ) )"), "vec4 Lua initialization is incorrect.")
	_assert(lua_setup.contains("setUniformFloat( 'u_time', 0.0 )"), "TIME Lua initialization is missing.")


func _test_rejects_vertex_shader() -> void:
	var source := "shader_type canvas_item;\nvoid vertex() {}\nvoid fragment() { COLOR = vec4(1.0); }"
	var result := Parser.convert_to_epic7_frag(source)
	_assert(not result.ok, "Shaders with vertex() must be rejected instead of silently producing incompatible output.")


func _test_czn_shader_pack() -> void:
	var directory := DirAccess.open("res://czn_shader_pack/shaders")
	_assert(directory != null, "CZN shader directory could not be opened.")
	if directory == null:
		return

	var shader_files := PackedStringArray()
	for file_name in directory.get_files():
		if file_name.ends_with(".gdshader"):
			shader_files.append("res://czn_shader_pack/shaders/" + file_name)
	shader_files.sort()
	_assert(shader_files.size() == 22, "Expected 22 CZN shaders, found %d." % shader_files.size())

	for shader_path in shader_files:
		var loaded := SourceLoader.read_with_includes(shader_path)
		_assert(loaded.ok, "%s include expansion failed: %s" % [shader_path, loaded.errors])
		if not loaded.ok:
			continue
		var result := Parser.convert_to_epic7_frag(loaded.content, shader_path)
		_assert(result.ok, "%s conversion failed: %s" % [shader_path, result.errors])
		if not result.ok:
			continue
		_assert(not result.content.contains("#include"), "%s still contains #include." % shader_path)
		_assert(not result.content.contains("shader_type"), "%s still contains shader_type." % shader_path)
		_assert(not result.content.contains("render_mode"), "%s still contains render_mode." % shader_path)
		_assert(not result.content.contains("hint_"), "%s still contains Godot uniform hints." % shader_path)
		_assert(not _has_regex(result.content, "(?m)^uniform\\s+[^;=]+="), "%s still contains a GLSL uniform initializer." % shader_path)
		_assert(result.content.contains("#define SAMPLE_TEXTURE( UV_ ) texture2D"), "%s lacks the legacy texture branch." % shader_path)
		_assert(_has_regex(result.content, "OUTPUT_COLOR\\s*="), "%s has no converted fragment assignment." % shader_path)


func _test_batch_file_output() -> void:
	var output_path := "res://.godot/epic7-converter-integration"
	_assert(BatchConverter.ensure_directory(output_path), "Batch converter could not create its test output directory.")
	var file_result := BatchConverter.convert_file("res://czn_shader_pack/shaders/critical_text_glow.gdshader", output_path)
	_assert(file_result.ok, "Batch file conversion failed: %s" % [file_result.get("errors", [])])
	if not file_result.ok:
		return

	var entries: Array[Dictionary] = [file_result.manifest]
	var manifest_error := BatchConverter.write_manifest(output_path, entries)
	_assert(manifest_error.is_empty(), "Batch manifest write failed: %s" % manifest_error)
	_assert(FileAccess.file_exists(output_path + "/czn_shader_pack/shaders/critical_text_glow.frag"), "Batch converter did not preserve the fragment output path.")
	_assert(FileAccess.file_exists(output_path + "/czn_shader_pack/shaders/critical_text_glow.uniforms.lua"), "Batch converter did not emit the Lua uniform template.")
	_assert(FileAccess.file_exists(output_path + "/shader_manifest.json"), "Batch converter did not emit shader_manifest.json.")


func _has_regex(content: String, pattern: String) -> bool:
	var regex := RegEx.new()
	return regex.compile(pattern) == OK and regex.search(content) != null


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
