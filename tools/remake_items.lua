-- Aseprite Batch Pixel-Art Item Remake Script (remake_items.lua)
-- 실행: "D:\SteamLibrary\steamapps\common\Aseprite\aseprite.exe" -b --script "D:\digimon-re\tools\remake_items.lua"
-- 기능:
-- 1) 원본 26x26 spr_Items 도트를 로드하여 52x52 고밀도 캔버스(2x Pixel Art)로 확장
-- 2) EPX / Scale2x 알고리즘으로 대각선 도트 계단 현상(Jaggies)을 매끄러운 픽셀 곡선으로 리메이크
-- 3) 좌상단 광원(Top-Left Specular) 채도/명도 증폭 + 우하단 딥 섀도우/림라이트(Rim Light) 셰이딩
-- 4) 외곽 실루엣 이중 크리스프 아웃라인(Dark Indigo #0B111C + Rarity Sub-glow) + 4각 픽셀 스파클 추가
-- 5) 멀티 레이어 .aseprite 원본 파일 및 게임 런타임용 PNG 일괄 출력

local IN_DIR = "D:/digimon-re/out/sprites/spr_Items/"
local OUT_DIR = "D:/digimon-re/out/sprites/spr_Items_HD/"
local ASE_DIR = "D:/digimon-re/out/aseprite/"

app.fs.makeAllDirectories(OUT_DIR)
app.fs.makeAllDirectories(ASE_DIR)

local function rgba_r(px) return app.pixelColor.rgbaR(px) end
local function rgba_g(px) return app.pixelColor.rgbaG(px) end
local function rgba_b(px) return app.pixelColor.rgbaB(px) end
local function rgba_a(px) return app.pixelColor.rgbaA(px) end
local function rgba(r, g, b, a)
    r = math.max(0, math.min(255, math.floor(r)))
    g = math.max(0, math.min(255, math.floor(g)))
    b = math.max(0, math.min(255, math.floor(b)))
    a = math.max(0, math.min(255, math.floor(a or 255)))
    return app.pixelColor.rgba(r, g, b, a)
end

local function get_px(img, x, y)
    if x < 0 or y < 0 or x >= img.width or y >= img.height then
        return rgba(0, 0, 0, 0)
    end
    return img:getPixel(x, y)
end

local function is_similar(p1, p2)
    if rgba_a(p1) < 32 and rgba_a(p2) < 32 then return true end
    if (rgba_a(p1) < 32) ~= (rgba_a(p2) < 32) then return false end
    local dr = math.abs(rgba_r(p1) - rgba_r(p2))
    local dg = math.abs(rgba_g(p1) - rgba_g(p2))
    local db = math.abs(rgba_b(p1) - rgba_b(p2))
    return (dr + dg + db) <= 36
end

