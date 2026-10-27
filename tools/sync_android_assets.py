import os
import json
import shutil

OUT = r"D:\digimon-re\out"
ASSETS = r"D:\digimon-re\android\app\src\main\assets"

if os.path.exists(ASSETS):
    shutil.rmtree(ASSETS)
os.makedirs(ASSETS, exist_ok=True)

# 1. Copy full_db.json and sprites.json
os.makedirs(os.path.join(ASSETS, "data"), exist_ok=True)
shutil.copy2(os.path.join(OUT, "data", "full_db.json"), os.path.join(ASSETS, "data", "full_db.json"))
shutil.copy2(os.path.join(OUT, "data", "sprites.json"), os.path.join(ASSETS, "data", "sprites.json"))

# 2. Copy all 55 Aseprite HD remastered backgrounds & sanctuary layers (bg_HD)
shutil.copytree(os.path.join(OUT, "sprites", "bg_HD"), os.path.join(ASSETS, "sprites", "bg_HD"))

# 3. Copy all 750 Aseprite HD remastered item sprites (spr_Items_HD)
shutil.copytree(os.path.join(OUT, "sprites", "spr_Items_HD"), os.path.join(ASSETS, "sprites", "spr_Items_HD"))

# 4. Copy all 663+ Digimon icons (spr_Icons)
shutil.copytree(os.path.join(OUT, "sprites", "spr_Icons"), os.path.join(ASSETS, "sprites", "spr_Icons"))

# 5. Copy UI & projectile & sanctuary prop sprites
extra_sprites = [
    "spr_GameLogo", "spr_egg01", "spr_FireBurst01", "spr_FireBarr04",
    "spr_DecoTree03", "spr_DecoStatue02", "spr_DecoStatue03", "spr_DecoFossil01",
    "spr_DecoMeatField", "spr_Deco04", "spr_DecoPlant18", "spr_DecoPlant20",
    "BG_SelectMap", "BG_TrainingLobby", "BG_EvoRoom", "bg_Tech01", "BG01",
]
for s in extra_sprites:
    src_s = os.path.join(OUT, "sprites", s)
    if os.path.exists(src_s):
        shutil.copytree(src_s, os.path.join(ASSETS, "sprites", s), dirs_exist_ok=True)

# 6. Copy all 663 Digimon idle sprites (d<id>_idle) + full combat animation sets for active/boss/evolution roster
spr_root = os.path.join(OUT, "sprites")
full_anim_ids = {1, 2, 3, 5, 14, 20, 35, 49, 85, 87, 89, 151, 152, 155, 202, 211, 233, 347}
full_acts = {"idle", "walk", "jump", "atk01", "atk02", "atkSP", "block", "dmg", "win", "lose"}

copied_dirs = 0
for d in os.listdir(spr_root):
    if d.startswith("d") and "_" in d:
        prefix, act = d.split("_", 1)
        if prefix[1:].isdigit():
            did = int(prefix[1:])
            if act == "idle" or (did in full_anim_ids and act in full_acts):
                shutil.copytree(os.path.join(spr_root, d), os.path.join(ASSETS, "sprites", d), dirs_exist_ok=True)
                copied_dirs += 1

# 7. Copy core sound effects & BGM
os.makedirs(os.path.join(ASSETS, "sounds"), exist_ok=True)
for snd in ["snd_Click02.ogg", "snd_Click04.ogg", "snd_Click06.ogg", "snd_ClickBack.ogg", "snd_Summon.ogg", "BGM_Main_Lobby.ogg"]:
    for sub in ["", "external"]:
        cand = os.path.join(OUT, "sounds", sub, snd)
        if os.path.exists(cand):
            shutil.copy2(cand, os.path.join(ASSETS, "sounds", snd))
        cand_wav = os.path.join(OUT, "sounds", sub, snd.replace(".ogg", ".wav"))
        if os.path.exists(cand_wav):
            shutil.copy2(cand_wav, os.path.join(ASSETS, "sounds", snd.replace(".ogg", ".wav")))

total_bytes = sum(os.path.getsize(os.path.join(dp, f)) for dp, dn, fn in os.walk(ASSETS) for f in fn)
print(f"Android assets synced! copied_digi_dirs={copied_dirs}, total_size={total_bytes // 1024} KB")
