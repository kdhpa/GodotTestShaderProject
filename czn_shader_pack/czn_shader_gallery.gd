extends Control

## Public-reference visual study of Chaos Zero Nightmare-style rendering.
## The gallery intentionally uses only procedural shapes and the project's icon.

const SHADER_ROOT := "res://czn_shader_pack/shaders/"
const CATEGORY_COLORS := {
	"화면": Color("d32968"),
	"캐릭터": Color("5fb8ff"),
	"전투": Color("d66cff"),
	"카드·UI": Color("56e2d2"),
	"상태": Color("ff9d4d"),
}

const OFFICIAL_REFERENCES := {
	"CHAOS FOG": ["01_chaos_fog.jpg", "TRAILER 1  ·  01:44.00"],
	"MENTAL BREAKDOWN": ["02_mental_breakdown.jpg", "TRAILER 1  ·  01:16.50"],
	"UNIDENTIFIED AREA": ["03_unidentified_area.jpg", "TRAILER 2  ·  01:32.00"],
	"CHAOS TRANSITION": ["04_chaos_transition.jpg", "TRAILER 1  ·  01:06.00"],
	"SPEED LINES": ["05_speed_lines.jpg", "TRAILER 1  ·  01:36.75"],
	"DYNAMIC 2D LIGHT": ["06_dynamic_light.jpg", "TRAILER 1  ·  00:40.00"],
	"HIT / OUTLINE": ["07_hit_outline.jpg", "TRAILER 1  ·  00:26.25"],
	"CHAOS DISSOLVE": ["08_dissolve.jpg", "TRAILER 1  ·  01:24.00"],
	"ARC SLASH": ["09_slash.jpg", "TRAILER 2  ·  01:06.00"],
	"ENERGY BEAM": ["10_beam.jpg", "TRAILER 2  ·  01:08.50"],
	"IMPACT SHOCKWAVE": ["11_impact.jpg", "TRAILER 1  ·  00:26.75"],
	"HEX BARRIER": ["12_barrier.jpg", "TRAILER 1  ·  00:20.50"],
	"HEAL ENERGY": ["13_heal.jpg", "TRAILER 2  ·  00:52.00"],
	"TARGET LOCK": ["14_target_lock.jpg", "TRAILER 1  ·  00:36.00"],
	"ATTACK INTENT": ["15_attack_intent.jpg", "TRAILER 1  ·  00:22.00"],
	"DEFEND INTENT": ["16_defend_intent.jpg", "TRAILER 2  ·  00:28.00"],
	"DEBUFF INTENT": ["17_debuff_intent.jpg", "TRAILER 2  ·  00:44.00"],
	"HOLOGRAPHIC CARD": ["18_holo_card.jpg", "TRAILER 1  ·  00:52.00"],
	"BREAKDOWN CARD": ["19_breakdown_card.jpg", "TRAILER 1  ·  00:58.00"],
	"DATA GLITCH": ["20_ui_glitch.jpg", "TRAILER 2  ·  01:34.75"],
	"STRESS METER": ["21_stress.jpg", "TRAILER 1  ·  01:16.50"],
	"CRITICAL TEXT": ["22_critical.jpg", "TRAILER 1  ·  01:00.25"],
	"BURN": ["23_burn.jpg", "TRAILER 1  ·  00:52.70"],
	"POISON": ["24_poison.jpg", "TRAILER 2  ·  00:46.00"],
	"BLEED": ["25_bleed.jpg", "TRAILER 2  ·  00:42.75"],
	"CHAOS CORRUPTION": ["26_corruption.jpg", "TRAILER 2  ·  00:30.00"],
}

