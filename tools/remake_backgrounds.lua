-- Aseprite Batch Background & Sanctuary Layer Remaster Script (remake_backgrounds.lua)
-- 실행: "D:\SteamLibrary\steamapps\common\Aseprite\aseprite.exe" -b --script "D:\digimon-re\tools\remake_backgrounds.lua"
-- 기능:
-- 1) 원본 538x300 전투 배경(bg_Btl_*), 거점 배경(BG_*), 데코 레이어(spr_Floor_Deco, spr_DecoLayer01/02)를 Aseprite로 로드
-- 2) 대기 원근감(Atmospheric Depth), 채도/명암비(Contrast Curve), 지면 분리 하이라이트(Rim Ground Line) 리마스터링
-- 3) out/sprites/bg_HD/<name>_<frame>.png 로 저장해 GM.tex()에서 HD 배경으로 즉시 로드 가능하게 처리

local SPR_DIR = "D:/digimon-re/out/sprites/"
local OUT_DIR = "D:/digimon-re/out/sprites/bg_HD/"
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

local function remaster_bg_image(src, is_battle_bg)
    local w = src.width
    local h = src.height
    local dst = Image(w, h, ColorMode.RGB)
    dst:clear(rgba(0, 0, 0, 0))

    for y = 0, h - 1 do
        local ny = y / math.max(1, h - 1)
        -- 상단 하늘/천장은 청량한 깊이감, 지면(y=215..230) 근처는 선명도 및 따뜻한 발광 보강
        local sky_factor = math.max(0.0, 1.0 - ny * 1.6)
        local ground_rim = 0.0
        if is_battle_bg and y >= 214 and y <= 224 then
            ground_rim = 1.0 - math.abs(y - 219) / 6.0
        end

        for x = 0, w - 1 do
            local px = src:getPixel(x, y)
            local a = rgba_a(px)
            if a > 0 then
                local r = rgba_r(px)
                local g = rgba_g(px)
                local b = rgba_b(px)

                local lum = r * 0.299 + g * 0.587 + b * 0.114
                -- S-Curve 대비 강화 + 채도 22% 부스트
                local norm_l = lum / 255.0
                local curved_l = norm_l * norm_l * (3.0 - 2.0 * norm_l)
                local new_lum = (norm_l * 0.45 + curved_l * 0.55) * 255.0

                local sat = 1.22
                r = new_lum + (r - lum) * sat
                g = new_lum + (g - lum) * sat
                b = new_lum + (b - lum) * sat

                -- 대기 원근 보정
                if sky_factor > 0.0 and lum > 35 then
                    r = r + sky_factor * 4
                    g = g + sky_factor * 8
                    b = b + sky_factor * 14
                end

                -- 전투 스테이지 지면 라인 크리스프 하이라이트
                if ground_rim > 0.0 and lum > 45 then
                    r = r + ground_rim * 16
                    g = g + ground_rim * 18
                    b = b + ground_rim * 14
                end

                dst:drawPixel(x, y, rgba(r, g, b, a))
            end
        end
    end
    return dst
end

local targets = {
    {name = "bg_Btl_Village_Beginnings", frames = {0}, battle = true},
    {name = "bg_Btl_Dina_Plains", frames = {0}, battle = true},
    {name = "bg_Btl_Boot_Jungle", frames = {0}, battle = true},
    {name = "bg_Btl_Chrome_Mines", frames = {0}, battle = true},
    {name = "bg_Btl_ServerCity_Ruins", frames = {0}, battle = true},
    {name = "bg_Btl_Magma_Mountain", frames = {0}, battle = true},
    {name = "bg_Btl_Dark_Area", frames = {0}, battle = true},
    {name = "bg_Btl_Net_Ocean", frames = {0}, battle = true},
    {name = "bg_Btl_Snow_Land", frames = {0}, battle = true},
    {name = "bg_Btl_Mecha_Plant", frames = {0}, battle = true},
    {name = "bg_Btl_Sizzling_Desert", frames = {0}, battle = true},
    {name = "bg_Btl_Link_Ruins", frames = {0}, battle = true},
    {name = "bg_Btl_D_Dungeon01", frames = {0}, battle = true},
    {name = "BG_InfinityTower", frames = {0}, battle = true},
    {name = "BG16", frames = {0}, battle = false},
    {name = "BG18", frames = {0}, battle = false},
    {name = "BG19", frames = {0}, battle = false},
    {name = "BG21", frames = {0}, battle = false},
    {name = "BG22", frames = {0}, battle = false},
    {name = "BG24", frames = {0}, battle = false},
    {name = "BG25", frames = {0}, battle = false},
    {name = "BG26", frames = {0}, battle = false},
    {name = "BG28", frames = {0}, battle = false},
    {name = "BG_Dragons_Roar", frames = {0}, battle = false},
    {name = "BG_Deep_Savers", frames = {0}, battle = false},
    {name = "BG_Nature_Spirits", frames = {0}, battle = false},
    {name = "BG_Nightmare_Soldiers", frames = {0}, battle = false},
    {name = "BG_Metal_Empire", frames = {0}, battle = false},
    {name = "BG_Wind_Guardians", frames = {0}, battle = false},
    {name = "BG_Virus_Busters", frames = {0}, battle = false},
    {name = "BG_Jungle_Troopers", frames = {0}, battle = false},
    {name = "spr_Floor_Deco", frames = {0, 1, 2, 3, 4, 5, 6, 7}, battle = false},
    {name = "spr_DecoLayer01", frames = {0, 1, 2, 3, 4, 5, 6, 7}, battle = false},
    {name = "spr_DecoLayer02", frames = {0, 1, 2, 3, 4, 5, 6, 7}, battle = false},
}

local count = 0
for _, t in ipairs(targets) do
    for _, f in ipairs(t.frames) do
        local in_path = string.format("%s%s/%s_%d.png", SPR_DIR, t.name, t.name, f)
        local out_path = string.format("%s%s_%d.png", OUT_DIR, t.name, f)
        if app.fs.isFile(in_path) then
            local src_spr = app.open(in_path)
            if src_spr ~= nil then
                local src_img = Image(src_spr.width, src_spr.height, ColorMode.RGB)
                src_img:drawSprite(src_spr, 1)
                local remade = remaster_bg_image(src_img, t.battle)
                local out_spr = Sprite(remade.width, remade.height, ColorMode.RGB)
                out_spr.cels[1].image = remade
                out_spr:saveCopyAs(out_path)
                if t.name == "bg_Btl_Magma_Mountain" or t.name == "bg_Btl_Village_Beginnings" or t.name == "BG26" then
                    out_spr:saveCopyAs(string.format("%s%s_HD.aseprite", ASE_DIR, t.name))
                end
                out_spr:close()
                src_spr:close()
                count = count + 1
            end
        end
    end
end

print("ASEPRITE_BG_REMAKE_DONE count=" .. tostring(count))
