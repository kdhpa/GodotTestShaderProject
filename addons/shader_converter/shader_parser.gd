@tool
class_name ShaderParser
extends RefCounted

## Converts a Godot 4 canvas_item fragment shader into the shader layout used by
## Epic7's Cocos2d-x v4 renderer. The generated source supports both the
## GLSL300ES and legacy GLES branches used by system/program_v4/sprite_base.vert.

const CONVERTER_VERSION := "2.0.0"

const SUPPORTED_UNIFORM_TYPES := {
	"bool": true,
	"int": true,
	"float": true,
	"vec2": true,
	"vec3": true,
	"vec4": true,
	"sampler2D": true,
}

const UNSUPPORTED_FRAGMENT_BUILTINS := [
	"NORMAL",
	"NORMAL_MAP",
	"NORMAL_MAP_DEPTH",
	"LIGHT_VERTEX",
	"SHADOW_VERTEX",
	"POINT_COORD",
]


## Compatibility entry point kept for scripts which used converter 1.x.
## Call convert_to_epic7_frag() when diagnostics and uniform metadata are needed.
static func convert_to_frag(shader_content: String) -> String:
	var conversion := convert_to_epic7_frag(shader_content)
	if conversion.ok:
		return conversion.content
	return "// Epic7 shader conversion failed:\n// %s\n" % "\n// ".join(conversion.errors)


static func convert_to_epic7_frag(shader_content: String, source_path: String = "") -> Dictionary:
	var errors := PackedStringArray()
	var warnings := PackedStringArray()
	var uniforms: Array[Dictionary] = []

	if shader_content.strip_edges().is_empty():
		errors.append("Shader source is empty.")
		return _make_result(false, "", uniforms, warnings, errors, false, false)

	if not _has_regex(shader_content, "(?m)^\\s*shader_type\\s+canvas_item\\s*;"):
		errors.append("Only Godot 'shader_type canvas_item' shaders are supported.")

	if _has_regex(shader_content, "\\bvoid\\s+vertex\\s*\\("):
		errors.append("vertex() cannot be converted to Epic7's shared sprite_base.vert automatically.")
	if _has_regex(shader_content, "\\bvoid\\s+light\\s*\\("):
		errors.append("light() has no equivalent in this Epic7 fragment-shader pipeline.")
	if not _has_regex(shader_content, "\\bvoid\\s+fragment\\s*\\(\\s*\\)"):
		errors.append("fragment() entry point was not found.")
	if _has_regex(shader_content, "(?m)^\\s*#include\\b"):
		errors.append("Unresolved #include found. Expand includes with ShaderSourceLoader first.")
	if _has_regex(shader_content, "\\bCOLOR\\s*(?:[+\\-*/]=|\\.\\s*[rgba]{1,4}\\s*=)"):
		errors.append("Compound or component COLOR writes are not supported; assign the complete COLOR value once.")

	for builtin in UNSUPPORTED_FRAGMENT_BUILTINS:
		if _has_word(shader_content, builtin):
			errors.append("Unsupported Godot fragment builtin: %s" % builtin)

	if not errors.is_empty():
		return _make_result(false, "", uniforms, warnings, errors, false, false)

	var body := shader_content
	var uniform_parse := _extract_uniforms(body)
	body = uniform_parse.body
	uniforms = uniform_parse.uniforms
	errors.append_array(uniform_parse.errors)
	warnings.append_array(uniform_parse.warnings)

	if _has_regex(body, "(?m)^\\s*(?:instance\\s+)?uniform\\b"):
		errors.append("A uniform declaration could not be parsed. Use one declaration per line and a supported type.")

	var render_modes := _find_render_modes(body)
	for render_mode in render_modes:
		if render_mode != "unshaded":
			warnings.append("Godot render_mode '%s' was removed; configure the equivalent Cocos blend/render state manually." % render_mode)
	body = _remove_declarations(body)

	var uniform_names := {}
	for uniform_data in uniforms:
		if uniform_data.output_name == "u_texture" and not uniform_data.is_main_texture:
			errors.append("Uniform '%s' collides with Epic7's reserved main texture uniform u_texture." % uniform_data.source_name)
		elif uniform_names.values().has(uniform_data.output_name):
			errors.append("Uniform '%s' maps to duplicate Epic7 name '%s'." % [uniform_data.source_name, uniform_data.output_name])
		uniform_names[uniform_data.source_name] = uniform_data.output_name
	for source_name in uniform_names:
		body = _replace_word(body, source_name, uniform_names[source_name])

	# COLOR has read and write semantics in Godot. Protect the write target first,
	# then map any remaining reads to the sprite's vertex/modulate color.
	body = _replace_regex(body, "\\bCOLOR\\s*=", "OUTPUT_COLOR =")
	body = _replace_word(body, "COLOR", "v_fragmentColor")

	var uses_time := _has_word(body, "TIME")
	var uses_resolution := _has_word(body, "TEXTURE_PIXEL_SIZE") or _has_word(body, "SCREEN_PIXEL_SIZE")

	body = _replace_word(body, "SCREEN_PIXEL_SIZE", "(1.0 / u_resolution)")
	body = _replace_word(body, "TEXTURE_PIXEL_SIZE", "(1.0 / u_resolution)")
	body = _replace_word(body, "SCREEN_UV", "v_texCoord")
	body = _replace_word(body, "FRAGCOORD", "gl_FragCoord")
	body = _replace_word(body, "TIME", "u_time")
	body = _replace_word(body, "UV", "v_texCoord")
	body = _replace_word(body, "SCREEN_TEXTURE", "u_texture")
	body = _replace_word(body, "TEXTURE", "u_texture")

	# Main sprite/screen texture uses Epic7's backend-specific macro. Named
	# sampler2D uniforms are retained and routed through a two-argument macro.
	body = _replace_regex(body, "\\btexture\\s*\\(\\s*u_texture\\s*,", "SAMPLE_TEXTURE(")
	body = _replace_regex(body, "\\btexture\\s*\\(", "SAMPLE_TEXTURE_2D(")
	body = _replace_regex(body, "\\bvoid\\s+fragment\\s*\\(\\s*\\)", "void main()")
	body = _apply_vertex_color(body)
	if not _has_regex(body, "\\bOUTPUT_COLOR\\s*="):
		errors.append("fragment() does not assign the complete COLOR output.")

	for unsupported_call in ["textureLod", "textureGrad", "texelFetch", "dFdx", "dFdy", "fwidth"]:
		if _has_regex(body, "\\b%s\\s*\\(" % unsupported_call):
			errors.append("'%s' is not portable to Epic7's legacy GLES shader branch." % unsupported_call)

	if _has_word(body, "SCREEN_UV") or _has_word(body, "TEXTURE_PIXEL_SIZE") or _has_word(body, "TIME"):
		errors.append("One or more Godot builtins were left unresolved after conversion.")

	if not errors.is_empty():
		return _make_result(false, "", uniforms, warnings, errors, uses_time, uses_resolution)

	_add_runtime_uniforms(uniforms, uses_time, uses_resolution)
	var converted := _build_header(source_path) + _build_uniform_declarations(uniforms) + "\n" + body.strip_edges() + "\n"
	return _make_result(true, converted, uniforms, warnings, errors, uses_time, uses_resolution)


