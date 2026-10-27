# Digital Tamers 02 — Remastered Mobile UI Design System (`DESIGN.md`)

## 1. D1 Visual Direction & Hallmark Picks (`hallmark` + `hallmark-apps`)

- **Target & Renderer**: Godot 4.7.2 Native (`Control` + `StyleBoxFlat` on a 1076×600 high-DPI UI `CanvasLayer` over a 2× nearest-neighbor 538×300 pixel-art world).
- **Concept (Signature)**: **"D-Terminal OS"** — an authentic handheld Digivice tactical HUD that frames the pixel-art sanctuary without obscuring it. Crisp high-DPI vector HUD chrome + original pixel-art Digimon icons (`spr_Icons`, `spr_EvoStage`, `spr_Attribute`).
- **Palette Tokens (Dark Tactical Telemetry — WCAG AA/AAA verified)**:
  - `surface_base`: `#0B1118` (92% alpha HUD bar) — deep obsidian slate
  - `surface_elevated`: `#131D28` — panel & dock slot fill
  - `surface_interactive`: `#1B2938` — hover / active slot surface
  - `border_subtle`: `#26384D` (1px structural hairlines)
  - `ink_primary`: `#F0F6FC` (Contrast 16.4:1 on base)
  - `ink_secondary`: `#9BB0C7` (Contrast 7.8:1 on base — tinted cool slate, never neutral gray)
  - `ink_muted`: `#647D96` (Contrast 4.6:1 on base)
  - `accent_primary`: `#00E5B0` (Digivice Cyber Mint — primary CTA, active selection, XP/Energy fill)
  - `accent_battle`: `#FF6B4A` (Tactical Amber-Coral — Battle CTA & HP alert)
  - `accent_gold`: `#F5C451` (Bits currency & Level badge)
  - `focus_ring`: `#38BDF8` (2px instant `:focus-visible` outline)
- **Typography & Hierarchy**:
  - Single clean geometric UI face with strict size steps (`22px` title / `15px` section & primary button / `13px` body & HUD stat / `11px` sentence-case label; no ALL-CAPS tracked eyebrows).
  - Tabular numerals for Level, HP, Energy, Bits, and timers.
- **Layout & Density (`hallmark-apps` / `ui-ux-pro-max`)**:
  - Minimum touch target `48×48px` (exceeds 44×44px mobile minimum) with `8px` gap between dock buttons.
  - Safe-area margins (`16px` horizontal, `12px` vertical) so notch/rounded mobile corners never clip controls.
  - Four explicit data states supported on HUD & lists: `Normal (Demo)`, `Worst-case` (long name/huge numbers), `Empty` (no partner/0 bits), and `Toast Feedback`.
- **Motion Budget (`emil-design-eng` + `animate` + `apple-design`)**:
  - **Pointer-down response**: buttons scale to `0.96` immediately on press (`100ms` strong ease-out `cubic-bezier(0.23, 1, 0.32, 1)`), never waiting for release.
  - **Interruptible critically-damped springs**: panel/drawer transitions animate `position`/`modulate:a`/`scale` from current presentation value (never `scale(0)`, starts from `0.95`).
  - **Reduced Motion**: `GM.g["reducedMotion"]` toggle disables spring/slide motion and switches to instant opacity state changes.

---

## 2. Design & Motion Stack Results Table (`D0`–`D5`)

| 단계 | 스킬 | 결과 (적용 / 해당 없음: 이유) | 적용한 것 | 충돌 기록 |
|---|---|---|---|---|
| D0 | 참고 자료 | 적용 (기존 추출 에셋 활용) | 원작 APK에서 추출한 디지몬 아이콘(`spr_Icons`), 속성 배지, 배경(`bg_Tech01`)을 실제 재료로 사용 | 없음 |
| D1 | `hallmark` + `hallmark-apps` | 적용 | `DESIGN.md` 토큰 확정, App screens 밀도·상태 규칙, 네이티브 Godot `Theme`/`StyleBoxFlat` 변환, 포커스 링 및 문장형 라벨 적용 | 웹 전용 `sloplint.mjs`는 `hallmark-apps` 지침에 따라 네이티브 Godot 런타임 검증으로 대체 |
| D2 | `ui-ux-pro-max` | 적용 | 모바일 터치 타겟 ≥48px, 8px 간격, 하단 독 6개 이하 집중, 대비 ≥4.5:1 검증 | `--design-system`은 D1 후보 참고만 하고 `DESIGN.md` 단일 기록 유지 |
| D2 | `frontend-design` | 적용 | AI 클리셰(보라색 그라데이션, 대문자 자간 아이브로우, `01/02` 번호 장식) 배제, 디지바이스 단말기 콘셉트 집중 | 없음 |
| D2 | `design-taste-frontend` | 적용 (원칙만) | 장식용 빈 카드·의미 없는 스파크라인 배제, 실제 파트너 디지몬 데이터와 월드 뷰포트가 화면의 중심을 차지하도록 구성 | 브라우저 전용 `inspect.mjs`는 Godot 네이티브 앱이므로 미실행(플랫폼 우선순위 2번) |
| D3 | `emil-design-eng` | 적용 | 포인터 다운 시 즉각 `scale(0.96)` 피드백, `scale(0)` 금지(`0.95`에서 시작), 키보드/고빈도 동작 무애니메이션 | 없음 |
| D3 | `animate` | 적용 | 진입/퇴장 `ease-out`(`cubic-bezier(0.23,1,0.32,1)` 동등 커브), `scale`·`position`·`modulate`만 애니메이션, `reducedMotion` 분기 | 없음 |
| D3 | `animation-performance` | 적용 | 레이아웃 재계산 없이 `pivot_offset` 기반 `scale` 및 `CanvasItem.modulate`만 프레임 예산 내 갱신 | 없음 |
| D3 | `mobile-native` | 적용 | 터치 스티키 호버 방지(포인터 다운/릴리즈 분리), 노치 안전 영역 패딩(16px/12px), 버튼 텍스트 선택 방지 | 웹 메타태그는 Godot 네이티브 뷰포트 설정으로 번역 |
| D3 | `animate-expo` | 해당 없음: React Native/Expo 프로젝트 아님 | — | — |
| D3 | `apple-design` | 적용 | 도중 입력으로 언제든 방향 전환 가능한 감쇠비 1.0 스프링(`_spring_step`) 및 즉각적인 프레스 응답 | `design-taste-frontend`의 반투명 금지와 충돌 → 플랫폼/게임 HUD 관례(우선순위 2)에 따라 반투명 다크 슬레이트(`92%`) 채택 |
| D3 | `break-ui` | 적용 | 상단 유틸리티 바에 `Demo / Worst / Empty` 실시간 데이터 토글 내장(긴 디지몬 이름, 999,999,999 BIT, Lv.999, 빈 파트너 상태 검증) | 없음 |
| D4 | `impeccable` (`craft-floor`) | 적용 | 문서 지침 모드로 `craft-floor.md` 대조(대비, 그림자 오프셋, 상태, 포커스, 모션 절제) 후 Godot 렌더 캡처로 시각 검수 | 런처 바이너리는 정책에 따라 미설치·미실행 |
| D4 | `improve-animations` | 적용 | 구축된 UI 모션의 목적·빈도·커브·감속 모드 자체 점검 반영 | 없음 |
| D5 | `remotion-best-practices` / `hyperframes` | 해당 없음: 영상 산출물 요청 없음 | — | — |
