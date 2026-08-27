# Epic7 Shader Converter

Godot 4의 `canvas_item` fragment shader를 Epic7 클라이언트의 Cocos2d-x v4 셰이더 형식으로 변환하는 Godot 편집기 플러그인입니다.

변환 기준은 Epic7의 다음 운영 패턴입니다.

- vertex shader: `system/program_v4/sprite_base.vert`
- fragment shader: `system/program_v4/*.frag`
- 프로그램 등록: `script/module/shader.lua`
- uniform 적용: `cc.GLProgramState`의 `setUniform*`
- 후처리: `LayerPostProcess`와 `PPUtil`

## 사용법

1. Godot에서 **Project > Project Settings > Plugins**를 엽니다.
2. **Epic7 Shader Converter**를 활성화합니다.
3. 상단 툴바의 **Output...**에서 출력 위치를 정합니다. 기본값은 `res://converted_epic7_shaders`입니다.
4. **Convert for Epic7**을 누릅니다.

플러그인은 `res://` 아래를 재귀 탐색합니다. `.godot`, `addons`, 설정한 출력 폴더는 제외하며 원본의 하위 폴더 구조를 그대로 유지합니다.

각 shader에서 다음 파일을 생성합니다.

- `name.frag`: Epic7용 fragment shader
- `name.uniforms.lua`: Godot 기본값을 옮긴 `GLProgramState` uniform 설정 템플릿
- `shader_manifest.json`: 전체 변환 결과, 경고, include, uniform 메타데이터

## 변환 규칙

| Godot | Epic7 Cocos2d-x |
|---|---|
| `fragment()` | `main()` |
| `UV`, `SCREEN_UV` | `v_texCoord` |
| `TIME` | `u_time` |
| `FRAGCOORD` | `gl_FragCoord` |
| `TEXTURE`, screen texture sampler | `u_texture` |
| `texture(TEXTURE, uv)` | backend별 `SAMPLE_TEXTURE(uv)` |
| `COLOR = value` | backend별 `OUTPUT_COLOR = value * v_fragmentColor` |
| `TEXTURE_PIXEL_SIZE` | `1.0 / u_resolution` |
| Godot uniform `value` | `u_value` |

생성된 `.frag`에는 Epic7 렌더러가 사용하는 두 경로가 함께 들어갑니다.

```glsl
#ifdef GLSL300ES
in vec4 v_fragmentColor;
in vec2 v_texCoord;
layout (location = 0) out vec4 FragColor;
#define SAMPLE_TEXTURE(UV_) texture(u_texture, UV_)
#define OUTPUT_COLOR FragColor
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
#define SAMPLE_TEXTURE(UV_) texture2D(u_texture, UV_)
#define OUTPUT_COLOR gl_FragColor
#endif
```

Godot의 uniform hint와 GLSL uniform 기본값은 Cocos 셰이더에 남기지 않습니다. Cocos에서 기본값이 보장되지 않으므로 `name.uniforms.lua`에 다음과 같은 초기화 코드로 분리됩니다.

```lua
pst:setUniformFloat( 'u_speed', 1.0 )
pst:setUniformVec4( 'u_tint', cc.vec4( 0.2, 0.7, 1.0, 1.0 ) )
pst:setUniformFloat( 'u_time', 0.0 ) -- 매 프레임 elapsed seconds로 갱신
pst:setUniformVec2( 'u_resolution', { x = width, y = height } )
```

## Epic7에 넣을 때

생성 파일은 Epic7 저장소에 자동으로 복사하거나 등록하지 않습니다. 검토한 `.frag`를 리소스의 `system/program_v4`에 넣고 `script/module/shader.lua`에 등록한 뒤, 호출부에서 생성된 Lua 템플릿을 참고해 모든 uniform을 설정합니다.

```lua
cc.GLProgramCache:getInstance():addGLProgramFromFile(
	'MY_SHADER',
	'system/program_v4/sprite_base.vert',
    'system/program_v4/my_shader.frag'
)
```

`u_resolution`에는 현재 `u_texture`의 픽셀 크기를 넣습니다. 화면 전체 효과라면 `LayerPostProcess`/`PPUtil`의 실제 render-target 크기이고, sprite 효과라면 원본 texture 크기입니다. `u_time`은 초 단위 경과 시간으로 매 프레임 갱신합니다.

## 지원 범위

지원:

- Godot 4 `shader_type canvas_item`
- fragment 함수
- 단일 행 uniform 선언과 `bool`, `int`, `float`, `vec2/3/4`, `sampler2D`
- 재귀 `#include` 확장
- screen texture를 현재 post-process 입력인 `u_texture`로 변환

자동 변환을 중단하고 오류를 표시하는 항목:

- `vertex()` 또는 `light()`
- normal/light 전용 Godot builtin
- legacy GLES에서 이식성이 없는 `textureLod`, `textureGrad`, `texelFetch`, derivative 함수
- 해석할 수 없는 uniform 선언

blend mode 같은 `render_mode`는 셰이더 코드만으로 동일하게 옮길 수 없습니다. `unshaded` 외 모드는 경고를 남기며 Cocos 노드/렌더 상태에서 별도로 맞춰야 합니다.

## 테스트

Godot 4.5.1에서 parser와 현재 CZN shader pack 22종 전체를 검사합니다.

```powershell
& 'D:\godot_exe\Godot_v4.5.1-stable_win64.exe' `
  --headless `
  --path 'C:\Users\kdhpa147\godot_pojects\shader-test' `
  --log-file '.godot\converter-test.log' `
  --script 'res://addons/shader_converter/tests/test_shader_converter.gd'
```

편집기 없이 전체 프로젝트를 변환할 수도 있습니다.

```powershell
& 'D:\godot_exe\Godot_v4.5.1-stable_win64.exe' `
  --headless `
  --path 'C:\Users\kdhpa147\godot_pojects\shader-test' `
  --log-file '.godot\converter-cli.log' `
  --script 'res://addons/shader_converter/convert_shaders_cli.gd' `
  -- --output='res://converted_epic7_shaders'
```
