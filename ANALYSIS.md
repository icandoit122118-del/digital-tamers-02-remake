# Digital Tamers 02 — 역분석 요약 (Godot 이식 준비)

- 원본: `디지몬 개발중.apk` (`com.DragonRodGames.DigitalTamers02x64` v2.0.2, GameMaker, 바이트코드 17)
- 디컴파일 도구: UndertaleModTool CLI 0.9.2.0 (`tools/cli`, 로컬 전용)
- 산출물: `out/code/` — GML 6,463개 (17.1MB). `game.droid`는 원본 복사본이라 저장소에 올리지 않음

## 데이터 규모 (`parse_droid.py`)
| 항목 | 개수 |
|---|---|
| 스프라이트 | 10,890 |
| 오브젝트 | 759 |
| 룸 | 101 |
| 코드 엔트리 (디컴파일) | 6,463 (헤더 기준 7,008) |
| 전역 스크립트 | 4,265 (헤더 기준) |
| 사운드 / 오디오 | 564 / 538 (약 412MB) |
| 텍스처 페이지 | 569 (약 153MB) |
| 폰트 / 타임라인 | 6 / 3 |

## 코드 구성 (6,463개)
| 종류 | 개수 |
|---|---|
| Create | 3,595 |
| Mouse | 518 |
| Step | 466 |
| Alarm | 368 |
| RoomCC | 301 |
| Draw | 251 |
| Collision | 185 |
| Other | 123 |
| Timeline | 80 |

가장 큰 파일: `obj_Digi_Step_0` (1.0MB), `obj_EvoCards_Step_0` (0.9MB), `Digi_Battle_*` / `Enemy_Battle_*` (100단위 묶음 × 8, 각 0.3~0.56MB), `obj_Bios_Step_0`, `NPC_Step_Dialogue`.

## 게임 구조 관찰
- **장르**: 오프라인 싱글 RPG — 디지몬 육성, 배틀, 진화 카드, 퀘스트 NPC, 던전, 제작(Crafting), 헌트, 보스전(Agumon, Garurumon, Guilmon, Gaia 등).
- **네트워크**: 없음. `network_*`·`http_*`·`steam_*` 사용 0건.
- **저장**: `json_encode` → `buffer_save` (`SaveGame`, `scr_SaveDECO`, `scr_SaveMusic`), 점수는 `scores.ini`.
- **입력**: 마우스 이벤트 중심(`device_mouse`, Mouse 518개). 가상 키보드/제스처 API 미사용 → 터치 이식 시 마우스→터치 매핑으로 충분.
- **해상도**: `surface_resize(application_surface, 538, 300)` (≈16:9 저해상도 픽셀 기반).
- **언어**: 스크립트 접두사 `PTBR_`(9), `ING_`(8) → 포르투갈어/영어 텍스트 분리.
- **오브젝트 접두사 상위**: SPAWN(25), Hunt(13), Adv(12), Enemy(12), Player(11), Training(10), Leader(9), CityWall(9), Digi(9).

## 아직 추출하지 않은 것
- 스프라이트/텍스처/오디오 에셋 (`ExportAllSprites.csx`, `ExportAllTextures.csx`, `ExportAllSounds.csx`)
- 룸 레이아웃(인스턴스 배치), 오브젝트-스프라이트 매핑, 문자열 39,882개

## Godot 이식 시 주의
- `obj_Digi_Step_0.gml`(1MB), `obj_EvoCards_Step_0.gml`(0.9MB)은 한 파일에 로직이 뭉쳐 있어 수동 분해가 필요하다.
- 배틀 스크립트 16개(Digi/Enemy × 8)는 데이터형(스탯 테이블)에 가까워 자동 변환 후보다.
- GML→GDScript 완전 자동 변환은 불가. 데이터(스탯·퀘스트·대사)는 JSON/Resource로 변환하고, 로직은 시스템 단위로 재작성한다.

## 추출 결과 (D:\digimon-re\out, 2026-10-27)
| 항목 | 결과 |
|---|---|
| 스프라이트 | 10,890개 폴더 / PNG 71,278장 / 320MB (`out/sprites`, 마스크 `*_mask` 포함) |
| 사운드 | 548개 (OGG 275, WAV 273) / 393MB (`out/sounds`) |
| 문자열 | `out/strings.json` 2.3MB |
| 코드 | `out/code` GML 6,463개 |

## Godot 4 작업 가능성 판정: 가능 (에셋 직접 사용, 로직은 수동 재작성)
- **에셋**: PNG/OGG/WAV는 Godot이 그대로 임포트한다. 프레임 폴더는 `SpriteFrames`로 일괄 변환 가능.
- **코드 의존성 (GML 파일 수)**: `instance_create` 783, `with` 741, `audio_play` 528, `draw_text` 109, `room_goto` 11, `ds_map` 7, `json_` 5, `surface_` 3, `buffer_` 2.
- **없음**: 셰이더, `ds_grid`, `script_execute`, `variable_instance_*`, `file_text_*` → 자동 변환 장애물 없음.
- **부담**: `with`/`instance_create` 중심의 인스턴스 모델 → Godot 노드/씬 구조로 재설계 필요. 이식 분량이 크다(오브젝트 759, 룸 101).