static func generate_lua_uniform_setup(conversion: Dictionary, state_name: String = "pst") -> String:
	var lines := PackedStringArray([
		"-- Generated by Epic7 Shader Converter %s." % CONVERTER_VERSION,
		"-- Apply after assigning the GLProgramState. Update u_time every frame when present.",
	])

	for uniform_data in conversion.uniforms:
		if uniform_data.is_main_texture:
			continue
		var uniform_name: String = uniform_data.output_name
		var uniform_type: String = uniform_data.type
		var default_value: String = uniform_data.default
		var runtime_kind: String = uniform_data.runtime_kind

		if runtime_kind == "resolution":
			lines.append("%s:setUniformVec2( '%s', { x = width, y = height } ) -- current u_texture size" % [state_name, uniform_name])
			continue
		if runtime_kind == "time":
			lines.append("%s:setUniformFloat( '%s', 0.0 ) -- update with elapsed seconds" % [state_name, uniform_name])
			continue
		if uniform_type == "sampler2D":
			lines.append("-- TODO: bind texture uniform '%s' explicitly." % uniform_name)
			continue
		if default_value.is_empty():
			lines.append("-- TODO: set '%s' (%s); the Godot shader declared no default." % [uniform_name, uniform_type])
			continue

		var statement := _lua_uniform_statement(state_name, uniform_name, uniform_type, default_value)
		if statement.is_empty():
			lines.append("-- TODO: set '%s' (%s), original default: %s" % [uniform_name, uniform_type, default_value])
		else:
			lines.append(statement)

	return "\n".join(lines) + "\n"