const ITEMS := [
	{
		"title": "CHAOS FOG",
		"subtitle": "다층 카오스 안개 · 신호 그리드",
		"category": "화면",
		"shader": "background_chaos_fog.gdshader",
		"kind": "background",
	},
	{
		"title": "MENTAL BREAKDOWN",
		"subtitle": "정신 붕괴 · RGB 분리 · 화면 찢김",
		"category": "화면",
		"shader": "mental_breakdown.gdshader",
		"kind": "screen",
	},
	{
		"title": "UNIDENTIFIED AREA",
		"subtitle": "미확인 영역 · 상처 스크래치 · 암전",
		"category": "화면",
		"shader": "unidentified_area_horror.gdshader",
		"kind": "screen",
	},
	{
		"title": "CHAOS TRANSITION",
		"subtitle": "유기적 침식 화면 전환",
		"category": "화면",
		"shader": "chaos_scene_transition.gdshader",
		"kind": "screen",
	},
	{
		"title": "SPEED LINES",
		"subtitle": "필살기 집중선 · 방사형 대시",
		"category": "화면",
		"shader": "speed_lines.gdshader",
		"kind": "procedural",
	},
	{
		"title": "DYNAMIC 2D LIGHT",
		"subtitle": "알파 기반 가상 노멀 · 림 · 그림자",
		"category": "캐릭터",
		"shader": "sprite_dynamic_light.gdshader",
		"kind": "sprite",
	},
	{
		"title": "HIT / OUTLINE",
		"subtitle": "피격 백색화 · 외곽선 · 잔상",
		"category": "캐릭터",
		"shader": "sprite_hit_outline.gdshader",
		"kind": "sprite",
	},
	{
		"title": "CHAOS DISSOLVE",
		"subtitle": "노이즈 소멸 · 마젠타/시안 연소선",
		"category": "캐릭터",
		"shader": "sprite_chaos_dissolve.gdshader",
		"kind": "sprite",
	},
	{
		"title": "ARC SLASH",
		"subtitle": "참격 코어 · 난류 꼬리 · 스파크",
		"category": "전투",
		"shader": "skill_slash.gdshader",
		"kind": "procedural",
	},
	{
		"title": "ENERGY BEAM",
		"subtitle": "펄스 패킷 · 난류 가장자리",
		"category": "전투",
		"shader": "energy_beam.gdshader",
		"kind": "procedural",
	},
	{
		"title": "IMPACT SHOCKWAVE",
		"subtitle": "충격 링 · 방사 스포크 · 파편",
		"category": "전투",
		"shader": "impact_shockwave.gdshader",
		"kind": "procedural",
	},
	{
		"title": "HEX BARRIER",
		"subtitle": "육각 실드 · 피격점 · 전파 리플",
		"category": "전투",
		"shader": "hex_barrier.gdshader",
		"kind": "procedural",
	},
	{
		"title": "HEAL ENERGY",
		"subtitle": "상승 입자 · 회복 룬 · 에너지 링",
		"category": "전투",
		"shader": "heal_energy.gdshader",
		"kind": "procedural",
	},
	{
		"title": "TARGET LOCK",
		"subtitle": "타깃 브래킷 · 잠금 진행 · 스윕",
		"category": "전투",
		"shader": "target_lock.gdshader",
		"kind": "procedural",
	},
	{
		"title": "ATTACK INTENT",
		"subtitle": "적 행동 예고 · 공격",
		"category": "전투",
		"shader": "enemy_intent_aura.gdshader",
		"kind": "procedural",
		"params": {"intent_mode": 0},
	},
	{
		"title": "DEFEND INTENT",
		"subtitle": "적 행동 예고 · 방어",
		"category": "전투",
		"shader": "enemy_intent_aura.gdshader",
		"kind": "procedural",
		"params": {"intent_mode": 1},
	},
	{
		"title": "DEBUFF INTENT",
		"subtitle": "적 행동 예고 · 약화",
		"category": "전투",
		"shader": "enemy_intent_aura.gdshader",
		"kind": "procedural",
		"params": {"intent_mode": 2},
	},
	{
		"title": "HOLOGRAPHIC CARD",
		"subtitle": "희귀도 포일 · 스펙트럼 프레임",
		"category": "카드·UI",
		"shader": "card_holographic.gdshader",
		"kind": "card",
	},
	{
		"title": "BREAKDOWN CARD",
		"subtitle": "붕괴 카드 · 보로노이 균열 · 오염",
		"category": "카드·UI",
		"shader": "card_breakdown.gdshader",
		"kind": "sprite",
	},
	{
		"title": "DATA GLITCH",
		"subtitle": "UI 신호 오류 · 블록 지터 · 드롭아웃",
		"category": "카드·UI",
		"shader": "ui_data_glitch.gdshader",
		"kind": "sprite",
	},
	{
		"title": "STRESS METER",
		"subtitle": "분절 게이지 · 위험 심박 · 파형",
		"category": "카드·UI",
		"shader": "stress_meter.gdshader",
		"kind": "meter",
	},
	{
		"title": "CRITICAL TEXT",
		"subtitle": "크리티컬 숫자 · 외곽 발광",
		"category": "카드·UI",
		"shader": "critical_text_glow.gdshader",
		"kind": "text",
	},
	{
		"title": "BURN",
		"subtitle": "화상 · 상승 불꽃",
		"category": "상태",
		"shader": "elemental_status.gdshader",
		"kind": "procedural",
		"params": {"effect_mode": 0},
	},
	{
		"title": "POISON",
		"subtitle": "중독 · 독성 구름 · 포자",
		"category": "상태",
		"shader": "elemental_status.gdshader",
		"kind": "procedural",
		"params": {"effect_mode": 1},
	},
	{
		"title": "BLEED",
		"subtitle": "출혈 · 낙하 방울 · 절상",
		"category": "상태",
		"shader": "elemental_status.gdshader",
		"kind": "procedural",
		"params": {"effect_mode": 2},
	},
	{
		"title": "CHAOS CORRUPTION",
		"subtitle": "유기적 카오스 덩어리 · 발광 혈관",
		"category": "상태",
		"shader": "chaos_corruption.gdshader",
		"kind": "background",
	},
]

