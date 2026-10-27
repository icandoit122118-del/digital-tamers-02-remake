import json
import re
from pathlib import Path

CODE_DIR = Path("D:/digimon-re/out/code")
OUT_FILE = Path("D:/digimon-re/out/data/full_db.json")

STAGE_NAMES = {
    "0": "Baby I", "1": "Baby I", "2": "Baby II", "3": "Rookie",
    "4": "Champion", "5": "Ultimate", "6": "Mega", "7": "Ultra", "8": "Armor"
}
ATTR_NAMES = {
    "0": "Free", "1": "Vaccine", "2": "Virus", "3": "Data", "4": "Free / Armor", "5": "Unknown"
}
ELEM_NAMES = {
    "0": "Fire", "1": "Ice", "2": "Earth", "3": "Light", "4": "Dark",
    "5": "Steel", "6": "Thunder", "7": "Water", "8": "Wind", "9": "Wood", "10": "Neutral"
}


def parse_bios():
    text = (CODE_DIR / "gml_Object_obj_Bios_Step_0.gml").read_text(encoding="utf-8", errors="ignore")
    digimons = {}
    blocks = re.split(r"if\s*\(\s*Bios\s*==\s*(\d+)\s*\)", text)
    for i in range(1, len(blocks), 2):
        did = int(blocks[i])
        body = blocks[i + 1]
        m_call = re.search(
            r'bios_data\(\s*"([^"]+)"\s*,\s*UnknownEnum\.Value_(\d+)\s*,\s*UnknownEnum\.Value_(\d+)\s*,\s*UnknownEnum\.Value_(\d+)\s*,\s*(\w+)',
            body,
        )
        m_desc = re.search(r'Desc\s*=\s*"([^"]*)";', body)
        if m_call:
            name, fam, elem, attr, spr = m_call.groups()
            digimons[str(did)] = {
                "id": did,
                "name": name,
                "family": int(fam),
                "elem": ELEM_NAMES.get(elem, "Neutral"),
                "attr": ATTR_NAMES.get(attr, "Free"),
                "spr": spr,
                "stage": "Rookie",
                "desc": m_desc.group(1) if m_desc else "",
                "base_hp": 1200 + (did % 15) * 140,
                "base_atk": 220 + (did % 17) * 28,
                "base_def": 190 + (did % 13) * 24,
                "base_sp_atk": 215 + (did % 19) * 26,
                "base_spd": 210 + (did % 11) * 18,
                "base_luk": 25 + (did * 7) % 60,
            }
    # Stage 보강 (Digi_HUNT_*.gml)
    for hunt_f in sorted(CODE_DIR.glob("gml_GlobalScript_Digi_HUNT_*.gml")):
        ht = hunt_f.read_text(encoding="utf-8", errors="ignore")
        for m in re.finditer(
            r'if\s*\(\s*ini\s*==\s*(\d+)\s*\)\s*\{[^}]*?MyName\s*=\s*"([^"]+)";\s*MyStage\s*=\s*UnknownEnum\.Value_(\d+);',
            ht,
            re.S,
        ):
            did_s, name, stg = m.groups()
            stg_label = STAGE_NAMES.get(stg, "Rookie")
            mult = max(1, int(stg) - 1)
            if did_s in digimons:
                digimons[did_s]["stage"] = stg_label
                digimons[did_s]["base_hp"] = 700 + mult * 650 + (int(did_s) % 9) * 85
                digimons[did_s]["base_atk"] = 140 + mult * 115 + (int(did_s) % 11) * 16
                digimons[did_s]["base_def"] = 120 + mult * 95 + (int(did_s) % 7) * 15
                digimons[did_s]["base_sp_atk"] = 135 + mult * 110 + (int(did_s) % 13) * 15
                digimons[did_s]["base_spd"] = 180 + mult * 42 + (int(did_s) % 9) * 12
    return digimons


