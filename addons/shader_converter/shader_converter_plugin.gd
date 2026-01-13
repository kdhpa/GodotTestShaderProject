@tool
extends EditorPlugin

var convert_button: Button
var settings_button: Button
var toolbar_container: HBoxContainer
var settings_dialog: ConfirmationDialog
var output_path: String = ""


func _enter_tree() -> void:
	# Load output path from EditorSettings
	_load_output_path()

	# Create toolbar container for buttons
	toolbar_container = HBoxContainer.new()
	toolbar_container.add_theme_constant_override("separation", 4)

	# Create convert button
	convert_button = Button.new()
	convert_button.text = "Convert All Shaders"
	convert_button.tooltip_text = "Convert all .gdshader files in res:// to .frag format"
	convert_button.pressed.connect(_on_convert_button_pressed)
	toolbar_container.add_child(convert_button)

	# Create settings button
	settings_button = Button.new()
	settings_button.text = "⚙"
	settings_button.tooltip_text = "Configure output directory"
	settings_button.pressed.connect(_on_settings_button_pressed)
	toolbar_container.add_child(settings_button)

	# Add container to toolbar
	add_control_to_container(CONTAINER_TOOLBAR, toolbar_container)

	# Create and setup settings dialog
	_setup_settings_dialog()


func _exit_tree() -> void:
	# Remove toolbar buttons
	if toolbar_container:
		remove_control_from_container(CONTAINER_TOOLBAR, toolbar_container)
		toolbar_container.queue_free()

	# Free settings dialog
	if settings_dialog:
		settings_dialog.queue_free()


func _load_output_path() -> void:
	var editor_settings = EditorInterface.get_editor_settings()

	if editor_settings.has_setting("shader_converter/output_path"):
		output_path = editor_settings.get_setting("shader_converter/output_path")
	else:
		# Default path: Desktop/shader_folder
		output_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/shader_folder"


func _setup_settings_dialog() -> void:
	# Create settings dialog dynamically
	settings_dialog = ConfirmationDialog.new()
	settings_dialog.title = "Shader Converter Settings"
	settings_dialog.size = Vector2i(500, 150)

	# Create main container
	var main_container = VBoxContainer.new()
	main_container.add_theme_constant_override("separation", 8)

	# Create label
	var label = Label.new()
	label.text = "Output Directory for .frag files:"
	main_container.add_child(label)

	# Create path input with browse button
	var path_container = HBoxContainer.new()
	path_container.add_theme_constant_override("separation", 8)

	var path_input = LineEdit.new()
	path_input.custom_minimum_size = Vector2(300, 0)
	path_input.editable = false
	path_input.text = output_path
	path_input.name = "PathInput"
	path_container.add_child(path_input)

	var browse_button = Button.new()
	browse_button.text = "Browse..."
	browse_button.pressed.connect(func(): _on_browse_pressed(settings_dialog))
	path_container.add_child(browse_button)

	main_container.add_child(path_container)

	# Add to dialog
	settings_dialog.add_child(main_container)

	# Connect signals
	settings_dialog.confirmed.connect(func(): _on_settings_confirmed(settings_dialog))

	# Add to scene
	add_child(settings_dialog)


func _on_convert_button_pressed() -> void:
	# Validate output path
	if output_path.is_empty():
		_show_error("Output path not configured. Please click the settings button (⚙) first.")
		return

	# Ensure output directory exists
	if not _ensure_output_directory(output_path):
		_show_error("Failed to create output directory: %s\n\nCheck permissions and valid path." % output_path)
		return

	# Scan for shaders
	var shader_files = _scan_gdshader_files()
	if shader_files.is_empty():
		_show_error("No .gdshader files found in res://")
		return

	# Convert each file
	var success_count = 0
	var fail_count = 0

	for shader_path in shader_files:
		if _convert_file(shader_path, output_path):
			success_count += 1
		else:
			fail_count += 1

	# Show results
	_show_success("Conversion complete!\n\nSuccess: %d\nFailed: %d" % [success_count, fail_count])

	# Refresh filesystem
	EditorInterface.get_resource_filesystem().scan()


func _on_settings_button_pressed() -> void:
	if settings_dialog:
		# Update path input to current value
		var path_input = settings_dialog.find_child("PathInput", true, false)
		if path_input:
			path_input.text = output_path
		settings_dialog.popup_centered()


func _on_browse_pressed(dialog: ConfirmationDialog) -> void:
	var dir_dialog = EditorFileDialog.new()
	dir_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dir_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	dir_dialog.title = "Select Output Directory"

	# Set initial directory
	if not output_path.is_empty() and DirAccess.open(output_path) != null:
		dir_dialog.current_path = output_path
	else:
		dir_dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

	var path_input = dialog.find_child("PathInput", true, false)
	if path_input:
		dir_dialog.dir_selected.connect(func(path: String): path_input.text = path)

	add_child(dir_dialog)
	dir_dialog.popup_centered_ratio(0.5)


func _on_settings_confirmed(dialog: ConfirmationDialog) -> void:
	var path_input = dialog.find_child("PathInput", true, false)
	if not path_input:
		return

	var selected_path = path_input.text

	# Validate path
	if selected_path.is_empty():
		_show_error("Please select a valid directory")
		return

	# Save to EditorSettings
	var editor_settings = EditorInterface.get_editor_settings()
	editor_settings.set_setting("shader_converter/output_path", selected_path)

	# Update current path
	output_path = selected_path


func _scan_gdshader_files() -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open("res://")

	if dir == null:
		return files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".gdshader"):
			files.append("res://" + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	return files


func _convert_file(shader_path: String, output_dir: String) -> bool:
	# Read shader file
	var file = FileAccess.open(shader_path, FileAccess.READ)
	if file == null:
		return false

	var shader_content = file.get_as_text()
	file.close()

	# Validate content
	if shader_content.is_empty():
		return false

	# Convert shader
	var converted_content = ShaderParser.convert_to_frag(shader_content)

	# Determine output filename
	var filename = shader_path.get_file().trim_suffix(".gdshader") + ".frag"
	var output_path_full = output_dir.path_join(filename)

	# Write converted content
	var output_file = FileAccess.open(output_path_full, FileAccess.WRITE)
	if output_file == null:
		return false

	output_file.store_string(converted_content)
	output_file.close()

	return true


func _ensure_output_directory(path: String) -> bool:
	var dir = DirAccess.open(path.get_base_dir())
	if dir == null:
		return false

	if DirAccess.open(path) == null:
		var error = dir.make_dir(path)
		if error != OK:
			return false

	return true


func _show_error(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "Conversion Error"
	get_tree().root.add_child(dialog)
	dialog.popup_centered(Vector2i(400, 150))
	dialog.confirmed.connect(dialog.queue_free)


func _show_success(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "Conversion Successful"
	get_tree().root.add_child(dialog)
	dialog.popup_centered(Vector2i(400, 150))
	dialog.confirmed.connect(dialog.queue_free)