## 아직 없는 데이터
- 스프라이트 원점(origin)/충돌 마스크 범위, 룸 인스턴스 배치, 오브젝트-스프라이트 매핑 (커스텀 csx 필요)
- Godot 미설치

## Godot 4.7.2 실측 검증 (2026-10-27) — 통과
- 설치: `D:\tools\godot\Godot_v4.7.2-stable_win64(.exe/_console.exe)`
- 추가 추출 (`out/data/`, 스크립트 `tools/ExportGameData.csx`): 스프라이트 원점·bbox·프레임수, 오브젝트→스프라이트 매핑(699/759), 룸 101개(인스턴스 7,164개, 레이어, 배경, 뷰), 타일셋 2개.
- 사운드: `ag_music.dat` + APK 외부 ogg 17개를 `game.droid` 옆에 두고 재추출 → 564개 전부 정상(빈 파일 0). 이전 추출은 외부 오디오 10개가 44바이트 빈 WAV였음.
- 룸 로더(`godot/room_loader.gd`): JSON만으로 룸을 재구성. `room_Training`, `room_Agumon_House`, `room_Tamer_Info` 렌더링 성공 — 원점/스케일/반전/레이어 깊이/타일 배경/배경색 일치 (`out/shots/*.png`).
- 임포트: OGG 3 / WAV 3 / PNG 1 샘플을 `--import`로 변환 성공.
- 남은 한계: 타일 레이어는 6개 룸만 사용(미구현), 오브젝트 로직(GML 6,463개)은 미이식, 오디오 루프/그룹 설정은 별도 확인 필요.

## UI 룸 메뉴 이식 완료 (2026-10-27)
- **런타임 계층 (`godot/gm/`)**:
  - `gm.gd` (Autoload `GM`): 룸 전환(`room_goto` / `room_transition`), 인스턴스 생성·제거·생명주기(`create`/`step`/`on_alarm`/`draw`), 마우스 이벤트(bbox 기반 `mouse_enter`/`leave`/`left_pressed`/`left_released`/`global_left_released`), OGG/WAV 오디오 스트리밍(`play_music`/`play_sound_fx`), 인스턴스·룸 생성 코드 인터프리터.
  - `gm_font.gd`: 추출된 6개 비트맵 폰트(`fnt_Text`, `fnt_MidText` 등 PNG + CSV 글리프 테이블) 렌더러 및 그림자/정렬 지원.
  - `gm_background.gd`: 타일링 배경 및 `__background_set` 스크롤 속도 구현.
  - `gm_instance.gd`: GameMaker 인스턴스 호환 베이스 클래스.
- **이식 완료 오브젝트 (`godot/gm/objects/`)**:
  - `obj_Transition.gd`: 룸 전환 트랜지션 0~8번 연출.
  - `obj_Game_Title.gd`: 타이틀 페이드인, 상단 슬라이드, `Tap to Continue...` 점멸, 탭 시 메뉴 버튼(`NEW GAME`/`CONTINUE`/`Settings`) 동적 생성.
  - `obj_MainMenu_Buttons.gd`: 메인 메뉴 버튼 호버/클릭 하이라이트 및 룸 전환.
  - `obj_Room_Label.gd`: 룸별 상단 배너 및 다국어(`ENG`/`PT-BR`) 스프라이트 자동 전환.
  - `obj_OptionBut01.gd` / `obj_Options_But02.gd`: 설정 화면 항목 표시, 언어(`ENG`↔`PT-BR`) 및 사운드(`Music`/`Sound Effects`/`Digimon Voices`) On/Off 스위치 토글.
  - `obj_Back_Button.gd`: 이전 룸 복귀 버튼.
  - `obj_Intro_Connect.gd`: 신규 게임 진입 연결 연출.
- **실측 검증**: `out/shots/01_mainmenu_tap.png` ~ `05_back_to_mainmenu.png` 5단계 자동 시나리오 통과.

## D-Terminal OS 모바일 UI/UX 전면 리디자인 (2026-10-27)
- **설계 명세**: `DESIGN.md` (D0~D5 `design-motion-stack` 결과표 및 D1 Picks 수록)
- **해상도 아키텍처**:
  - 월드/배경(`GM.bg`, `GM.world`): 538×300 원본 픽셀아트를 `2.0x` 정수배(`TEXTURE_FILTER_NEAREST`)로 렌더링하여 도트 선명도 유지.
  - UI 레이어(`GM.ui` / `TamerUI`): 1076×600 고해상도 Godot `Control` 벡터 카드·타이포그래피·프로그레스 바 렌더링.
