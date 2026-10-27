"""Read-only GameMaker data.win/game.droid chunk survey (FORM container)."""
import struct
import sys

path = sys.argv[1]
f = open(path, "rb")
assert f.read(4) == b"FORM"
total = struct.unpack("<I", f.read(4))[0]
end = 8 + total
chunks = {}
while f.tell() < end:
    name = f.read(4).decode("ascii", "replace")
    size = struct.unpack("<I", f.read(4))[0]
    chunks[name] = (f.tell(), size)
    f.seek(size, 1)

print(f"FORM size={total:,}  chunks={len(chunks)}")
for n, (o, s) in sorted(chunks.items(), key=lambda kv: -kv[1][1]):
    cnt = ""
    if n in ("SPRT", "OBJT", "ROOM", "SCPT", "CODE", "SOND", "FONT", "TXTR", "AUDO", "BGND",
             "PATH", "TMLN", "SHDR", "TPAG", "EMBI", "VARI", "FUNC", "STRG", "EXTN", "AGRP", "SEQN"):
        f.seek(o)
        cnt = struct.unpack("<I", f.read(4))[0]
    print(f"  {n}  off={o:>11,}  size={s:>11,}  count={cnt}")


def read_str(off):
    f.seek(off - 4)
    ln = struct.unpack("<I", f.read(4))[0]
    return f.read(ln).decode("utf-8", "replace")


o, s = chunks["GEN8"]
f.seek(o)
d = f.read(0x80)
(dbg, bc) = struct.unpack("<BB", d[:2])
fname, cfg, lastobj, lasttile, gid = struct.unpack("<5I", d[4:24])
nameoff, major, minor, rel, build = struct.unpack("<5I", d[40:60])
print("\nGEN8")
print("  bytecode version:", bc)
print("  filename:", read_str(fname), "| config:", read_str(cfg))
print("  name:", read_str(nameoff))
print(f"  version: {major}.{minor}.{rel}.{build}  lastObj={lastobj} lastTile={lasttile}")