var _grid: GridContainer
var _card_records: Array[Dictionary] = []
var _focus_layer: CanvasLayer
var _focus_root: Control
var _focus_preview_host: Control
var _focus_title: Label
var _active_category := "전체"


func _ready() -> void:
	_build_background()
	_build_header()
	_build_gallery()
	_build_focus_layer()
	get_viewport().size_changed.connect(_update_columns)
	_update_columns()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and _focus_root.visible:
			_close_focus()
		elif event.keycode == KEY_SPACE and not _focus_root.visible:
			_open_focus(ITEMS[1])


func _build_background() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.material = _make_material("background_chaos_fog.gdshader")
	add_child(background)

	var wash := ColorRect.new()
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color(0.01, 0.015, 0.035, 0.58)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wash)


func _build_header() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.custom_minimum_size.y = 150.0
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.035, 0.075, 0.94), Color("2a7da4"), 1, 0))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title_row := HBoxContainer.new()
	content.add_child(title_row)
	var title := Label.new()
	title.text = "CZN // SHADER ARCHIVE"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("eaf8ff"))
	title.add_theme_color_override("font_shadow_color", Color(0.12, 0.7, 1.0, 0.65))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title_row.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(spacer)
	var count := Label.new()
	count.text = "%02d SHADERS  //  GODOT 4.5" % (ITEMS.size() - 4)
	count.add_theme_font_size_override("font_size", 14)
	count.add_theme_color_override("font_color", Color("65d8f2"))
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(count)

	var subtitle := Label.new()
	subtitle.text = "카오스 제로 나이트메어 공개 비주얼 기반 재현 팩  ·  카드 클릭: 확대  ·  SPACE: 정신 붕괴  ·  ESC: 닫기"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("8faec1"))
	content.add_child(subtitle)

	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 8)
	content.add_child(filters)
	var button_group := ButtonGroup.new()
	var categories := ["전체", "화면", "캐릭터", "전투", "카드·UI", "상태"]
	for category in categories:
		var button := Button.new()
		button.text = category
		button.toggle_mode = true
		button.button_group = button_group
		button.custom_minimum_size = Vector2(92, 30)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_set_filter.bind(category))
		filters.add_child(button)
		if category == "전체":
			button.button_pressed = true


func _build_gallery() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 150.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 32)
	scroll.add_child(margin)

	var gallery_content := VBoxContainer.new()
	gallery_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gallery_content.add_theme_constant_override("separation", 15)
	margin.add_child(gallery_content)

	_grid = GridContainer.new()
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 15)
	_grid.add_theme_constant_override("v_separation", 15)
	gallery_content.add_child(_grid)

	for item in ITEMS:
		var card := _make_card(item)
		_grid.add_child(card)
		_card_records.append({"node": card, "category": item["category"]})