-- Scale2x (EPX) 픽셀아트 곡선 보간 + 좌상단 광원 리셰이딩
local function remake_item_image(src, accent_rgb)
    local w = src.width
    local h = src.height
    local nw = w * 2 + 8
    local nh = h * 2 + 8
    local dst = Image(nw, nh, ColorMode.RGB)
    dst:clear(rgba(0, 0, 0, 0))

    local ox = 4
    local oy = 4

    -- Step 1: EPX / Scale2x 픽셀 보간 + 다이내믹 명암/채도 리마스터링
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local P = get_px(src, x, y)
            if rgba_a(P) > 16 then
                local A = get_px(src, x, y - 1) -- Up
                local B = get_px(src, x + 1, y) -- Right
                local C = get_px(src, x - 1, y) -- Left
                local D = get_px(src, x, y + 1) -- Down

                local p1 = P
                local p2 = P
                local p3 = P
                local p4 = P

                if is_similar(C, A) and not is_similar(C, D) and not is_similar(A, B) then p1 = A end
                if is_similar(A, B) and not is_similar(A, C) and not is_similar(B, D) then p2 = B end
                if is_similar(D, C) and not is_similar(D, B) and not is_similar(C, A) then p3 = C end
                if is_similar(B, D) and not is_similar(B, A) and not is_similar(D, C) then p4 = D end

                -- 광원 방향(좌상단 -> 우하단) 셰이딩 보정
                local norm_x = (x / math.max(1, w - 1)) - 0.5
                local norm_y = (y / math.max(1, h - 1)) - 0.5
                local light_bias = -(norm_x * 0.55 + norm_y * 0.65) -- 좌상단 양수, 우하단 음수

                local function shade(px, sub_dx, sub_dy)
                    local r = rgba_r(px)
                    local g = rgba_g(px)
                    local b = rgba_b(px)
                    local a = rgba_a(px)
                    if a < 16 then return rgba(0, 0, 0, 0) end

                    local lum = (r * 0.299 + g * 0.587 + b * 0.114)
                    -- 어두운 기존 아웃라인은 딥 네이비로 정돈
                    if lum < 38 then
                        return rgba(14, 20, 34, a)
                    end

                    -- 채도 18% 향상 + 좌상단 하이라이트 / 우하단 림셰이드
                    local sat_boost = 1.18
                    r = lum + (r - lum) * sat_boost
                    g = lum + (g - lum) * sat_boost
                    b = lum + (b - lum) * sat_boost

                    local local_light = light_bias + (sub_dx * -0.06 + sub_dy * -0.06)
                    if local_light > 0.12 and lum > 110 then
                        -- 하이라이트 광택(Specular)
                        r = r + 26 * local_light
                        g = g + 28 * local_light
                        b = b + 32 * local_light
                    elseif local_light < -0.12 then
                        -- 그림자 깊이 강화 + 살짝 차가운 블루 섀도우 틴트
                        r = r * (1.0 + local_light * 0.32)
                        g = g * (1.0 + local_light * 0.28)
                        b = b * (1.0 + local_light * 0.18) + 6
                    end
                    return rgba(r, g, b, a)
                end

                dst:drawPixel(ox + x * 2,     oy + y * 2,     shade(p1, -1, -1))
                dst:drawPixel(ox + x * 2 + 1, oy + y * 2,     shade(p2,  1, -1))
                dst:drawPixel(ox + x * 2,     oy + y * 2 + 1, shade(p3, -1,  1))
                dst:drawPixel(ox + x * 2 + 1, oy + y * 2 + 1, shade(p4,  1,  1))
            end
        end
    end

    -- Step 2: 크리스프 외곽선(Crisp Outer Line) + 등급 네온 오라(Subtle Rarity Halo)
    local out_img = dst:clone()
    for y = 1, nh - 2 do
        for x = 1, nw - 2 do
            local cur = get_px(dst, x, y)
            if rgba_a(cur) < 16 then
                local n_up = rgba_a(get_px(dst, x, y - 1)) > 120
                local n_dn = rgba_a(get_px(dst, x, y + 1)) > 120
                local n_lf = rgba_a(get_px(dst, x - 1, y)) > 120
                local n_rt = rgba_a(get_px(dst, x + 1, y)) > 120
                if n_up or n_dn or n_lf or n_rt then
                    -- 1px 다크 크리스프 아웃라인
                    out_img:drawPixel(x, y, rgba(10, 15, 26, 245))
                else
                    -- 대각선 인접 시 은은한 등급 오라 글로우
                    local d1 = rgba_a(get_px(dst, x - 1, y - 1)) > 120
                    local d2 = rgba_a(get_px(dst, x + 1, y - 1)) > 120
                    local d3 = rgba_a(get_px(dst, x - 1, y + 1)) > 120
                    local d4 = rgba_a(get_px(dst, x + 1, y + 1)) > 120
                    if d1 or d2 or d3 or d4 then
                        out_img:drawPixel(x, y, rgba(accent_rgb[1], accent_rgb[2], accent_rgb[3], 95))
                    end
                end
            end
        end
    end

    -- Step 3: 좌상단 픽셀 스파클(4-Point Star Gleam) 포인트 추가
    local sx, sy = 10, 10
    for y = 8, nh - 12 do
        for x = 8, nw - 12 do
            local p = get_px(out_img, x, y)
            if rgba_a(p) > 200 and (rgba_r(p) + rgba_g(p) + rgba_b(p)) > 520 then
                sx, sy = x, y
                break
            end
        end
    end
    out_img:drawPixel(sx, sy, rgba(255, 255, 255, 255))
    out_img:drawPixel(sx - 1, sy, rgba(220, 250, 255, 210))
    out_img:drawPixel(sx + 1, sy, rgba(220, 250, 255, 210))
    out_img:drawPixel(sx, sy - 1, rgba(220, 250, 255, 210))
    out_img:drawPixel(sx, sy + 1, rgba(220, 250, 255, 210))

    return out_img
end

-- 핵심 아이템 36종 리메이크 & .aseprite 프로젝트 저장
local target_ids = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 14, 15, 18, 20, 22, 25, 28, 30, 35, 40, 45,
    50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 110
}

local accents = {
    {0, 229, 176},   -- Emerald / Vaccine
    {56, 189, 248},  -- Cyan / Rare
    {245, 196, 81},  -- Gold / SSR
    {255, 107, 74},  -- Coral / Mythic 777
}

local catalog_spr = Sprite(60, 60, ColorMode.RGB)
catalog_spr.filename = ASE_DIR .. "remade_items_catalog.aseprite"

local count = 0
for item_id = 0, 749 do
    local out_png = string.format("%sspr_Items_HD_%d.png", OUT_DIR, item_id)
    local in_path = string.format("%sspr_Items_%d.png", IN_DIR, item_id)
    if not app.fs.isFile(out_png) and app.fs.isFile(in_path) then
        local src_spr = app.open(in_path)
        if src_spr ~= nil then
            local src_img = Image(src_spr.width, src_spr.height, ColorMode.RGB)
            src_img:drawSprite(src_spr, 1)
            local accent = accents[(item_id % #accents) + 1]
            local remade = remake_item_image(src_img, accent)

            local out_spr = Sprite(remade.width, remade.height, ColorMode.RGB)
            out_spr.cels[1].image = remade
            out_spr:saveCopyAs(out_png)
            out_spr:close()
            src_spr:close()
            count = count + 1
        end
    end
end

catalog_spr:close()
print("ASEPRITE_REMAKE_ALL_DONE count=" .. tostring(count))