static func _extract_uniforms(content: String) -> Dictionary:
	var uniforms: Array[Dictionary] = []
	var errors := PackedStringArray()
	var warnings := PackedStringArray()
	var regex := RegEx.new()
	var pattern := "(?m)^\\s*uniform\\s+([A-Za-z_][A-Za-z0-9_]*)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*((?::[^;=]*)?)(?:=\\s*([^;]+))?;[ \\t]*(?://[^\\r\\n]*)?"
	if regex.compile(pattern) != OK:
		errors.append("Internal error: uniform parser regex could not be compiled.")
		return {"body": content, "uniforms": uniforms, "errors": errors, "warnings": warnings}

	var matches := regex.search_all(content)
	var body := content
	for index in range(matches.size() - 1, -1, -1):
		var regex_match: RegExMatch = matches[index]
		var uniform_type := regex_match.get_string(1)
		var source_name := regex_match.get_string(2)
		var hints := regex_match.get_string(3).strip_edges()
		var default_value := regex_match.get_string(4).strip_edges()

		if not SUPPORTED_UNIFORM_TYPES.has(uniform_type):
			errors.append("Unsupported uniform type '%s' for '%s'." % [uniform_type, source_name])
		else:
			var is_screen_texture := uniform_type == "sampler2D" and (hints.contains("hint_screen_texture") or source_name == "screen_texture")
			var output_name := "u_texture" if is_screen_texture else _epic7_uniform_name(source_name)
			if is_screen_texture:
				warnings.append("Godot screen texture '%s' is mapped to Epic7's current-pass u_texture." % source_name)
			uniforms.push_front({
				"source_name": source_name,
				"output_name": output_name,
				"type": uniform_type,
				"default": default_value,
				"hints": hints.trim_prefix(":" ).strip_edges(),
				"is_main_texture": is_screen_texture,
				"runtime_kind": "",
			})

		body = body.substr(0, regex_match.get_start()) + body.substr(regex_match.get_end())

	return {"body": body, "uniforms": uniforms, "errors": errors, "warnings": warnings}


static func _remove_declarations(content: String) -> String:
	var result := _replace_regex(content, "(?m)^\\s*shader_type\\s+[^;]+;[ \\t]*(?://[^\\r\\n]*)?", "")
	result = _replace_regex(result, "(?m)^\\s*render_mode\\s+[^;]+;[ \\t]*(?://[^\\r\\n]*)?", "")
	result = _replace_regex(result, "(?m)^\\s*group_uniforms\\s+[^;]+;[ \\t]*(?://[^\\r\\n]*)?", "")
	return result


static func _find_render_modes(content: String) -> PackedStringArray:
	var modes := PackedStringArray()
	var regex := RegEx.new()
	if regex.compile("(?m)^\\s*render_mode\\s+([^;]+);") != OK:
		return modes
	for regex_match in regex.search_all(content):
		for mode in regex_match.get_string(1).split(","):
			modes.append(mode.strip_edges())
	return modes


static func _apply_vertex_color(content: String) -> String:
	var regex := RegEx.new()
	if regex.compile("OUTPUT_COLOR\\s*=\\s*([^;]+);") != OK:
		return content
	var result := content
	var matches := regex.search_all(result)
	for index in range(matches.size() - 1, -1, -1):
		var regex_match: RegExMatch = matches[index]
		var expression := regex_match.get_string(1).strip_edges()
		if expression.contains("v_fragmentColor"):
			continue
		var replacement := "OUTPUT_COLOR = (%s) * v_fragmentColor;" % expression
		result = result.substr(0, regex_match.get_start()) + replacement + result.substr(regex_match.get_end())
	return result


static func _add_runtime_uniforms(uniforms: Array[Dictionary], uses_time: bool, uses_resolution: bool) -> void:
	var output_names := {}
	for uniform_data in uniforms:
		output_names[uniform_data.output_name] = true
		if uses_time and uniform_data.output_name == "u_time":
			uniform_data.runtime_kind = "time"
			if uniform_data.default.is_empty():
				uniform_data.default = "0.0"
		if uses_resolution and uniform_data.output_name == "u_resolution":
			uniform_data.runtime_kind = "resolution"
	if uses_time and not output_names.has("u_time"):
		uniforms.push_front({
			"source_name": "TIME",
			"output_name": "u_time",
			"type": "float",
			"default": "0.0",
			"hints": "",
			"is_main_texture": false,
			"runtime_kind": "time",
		})
	if uses_resolution and not output_names.has("u_resolution"):
		uniforms.push_front({
			"source_name": "TEXTURE_PIXEL_SIZE",
			"output_name": "u_resolution",
			"type": "vec2",
			"default": "",
			"hints": "",
			"is_main_texture": false,
			"runtime_kind": "resolution",
		})


