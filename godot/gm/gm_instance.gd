class_name GMInstance
extends Node2D
## GameMaker 인스턴스 호환 베이스. Node2D 위치는 항상 (0,0)이고 좌표는 x/y(룸 좌표)로 직접 그린다.
## 가상 이벤트: create / step / draw / on_alarm(n) / mouse_enter / mouse_leave /
##              mouse_left_pressed / mouse_left_released / global_left_released

var obj_name := ""
var id := 0
var x := 0.0
var y := 0.0
var xstart := 0.0
var ystart := 0.0
var hspeed := 0.0
var vspeed := 0.0
var sprite_index := ""
var image_index := 0.0
var image_speed := 1.0
var image_alpha := 1.0
var image_blend := Color.WHITE
var image_xscale := 1.0
var image_yscale := 1.0
var image_angle := 0.0
var depth := 0
var persistent := false
var alarm: Array = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
var vars := {}              # 생성 코드가 설정하는 임의 변수
var dead := false
var _hover := false

# draw 상태 (draw_set_format 등)
var _font: GMFont = null
var _col := Color.WHITE
var _halign := 0
var _valign := 0
var _alpha := 1.0


# ---------- 가상 이벤트 ----------
func create() -> void: pass
func step() -> void: pass
func draw() -> void: draw_self()
func on_alarm(_n: int) -> void: pass
func mouse_enter() -> void: pass
func mouse_leave() -> void: pass
func mouse_left_pressed() -> void: pass
func mouse_left_released() -> void: pass
func global_left_released() -> void: pass


# ---------- 엔진 내부 ----------
func _gm_step() -> void:
	for i in alarm.size():
		if alarm[i] > 0:
			alarm[i] -= 1
			if alarm[i] == 0:
				alarm[i] = -1
				on_alarm(i)
				if dead:
					return
	step()
	if dead:
		return
	x += hspeed
	y += vspeed
	_advance_animation()
	queue_redraw()


func _advance_animation() -> void:
	if image_speed == 0.0 or sprite_index == "":
		return
	var s = GM.sprites.get(sprite_index)
	if s == null or s["frames"] <= 1:
		return
	var rate: float = s["playbackSpeed"] * image_speed
	if s["playbackType"] == "FramesPerSecond":
		rate /= GM.FPS
	image_index += rate


func _draw() -> void:
	if not visible or dead:
		return
	draw()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func instance_destroy() -> void:
	dead = true
	GM.instance_removed(self)


## 마스크(바운딩 박스)에 점이 들어오는지
func contains_point(p: Vector2) -> bool:
	var s = GM.sprites.get(sprite_index)
	if s == null:
		return false
	var b: Dictionary = s["bbox"]
	var ox: float = float(s["originX"])
	var oy: float = float(s["originY"])
	var x0: float = x + (float(b["l"]) - ox) * image_xscale
	var x1: float = x + (float(b["r"]) + 1.0 - ox) * image_xscale
	var y0: float = y + (float(b["t"]) - oy) * image_yscale
	var y1: float = y + (float(b["b"]) + 1.0 - oy) * image_yscale
	return p.x >= minf(x0, x1) and p.x < maxf(x0, x1) and p.y >= minf(y0, y1) and p.y < maxf(y0, y1)


# ---------- 그리기 헬퍼 (GM 함수 대응) ----------
func draw_self() -> void:
	draw_sprite_ext(sprite_index, int(floor(image_index)), x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha)


func draw_sprite(spr: String, frame: int, px: float, py: float) -> void:
	draw_sprite_ext(spr, frame, px, py, 1.0, 1.0, 0.0, Color.WHITE, 1.0)


func draw_sprite_ext(spr: String, frame: int, px: float, py: float, xs: float, ys: float, ang: float, blend: Color, alpha: float) -> void:
	if spr == "":
		return
	var s = GM.sprites.get(spr)
	if s == null:
		return
	var n: int = maxi(s["frames"], 1)
	var tex := GM.tex(spr, posmod(frame, n))
	if tex == null:
		return
	var lw: float = float(s.get("w", tex.get_width()))
	var lh: float = float(s.get("h", tex.get_height()))
	var ox: float = float(s.get("originX", 0.0))
	var oy: float = float(s.get("originY", 0.0))
	draw_set_transform(Vector2(px, py), deg_to_rad(-ang), Vector2(xs, ys))
	draw_texture_rect(tex, Rect2(-ox, -oy, lw, lh), false, Color(blend.r, blend.g, blend.b, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_sprite_stretched(spr: String, frame: int, px: float, py: float, w: float, h: float, blend: Color, alpha: float) -> void:
	var s = GM.sprites.get(spr)
	if s == null:
		return
	var tex := GM.tex(spr, posmod(frame, maxi(s["frames"], 1)))
	if tex != null:
		draw_texture_rect(tex, Rect2(px, py, w, h), false, Color(blend.r, blend.g, blend.b, alpha))


func draw_set_format(font_name: String, color: int, valign: int, halign: int) -> void:
	_font = GM.font(font_name)
	_col = GM.col(color)
	_valign = valign
	_halign = halign


func draw_set_color(color: int) -> void:
	_col = GM.col(color)


func draw_set_alpha(a: float) -> void:
	_alpha = a


func draw_text(px: float, py: float, text: String) -> void:
	if _font == null:
		return
	_font.draw(self, Vector2(px, py), text.replace("#", "\n"), Color(_col.r, _col.g, _col.b, _alpha), _halign, _valign)


func draw_text_shadow(px: float, py: float, text: String, color: Variant, shadow: int) -> void:
	if _font == null:
		return
	var t := text.replace("#", "\n")
	var main: Color = color if color is Color else GM.col(int(color))
	_font.draw(self, Vector2(px + 1, py + 1), t, Color(GM.col(shadow), _alpha), _halign, _valign)
	_font.draw(self, Vector2(px, py), t, Color(main, _alpha), _halign, _valign)


func draw_rectangle(x1: float, y1: float, x2: float, y2: float, outline: bool = false) -> void:
	var r := Rect2(minf(x1, x2), minf(y1, y2), absf(x2 - x1), absf(y2 - y1))
	var c := Color(_col.r, _col.g, _col.b, _alpha)
	if outline:
		draw_rect(r, c, false)
	else:
		draw_rect(r, c, true)
