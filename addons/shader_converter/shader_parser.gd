@tool
class_name ShaderParser

# Main conversion function
static func convert_to_frag(shader_content: String) -> String:
	var result = shader_content

	# Step 1: Check if TIME is used
	var uses_time = result.contains("TIME")

	# Step 2: Remove shader_type declaration
	result = _remove_shader_type(result)

	# Step 3: Add GLSL header
	result = _add_glsl_header(result, uses_time)

	# Step 4: Convert function signature
	result = _convert_fragment_function(result)

	# Step 5: Replace Godot built-ins with GLSL equivalents
	result = _replace_builtins(result)

	# Step 6: Update texture function calls
	result = _replace_texture_calls(result)

	# Step 7: Fix COLOR assignments
	result = _fix_color_assignments(result)

	return result


# Remove shader_type declaration
static func _remove_shader_type(content: String) -> String:
	var regex = RegEx.new()
	regex.compile("^\\s*shader_type\\s+\\w+\\s*;\\s*$")
	return regex.sub(content, "", true)


# Add GLSL header
static func _add_glsl_header(content: String, uses_time: bool) -> String:
	var header = """
#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;
"""

	if uses_time:
		header += "uniform float u_time;\n"

	header += "\n"
	return header + content


# Convert void fragment() to void main()
static func _convert_fragment_function(content: String) -> String:
	var regex = RegEx.new()
	regex.compile("void\\s+fragment\\s*\\(\\s*\\)")
	return regex.sub(content, "void main()")


# Replace Godot built-in variables with GLSL equivalents
static func _replace_builtins(content: String) -> String:
	var result = content

	# Replace UV with v_texCoord
	result = result.replace("UV", "v_texCoord")

	# Replace TIME with u_time
	result = result.replace("TIME", "u_time")

	# Replace TEXTURE with u_texture (before COLOR replacement)
	result = result.replace("TEXTURE", "u_texture")

	# Replace COLOR with gl_FragColor
	result = result.replace("COLOR", "gl_FragColor")

	return result


# Replace texture() calls with texture2D()
static func _replace_texture_calls(content: String) -> String:
	var regex = RegEx.new()
	regex.compile("texture\\s*\\(\\s*u_texture\\s*,\\s*([^)]+)\\s*\\)")
	return regex.sub(content, "texture2D(u_texture, $1)")


# Fix COLOR assignments to multiply by v_fragmentColor
static func _fix_color_assignments(content: String) -> String:
	var regex = RegEx.new()
	regex.compile("gl_FragColor\\s*=\\s*([^;]+);")

	var result = content
	var matches = regex.search_all(result)

	# Process matches in reverse order to maintain correct indices
	for i in range(matches.size() - 1, -1, -1):
		var match = matches[i]
		var expression = match.get_string(1).strip_edges()

		# Skip if already contains v_fragmentColor
		if not expression.contains("v_fragmentColor"):
			var replacement = "gl_FragColor = (%s) * v_fragmentColor;" % expression
			result = result.substr(0, match.get_start()) + replacement + result.substr(match.get_end())

	return result