static func _build_header(source_path: String) -> String:
	var source_label := source_path if not source_path.is_empty() else "inline shader"
	return """// Generated from %s by Epic7 Shader Converter %s.
// Target vertex shader: system/program_v4/sprite_base.vert

#ifdef GLSL300ES

#ifdef GL_ES
precision highp float;
precision highp int;
#endif

in vec4 v_fragmentColor;
in vec2 v_texCoord;
uniform sampler2D u_texture;
layout (location = 0) out vec4 FragColor;

#define SAMPLE_TEXTURE( UV_ ) texture( u_texture, UV_ )
#define SAMPLE_TEXTURE_2D( TEX_, UV_ ) texture( TEX_, UV_ )
#define OUTPUT_COLOR FragColor

#else

#ifdef GL_ES
precision highp float;
precision highp int;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;

#define SAMPLE_TEXTURE( UV_ ) texture2D( u_texture, UV_ )
#define SAMPLE_TEXTURE_2D( TEX_, UV_ ) texture2D( TEX_, UV_ )
#define OUTPUT_COLOR gl_FragColor

#endif

""" % [source_label, CONVERTER_VERSION]


static func _build_uniform_declarations(uniforms: Array[Dictionary]) -> String:
	var lines := PackedStringArray()
	var emitted := {}
	for uniform_data in uniforms:
		if uniform_data.is_main_texture:
			continue
		var uniform_name: String = uniform_data.output_name
		if emitted.has(uniform_name):
			continue
		emitted[uniform_name] = true
		lines.append("uniform %s %s;" % [uniform_data.type, uniform_name])
	return "\n".join(lines) + "\n"


static func _lua_uniform_statement(state_name: String, uniform_name: String, uniform_type: String, default_value: String) -> String:
	match uniform_type:
		"float":
			return "%s:setUniformFloat( '%s', %s )" % [state_name, uniform_name, default_value]
		"int":
			return "%s:setUniformInt( '%s', %s )" % [state_name, uniform_name, default_value]
		"bool":
			var bool_value := "1" if default_value == "true" else "0"
			return "%s:setUniformInt( '%s', %s )" % [state_name, uniform_name, bool_value]
		"vec2", "vec3", "vec4":
			var components := _parse_vector_default(default_value, uniform_type)
			if components.is_empty():
				return ""
			if uniform_type == "vec2":
				return "%s:setUniformVec2( '%s', { x = %s, y = %s } )" % [state_name, uniform_name, components[0], components[1]]
			if uniform_type == "vec3":
				return "%s:setUniformVec3( '%s', { x = %s, y = %s, z = %s } )" % [state_name, uniform_name, components[0], components[1], components[2]]
			return "%s:setUniformVec4( '%s', cc.vec4( %s, %s, %s, %s ) )" % [state_name, uniform_name, components[0], components[1], components[2], components[3]]
	return ""


static func _parse_vector_default(default_value: String, uniform_type: String) -> PackedStringArray:
	var regex := RegEx.new()
	if regex.compile("^\\s*%s\\s*\\((.*)\\)\\s*$" % uniform_type) != OK:
		return PackedStringArray()
	var regex_match := regex.search(default_value)
	if regex_match == null:
		return PackedStringArray()
	var components := PackedStringArray()
	for component in regex_match.get_string(1).split(","):
		components.append(component.strip_edges())
	var required_count := int(uniform_type.trim_prefix("vec"))
	if components.size() == 1:
		while components.size() < required_count:
			components.append(components[0])
	if components.size() != required_count:
		return PackedStringArray()
	return components


static func _epic7_uniform_name(source_name: String) -> String:
	return source_name if source_name.begins_with("u_") else "u_" + source_name


static func _make_result(ok: bool, content: String, uniforms: Array[Dictionary], warnings: PackedStringArray, errors: PackedStringArray, uses_time: bool, uses_resolution: bool) -> Dictionary:
	return {
		"ok": ok,
		"content": content,
		"uniforms": uniforms,
		"warnings": warnings,
		"errors": errors,
		"uses_time": uses_time,
		"uses_resolution": uses_resolution,
	}


static func _has_word(content: String, word: String) -> bool:
	return _has_regex(content, "\\b%s\\b" % word)


static func _has_regex(content: String, pattern: String) -> bool:
	var regex := RegEx.new()
	return regex.compile(pattern) == OK and regex.search(content) != null


static func _replace_word(content: String, word: String, replacement: String) -> String:
	return _replace_regex(content, "\\b%s\\b" % word, replacement)


static func _replace_regex(content: String, pattern: String, replacement: String) -> String:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return content
	return regex.sub(content, replacement, true)
