@tool
extends EditorPlugin

const BatchConverter = preload("res://addons/shader_converter/shader_batch_converter.gd")
const SETTINGS_KEY := "epic7_shader_converter/output_path"
const DEFAULT_OUTPUT_PATH := "res://converted_epic7_shaders"

var convert_button: Button
var settings_button: Button
var toolbar_container: HBoxContainer
var settings_dialog: ConfirmationDialog
var path_input: LineEdit
var output_path := DEFAULT_OUTPUT_PATH


func _enter_tree() -> void:
	_load_output_path()

	toolbar_container = HBoxContainer.new()
	toolbar_container.add_theme_constant_override("separation", 4)

	convert_button = Button.new()
	convert_button.text = "Convert for Epic7"
	convert_button.tooltip_text = "Recursively convert Godot canvas_item shaders to Epic7 Cocos2d-x .frag files"
	convert_button.pressed.connect(_on_convert_button_pressed)
	toolbar_container.add_child(convert_button)

	settings_button = Button.new()
	settings_button.text = "Output..."
	settings_button.tooltip_text = "Configure the conversion output directory"
	settings_button.pressed.connect(_on_settings_button_pressed)
	toolbar_container.add_child(settings_button)

	add_control_to_container(CONTAINER_TOOLBAR, toolbar_container)
	_setup_settings_dialog()


func _exit_tree() -> void:
	if toolbar_container:
		remove_control_from_container(CONTAINER_TOOLBAR, toolbar_container)
		toolbar_container.queue_free()
	if settings_dialog:
		settings_dialog.queue_free()


func _load_output_path() -> void:
	var editor_settings := EditorInterface.get_editor_settings()
	if editor_settings.has_setting(SETTINGS_KEY):
		output_path = str(editor_settings.get_setting(SETTINGS_KEY))
	else:
		output_path = DEFAULT_OUTPUT_PATH


func _setup_settings_dialog() -> void:
	settings_dialog = ConfirmationDialog.new()
	settings_dialog.title = "Epic7 Shader Converter"
	settings_dialog.size = Vector2i(560, 180)

	var main_container := VBoxContainer.new()
	main_container.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = "Output directory (.frag, .uniforms.lua, shader_manifest.json):"
	main_container.add_child(label)

	var path_container := HBoxContainer.new()
	path_container.add_theme_constant_override("separation", 8)

	path_input = LineEdit.new()
	path_input.custom_minimum_size = Vector2(390, 0)
	path_input.text = output_path
	path_input.placeholder_text = DEFAULT_OUTPUT_PATH
	path_container.add_child(path_input)

	var browse_button := Button.new()
	browse_button.text = "Browse..."
	browse_button.pressed.connect(_on_browse_pressed)
	path_container.add_child(browse_button)
	main_container.add_child(path_container)

	var hint := Label.new()
	hint.text = "Use res:// for project-local output. Folder structure is preserved to avoid name collisions."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_container.add_child(hint)

	settings_dialog.add_child(main_container)
	settings_dialog.confirmed.connect(_on_settings_confirmed)
	add_child(settings_dialog)


func _on_convert_button_pressed() -> void:
	output_path = output_path.strip_edges().trim_suffix("/").trim_suffix("\\")
	if output_path.is_empty():
		_show_error("Output path is empty. Choose Output... and enter a directory.")
		return

	convert_button.disabled = true
	var batch_result := BatchConverter.convert_project(output_path)
	convert_button.disabled = false

	EditorInterface.get_resource_filesystem().scan()
	var summary := "Epic7 conversion complete.\n\nConverted: %d\nFailed: %d\nWarnings: %d\nOutput: %s" % [batch_result.converted_count, batch_result.failed_count, batch_result.warning_count, output_path]
	if not batch_result.failures.is_empty():
		summary += "\n\nFailures:\n" + "\n\n".join(batch_result.failures.slice(0, 8))
		_show_error(summary)
	else:
		_show_result(summary)


func _on_settings_button_pressed() -> void:
	path_input.text = output_path
	settings_dialog.popup_centered(Vector2i(560, 180))


func _on_browse_pressed() -> void:
	var directory_dialog := EditorFileDialog.new()
	directory_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	directory_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	directory_dialog.title = "Select Epic7 shader output directory"
	var initial_path := ProjectSettings.globalize_path(output_path) if output_path.begins_with("res://") else output_path
	if DirAccess.open(initial_path) != null:
		directory_dialog.current_path = initial_path
	directory_dialog.dir_selected.connect(func(path: String) -> void:
		path_input.text = path
		directory_dialog.queue_free()
	)
	directory_dialog.canceled.connect(directory_dialog.queue_free)
	add_child(directory_dialog)
	directory_dialog.popup_centered_ratio(0.55)


func _on_settings_confirmed() -> void:
	var selected_path := path_input.text.strip_edges().trim_suffix("/").trim_suffix("\\")
	if selected_path.is_empty():
		_show_error("Please enter a valid output directory.")
		return
	output_path = selected_path
	EditorInterface.get_editor_settings().set_setting(SETTINGS_KEY, output_path)


func _show_error(message: String) -> void:
	_show_dialog("Epic7 Conversion Error", message)


func _show_result(message: String) -> void:
	_show_dialog("Epic7 Conversion Complete", message)


func _show_dialog(title: String, message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.min_size = Vector2i(520, 220)
	get_tree().root.add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(600, 340))