- **신규 구현 (`godot/gm/ui/tamer_ui.gd`, `godot/gm/objects/obj_Digi.gd`)**:
  - `room_MainMenu`: 좌측 D-Terminal 커맨드 데크(Enter Sanctuary / Start New Story / System Settings) + 우측 실시간 파트너 쇼케이스(`d5_idle` 그레이몬 / `d152_idle` 블랙워그레이몬 / `spr_egg01` 디지타마) 및 데이터 픽스처 전환기.
  - `room_options_MainMenu`: 언어(`ENG` ↔ `PT-BR`), 배경음, 효과음, 디지몬 보이스, 접근성 모션 감소(`Reduced motion`) 토글 및 세이브 데이터 관리 카드.
  - `room_MainRoom` (생추어리 HUD): 상단 파트너 텔레메트리 카드(아이콘, 이름·레벨, HP/EN/XP 게이지), 우측 상단 유틸리티 바(BIT 재화, 1x/2x 줌, 세이브, 타이틀 복귀, `Demo / Worst / Empty` 토글), 하단 6슬롯 엄지 커맨드 독(Digivice, Care & Items, Training, Digivolve, Database, Battle Arena).
  - `room_SelectTraining`: 6대 전술 훈련 모듈 그리드 카드 + 우측 파트너 6대 스탯 텔레메트리 분석 카드.
- **실측 스크린샷 검증 (`out/shots/ui_01_*.png` ~ `ui_09_*.png`)**:
  - `ui_01_mainmenu.png`, `ui_02_options_ptbr.png`, `ui_03_sanctuary_demo.png`, `ui_04_sanctuary_worst.png` (40자 이름·Lv.999·999,999,999 BIT 스트레스 테스트 통과), `ui_05_sanctuary_empty.png` (초기 디지타마 상태 통과), `ui_06_subroom_nav.png` (능력치 × 운빨 잭팟 훈련소 통과).
  - `ui_07_aseprite_items.png`: Steam `Aseprite 1.3.18.6-x64`(`tools/remake_items.lua`) 배치 파이프라인으로 원본 26×26 아이템 36종을 60×60 고밀도 EPX 보간·상단 광원(Specular)·다크 아웃라인·희귀도 오라·스파클로 리메이크(`out/sprites/spr_Items_HD/`, `out/aseprite/item_*_remake.aseprite`) 및 운빨 옵션 재감정 UI 검증 완료.
  - `ui_08_autochess_battle_mid.png` & `ui_09_autochess_battle_result.png`: 1:1 단판 오토체스형 자율 기동·점프 회피(`jump` + 중력 물리)·가드 패링(`block`)·자동 스킬(`atk01`/`atk02`/`atkSP`) AI 및 능력치 기반 × D100 운빨 배율(`0.5x ~ 7.77x 잭팟`) 승패 시스템(`obj_Digi_Battle.gd`, `obj_Enemy_Battle.gd`) 검증 완료.

## 전체 게임 데이터베이스 & 코어 루프 완전 이식 (2026-10-27)
- **전체 데이터베이스 추출 (`tools/extract_full_db.py` → `out/data/full_db.json`)**:
  - **디지몬 도감 & 스탯**: 663종 전체 디지몬(`gml_Object_obj_Bios_Step_0.gml` + `Digi_HUNT_*.gml` — ID, 이름, 단계, 속성, 원소, 기본 스탯, 영문 도감 설명)
  - **진화 트리**: 436개 진화 루트(`gml_Object_obj_EvoCards_Step_0.gml` — 분기별 조건 및 보너스 스탯)
  - **아이템 DB**: 748종 전체 아이템(`ENG_Items_ID.gml` + `PTBR_Items_ID.gml` 다국어 이름·가격·설명)
  - **캠페인 퀘스트 DB**: 78개 전체 퀘스트(`ING_Questlog_Info.gml` + `PTBR_Questlog_Info.gml` 다국어 제목·NPC·설명·힌트)
- **Aseprite 1.3.18.6 전체 아이템 리마스터링 완료 (`out/sprites/spr_Items_HD/`)**:
  - `spr_Items_0.png` ~ `spr_Items_749.png` 총 **750개 전체 아이템 프레임**을 `tools/remake_items.lua`로 일괄 60×60 EPX 곡선 보간 + 광원/외곽선/오라/스파클 리메이크 완료.
- **전체 코어 게임플레이 화면 통합 (`godot/gm/ui/tamer_ui.gd`, `godot/gm/gm.gd`)**:
  - `full_01_digivice_quests.png` (`room_DigiVice`): 78개 캠페인 퀘스트 로그 및 `user://tamer_save_v2.json` 영구 세이브/로드.
  - `full_02_digivolve_tree.png` (`room_Evo_Select`): 436개 진화 루트 실시간 연동 및 파트너 즉시 진화 / 777 돌연변이 도박 진화.
  - `full_03_database_663.png` (`room_Database`): 663종 전체 디지몬 바이오 도감 열람, 파트너 즉시 링크 및 1v1 스파링 출격.
  - `full_04_world_expedition.png` (`room_Select_Map`): 디지털 월드 9대 원정 사냥터 & 보스 1v1 오토체스 출격 데크.
  - `full_05_evolved_battle.png` (`room_Battle`): 진화한 메탈그레이몬(#85) vs 워그레이몬(#151) 실시간 공중 점프 강습 & 점프 회피 오토체스 교전 검증.