func _make_card(item: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(315, 286)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var category_color: Color = CATEGORY_COLORS[item["category"]]
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.035, 0.068, 0.91), category_color * Color(1, 1, 1, 0.62), 1, 8))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 9)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	var compare_row := HBoxContainer.new()
	compare_row.custom_minimum_size.y = 166.0
	compare_row.add_theme_constant_override("separation", 5)
	column.add_child(compare_row)

	var official := _create_official_preview(item)
	official.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	official.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	official.gui_input.connect(_on_preview_input.bind(item))
	compare_row.add_child(official)

	var preview := _create_preview(item)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	preview.gui_input.connect(_on_preview_input.bind(item))
	_add_preview_badge(preview, "GODOT", Color("ff5aab"), false)
	compare_row.add_child(preview)

	var title_row := HBoxContainer.new()
	column.add_child(title_row)
	var title := Label.new()
	title.text = item["title"]
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color("edf8ff"))
	title_row.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(spacer)
	var category := Label.new()
	category.text = item["category"]
	category.add_theme_font_size_override("font_size", 11)
	category.add_theme_color_override("font_color", category_color)
	category.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(category)

	var subtitle := Label.new()
	subtitle.text = item["subtitle"]
	subtitle.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("8299aa"))
	column.add_child(subtitle)

	var reference: Array = OFFICIAL_REFERENCES[item["title"]]
	var source := Label.new()
	source.text = "OFFICIAL  //  %s" % reference[1]
	source.add_theme_font_size_override("font_size", 10)
	source.add_theme_color_override("font_color", Color("54bdd7"))
	column.add_child(source)
	return card


func _create_official_preview(item: Dictionary) -> Control:
	var reference: Array = OFFICIAL_REFERENCES[item["title"]]
	var host := Control.new()
	host.clip_contents = true
	host.mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("030611")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(background)

	var image := TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.texture = load("res://czn_shader_pack/references/official_frames/" + reference[0])
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(image)
	_add_preview_badge(host, "OFFICIAL", Color("55dcff"), true)
	return host


func _add_preview_badge(host: Control, text: String, color: Color, left_side: bool) -> void:
	var badge := Label.new()
	badge.anchor_left = 0.0 if left_side else 1.0
	badge.anchor_right = 0.0 if left_side else 1.0
	badge.offset_left = 5.0 if left_side else -67.0
	badge.offset_right = 74.0 if left_side else -5.0
	badge.offset_top = 5.0
	badge.offset_bottom = 23.0
	badge.text = text
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if left_side else HORIZONTAL_ALIGNMENT_RIGHT
	badge.add_theme_font_size_override("font_size", 10)
	badge.add_theme_color_override("font_color", color)
	badge.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	badge.add_theme_constant_override("outline_size", 4)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(badge)


func _create_preview(item: Dictionary) -> Control:
	var host := Control.new()
	host.clip_contents = true
	host.mouse_filter = Control.MOUSE_FILTER_STOP

	var base := ColorRect.new()
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.color = Color("070b18")
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(base)

	var kind: String = item["kind"]
	if kind == "screen":
		base.material = _make_material("background_chaos_fog.gdshader")
		var terminal := Label.new()
		terminal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		terminal.text = "SS NIGHTMARE\nSECTOR 00 // SIGNAL LOST"
		terminal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		terminal.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		terminal.add_theme_font_size_override("font_size", 18)
		terminal.add_theme_color_override("font_color", Color(0.54, 0.84, 0.95, 0.82))
		terminal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(terminal)
		var screen_effect := ColorRect.new()
		screen_effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		screen_effect.material = _material_for_item(item)
		screen_effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(screen_effect)
	elif kind == "sprite" or kind == "card":
		var texture_rect := TextureRect.new()
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_rect.texture = load("res://icon.svg")
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.material = _material_for_item(item)
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(texture_rect)
	elif kind == "text":
		var damage_text := Label.new()
		damage_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		damage_text.text = "CRITICAL\n12,480"
		damage_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		damage_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		damage_text.add_theme_font_size_override("font_size", 31)
		damage_text.add_theme_color_override("font_color", Color.WHITE)
		damage_text.material = _material_for_item(item)
		damage_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(damage_text)
	elif kind == "meter":
		var meter := ColorRect.new()
		meter.anchor_left = 0.08
		meter.anchor_right = 0.92
		meter.anchor_top = 0.38
		meter.anchor_bottom = 0.68
		meter.material = _material_for_item(item)
		meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(meter)
	else:
		var effect := ColorRect.new()
		effect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		effect.material = _material_for_item(item)
		effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(effect)

	var top_line := ColorRect.new()
	top_line.anchor_right = 1.0
	top_line.offset_bottom = 2.0
	top_line.color = CATEGORY_COLORS[item["category"]]
	top_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(top_line)
	return host


