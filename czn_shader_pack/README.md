# CZN Shader Archive

카오스 제로 나이트메어의 공개 게임플레이·공식 소개에서 관찰되는 시각 언어를 Godot 4.5 `canvas_item` 셰이더로 재구성한 독립형 샘플 팩입니다.

> 이 폴더는 게임 원본 셰이더나 추출 리소스를 포함하지 않습니다. 공개 자료에서 확인되는 결과 화면을 분석해 절차적으로 다시 만든 **팬메이드 기술 재현**입니다. 따라서 내부 구현 및 정확한 전체 셰이더 목록과 동일하다고 보장할 수 없습니다.

## 실행

Godot에서 `res://czn_shader_pack/czn_shader_gallery.tscn`을 열고 **현재 씬 실행(F6)** 하세요.

- 상단 카테고리 버튼: 화면 / 캐릭터 / 전투 / 카드·UI / 상태 필터
- 모든 카드의 왼쪽: 공식 영상에서 추출한 해당 연출 프레임
- 모든 카드의 오른쪽: 대응하는 Godot 셰이더 실시간 렌더링
- 카드 클릭: 공식 프레임과 셰이더 결과를 전체 화면 1:1 비교
- `Space`: 정신 붕괴 후처리 즉시 확대
- `Esc`: 확대 닫기

프로젝트 main scene은 이 갤러리로 지정되어 있으므로 **Play Project(F5)** 로 바로 실행할 수 있습니다.

## 공식 영상 비교 프레임

비교 프레임은 카제나 공식 채널의 다음 영상에서 추출했습니다.

- [Gameplay Trailer](https://www.youtube.com/watch?v=0nydDSWNwMA)
- [Gameplay Trailer Part 2](https://www.youtube.com/watch?v=-7puoO8TDKE)

각 카드 하단과 확대 제목에 출처 영상 번호와 타임코드가 표시됩니다. 전체 매핑은 [`references/README.md`](references/README.md)를 확인하세요.

`references/official_frames/`의 이미지 저작권은 Smilegate/Super Creative에 있으며, 셰이더 비교·연구 목적으로만 포함했습니다. 해당 이미지는 이 프로젝트의 코드 라이선스 대상이 아닙니다.

## 포함 셰이더

| 분류 | 파일 | 용도 |
|---|---|---|
| 화면 | `background_chaos_fog.gdshader` | 다층 안개, 원거리 신호 그리드, 별빛 |
| 화면 | `mental_breakdown.gdshader` | 정신 붕괴, RGB 분리, 화면 찢김, 적색 비네트 |
| 화면 | `unidentified_area_horror.gdshader` | 미확인 영역, 상처 스크래치, 공포 암전 |
| 화면 | `chaos_scene_transition.gdshader` | 카오스 침식형 장면 전환 |
| 화면 | `speed_lines.gdshader` | 필살기/돌진용 방사형 집중선 |
| 캐릭터 | `sprite_dynamic_light.gdshader` | 알파 기반 가상 노멀 조명, 림, 그림자 |
| 캐릭터 | `sprite_hit_outline.gdshader` | 피격 백색화, 외곽선, 색 잔상 |
| 캐릭터 | `sprite_chaos_dissolve.gdshader` | 노이즈 디졸브와 2색 연소선 |
| 전투 | `skill_slash.gdshader` | 회전 참격, 코어, 난류 꼬리, 스파크 |
| 전투 | `energy_beam.gdshader` | 빔 코어, 난류 외곽, 이동 펄스 |
| 전투 | `impact_shockwave.gdshader` | 충격 링, 스포크, 파편 |
| 전투 | `hex_barrier.gdshader` | 육각 보호막, 피격점, 리플 |
| 전투 | `heal_energy.gdshader` | 상승 입자, 회복 룬, 에너지 링 |
| 전투 | `target_lock.gdshader` | 타깃 브래킷과 잠금 스윕 |
| 전투 | `enemy_intent_aura.gdshader` | 공격/방어/약화 행동 예고 |
| 카드·UI | `card_holographic.gdshader` | 희귀도 포일, 스펙트럼 프레임 |
| 카드·UI | `card_breakdown.gdshader` | 붕괴 카드, 보로노이 균열과 오염 |
| 카드·UI | `ui_data_glitch.gdshader` | 블록 지터, RGB 분리, 신호 드롭아웃 |
| 카드·UI | `stress_meter.gdshader` | 분절 스트레스 게이지와 위험 심박 |
| 카드·UI | `critical_text_glow.gdshader` | 크리티컬 텍스트 외곽 발광 |
| 상태 | `elemental_status.gdshader` | 화상/중독/출혈 3모드 |
| 상태 | `chaos_corruption.gdshader` | 유기적 카오스 덩어리와 혈관 발광 |

공통 노이즈·FBM·보로노이·도형 함수는 `shaders/czn_common.gdshaderinc`에 모았습니다.

## 적용 예시

1. 대상 `Sprite2D`, `TextureRect`, `ColorRect` 또는 `Label`에 새 `ShaderMaterial`을 만듭니다.
2. 원하는 `.gdshader`를 지정합니다.
3. Inspector의 uniform을 장면에 맞게 조정합니다.

화면 후처리 계열은 `hint_screen_texture`를 사용하므로 화면을 덮는 `ColorRect`에 적용하세요. 스프라이트 계열은 투명 알파가 있는 텍스처에서 가장 잘 동작합니다. 전투 VFX 계열은 투명 배경을 출력하므로 `ColorRect`를 이펙트 쿼드처럼 배치하면 됩니다.