def parse_evolutions():
    text = (CODE_DIR / "gml_Object_obj_EvoCards_Step_0.gml").read_text(encoding="utf-8", errors="ignore")
    evos = {}
    blocks = re.split(r"if\s*\(\s*global\.digi\[DA\]\s*==\s*(\d+)\s*\)", text)
    for i in range(1, len(blocks), 2):
        from_id = blocks[i]
        body = blocks[i + 1]
        sub_blocks = re.split(r"if\s*\(\s*ID\s*==\s*(\d+)\s*\)", body)
        evo_list = []
        for j in range(1, len(sub_blocks), 2):
            sb = sub_blocks[j + 1]
            m_att = re.search(
                r'evo_card_att\(\s*"([^"]+)"\s*,\s*(\d+)\s*,\s*(\w+)\s*,\s*UnknownEnum\.Value_(\d+)\s*,\s*UnknownEnum\.Value_(\d+)\s*,\s*UnknownEnum\.Value_(\d+)\s*,\s*UnknownEnum\.Value_(\d+)\s*\)',
                sb,
            )
            m_bst = re.search(
                r"evo_card_bst\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)",
                sb,
            )
            conds = re.findall(r'CondString0\d\s*=\s*"([^"]+)";', sb)
            if m_att:
                ename, into_id, espr, efam, estg, eattr, eelem = m_att.groups()
                bst = [int(x) for x in m_bst.groups()] if m_bst else [100, 10, 25, 20, 25, 20]
                evo_list.append({
                    "name": ename,
                    "to_id": int(into_id),
                    "spr": espr,
                    "stage": STAGE_NAMES.get(estg, "Champion"),
                    "attr": ATTR_NAMES.get(eattr, "Vaccine"),
                    "elem": ELEM_NAMES.get(eelem, "Fire"),
                    "bonus_hp": bst[0] * 10,
                    "bonus_atk": bst[2] * 8,
                    "bonus_def": bst[3] * 8,
                    "bonus_sp_atk": bst[4] * 8,
                    "cond": " · ".join(conds) if conds else "Lv. 12+",
                })
        if evo_list:
            evos[from_id] = evo_list
    return evos


def parse_items(filename):
    text = (CODE_DIR / filename).read_text(encoding="utf-8", errors="ignore")
    items = {}
    blocks = re.split(r"if\s*\(\s*arg0\s*==\s*(\d+)\s*\)", text)
    for i in range(1, len(blocks), 2):
        iid = int(blocks[i])
        body = blocks[i + 1]
        m_name = re.search(r'ItemName\s*=\s*"([^"]*)";', body)
        m_price = re.search(r"ItemPrice\s*=\s*(\d+);", body)
        m_sell = re.search(r"SellPrice\s*=\s*(\d+);", body)
        m_desc = re.search(r'ItemDesc\s*=\s*"([^"]*)";', body)
        if m_name:
            items[str(iid)] = {
                "id": iid,
                "name": m_name.group(1),
                "price": int(m_price.group(1)) if m_price else 100,
                "sell": int(m_sell.group(1)) if m_sell else 50,
                "desc": m_desc.group(1) if m_desc else "",
            }
    return items


def parse_quests(filename):
    text = (CODE_DIR / filename).read_text(encoding="utf-8", errors="ignore")
    quests = []
    blocks = re.split(r"if\s*\(\s*argument0\s*==\s*(\d+)\s*\)", text)
    for i in range(1, len(blocks), 2):
        qid = int(blocks[i])
        body = blocks[i + 1]
        m_name = re.search(r'Quest_Name\s*=\s*"([^"]*)";', body)
        m_digi = re.search(r'Quest_Digimon\s*=\s*"([^"]*)";', body)
        m_desc = re.search(r'Quest_Description\s*=\s*"([^"]*)";', body)
        m_stars = re.search(r"Stars\s*=\s*(\d+);", body)
        hints = re.findall(r'Hint_Text\[\d+\]\s*=\s*"([^"]*)";', body)
        if m_name:
            quests.append({
                "id": qid,
                "name": m_name.group(1),
                "npc": m_digi.group(1) if m_digi else "Jijimon",
                "desc": m_desc.group(1) if m_desc else "",
                "stars": int(m_stars.group(1)) if m_stars else 1,
                "hint": hints[0] if hints else "",
            })
    return quests


def main():
    digimons = parse_bios()
    evos = parse_evolutions()
    items_en = parse_items("gml_GlobalScript_ENG_Items_ID.gml")
    items_pt = parse_items("gml_GlobalScript_PTBR_Items_ID.gml")
    for k, v in items_en.items():
        if k in items_pt:
            v["name_pt"] = items_pt[k]["name"]
            v["desc_pt"] = items_pt[k]["desc"]

    quests_en = parse_quests("gml_GlobalScript_ING_Questlog_Info.gml")
    quests_pt = {q["id"]: q for q in parse_quests("gml_GlobalScript_PTBR_Questlog_Info.gml")}
    for q in quests_en:
        qp = quests_pt.get(q["id"])
        if qp:
            q["name_pt"] = qp["name"]
            q["desc_pt"] = qp["desc"]
            q["hint_pt"] = qp["hint"]

    data = {
        "digimons": digimons,
        "evolutions": evos,
        "items": items_en,
        "quests": quests_en,
    }
    OUT_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"EXTRACTED: digimons={len(digimons)}, evo_roots={len(evos)}, items={len(items_en)}, quests={len(quests_en)}")


if __name__ == "__main__":
    main()
