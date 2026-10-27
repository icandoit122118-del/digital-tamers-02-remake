class_name GMFont
extends RefCounted
## GameMaker 스프라이트 폰트(UTMT ExportAllFonts 결과: PNG 아틀라스 + glyphs CSV) 렌더러.

var font_name := ""
var atlas: Texture2D
var glyphs := {}   # code -> {sx, sy, w, h, shift, off}
var line_height := 0


static func load_font(name: String) -> GMFont:
	var f := GMFont.new()
	var base := GM.ROOT + "fonts/"
	var csv := FileAccess.get_file_as_string("%sglyphs_%s.csv" % [base, name])
	var img := Image.load_from_file("%s%s.png" % [base, name])
	if csv.is_empty() or img == null:
		push_error("font load failed: " + name)
		return null
	f.atlas = ImageTexture.create_from_image(img)
	var lines := csv.split("\n", false)
	f.font_name = lines[0].split(";")[0].replace("\"", "")
	for i in range(1, lines.size()):
		var p := lines[i].strip_edges().split(";")
		if p.size() < 7:
			continue
		var h := int(p[4])
		f.glyphs[int(p[0])] = {"sx": int(p[1]), "sy": int(p[2]), "w": int(p[3]), "h": h, "shift": int(p[5]), "off": int(p[6])}
		f.line_height = maxi(f.line_height, h)
	return f


func text_width(line: String) -> int:
	var w := 0
	for ch in line:
		var gl = glyphs.get(ch.unicode_at(0))
		if gl != null:
			w += gl["shift"]
	return w


## halign: 0 left / 1 center / 2 right,  valign: 0 top / 1 middle / 2 bottom
func draw(ci: CanvasItem, pos: Vector2, text: String, color: Color, halign: int, valign: int) -> void:
	var lines := text.split("\n")
	var total_h := lines.size() * line_height
	var y := pos.y
	match valign:
		1: y -= total_h / 2.0
		2: y -= total_h
	for line in lines:
		var w := text_width(line)
		var x := pos.x
		match halign:
			1: x -= w / 2.0
			2: x -= w
		for ch in line:
			var gl = glyphs.get(ch.unicode_at(0))
			if gl == null:
				continue
			if gl["w"] > 0 and gl["h"] > 0:
				ci.draw_texture_rect_region(atlas,
					Rect2(floorf(x + gl["off"]), floorf(y), gl["w"], gl["h"]),
					Rect2(gl["sx"], gl["sy"], gl["w"], gl["h"]), color)
			x += gl["shift"]
		y += line_height