func _build_focus_layer() -> void:
	_focus_layer = CanvasLayer.new()
	_focus_layer.layer = 50
	add_child(_focus_layer)
	_focus_root = Control.new()
	_focus_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_focus_root.visible = false
	_focus_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_focus_layer.add_child(_focus_root)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.004, 0.006, 0.018, 0.94)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.gui_input.connect(_on_focus_backdrop_input)
	_focus_root.add_child(shade)

	_focus_preview_host = Control.new()
	_focus_preview_host.anchor_left = 0.08
	_focus_preview_host.anchor_top = 0.12
	_focus_preview_host.anchor_right = 0.92
	_focus_preview_host.anchor_bottom = 0.88
	_focus_preview_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_focus_root.add_child(_focus_preview_host)

	_focus_title = Label.new()
	_focus_title.anchor_left = 0.08
	_focus_title.anchor_top = 0.035
	_focus_title.anchor_right = 0.8
	_focus_title.anchor_bottom = 0.11
	_focus_title.add_theme_font_size_override("font_size", 25)
	_focus_title.add_theme_color_override("font_color", Color("eaf8ff"))
	_focus_root.add_child(_focus_title)

	var close := Button.new()
	close.anchor_left = 0.88
	close.anchor_top = 0.035
	close.anchor_right = 0.95
	close.anchor_bottom = 0.09
	close.text = "ESC  CLOSE"
	close.pressed.connect(_close_focus)
	_focus_root.add_child(close)

	var hint := Label.new()
	hint.anchor_left = 0.08
	hint.anchor_top = 0.90
	hint.anchor_right = 0.92
	hint.anchor_bottom = 0.96
	hint.text = "실제 적용 시 Inspector에서 uniform 값을 조절하세요  //  ESC 또는 바깥 영역 클릭으로 닫기"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("7794a8"))
	_focus_root.add_child(hint)


func _make_material(shader_file: String, parameters := {}) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = load(SHADER_ROOT + shader_file)
	for parameter in parameters:
		material.set_shader_parameter(parameter, parameters[parameter])
	return material


func _material_for_item(item: Dictionary) -> ShaderMaterial:
	return _make_material(item["shader"], item.get("params", {}))


func _make_panel_style(background: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	return style


func _on_preview_input(event: InputEvent, item: Dictionary) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_open_focus(item)


func _on_focus_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_close_focus()


func _open_focus(item: Dictionary) -> void:
	for child in _focus_preview_host.get_children():
		_focus_preview_host.remove_child(child)
		child.queue_free()
	var comparison := HBoxContainer.new()
	comparison.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	comparison.add_theme_constant_override("separation", 16)
	_focus_preview_host.add_child(comparison)

	var official := _create_official_preview(item)
	official.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	official.mouse_filter = Control.MOUSE_FILTER_IGNORE
	comparison.add_child(official)

	var preview := _create_preview(item)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_preview_badge(preview, "GODOT SHADER", Color("ff5aab"), false)
	comparison.add_child(preview)

	var reference: Array = OFFICIAL_REFERENCES[item["title"]]
	_focus_title.text = "%s  //  %s  //  %s" % [item["title"], item["subtitle"], reference[1]]
	_focus_title.add_theme_color_override("font_color", CATEGORY_COLORS[item["category"]].lightened(0.42))
	_focus_root.visible = true


func _close_focus() -> void:
	_focus_root.visible = false


func _set_filter(category: String) -> void:
	_active_category = category
	for record in _card_records:
		record["node"].visible = category == "전체" or record["category"] == category


func _update_columns() -> void:
	if _grid == null:
		return
	var width := get_viewport_rect().size.x
	_grid.columns = 1 if width < 720.0 else (2 if width < 1120.0 else 3)
